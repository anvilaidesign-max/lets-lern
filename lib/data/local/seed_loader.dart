import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/utils/logger.dart';
import '../../domain/models/app_settings.dart';
import '../repositories/content_repository.dart';
import 'daos/content_dao.dart';
import 'daos/misc_daos.dart';
import 'database.dart';

/// Loads the offline seed pack shipped with the app (ARCHITECTURE.md 7.1) so
/// the app works from minute one, before login and without internet.
///
/// Runs on every launch but only writes when the pack version is newer than
/// the one already loaded. Items that the server has updated since are kept.
class SeedLoader {
  SeedLoader(this.db, {this.assetPath = 'assets/seed/content_seed.json', this.loadString});

  final AppDatabase db;
  final String assetPath;
  final Future<String> Function(String path)? loadString;

  Future<void> loadIfNeeded(Map<String, String> settings) async {
    try {
      final source = await (loadString ?? rootBundle.loadString)(assetPath);
      final json = jsonDecode(source) as Map<String, dynamic>;
      final version = (json['version'] as num?)?.toInt() ?? 0;
      final loaded = int.tryParse(settings[SettingKeys.seedVersion] ?? '') ?? 0;
      if (version <= loaded) return;

      final contentDao = ContentDao(db);

      final topics = (json['topics'] as List? ?? const [])
          .whereType<Map>()
          .map((t) => TopicsCompanion.insert(
                code: t['code'] as String,
                name: t['name'] as String,
                icon: t['icon'] as String? ?? '',
                sortOrder: (t['sort_order'] as num?)?.toInt() ?? 0,
              ))
          .toList();
      await contentDao.upsertTopics(topics);

      final prompts = (json['essay_prompts'] as List? ?? const [])
          .whereType<Map>()
          .map((p) => EssayPromptsCompanion.insert(
                id: p['id'] as String,
                topicCode: Value(p['topic_code'] as String?),
                prompt: p['prompt'] as String,
              ))
          .toList();
      await contentDao.upsertPrompts(prompts);

      final candidates = <ContentItemsCompanion>[];
      var skipped = 0;
      for (final raw in (json['items'] as List? ?? const [])) {
        final companion = raw is Map ? ContentValidator.toCompanion(Map<String, dynamic>.from(raw)) : null;
        if (companion == null) {
          skipped++;
        } else {
          candidates.add(companion);
        }
      }

      // Do not overwrite content the server has updated more recently.
      final existing = await contentDao.updatedAtFor(candidates.map((c) => c.id.value));
      final toWrite = candidates.where((c) {
        if (!existing.containsKey(c.id.value)) return true;
        final local = existing[c.id.value];
        final seed = c.updatedAt.value;
        return local == null || (seed != null && seed.isAfter(local));
      }).toList();
      await contentDao.upsertAll(toWrite);

      await SettingsDao(db).set(SettingKeys.seedVersion, '$version');
      settings[SettingKeys.seedVersion] = '$version';
      AppLogger.info('Seed pack v$version loaded: ${toWrite.length} items, $skipped skipped');
    } catch (e, st) {
      AppLogger.error('Seed pack failed to load', e, st);
    }
  }
}
