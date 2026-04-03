import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/features/offers/presentation/state/offers_provider.dart';
import '../widgets/offer_card.dart';
import 'package:grad_store_app/features/offers/domain/entities/offer.dart';
import 'package:grad_store_app/features/products/presentation/pages/product_details_page.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyActive = true;
  bool _isGrid = false;
  SortOption _sort = SortOption.timeRemainingAsc;

  List<Offer> _applyFilters(List<Offer> items) {
    var list = items;
    final q = _searchController.text.trim();
    if (q.isNotEmpty) {
      list = list.where((o) => o.productName.toLowerCase().contains(q.toLowerCase())).toList();
    }
    if (_showOnlyActive) {
      list = list.where((o) => o.endDateTime == null ? true : o.endDateTime!.isAfter(DateTime.now())).toList();
    }
    switch (_sort) {
      case SortOption.timeRemainingAsc:
        list.sort((a, b) {
          final ra = a.endDateTime == null ? Duration(days: 36500) : a.endDateTime!.difference(DateTime.now());
          final rb = b.endDateTime == null ? Duration(days: 36500) : b.endDateTime!.difference(DateTime.now());
          return ra.compareTo(rb);
        });
        break;
      case SortOption.timeRemainingDesc:
        list.sort((a, b) {
          final ra = a.endDateTime == null ? Duration(days: 36500) : a.endDateTime!.difference(DateTime.now());
          final rb = b.endDateTime == null ? Duration(days: 36500) : b.endDateTime!.difference(DateTime.now());
          return rb.compareTo(ra);
        });
        break;
      case SortOption.discountDesc:
        list.sort((a, b) => b.discount.compareTo(a.discount));
        break;
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    // Fetch offers if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<OffersProvider>(context, listen: false);
      if (prov.items.isEmpty) prov.fetchPublicOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OffersProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العروض'),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
            tooltip: _isGrid ? 'قائمة' : 'شبكة',
          ),
          PopupMenuButton<SortOption>(
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => [
              const PopupMenuItem(value: SortOption.timeRemainingAsc, child: Text('الأقرب انتهاء')),
              const PopupMenuItem(value: SortOption.timeRemainingDesc, child: Text('الأبعد انتهاء')),
              const PopupMenuItem(value: SortOption.discountDesc, child: Text('الأعلى خصم')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => prov.fetchPublicOffers(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            // search + filter row
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث داخل العروض'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Column(children: [
                const Text('نشطة فقط'),
                Switch(value: _showOnlyActive, onChanged: (v) => setState(() => _showOnlyActive = v)),
              ])
            ]),
            const SizedBox(height: 12),
            Expanded(child: Builder(builder: (ctx) {
              if (prov.status == OffersStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (prov.status == OffersStatus.error) {
                return Center(child: Text('حدث خطأ: ${prov.error}'));
              }
              final items = _applyFilters(prov.items);
              if (items.isEmpty) return const Center(child: Text('لا توجد عروض حالياً'));

              if (_isGrid) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: items.length,
                  itemBuilder: (_, idx) => OfferCard(
                    offer: items[idx],
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailsPage(productId: items[idx].productId)));
                    },
                  ),
                );
              }

              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final of = items[index];
                  return SizedBox(
                    height: 120,
                    child: OfferCard(
                      offer: of,
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailsPage(productId: of.productId)));
                      },
                    ),
                  );
                },
              );
            })),
          ]),
        ),
      ),
    );
  }
}

enum SortOption { timeRemainingAsc, timeRemainingDesc, discountDesc }
