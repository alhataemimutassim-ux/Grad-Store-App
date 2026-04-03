import 'package:flutter/material.dart';

/// مكوّن حالة فارغة مع رسالة بسيطة وزر اختياري
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({super.key, required this.title, this.subtitle, this.buttonLabel, this.onButton});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey))],
            if (buttonLabel != null && onButton != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onButton, child: Text(buttonLabel!)),
            ]
          ],
        ),
      ),
    );
  }
}
