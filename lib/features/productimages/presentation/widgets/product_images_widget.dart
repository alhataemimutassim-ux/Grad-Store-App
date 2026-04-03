import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/product_images_provider.dart';

class ProductImagesWidget extends StatefulWidget {
  final int productId;
  final double height;

  const ProductImagesWidget({
    super.key,
    required this.productId,
    this.height = 120,
  });

  @override
  State<ProductImagesWidget> createState() => _ProductImagesWidgetState();
}

class _ProductImagesWidgetState extends State<ProductImagesWidget> {
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      // schedule fetch after this build frame to avoid calling notifyListeners
      // while widgets are being built (which throws in debug builds).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final prov = Provider.of<ProductImagesProvider>(context, listen: false);
        prov.fetchForProduct(widget.productId);
      });
      _loadedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductImagesProvider>(
      builder: (context, prov, _) {
        final status = prov.status;
        final images = prov.imagesFor(widget.productId);
        if (status == ProductImagesStatus.loading && images.isEmpty) {
          return SizedBox(
            height: widget.height,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (images.isEmpty) {
          return SizedBox(
            height: widget.height,
            child: Center(
              child: Text(
                'لا توجد صور إضافية',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return SizedBox(
          height: widget.height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemCount: images.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final img = images[index];
              final url = img.image ?? '';
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: widget.height * 1.2,
                  height: widget.height,
                  color: Colors.grey[200],
                  child: url.isEmpty
                      ? Icon(Icons.image, size: 48, color: Colors.grey)
                      : Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
