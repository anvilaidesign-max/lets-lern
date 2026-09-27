import 'package:flutter/material.dart';

/// The 8 learning topics (ARCHITECTURE.md 1.1).
class Topic {
  const Topic({
    required this.code,
    required this.name,
    required this.shortName,
    required this.icon,
    required this.sortOrder,
  });

  final String code;
  final String name;
  final String shortName;
  final IconData icon;
  final int sortOrder;

  static const all = <Topic>[
    Topic(code: 'math', name: 'Mathematics', shortName: 'Maths', icon: Icons.calculate_outlined, sortOrder: 1),
    Topic(code: 'english', name: 'English', shortName: 'English', icon: Icons.menu_book_outlined, sortOrder: 2),
    Topic(code: 'french', name: 'French', shortName: 'French', icon: Icons.translate, sortOrder: 3),
    Topic(code: 'science', name: 'Science', shortName: 'Science', icon: Icons.science_outlined, sortOrder: 4),
    Topic(code: 'politics', name: 'Politics', shortName: 'Politics', icon: Icons.account_balance_outlined, sortOrder: 5),
    Topic(code: 'economics', name: 'Economics', shortName: 'Economics', icon: Icons.trending_up, sortOrder: 6),
    Topic(code: 'finance', name: 'Finance', shortName: 'Finance', icon: Icons.savings_outlined, sortOrder: 7),
    Topic(code: 'relations', name: 'International Relations', shortName: 'World', icon: Icons.public, sortOrder: 8),
  ];

  static final List<String> allCodes = [for (final t in all) t.code];

  static Topic? byCode(String code) {
    for (final t in all) {
      if (t.code == code) return t;
    }
    return null;
  }

  static String nameOf(String code) => byCode(code)?.name ?? code;

  static String shortNameOf(String code) => byCode(code)?.shortName ?? code;
}
