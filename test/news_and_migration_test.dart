import 'dart:io';

import 'package:daily_mind/data/local/database.dart';
import 'package:daily_mind/data/remote/rss_parser.dart';
import 'package:daily_mind/domain/models/news.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _rss = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <title>Test</title>
    <item>
      <title><![CDATA[Brace for rains &amp; thunderstorms]]></title>
      <link>https://www.herald.co.zw/brace-for-rains/</link>
      <description><![CDATA[<p>The Met Department has <b>warned</b> of heavy rains.</p><p>The post Brace appeared first on The Herald.</p>]]></description>
      <pubDate>Sun, 27 Sep 2026 15:00:15 +0000</pubDate>
      <media:thumbnail url="https://example.com/rain.jpg"/>
    </item>
    <item>
      <title>No link here</title>
    </item>
  </channel>
</rss>''';

const _atom = '''<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <title>OpenAI agents tried a new trick</title>
    <link rel="alternate" type="text/html" href="https://www.theverge.com/story/1"/>
    <summary>A short summary.</summary>
    <updated>2026-09-27T17:21:07+00:00</updated>
  </entry>
</feed>''';

void main() {
  group('RssParser', () {
    const herald = NewsSource('The Herald', 'https://www.herald.co.zw/feed/', NewsCategory.zimbabwe);
    const verge = NewsSource('The Verge', 'https://www.theverge.com/rss/index.xml', NewsCategory.tech);

    test('parses RSS items, cleans HTML and entities, reads dates and images', () {
      final items = RssParser.parse(_rss, herald);
      expect(items.length, 1);
      final item = items.single;
      expect(item.title, 'Brace for rains & thunderstorms');
      expect(item.summary, 'The Met Department has warned of heavy rains.');
      expect(item.publishedAt, DateTime.utc(2026, 9, 27, 15, 0, 15));
      expect(item.imageUrl, 'https://example.com/rain.jpg');
      expect(item.category, NewsCategory.zimbabwe);
    });

    test('parses Atom entries', () {
      final items = RssParser.parse(_atom, verge);
      expect(items.single.link, 'https://www.theverge.com/story/1');
      expect(items.single.publishedAt, DateTime.utc(2026, 9, 27, 17, 21, 7));
    });

    test('handles RFC 822 time zones and bad input', () {
      expect(RssParser.parseDate('Sun, 27 Sep 2026 09:01:27 -0400'), DateTime.utc(2026, 9, 27, 13, 1, 27));
      expect(RssParser.parseDate('Fri, 25 Sep 2026 07:00:00 GMT'), DateTime.utc(2026, 9, 25, 7));
      expect(RssParser.parseDate('nonsense'), isNull);
      expect(RssParser.parse('<not xml', herald), isEmpty);
    });

    test('Google News titles give the real publisher', () {
      const google = NewsSource('Google News', 'https://news.google.com/rss/search?q=Zimbabwe', NewsCategory.zimbabwe);
      const feed = '<rss><channel><item><title>Harare water supply improves - NewsDay</title>'
          '<link>https://news.google.com/articles/abc</link><pubDate>Fri, 25 Sep 2026 07:00:00 GMT</pubDate></item></channel></rss>';
      final item = RssParser.parse(feed, google).single;
      expect(item.title, 'Harare water supply improves');
      expect(item.source, 'NewsDay');
    });
  });

  group('database migration', () {
    test('upgrading a v1 database adds news and books and keeps progress', () async {
      final dir = await Directory.systemTemp.createTemp('wl_migration');
      final file = File('${dir.path}/app.sqlite');
      addTearDown(() => dir.delete(recursive: true));

      // Create a current database, then turn it back into a v1 file.
      var db = AppDatabase(NativeDatabase(file));
      await db.into(db.userProgress).insert(UserProgressCompanion.insert(itemId: 'item-1', seenCount: const Value(4)));
      await db.customStatement('DROP TABLE news_items');
      await db.customStatement('DROP TABLE chapters');
      await db.customStatement('DROP TABLE chapter_progress');
      await db.customStatement('PRAGMA user_version = 1');
      await db.close();

      db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
      final progress = await (db.select(db.userProgress)..where((t) => t.itemId.equals('item-1'))).getSingle();
      expect(progress.seenCount, 4);
      expect(await db.select(db.newsItems).get(), isEmpty);
      expect(await db.select(db.chapters).get(), isEmpty);
      expect(await db.select(db.chapterProgressEntries).get(), isEmpty);
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.first, 2);
    });
  });
}
