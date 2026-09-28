import 'dart:convert';

import 'package:xml/xml.dart';

import '../../domain/models/news.dart';
import '../../domain/services/seeded_random.dart';

/// Parses RSS 2.0 and Atom feeds into [NewsItem]s. Malformed entries are
/// skipped; a malformed feed returns an empty list.
class RssParser {
  RssParser._();

  static const maxSummary = 280;

  static List<NewsItem> parse(String body, NewsSource source, {DateTime? now}) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(body);
    } catch (_) {
      return const [];
    }
    final fallbackTime = now ?? DateTime.now();
    final items = <NewsItem>[];

    for (final item in doc.findAllElements('item')) {
      final link = _text(item, 'link') ?? _text(item, 'guid');
      final parsed = _build(
        source: source,
        rawTitle: _text(item, 'title'),
        link: link,
        rawSummary: _text(item, 'description') ?? _text(item, 'content:encoded'),
        date: parseDate(_text(item, 'pubDate') ?? _text(item, 'dc:date')) ?? fallbackTime,
        image: _image(item),
      );
      if (parsed != null) items.add(parsed);
    }

    for (final entry in doc.findAllElements('entry')) {
      final links = entry.findElements('link').toList();
      final alternate = links.where((l) => (l.getAttribute('rel') ?? 'alternate') == 'alternate').firstOrNull ?? links.firstOrNull;
      final parsed = _build(
        source: source,
        rawTitle: _text(entry, 'title'),
        link: alternate?.getAttribute('href'),
        rawSummary: _text(entry, 'summary') ?? _text(entry, 'content'),
        date: parseDate(_text(entry, 'published') ?? _text(entry, 'updated')) ?? fallbackTime,
        image: _image(entry),
      );
      if (parsed != null) items.add(parsed);
    }
    return items;
  }

  static NewsItem? _build({
    required NewsSource source,
    required String? rawTitle,
    required String? link,
    required String? rawSummary,
    required DateTime date,
    required String? image,
  }) {
    var title = cleanText(rawTitle ?? '');
    final url = link?.trim();
    if (title.isEmpty || url == null || !url.startsWith('http')) return null;

    // Google News titles end with " - Publisher".
    var sourceName = source.name;
    if (source.url.contains('news.google.com')) {
      final dash = title.lastIndexOf(' - ');
      if (dash > 0 && dash > title.length - 60) {
        sourceName = title.substring(dash + 3).trim();
        title = title.substring(0, dash).trim();
      }
    }

    var summary = cleanText(rawSummary ?? '');
    if (summary == title || source.url.contains('news.google.com')) summary = '';
    if (summary.length > maxSummary) {
      final cut = summary.lastIndexOf(' ', maxSummary);
      summary = '${summary.substring(0, cut > 200 ? cut : maxSummary)}…';
    }

    return NewsItem(
      id: _id(url),
      category: source.category,
      source: sourceName,
      title: title.length > 300 ? title.substring(0, 300) : title,
      summary: summary,
      link: url,
      publishedAt: date,
      imageUrl: image,
    );
  }

  static String _id(String url) {
    final a = stableHash(url).toRadixString(16).padLeft(8, '0');
    final b = stableHash('$url#').toRadixString(16).padLeft(8, '0');
    return '$a$b';
  }

  static String? _text(XmlElement parent, String name) {
    final element = parent.findElements(name).firstOrNull;
    final value = element?.innerText.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String? _image(XmlElement item) {
    for (final name in ['media:thumbnail', 'media:content', 'enclosure']) {
      for (final e in item.findElements(name)) {
        final url = e.getAttribute('url');
        final type = e.getAttribute('type') ?? '';
        final medium = e.getAttribute('medium') ?? '';
        if (url != null && url.startsWith('https') && (name == 'media:thumbnail' || type.startsWith('image') || medium == 'image' || type.isEmpty)) {
          return url;
        }
      }
    }
    for (final group in item.findElements('media:group')) {
      final nested = _image(group);
      if (nested != null) return nested;
    }
    return null;
  }

  static final _tags = RegExp(r'<[^>]*>', multiLine: true);
  static final _spaces = RegExp(r'\s+');
  static final _entity = RegExp(r'&(#x?[0-9a-fA-F]+|[a-zA-Z]+);');
  static const _named = {'amp': '&', 'lt': '<', 'gt': '>', 'quot': '"', 'apos': "'", 'nbsp': ' ', 'hellip': '…', 'mdash': '—', 'ndash': '–', 'rsquo': '’', 'lsquo': '‘', 'rdquo': '”', 'ldquo': '“'};

  /// Removes HTML tags and decodes entities (feeds often double-encode).
  static String cleanText(String input) {
    var s = input;
    for (var pass = 0; pass < 2; pass++) {
      s = s.replaceAll(_tags, ' ');
      s = s.replaceAllMapped(_entity, (m) {
        final e = m.group(1)!;
        if (e.startsWith('#x') || e.startsWith('#X')) {
          final code = int.tryParse(e.substring(2), radix: 16);
          return code == null ? m.group(0)! : String.fromCharCode(code);
        }
        if (e.startsWith('#')) {
          final code = int.tryParse(e.substring(1));
          return code == null ? m.group(0)! : String.fromCharCode(code);
        }
        return _named[e] ?? m.group(0)!;
      });
    }
    s = s.replaceAll(RegExp(r'The post .* appeared first on .*$'), '');
    return s.replaceAll(_spaces, ' ').trim();
  }

  static const _months = {'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6, 'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12};
  static final _rfc822 = RegExp(
    r'^(?:[A-Za-z]{3},\s*)?(\d{1,2})\s+([A-Za-z]{3})[a-z]*\s+(\d{2,4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([A-Za-z]{1,5}|[+-]\d{4})?',
  );

  /// RSS dates (RFC 822, e.g. "Sun, 27 Sep 2026 14:09:22 GMT" or "+0200")
  /// and Atom dates (ISO 8601). Returns UTC.
  static DateTime? parseDate(String? value) {
    if (value == null) return null;
    final v = value.trim();
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso.toUtc();
    final m = _rfc822.firstMatch(v);
    if (m == null) return null;
    final month = _months[m.group(2)!.toLowerCase()];
    if (month == null) return null;
    var year = int.parse(m.group(3)!);
    if (year < 100) year += 2000;
    final utc = DateTime.utc(year, month, int.parse(m.group(1)!), int.parse(m.group(4)!), int.parse(m.group(5)!), int.tryParse(m.group(6) ?? '') ?? 0);
    final zone = m.group(7) ?? 'GMT';
    Duration offset;
    if (zone.startsWith('+') || zone.startsWith('-')) {
      final sign = zone.startsWith('-') ? -1 : 1;
      offset = Duration(hours: int.parse(zone.substring(1, 3)), minutes: int.parse(zone.substring(3, 5))) * sign;
    } else {
      offset = switch (zone.toUpperCase()) {
        'EST' => const Duration(hours: -5),
        'EDT' => const Duration(hours: -4),
        'CST' => const Duration(hours: -6),
        'CDT' => const Duration(hours: -5),
        'PST' => const Duration(hours: -8),
        'PDT' => const Duration(hours: -7),
        'CAT' => const Duration(hours: 2),
        'SAST' => const Duration(hours: 2),
        _ => Duration.zero,
      };
    }
    return utc.subtract(offset);
  }

  /// Decodes a response body, tolerating bad bytes.
  static String decode(List<int> bytes) => utf8.decode(bytes, allowMalformed: true);
}
