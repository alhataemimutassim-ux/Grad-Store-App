import 'package:flutter/material.dart';

class AvatarHeader extends StatelessWidget {
  final String? name;
  final String? subtitle;
  final VoidCallback? onEdit;

  const AvatarHeader({super.key, this.name, this.subtitle, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final displayName = (name ?? 'طالب').trim();
    final avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    return Row(
      children: [
        CircleAvatar(radius: 36, backgroundColor: Theme.of(context).colorScheme.primary, child: Text(avatarLetter, style: const TextStyle(fontSize: 28, color: Colors.white))),
        const SizedBox(width: 16),
        // Use a constrained box instead of a flexible with non-zero flex so this widget
        // behaves correctly in parents that provide unbounded width (e.g. horizontal
        // scrolling areas). The maxWidth is a fraction of the screen width to keep the
        // layout stable across contexts.
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (subtitle != null) const SizedBox(height: 4),
              if (subtitle != null) Text(subtitle!, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        if (onEdit != null) IconButton(onPressed: onEdit, icon: const Icon(Icons.edit))
      ],
    );
  }
}
