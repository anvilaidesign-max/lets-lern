import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/theme/tokens.dart';
import '../../data/remote/supabase_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/sync/sync_service.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/services/streak_service.dart';
import '../common/widgets.dart';
import '../home/home_providers.dart';
import '../progress/progress_screen.dart';
import 'profile_avatar.dart';

/// Profile: name, what you study, level and avatar. Stored on the phone so it
/// works offline; the name is also saved to your account when online.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _field;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    final googleName = ref.read(supabaseServiceProvider).currentUser?.userMetadata?['full_name'] as String?;
    _name = TextEditingController(text: s.profileName.isNotEmpty ? s.profileName : (googleName ?? ''));
    _field = TextEditingController(text: s.profileField);
  }

  @override
  void dispose() {
    _name.dispose();
    _field.dispose();
    super.dispose();
  }

  Future<void> _saveText() async {
    await ref.read(settingsProvider.notifier).setMany({
      SettingKeys.profileName: _name.text.trim(),
      SettingKeys.profileField: _field.text.trim(),
    });
    ref.read(syncServiceProvider).run();
  }

  Future<void> _chooseAvatar() async {
    final chosen = await showModalBottomSheet<ProfileAvatar>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _AvatarPicker(),
    );
    if (chosen != null) {
      await ref.read(settingsProvider.notifier).set(SettingKeys.profileAvatar, chosen.storageValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(settingsProvider);
    final user = ref.watch(authUserProvider).value;
    final streak = ref.watch(streakProvider);
    final days = ref.watch(itemsByDayProvider).value ?? const {};
    final learned = ref.watch(itemsLearnedProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Stack(
              children: [
                GestureDetector(onTap: _chooseAvatar, child: const ProfileAvatarView(size: 112)),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    tooltip: 'Change picture',
                    onPressed: _chooseAvatar,
                    icon: const Icon(Icons.edit, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              user?.email ?? 'Offline profile (saved on this phone)',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _Stat(value: '🔥 $streak', label: 'Streak')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _Stat(value: '${StreakCalculator.longest(days)}', label: 'Best')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _Stat(value: '$learned', label: 'Learned')),
            ],
          ),
          const SectionTitle('Name'),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            decoration: const InputDecoration(hintText: 'Your name', counterText: ''),
            onSubmitted: (_) => _saveText(),
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
              _saveText();
            },
          ),
          const SectionTitle('What do you study or do?'),
          TextField(
            controller: _field,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: const InputDecoration(hintText: 'e.g. Industrial Electronics Engineering', counterText: ''),
            onSubmitted: (_) => _saveText(),
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
              _saveText();
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your AI tutor uses this to pitch its lessons at the right level.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SectionTitle('Level'),
          SegmentedButton<LearningLevel>(
            segments: [
              for (final l in LearningLevel.values) ButtonSegment(value: l, label: Text(l.label)),
            ],
            selected: {s.level},
            onSelectionChanged: (v) async {
              await ref.read(settingsProvider.notifier).set(SettingKeys.learningLevel, v.first.storageValue);
              ref.invalidate(homeItemProvider);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(s.level.description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        children: [
          FittedBox(child: Text(value, style: theme.textTheme.titleLarge)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Grid of bundled characters plus "use my photo".
class _AvatarPicker extends StatefulWidget {
  const _AvatarPicker();

  @override
  State<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> {
  bool _busy = false;

  Future<void> _usePhoto() async {
    setState(() => _busy = true);
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 90);
      if (picked == null) return;
      final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'profile'));
      await dir.create(recursive: true);
      // A new name each time so the image cache never shows the old photo.
      final target = p.join(dir.path, 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final saved = await FlutterImageCompress.compressAndGetFile(picked.path, target, minWidth: 512, minHeight: 512, quality: 85);
      if (saved == null) await File(picked.path).copy(target);
      for (final old in dir.listSync().whereType<File>()) {
        if (old.path != target) {
          try {
            old.deleteSync();
          } catch (_) {}
        }
      }
      if (mounted) Navigator.pop(context, ProfileAvatar.file(target));
    } catch (_) {
      if (mounted) showMessage(context, 'Could not open your photos.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Text('Choose your character', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 88,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                ),
                itemCount: ProfileAvatar.bundledCount,
                itemBuilder: (context, i) {
                  final avatar = ProfileAvatar.asset(i + 1);
                  return InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pop(context, avatar),
                    child: ClipOval(child: Image.asset(avatar.path, fit: BoxFit.cover)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: _busy
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton.icon(
                        onPressed: _usePhoto,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Use my own photo'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
