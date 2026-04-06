import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/features/sellershop/domain/entities/seller.dart';
import 'package:grad_store_app/features/sellershop/presentation/state/sellers_provider.dart';
import 'package:grad_store_app/features/products/presentation/state/products_provider.dart';
import 'package:grad_store_app/features/products/presentation/widgets/product_card.dart';

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
    if (sellersProv.items.isEmpty) {
      await sellersProv.fetchAll();
    }
    if (!mounted) return;
  final found = sellersProv.items.firstWhere((s) => s.id == widget.sellerId, orElse: () => Seller(id: widget.sellerId, name: 'متجر')); 
    setState(() {
      _seller = found;
      _loading = false;
    });
  }

  Future<void> _openMapsUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر فتح الخرائط')));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر فتح الخرائط')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProv = Provider.of<ProductsProvider>(context);
    final sellerProducts = productsProv.items.where((p) => p.sellerId == widget.sellerId).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_seller?.shopName ?? 'تفاصيل المتجر')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _buildHeader(context, _seller!),
                const SizedBox(height: 12),
                _buildContactCard(context, _seller!),
                const SizedBox(height: 12),
                _buildLocationCard(context, _seller!),
                const SizedBox(height: 16),
                const Text('منتجات البائع', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                sellerProducts.isEmpty
                    ? const Padding(padding: EdgeInsets.all(8.0), child: Text('لا توجد منتجات لهذا البائع بعد.'))
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: sellerProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
                        itemBuilder: (ctx, i) => ProductCard(product: sellerProducts[i]),
                      ),
              ]),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, Seller s) {
    final img = s.imagePath;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: img != null
                ? Image.network(img, width: 96, height: 96, fit: BoxFit.cover)
                : Container(width: 96, height: 96, color: Colors.grey[200], child: const Icon(Icons.store, size: 40)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.shopName ?? s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (s.location != null) Text(s.location!, style: const TextStyle(color: Colors.grey)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Seller s) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('معلومات الاتصال', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (s.phone != null)
            Row(children: [
              const Icon(Icons.phone, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(s.phone!)),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => Clipboard.setData(ClipboardData(text: s.phone ?? '')),
                tooltip: 'نسخ رقم الهاتف',
              ),
            ]),
          if (s.email != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.email, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(s.email!)),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => Clipboard.setData(ClipboardData(text: s.email ?? '')),
                tooltip: 'نسخ البريد الإلكتروني',
              ),
            ])
          ],
        ]),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, Seller s) {
    final lat = s.latitude;
    final lng = s.longitude;
    final coordsAvailable = lat != null && lng != null;
    final mapsUrl = coordsAvailable ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng' : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('الموقع', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (s.location != null) Text(s.location!),
          if (coordsAvailable) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(initialCameraFit: CameraFit.coordinates(coordinates: [LatLng(s.latitude!, s.longitude!)], padding: const EdgeInsets.all(50))),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.shaman',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(s.latitude!, s.longitude!),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.place, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('الإحداثيات: ${s.latitude?.toStringAsFixed(6) ?? ''}, ${s.longitude?.toStringAsFixed(6) ?? ''}')),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => Clipboard.setData(ClipboardData(text: '${s.latitude.toString()},${s.longitude.toString()}')),
                tooltip: 'نسخ الإحداثيات',
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: SelectableText(mapsUrl ?? '')),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('افتح في الخرائط'),
                onPressed: () { if (mapsUrl != null) _openMapsUrl(mapsUrl); },
              ),
            ]),
          ] else
            const Text('لا توجد إحداثيات متاحة'),
        ]),
      ),
    );
  }
}
