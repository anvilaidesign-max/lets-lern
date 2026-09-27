import 'dart:convert';
import 'dart:io';

import 'package:daily_mind/core/config/env.dart';
import 'package:daily_mind/core/errors/app_exception.dart';
import 'package:daily_mind/core/utils/date_utils.dart';
import 'package:daily_mind/data/local/daos/misc_daos.dart';
import 'package:daily_mind/data/local/database.dart';
import 'package:daily_mind/data/local/seed_loader.dart';
import 'package:daily_mind/data/remote/connectivity_service.dart';
import 'package:daily_mind/data/remote/edge_functions_api.dart';
import 'package:daily_mind/data/remote/supabase_service.dart';
import 'package:daily_mind/data/repositories/content_repository.dart';
import 'package:daily_mind/data/repositories/daily_plan_repository.dart';
import 'package:daily_mind/data/repositories/essay_repository.dart';
import 'package:daily_mind/data/repositories/progress_repository.dart';
import 'package:daily_mind/data/repositories/settings_repository.dart';
import 'package:daily_mind/data/sync/sync_queue.dart';
import 'package:daily_mind/domain/models/app_settings.dart';
import 'package:daily_mind/domain/models/content_item.dart';
import 'package:daily_mind/domain/models/essay.dart';
import 'package:daily_mind/features/home/home_providers.dart';
import 'package:daily_mind/features/home/home_screen.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class OfflineConnectivity extends ConnectivityService {
  @override
  Future<bool> isOnline() async => false;

  @override
  Stream<bool> get changes => const Stream.empty();
}

class FakeEdgeFunctions extends EdgeFunctionsApi {
  FakeEdgeFunctions(this.handler) : super(SupabaseService(const Env(supabaseUrl: '', supabaseAnonKey: '', googleWebClientId: '', googleIosClientId: '')));

  final Future<Map<String, dynamic>> Function(String name, Map<String, dynamic> body) handler;
  final calls = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> call(String name, Map<String, dynamic> body, {Duration timeout = EdgeFunctionsApi.contentTimeout}) {
    calls.add({'name': name, ...body});
    return handler(name, body);
  }
}

Future<(AppDatabase, Map<String, String>)> openSeededDatabase() async {
  final db = AppDatabase(NativeDatabase.memory());
  final settings = <String, String>{
    SettingKeys.deviceId: 'device-1',
    SettingKeys.onboardingDone: 'true',
    SettingKeys.guestMode: 'true',
  };
  await SeedLoader(db, loadString: (_) => File('assets/seed/content_seed.json').readAsString()).loadIfNeeded(settings);
  return (db, settings);
}

ProviderContainer containerFor(AppDatabase db, Map<String, String> settings, {EdgeFunctionsApi? edge}) => ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(settings),
        connectivityServiceProvider.overrideWithValue(OfflineConnectivity()),
        if (edge != null) edgeFunctionsApiProvider.overrideWithValue(edge),
      ],
    );

void main() {
  group('first launch offline', () {
    test('the seed pack loads and today has an item', () async {
      final (db, settings) = await openSeededDatabase();
      final container = containerFor(db, settings);
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final count = await container.read(contentRepositoryProvider).countActive();
      expect(count, greaterThanOrEqualTo(320));

      final topics = await container.read(dailyPlanRepositoryProvider).topicsFor(DateTime.now());
      expect(topics.length, inInclusiveRange(1, 2));

      final item = await container.read(dailyPlanRepositoryProvider).nextItem();
      expect(item, isNotNull);
      expect(topics, contains(item!.topicCode));

      // Same topics after a "restart" (new container, same database).
      final again = containerFor(db, settings);
      addTearDown(again.dispose);
      expect(await again.read(dailyPlanRepositoryProvider).topicsFor(DateTime.now()), topics);
    });

    test('the seed pack is only loaded once per version', () async {
      final (db, settings) = await openSeededDatabase();
      addTearDown(db.close);
      expect(settings[SettingKeys.seedVersion], isNotNull);
      await (db.update(db.contentItems)..where((t) => t.topicCode.equals('math')))
          .write(const ContentItemsCompanion(title: Value('changed')));
      await SeedLoader(db, loadString: (_) => File('assets/seed/content_seed.json').readAsString()).loadIfNeeded(settings);
      final changed = await (db.select(db.contentItems)..where((t) => t.title.equals('changed'))).get();
      expect(changed, isNotEmpty);
    });

    testWidgets('Home shows today\'s card', (tester) async {
      final (db, settings) = await tester.runAsync(openSeededDatabase) ?? (throw StateError('seed failed'));
      final container = containerFor(db, settings);
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ));
      await tester.runAsync(() async {
        await container.read(homeItemProvider.future);
      });
      await tester.pump();

      final item = container.read(homeItemProvider).value;
      expect(item, isNotNull);
      expect(find.text(item!.preview), findsOneWidget);
      expect(find.text('Quick quiz'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
    });
  });

  group('progress offline, synced later', () {
    test('answering a challenge offline records progress and queues it for upload', () async {
      final (db, settings) = await openSeededDatabase();
      final container = containerFor(db, settings);
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final plan = container.read(dailyPlanRepositoryProvider);
      final progress = container.read(progressRepositoryProvider);
      final challenge = await plan.nextItem(group: ContentGroup.challenge, topics: ['math']);
      expect(challenge, isNotNull);

      await progress.recordView(challenge!);
      await progress.recordAnswer(challenge, correct: false);

      final row = await (db.select(db.userProgress)..where((t) => t.itemId.equals(challenge.id))).getSingle();
      expect(row.seenCount, 1);
      expect(row.answeredWrong, 1);
      expect(row.lastAnswerCorrect, isFalse);

      final queue = await SyncQueueDao(db).oldest(100);
      final progressRows = queue.where((q) => q.entity == SyncEntity.progress).toList();
      final activityRows = queue.where((q) => q.entity == SyncEntity.activity).toList();
      // One queued row per item, holding the latest state.
      expect(progressRows.length, 1);
      final payload = jsonDecode(progressRows.single.payloadJson) as Map<String, dynamic>;
      expect(payload['item_id'], challenge.id);
      expect(payload['answered_wrong'], 1);
      expect(payload['seen_count'], 1);
      expect(activityRows.length, 1);
      expect((jsonDecode(activityRows.single.payloadJson) as Map)['items_completed'], 1);
    });

    test('three completed items make today count for the streak', () async {
      final (db, settings) = await openSeededDatabase();
      final container = containerFor(db, settings);
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final plan = container.read(dailyPlanRepositoryProvider);
      final progress = container.read(progressRepositoryProvider);
      final seen = <String>{};
      for (var i = 0; i < 3; i++) {
        final fact = (await plan.nextItem(group: ContentGroup.knowledge, topics: ['science'], exclude: seen))!;
        seen.add(fact.id);
        await progress.recordView(fact);
      }
      // Viewing the same item again the same day does not count twice.
      await progress.recordView((await container.read(contentRepositoryProvider).item(seen.first))!);

      final today = await ActivityDao(db).day(DateKeys.dayKey(DateTime.now()));
      expect(today!.itemsCompleted, 3);
    });
  });

  group('essay flow with a mocked Edge Function', () {
    Future<(AppDatabase, ProviderContainer, FakeEdgeFunctions)> setUpEssay(
      Future<Map<String, dynamic>> Function(String, Map<String, dynamic>) handler,
    ) async {
      final (db, settings) = await openSeededDatabase();
      final edge = FakeEdgeFunctions(handler);
      final container = containerFor(db, settings, edge: edge);
      await EssayDao(db).insert(EssaysCompanion.insert(
        id: 'essay-1',
        prompt: 'Why read?',
        extractedText: const Value('I recieve alot of leters evry week and I read them all.'),
        status: EssayStatus.transcribed.name,
        createdAt: DateTime.now(),
      ));
      return (db, container, edge);
    }

    test('confirmed text is scored and saved', () async {
      final (db, container, edge) = await setUpEssay((name, body) async => {
            'step': 'scored',
            'essay_id': 'essay-1',
            'result': {
              'score_total': 9,
              'breakdown': {'ideas': 2, 'structure': 2, 'grammar': 2, 'spelling_vocab': 3},
              'breakdown_comments': {'ideas': '', 'structure': '', 'grammar': '', 'spelling_vocab': ''},
              'mistakes': [
                {'original': 'recieve', 'correction': 'receive', 'reason': 'Spelling'},
              ],
              'biggest_habit': 'Spelling',
              'corrected_version': 'I receive a lot of letters every week.',
              'next_exercise': 'Practise ie/ei words.',
            },
          });
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final result = await container.read(essayRepositoryProvider).confirm('essay-1', 'I recieve alot of leters evry week and I read them all.');
      expect(result.isSuccess, isTrue);
      expect(edge.calls.single['name'], 'score-essay');
      expect(edge.calls.single['confirmed_text'], contains('recieve'));

      final essay = await container.read(essayRepositoryProvider).watch('essay-1').first;
      expect(essay!.status, EssayStatus.done);
      expect(essay.scoreTotal, 9);
      expect(essay.result!.mistakes.single.correction, 'receive');
    });

    test('a failed scoring call keeps the text for another try', () async {
      final (db, container, _) = await setUpEssay((name, body) async => throw const RateLimitException('Limit reached.'));
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final result = await container.read(essayRepositoryProvider).confirm('essay-1', 'I recieve alot of leters evry week and I read them all.');
      expect(result.errorOrNull, isA<RateLimitException>());
      final essay = await container.read(essayRepositoryProvider).watch('essay-1').first;
      expect(essay!.status, EssayStatus.transcribed);
      expect(essay.errorMessage, 'Limit reached.');
    });

    test('text that is too short is rejected before calling the server', () async {
      final (db, container, edge) = await setUpEssay((name, body) async => {});
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      final result = await container.read(essayRepositoryProvider).confirm('essay-1', 'Too short.');
      expect(result.errorOrNull, isA<ValidationException>());
      expect(edge.calls, isEmpty);
    });
  });
}
