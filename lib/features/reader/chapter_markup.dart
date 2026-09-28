import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/tokens.dart';

/// Renders chapter text written in a light markup:
/// `![caption](diagram)` shows `assets/diagrams/diagram.svg` as a figure,
/// `## heading`, `### subheading`, `- bullet`, `> callout` (formulas and
/// worked examples), blank lines between paragraphs, `**bold**`, `*italic*`, `~~struck~~`
/// and `` `code` `` inline.
class ChapterMarkup extends StatelessWidget {
  const ChapterMarkup({super.key, required this.body, this.scale = 1.0, required this.accent});

  final String body;
  final double scale;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyLarge!.copyWith(fontSize: 17 * scale, height: 1.6);
    final blocks = body.replaceAll('\r\n', '\n').split(RegExp(r'\n\s*\n'));
    final children = <Widget>[];

    for (final raw in blocks) {
      final block = raw.trim();
      if (block.isEmpty) continue;
      final lines = block.split('\n').map((l) => l.trimRight()).toList();

      final image = _image.firstMatch(block);
      if (image != null) {
        children.add(ChapterFigure(name: image.group(2)!.trim(), caption: image.group(1)!.trim(), scale: scale));
      } else if (block.startsWith('## ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
          child: Text(block.substring(3).trim(), style: theme.textTheme.titleLarge?.copyWith(fontSize: 21 * scale, fontWeight: FontWeight.w700)),
        ));
      } else if (block.startsWith('### ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
          child: Text(block.substring(4).trim(), style: theme.textTheme.titleMedium?.copyWith(fontSize: 18 * scale)),
        ));
      } else if (lines.every((l) => l.startsWith('- '))) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10 * scale, right: 10),
                        child: Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                      ),
                      Expanded(child: Text.rich(inline(l.substring(2), base))),
                    ],
                  ),
                ),
            ],
          ),
        ));
      } else if (lines.every((l) => l.startsWith('>'))) {
        final text = lines.map((l) => l.replaceFirst(RegExp(r'^>\s?'), '')).join('\n');
        children.add(Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: accent, width: 4)),
          ),
          child: Text.rich(inline(text, base.copyWith(height: 1.5))),
        ));
      } else {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Text.rich(inline(lines.join(' '), base)),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  static final _image = RegExp(r'^!\[([^\]]*)\]\(([a-z0-9_\-]+)\)$');

  static final _inline = RegExp(r'(\*\*[^*]+\*\*|~~[^~]+~~|\*[^*\s][^*]*\*|`[^`]+`)');

  static TextSpan inline(String text, TextStyle style) {
    final spans = <InlineSpan>[];
    var index = 0;
    for (final m in _inline.allMatches(text)) {
      if (m.start > index) spans.add(TextSpan(text: text.substring(index, m.start)));
      final token = m.group(0)!;
      if (token.startsWith('**')) {
        spans.add(TextSpan(text: token.substring(2, token.length - 2), style: const TextStyle(fontWeight: FontWeight.w700)));
      } else if (token.startsWith('~~')) {
        // Struck-through text marks a wrong example.
        spans.add(TextSpan(
          text: token.substring(2, token.length - 2),
          style: const TextStyle(decoration: TextDecoration.lineThrough, decorationThickness: 2),
        ));
      } else if (token.startsWith('*')) {
        spans.add(TextSpan(text: token.substring(1, token.length - 1), style: const TextStyle(fontStyle: FontStyle.italic)));
      } else {
        spans.add(TextSpan(
          text: token.substring(1, token.length - 1),
          style: TextStyle(fontFamily: 'monospace', fontSize: (style.fontSize ?? 16) * 0.92),
        ));
      }
      index = m.end;
    }
    if (index < text.length) spans.add(TextSpan(text: text.substring(index)));
    return TextSpan(style: style, children: spans);
  }
}

/// A chapter illustration: always drawn on white so colours read the same in
/// light and dark mode. Tap to zoom.
class ChapterFigure extends StatelessWidget {
  const ChapterFigure({super.key, required this.name, required this.caption, this.scale = 1.0});

  final String name;
  final String caption;
  final double scale;

  String get _path => 'assets/diagrams/$name.svg';

  void _zoom(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.white,
        child: Stack(
          children: [
            InteractiveViewer(
              maxScale: 6,
              child: Center(child: SvgPicture.asset(_path, fit: BoxFit.contain)),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            if (caption.isNotEmpty)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(caption, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 15)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.lg),
      child: Semantics(
        image: true,
        label: caption.isEmpty ? 'Diagram' : 'Diagram: $caption',
        child: InkWell(
          onTap: () => _zoom(context),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: SvgPicture.asset(
                  _path,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) => const SizedBox(height: 160),
                ),
              ),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13 * scale,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
