import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'package:grad_store_app/core/constants/api_constants.dart';
import 'package:grad_store_app/features/sellershop/domain/entities/seller.dart';
import 'package:grad_store_app/features/sellershop/presentation/state/sellers_provider.dart';
import 'package:grad_store_app/features/products/presentation/state/products_provider.dart';
import 'package:grad_store_app/features/products/presentation/widgets/product_card.dart';
import 'package:grad_store_app/core/theme/dimens.dart';

class SellerDetailsPage extends StatefulWidget {
  final int sellerId;
  const SellerDetailsPage({super.key, required this.sellerId});

  @override
  State<SellerDetailsPage> createState() => _SellerDetailsPageState();
}

class _SellerDetailsPageState extends State<SellerDetailsPage> {
  Seller? _seller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final sellersProv = Provider.of<SellersProvider>(context, listen: false);
    if (sellersProv.items.isEmpty) await sellersProv.fetchAll();
    if (!mounted) return;
    final found = sellersProv.items.firstWhere(
      (s) => s.id == widget.sellerId,
      orElse: () => Seller(id: widget.sellerId, name: 'متجر'),
    );
    setState(() {
      _seller = found;
      _loading = false;
    });
  }

  Future<void> _openMapsUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تعذّر فتح الخرائط')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تعذّر فتح الخرائط')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final productsProv = Provider.of<ProductsProvider>(context);
    final sellerProducts =
        productsProv.items.where((p) => p.sellerId == widget.sellerId).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ══════════════════════════════════════════════════════════
                // 1. SliverAppBar - خلفية المتجر
                // ══════════════════════════════════════════════════════════
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // cover / gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primary,
                                primary.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                        // shop logo
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              _buildShopAvatar(_seller!),
                              const SizedBox(height: 12),
                              Text(
                                _seller!.shopName ?? _seller!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(blurRadius: 8, color: Colors.black26)
                                  ],
                                ),
                              ),
                              if (_seller!.location != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.white70, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        _seller!.location!,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // gradient overlay (bottom)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  theme.colorScheme.surfaceContainerHighest,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ══════════════════════════════════════════════════════════
                // 2. Info Cards
                // ══════════════════════════════════════════════════════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildContactCard(theme, _seller!),
                        const SizedBox(height: 12),
                        _buildLocationCard(theme, _seller!),
                        const SizedBox(height: 20),

                        // ── Products header ──────────────────────────────
                        Row(
                          children: [
                            Icon(Icons.inventory_2_rounded, color: primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'منتجات المتجر',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${sellerProducts.length} منتج',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: primary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // ══════════════════════════════════════════════════════════
                // 3. Products Grid
                // ══════════════════════════════════════════════════════════
                sellerProducts.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 60, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text('لا توجد منتجات لهذا المتجر بعد',
                                  style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => ProductCard(product: sellerProducts[i]),
                            childCount: sellerProducts.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 210,
                            crossAxisSpacing: Dimens.largePadding,
                            mainAxisSpacing: Dimens.largePadding,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  // ─── Shop Avatar ──────────────────────────────────────────────────────────
  Widget _buildShopAvatar(Seller s) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: s.imagePath != null
            ? Image.network(
                s.imagePath!.startsWith('http')
                    ? s.imagePath!
                    : '${ApiConstants.baseUrl}${s.imagePath}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.store_rounded, size: 44, color: Colors.grey),
              )
            : const Icon(Icons.store_rounded, size: 44, color: Colors.grey),
      ),
    );
  }

  // ─── Contact Card ─────────────────────────────────────────────────────────
  Widget _buildContactCard(ThemeData theme, Seller s) {
    final primary = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_phone_rounded, color: primary, size: 18),
                const SizedBox(width: 8),
                Text('معلومات الاتصال',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: primary)),
              ],
            ),
            const SizedBox(height: 12),
            if (s.phone != null) _buildContactRow(Icons.phone_rounded, s.phone!, () {
              Clipboard.setData(ClipboardData(text: s.phone!));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('تم نسخ رقم الهاتف')));
            }, theme),
            if (s.email != null) ...[
              const SizedBox(height: 8),
              _buildContactRow(Icons.email_rounded, s.email!, () {
                Clipboard.setData(ClipboardData(text: s.email!));
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('تم نسخ البريد')));
              }, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
      IconData icon, String text, VoidCallback onTap, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
            Icon(Icons.copy_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ─── Location Card ────────────────────────────────────────────────────────
  Widget _buildLocationCard(ThemeData theme, Seller s) {
    final primary = theme.colorScheme.primary;
    final lat = s.latitude;
    final lng = s.longitude;
    final coordsAvailable = lat != null && lng != null;
    final mapsUrl = coordsAvailable
        ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
        : null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: primary, size: 18),
                const SizedBox(width: 8),
                Text('الموقع',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: primary)),
              ],
            ),
            if (s.location != null) ...[
              const SizedBox(height: 8),
              Text(s.location!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
            if (coordsAvailable) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCameraFit: CameraFit.coordinates(
                        coordinates: [LatLng(lat, lng)],
                        padding: const EdgeInsets.all(50),
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.shaman',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: Icon(Icons.location_on,
                                color: primary, size: 36),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: const Text('فتح في خرائط جوجل'),
                  onPressed: () {
                    if (mapsUrl != null) _openMapsUrl(mapsUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('لا توجد إحداثيات متاحة',
                    style: TextStyle(color: Colors.grey[400])),
              ),
          ],
        ),
      ),
    );
  }


}
