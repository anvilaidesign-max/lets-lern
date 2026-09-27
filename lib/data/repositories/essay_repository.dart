import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import 'package:uuid/uuid.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/essay.dart';
import '../local/daos/content_dao.dart';
import '../local/daos/misc_daos.dart';
import '../local/database.dart';
import '../remote/connectivity_service.dart';
import '../remote/edge_functions_api.dart';
import '../remote/supabase_service.dart';
import 'settings_repository.dart';

/// Weekend essay challenge (ARCHITECTURE.md 9.2, 9.3).
///
/// 1. The photo is compressed and saved on the phone first (works offline).
/// 2. When online: upload to Storage, create the `essays` row, and ask
///    `score-essay` to read the handwriting.
/// 3. The user checks and edits the text, then it is scored out of 20.
class EssayRepository {
  EssayRepository(this._ref);

  final Ref _ref;

  EssayDao get _dao => EssayDao(_ref.read(databaseProvider));

  static Essay toModel(EssayRow r) => Essay(
        id: r.id,
        prompt: r.prompt,
        status: EssayStatus.parse(r.status),
        createdAt: r.createdAt,
        localImagePath: r.localImagePath,
        imagePath: r.imagePath,
        extractedText: r.extractedText,
        scoreTotal: r.scoreTotal,
        result: EssayResult.tryDecode(r.resultJson),
        errorMessage: r.errorMessage,
      );

  Stream<List<Essay>> watchAll() => _dao.watchAll().map((rows) => rows.map(toModel).toList());

  Stream<Essay?> watch(String id) => _dao.watchById(id).map((r) => r == null ? null : toModel(r));

  /// All cached prompts, in a stable order.
  Future<List<String>> prompts() async {
    final rows = await ContentDao(_ref.read(databaseProvider)).prompts();
    return rows.map((r) => r.prompt).toList();
  }

  /// This weekend's prompt; "another prompt" moves the offset forward.
  Future<String> currentPrompt(DateTime now) async {
    final all = await prompts();
    if (all.isEmpty) return 'Write about something you learned this week and why it matters to you.';
    final offset = int.tryParse(_ref.read(settingsProvider.notifier).raw(SettingKeys.essayPromptOffset) ?? '') ?? 0;
    final week = now.difference(DateTime(2024, 1, 6)).inDays ~/ 7;
    return all[(week + offset) % all.length];
  }

  Future<void> anotherPrompt() async {
    final notifier = _ref.read(settingsProvider.notifier);
    final offset = int.tryParse(notifier.raw(SettingKeys.essayPromptOffset) ?? '') ?? 0;
    await notifier.set(SettingKeys.essayPromptOffset, '${offset + 1}');
  }

  /// Saves the photo locally and starts the upload if online.
  Future<Result<String>> createFromPhoto(String sourcePath, String prompt) => Result.guard(() async {
        final id = const Uuid().v4();
        final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'essays'));
        await dir.create(recursive: true);
        final target = p.join(dir.path, '$id.jpg');

        // Long side is already capped at 1600px by image_picker; this makes
        // it a JPEG at quality 80 (ARCHITECTURE.md 9.3).
        final compressed = await FlutterImageCompress.compressAndGetFile(
          sourcePath,
          target,
          minWidth: 1600,
          minHeight: 1600,
          quality: 80,
          format: CompressFormat.jpeg,
        );
        if (compressed == null) {
          await File(sourcePath).copy(target);
        }

        await _dao.insert(EssaysCompanion.insert(
          id: id,
          prompt: prompt,
          localImagePath: Value(target),
          status: EssayStatus.queued.name,
          createdAt: DateTime.now(),
        ));
        return id;
      }, context: 'createFromPhoto');

  /// Uploads the photo and gets the transcription. Offline or signed out
  /// leaves the essay queued; the sync service retries it automatically.
  Future<Result<void>> submit(String id) => Result.guard(() async {
        final row = await _dao.byId(id);
        if (row == null) throw const NotFoundException('Essay not found.');
        final supabase = _ref.read(supabaseServiceProvider);
        final client = supabase.client;
        final userId = supabase.userId;

        if (client == null || userId == null) {
          await _dao.patch(id, const EssaysCompanion(
            status: Value('queued'),
            errorMessage: Value('Sign in to get your essay scored. It is saved on your phone.'),
          ));
          throw const AppAuthException('Sign in to get your essay scored. It is saved on your phone.');
        }
        if (!await _ref.read(connectivityServiceProvider).isOnline()) {
          await _dao.patch(id, const EssaysCompanion(status: Value('queued'), errorMessage: Value(null)));
          throw const OfflineException('Waiting for internet. Your essay will be sent automatically.');
        }

        await _dao.patch(id, const EssaysCompanion(status: Value('transcribing'), errorMessage: Value(null)));
        try {
          var imagePath = row.imagePath;
          if (imagePath == null) {
            final local = row.localImagePath;
            if (local == null || !File(local).existsSync()) {
              throw const NotFoundException('The essay photo is missing. Please take it again.');
            }
            imagePath = '$userId/$id.jpg';
            await client.storage.from('essays').uploadBinary(
                  imagePath,
                  await File(local).readAsBytes(),
                  fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
                );
            await client.from('essays').upsert({
              'id': id,
              'user_id': userId,
              'prompt': row.prompt,
              'image_path': imagePath,
              'status': 'pending',
            });
            await _dao.patch(id, EssaysCompanion(imagePath: Value(imagePath)));
          }

          final response = await _ref.read(edgeFunctionsApiProvider).call(
                'score-essay',
                {'essay_id': id},
                timeout: EdgeFunctionsApi.essayTimeout,
              );
          if (response['step'] == 'scored') {
            await _saveResult(id, response);
            return;
          }
          final text = response['extracted_text'];
          if (text is! String) throw const ServerException('The transcription was empty.');
          await _dao.patch(id, EssaysCompanion(
            extractedText: Value(text),
            status: const Value('transcribed'),
          ));
        } on OfflineException {
          await _dao.patch(id, const EssaysCompanion(status: Value('queued')));
          rethrow;
        } on NetworkException catch (e) {
          await _dao.patch(id, EssaysCompanion(status: const Value('queued'), errorMessage: Value(e.userMessage)));
          rethrow;
        } on AppException catch (e) {
          await _dao.patch(id, EssaysCompanion(status: const Value('failed'), errorMessage: Value(e.userMessage)));
          rethrow;
        } catch (e) {
          AppLogger.error('Essay upload failed', e);
          await _dao.patch(id, const EssaysCompanion(
            status: Value('failed'),
            errorMessage: Value('Upload failed. Please try again.'),
          ));
          throw NetworkException('Upload failed. Please try again.', e);
        }
      }, context: 'submitEssay');

  /// Scores the text the user checked (ARCHITECTURE.md 9.2: reading errors
  /// on messy handwriting must not lower the score).
  Future<Result<void>> confirm(String id, String text) => Result.guard(() async {
        final trimmed = text.trim();
        if (trimmed.length < 30) {
          throw const ValidationException('The essay is too short to score. Add a few more sentences.');
        }
        await _dao.patch(id, EssaysCompanion(
          extractedText: Value(trimmed),
          status: const Value('scoring'),
          errorMessage: const Value(null),
        ));
        try {
          final response = await _ref.read(edgeFunctionsApiProvider).call(
                'score-essay',
                {'essay_id': id, 'confirmed_text': trimmed},
                timeout: EdgeFunctionsApi.essayTimeout,
              );
          await _saveResult(id, response);
        } on AppException catch (e) {
          await _dao.patch(id, EssaysCompanion(status: const Value('transcribed'), errorMessage: Value(e.userMessage)));
          rethrow;
        }
      }, context: 'confirmEssay');

  Future<void> _saveResult(String id, Map<String, dynamic> response) async {
    final result = EssayResult.fromJson(response['result']);
    await _dao.patch(id, EssaysCompanion(
      scoreTotal: Value(result.scoreTotal),
      resultJson: Value(jsonEncode(result.toJson())),
      status: const Value('done'),
      errorMessage: const Value(null),
    ));
  }

  /// Essays waiting for internet, sent by the sync service.
  Future<List<String>> queuedIds() async => [for (final r in await _dao.withStatus('queued')) r.id];

  Future<void> delete(String id) async {
    final row = await _dao.byId(id);
    final local = row?.localImagePath;
    if (local != null) {
      try {
        await File(local).delete();
      } catch (_) {}
    }
    final db = _ref.read(databaseProvider);
    await (db.delete(db.essays)..where((t) => t.id.equals(id))).go();
  }
}

final essayRepositoryProvider = Provider<EssayRepository>((ref) => EssayRepository(ref));
