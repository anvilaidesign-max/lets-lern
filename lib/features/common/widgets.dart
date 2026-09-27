import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/tokens.dart';
import '../../domain/models/topic.dart';

/// Rounded, bordered card used across the app.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(AppSpacing.md), this.color});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color ?? scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class TopicChip extends StatelessWidget {
  const TopicChip({super.key, required this.code, this.selected = false, this.onTap, this.compact = false});

  final String code;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.forTopicOn(theme.brightness, code);
    final topic = Topic.byCode(code);
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: topic?.name ?? code,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 5 : 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: selected ? color : theme.colorScheme.outline, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(topic?.icon ?? Icons.circle, size: compact ? 14 : 16, color: color),
              const SizedBox(width: 6),
              Text(
                compact ? (topic?.shortName ?? code) : (topic?.name ?? code),
                style: (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: AppSpacing.lg), action!],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Something went wrong',
        message: message,
        action: onRetry == null ? null : OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      );
}

class OfflinePill extends StatelessWidget {
  const OfflinePill({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'You are offline',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('Offline', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium,
                semanticsLabel: text,
              ),
            ),
            ?trailing,
          ],
        ),
      );
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showError(BuildContext context, AppException error) {
  if (error is CancelledException) return;
  showMessage(context, error.userMessage);
}

/// Small coloured label, e.g. "True or false".
class TypeLabel extends StatelessWidget {
  const TypeLabel({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      );
}
