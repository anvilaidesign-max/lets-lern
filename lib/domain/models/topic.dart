import 'package:flutter/material.dart';

/// Learning topics (ARCHITECTURE.md 1.1, extended in v1.1 with technology,
/// engineering, medicine, law and business).
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
    Topic(code: 'tech', name: 'Technology', shortName: 'Tech', icon: Icons.memory, sortOrder: 5),
    Topic(code: 'engineering', name: 'Electronics Engineering', shortName: 'Engineering', icon: Icons.electrical_services, sortOrder: 6),
    Topic(code: 'medicine', name: 'Medicine', shortName: 'Medicine', icon: Icons.medical_services_outlined, sortOrder: 7),
    Topic(code: 'law', name: 'Law', shortName: 'Law', icon: Icons.gavel, sortOrder: 8),
    Topic(code: 'politics', name: 'Politics', shortName: 'Politics', icon: Icons.account_balance_outlined, sortOrder: 9),
    Topic(code: 'economics', name: 'Economics', shortName: 'Economics', icon: Icons.trending_up, sortOrder: 10),
    Topic(code: 'finance', name: 'Finance', shortName: 'Finance', icon: Icons.savings_outlined, sortOrder: 11),
    Topic(code: 'business', name: 'Business & Startups', shortName: 'Business', icon: Icons.rocket_launch_outlined, sortOrder: 12),
    Topic(code: 'relations', name: 'International Relations', shortName: 'World', icon: Icons.public, sortOrder: 13),
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
