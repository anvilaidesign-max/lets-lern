import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/app_settings.dart';

/// The user's avatar. Bundled characters and saved photos are both files on
/// the phone, so the avatar shows offline.
class ProfileAvatarView extends ConsumerWidget {
  const ProfileAvatarView({super.key, this.size = 40, this.avatar, this.name});

  final double size;

  /// Overrides the saved avatar, e.g. while choosing a new one.
  final ProfileAvatar? avatar;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final chosen = avatar ?? settings.profileAvatar;
    final label = (name ?? settings.profileName).trim();
    final theme = Theme.of(context);

    Widget fallback() => Container(
          color: theme.colorScheme.surfaceContainer,
          alignment: Alignment.center,
          child: label.isEmpty
              ? Icon(Icons.person_outline, size: size * 0.55, color: theme.colorScheme.onSurfaceVariant)
              : Text(
                  label.characters.first.toUpperCase(),
                  style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                ),
        );

    Widget image;
    if (chosen == null) {
      image = fallback();
    } else if (chosen.isAsset) {
      image = Image.asset(chosen.path, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback());
    } else {
      final file = File(chosen.path);
      image = file.existsSync()
          ? Image.file(file, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback())
          : fallback();
    }

    return Semantics(
      label: label.isEmpty ? 'Profile picture' : '$label, profile picture',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.outline, width: 1.5),
        ),
        child: ClipOval(child: image),
      ),
    );
  }
}
