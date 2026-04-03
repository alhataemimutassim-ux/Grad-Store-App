import 'dart:async';

import 'package:flutter/material.dart';
import '../../domain/entities/offer.dart';
// removed unused import

class OfferCard extends StatefulWidget {
  final Offer offer;
  final VoidCallback? onTap;

  const OfferCard({super.key, required this.offer, this.onTap});

  @override
  State<OfferCard> createState() => _OfferCardState();
}

// small star rating widget with half-star support (kept local to avoid introducing new imports)
class _StarRating extends StatelessWidget {
  final double rating; // 0..5
  final double size;

  const _StarRating({required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = List.generate(5, (i) {
      final idx = i + 1;
      IconData icon;
      if (rating >= idx) {
        icon = Icons.star;
      } else if (rating >= idx - 0.5) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
  return Icon(icon, size: size, color: Colors.amber[600]);
    });
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}

class _OfferCardState extends State<OfferCard> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    if (widget.offer.endDateTime != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void _updateRemaining() {
    final end = widget.offer.endDateTime;
    if (end == null) {
      _remaining = null;
      return;
    }
    final now = DateTime.now();
    _remaining = end.difference(now);
    if (_remaining != null && _remaining!.isNegative) {
      _remaining = Duration.zero;
    }
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _updateRemaining();
      if (_remaining != null && _remaining == Duration.zero) {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  @override
  void didUpdateWidget(covariant OfferCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer.endDateTime != widget.offer.endDateTime) {
      _timer?.cancel();
      _updateRemaining();
      if (widget.offer.endDateTime != null) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return 'انتهى';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    // show days explicitly when >= 1 day
    if (days > 0) {
      // Example: "2 يوم 05:12:30"
      return '$days يوم ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final raw = offer.productImage;
    final imageUrl = (raw != null && raw.startsWith('/')) ? 'https://localhost:7095$raw' : raw;
    final expired = _remaining != null && _remaining == Duration.zero;

    // compute progress if start/end present
    double? progress;
    if (offer.startDateTime != null && offer.endDateTime != null) {
      final total = offer.endDateTime!.difference(offer.startDateTime!);
      if (total.inSeconds > 0) {
        final elapsed = DateTime.now().difference(offer.startDateTime!);
        progress = (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
      }
    }

    // decide chip color based on remaining
    Color chipColor = Theme.of(context).colorScheme.primary;
    if (_remaining == null) {
      chipColor = Colors.blueGrey;
    } else if (_remaining == Duration.zero) {
      chipColor = Colors.grey;
    } else if (_remaining! <= const Duration(hours: 1)) {
      chipColor = Colors.redAccent;
    } else if (_remaining! <= const Duration(days: 1)) {
      chipColor = Colors.orangeAccent;
    }

    return GestureDetector(
      onTap: expired ? null : widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl!= null
                      ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                      : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 40)),
                ),
                // countdown chip top-left
                Positioned(
                  left: 8,
                  top: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      _remaining == null ? 'مستمر' : _formatDuration(_remaining!),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // discount badge top-right
                if (offer.discount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                      child: Text('-${(offer.discount * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (expired)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withAlpha((0.45 * 255).round()), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                      alignment: Alignment.center,
                      child: const Text('انتهى العرض', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                // progress bar bottom of image
                if (progress != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.black26, valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary)),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Top row: product name and rating
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Text(offer.productName, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  // rating (if available)
                  if (offer.averageRating != null && offer.averageRating! > 0)
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      _StarRating(rating: offer.averageRating!, size: 12),
                      if (offer.reviewsCount != null) Text('(${offer.reviewsCount})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ])
                ]),
                const SizedBox(height: 6),
                // remaining time
                if (_remaining != null)
                  Text(_formatDuration(_remaining!), style: TextStyle(color: expired ? Colors.red.shade200 : Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                // price row: current price prominent, old price struck, discount badge
                Row(children: [
                  // current price
                  Expanded(
                    child: Text(
                      '${(offer.discount > 0 ? (offer.price * (1 - offer.discount)) : offer.price).toStringAsFixed(2)} ر.س',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (offer.discount > 0)
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${offer.price.toStringAsFixed(2)} ر.س', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.redAccent.withAlpha((0.95 * 255).round()), borderRadius: BorderRadius.circular(12)),
                        child: Text('-${(offer.discount * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ])
                ])
              ]),
            )
          ],
        ),
      ),
    );
  }
}
