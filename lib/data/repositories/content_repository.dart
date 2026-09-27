import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/topic.dart';
import '../local/daos/content_dao.dart';
import '../local/database.dart';

/// Validates content JSON from the seed pack or the server before it is saved
/// (ARCHITECTURE.md 13.8). Invalid items are skipped and logged.
class ContentValidator {
  ContentValidator._();

  static final _uuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);

  static String? _text(Object? v, {int max = 2000}) {
    if (v is! String) return null;
    final t = v.trim();
    if (t.isEmpty) return null;
    return t.length > max ? t.substring(0, max) : t;
  }

  /// Returns a companion ready to upsert, or null if the item is invalid.
  static ContentItemsCompanion? toCompanion(Map<String, dynamic> json) {
    final id = json['id'];
    final topic = json['topic_code'];
    final type = ContentType.tryParse(json['type'] as String?);
    final title = _text(json['title'], max: 200);
    final body = _text(json['body'], max: 1200);
    if (id is! String || !_uuid.hasMatch(id)) return null;
    if (topic is! String || Topic.byCode(topic) == null) return null;
    if (type == null || title == null || body == null) return null;

    final statement = _text(json['statement'], max: 300);
    final isTrue = json['is_true'];
    if (type == ContentType.challenge && (statement == null || isTrue is! bool)) return null;
    if ((type == ContentType.vocab || type == ContentType.phrase) && _text(json['term']) == null) return null;

    final difficulty = json['difficulty'] is num ? (json['difficulty'] as num).round().clamp(1, 3) : 1;

    return ContentItemsCompanion(
      id: Value(id),
      topicCode: Value(topic),
      type: Value(type.name),
      title: Value(title),
      body: Value(body),
      statement: Value(statement),
      isTrue: Value(isTrue is bool ? isTrue : null),
      correctAnswer: Value(_text(json['correct_answer'], max: 300)),
      explanation: Value(_text(json['explanation'], max: 1200)),
      term: Value(_text(json['term'], max: 200)),
      translation: Value(_text(json['translation'], max: 300)),
      exampleSentence: Value(_text(json['example_sentence'], max: 400)),
      difficulty: Value(difficulty),
      sourceName: Value(_text(json['source_name'], max: 200)),
      sourceUrl: Value(_text(json['source_url'], max: 500)),
      verified: Value(json['verified'] == true),
      inOfflinePack: Value(json['in_offline_pack'] == true),
      isActive: Value(json['is_active'] != false),
      createdAt: Value(DateTime.tryParse(json['created_at'] as String? ?? '')),
      updatedAt: Value(DateTime.tryParse(json['updated_at'] as String? ?? '')),
    );
  }
}

class ContentRepository {
  ContentRepository(this._dao);

  final ContentDao _dao;

  Future<ContentItem?> item(String id) => _dao.byId(id);

  Stream<ContentItem?> watchItem(String id) => _dao.watchById(id);

  Future<List<ContentItem>> activeForTopics(List<String> topics) => _dao.activeForTopics(topics);

  Future<List<ContentItem>> page(String topic, {ContentGroup? group, required int limit, required int offset}) {
    final types = group == null
        ? null
        : [for (final t in ContentType.values) if (t.group == group) t.name];
    return _dao.page(topic: topic, types: types, limit: limit, offset: offset);
  }

  Stream<List<ContentItem>> watchSaved() => _dao.watchSaved();

  Stream<Map<String, int>> watchCountsByTopic() => _dao.watchCountsByTopic();

  Future<int> countActive() => _dao.countActive();

  /// Applies items from `get-content-updates`. Server always wins
  /// (ARCHITECTURE.md 7.3). Tombstones ({id, is_active: false}) deactivate.
  Future<({int saved, int removed, int skipped})> applyServerItems(List<dynamic> items) async {
    final upserts = <ContentItemsCompanion>[];
    final removed = <String>[];
    var skipped = 0;
    for (final raw in items) {
      if (raw is! Map) {
        skipped++;
        continue;
      }
      final json = Map<String, dynamic>.from(raw);
      if (json['is_active'] == false && json['id'] is String && json['title'] == null) {
        removed.add(json['id'] as String);
        continue;
      }
      final companion = ContentValidator.toCompanion(json);
      if (companion == null) {
        skipped++;
        AppLogger.warn('Skipped invalid content item ${json['id']}');
        continue;
      }
      upserts.add(companion);
    }
    if (upserts.isNotEmpty) await _dao.upsertAll(upserts);
    await _dao.deactivate(removed);
    return (saved: upserts.length, removed: removed.length, skipped: skipped);
  }
}

final contentDaoProvider = Provider<ContentDao>((ref) => ContentDao(ref.watch(databaseProvider)));

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(contentDaoProvider)),
);
