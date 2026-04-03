import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import 'package:grad_store_app/core/widgets/rounded_card.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      minWidth: 120,
      maxWidth: 180,
      minHeight: 140,
      maxHeight: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: category.imageUrl != null
                  ? Hero(tag: 'cat-${category.id}', child: Image.network(category.imageUrl!, fit: BoxFit.cover))
                  : Container(color: Colors.grey[200], child: const Icon(Icons.category, size: 48)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
