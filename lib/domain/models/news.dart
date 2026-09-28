/// News sections on the News tab.
enum NewsCategory {
  zimbabwe('zimbabwe', 'Zimbabwe'),
  world('world', 'World'),
  africa('africa', 'Africa'),
  tech('tech', 'Tech'),
  engineering('engineering', 'Engineering'),
  business('business', 'Business & VC'),
  science('science', 'Science');

  const NewsCategory(this.code, this.label);
  final String code;
  final String label;

  static NewsCategory? tryParse(String code) {
    for (final c in values) {
      if (c.code == code) return c;
    }
    return null;
  }
}

/// A public RSS or Atom feed. Only headlines and short summaries are shown;
/// tapping opens the publisher's own page.
class NewsSource {
  const NewsSource(this.name, this.url, this.category);

  final String name;
  final String url;
  final NewsCategory category;

  /// All feeds were checked live on 27 September 2026.
  static const all = <NewsSource>[
    NewsSource('The Herald', 'https://www.herald.co.zw/feed/', NewsCategory.zimbabwe),
    NewsSource('NewsDay', 'https://www.newsday.co.zw/feed', NewsCategory.zimbabwe),
    NewsSource('NewZimbabwe', 'https://www.newzimbabwe.com/feed/', NewsCategory.zimbabwe),
    NewsSource('Google News', 'https://news.google.com/rss/search?q=Zimbabwe&hl=en-ZW&gl=ZW&ceid=ZW:en', NewsCategory.zimbabwe),
    NewsSource('BBC News', 'https://feeds.bbci.co.uk/news/world/rss.xml', NewsCategory.world),
    NewsSource('Al Jazeera', 'https://www.aljazeera.com/xml/rss/all.xml', NewsCategory.world),
    NewsSource('The Guardian', 'https://www.theguardian.com/world/rss', NewsCategory.world),
    NewsSource('BBC Africa', 'https://feeds.bbci.co.uk/news/world/africa/rss.xml', NewsCategory.africa),
    NewsSource('BBC Technology', 'https://feeds.bbci.co.uk/news/technology/rss.xml', NewsCategory.tech),
    NewsSource('Ars Technica', 'https://feeds.arstechnica.com/arstechnica/index', NewsCategory.tech),
    NewsSource('The Verge', 'https://www.theverge.com/rss/index.xml', NewsCategory.tech),
    NewsSource('TechCrunch', 'https://techcrunch.com/feed/', NewsCategory.tech),
    NewsSource('IEEE Spectrum', 'https://spectrum.ieee.org/feeds/feed.rss', NewsCategory.engineering),
    NewsSource('BBC Business', 'https://feeds.bbci.co.uk/news/business/rss.xml', NewsCategory.business),
    NewsSource('TechCrunch Venture', 'https://techcrunch.com/category/venture/feed/', NewsCategory.business),
    NewsSource('BBC Science', 'https://feeds.bbci.co.uk/news/science_and_environment/rss.xml', NewsCategory.science),
  ];

  static List<NewsSource> forCategory(NewsCategory category) =>
      [for (final s in all) if (s.category == category) s];
}

class NewsItem {
  const NewsItem({
    required this.id,
    required this.category,
    required this.source,
    required this.title,
    required this.summary,
    required this.link,
    required this.publishedAt,
    this.imageUrl,
  });

  final String id;
  final NewsCategory category;
  final String source;
  final String title;
  final String summary;
  final String link;
  final DateTime publishedAt;
  final String? imageUrl;
}
