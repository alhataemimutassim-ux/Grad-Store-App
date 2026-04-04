import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/sized_context.dart';
import 'package:grad_store_app/core/widgets/app_button.dart ';
import 'package:grad_store_app/core/widgets/app_read_more_text.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/rate_widget.dart';


import 'package:grad_store_app/features/products/presentation/state/products_provider.dart';
import 'package:grad_store_app/features/products/domain/entities/product.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
import 'package:grad_store_app/features/productimages/presentation/state/product_images_provider.dart';
import 'package:grad_store_app/features/products/presentation/state/reviews_provider.dart';
import 'package:grad_store_app/features/auth/presentation/state/auth_provider.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/theme/dimens.dart';
import '../widgets/product_details_app_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _userSelectedRating = 5;
  int _visibleCommentsCount = 5;
  Product? _product;
  bool _isLoading = true;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pProvider = context.read<ProductsProvider>();
      final p = await pProvider.fetchById(widget.productId);
      
      if (!mounted) return;
      
      // Fetch Images and Reviews
      await context.read<ProductImagesProvider>().fetchForProduct(widget.productId);
      await context.read<ReviewsProvider>().fetchForProduct(widget.productId);

      if (mounted) {
        setState(() {
          _product = p;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColor = context.theme.appColors;
    final appTypography = context.theme.appTypography;

    if (_isLoading) {
      return const AppScaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_product == null) {
      return const AppScaffold(body: Center(child: Text("المنتج غير موجود")));
    }

    final product = _product!;
    final imageUrl = product.mainImage != null && product.mainImage!.isNotEmpty
        ? (product.mainImage!.startsWith('http') ? product.mainImage! : '${ApiConstants.baseUrl}${product.mainImage}')
        : null;

    return AppScaffold(
      safeAreaTop: false,
      safeAreaBottom: false,
      padding: EdgeInsets.zero,
      body: SizedBox(
        height: context.heightPx,
        child: Stack(
          children: [
            // 1. صورة المنتج العلوية
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: imageUrl != null 
                  ? Image.network(
                      imageUrl,
                      width: context.widthPx,
                      height: context.heightPx * 0.45,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                    )
                  : Container(color: Colors.grey[300], width: context.widthPx, height: context.heightPx * 0.45),
            ),

            // 2. AppBar
            ProductDetailsAppBar(product: product),

            // 3. (التفاصيل + الإضافات)
            Positioned(
              top: context.heightPx * 0.38,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimens.corners * 3),
                    topRight: Radius.circular(Dimens.corners * 3),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimens.largePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: (appTypography.bodyLarge as TextStyle)
                                  .copyWith(fontSize: 18.0),
                            ),
                          ),
                          RateWidget(rate: product.averageRating != null ? product.averageRating!.toStringAsFixed(1) : "0.0"),
                        ],
                      ),
                      const SizedBox(height: Dimens.largePadding),
                      AppReadMoreText(product.description ?? "لا يوجد وصف للمنتج"),

                      const Divider(height: Dimens.largePadding * 2),

                      // Seller Details
                      Text(
                        "معلومات المتجر",
                        style: (appTypography.bodyLarge as TextStyle).copyWith(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Dimens.padding),
                      _buildSellerCard(appTypography, appColor, product),

                      const Divider(height: Dimens.largePadding * 2),

                      // Additional Images
                      Text(
                        "صور إضافية",
                        style: (appTypography.bodyLarge as TextStyle).copyWith(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Dimens.padding),
                      Consumer<ProductImagesProvider>(
                        builder: (context, imagesProvider, _) {
                          final images = imagesProvider.imagesFor(widget.productId);
                          if (imagesProvider.status == ProductImagesStatus.loading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (images.isEmpty) {
                            return const Text("لا توجد صور إضافية");
                          }
                          return SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                final imgPath = images[index].image ?? '';
                                final fullPath = imgPath.startsWith('http') ? imgPath : '${ApiConstants.baseUrl}$imgPath';
                                return _buildAdditionalImageNetwork(context, fullPath);
                              },
                            ),
                          );
                        },
                      ),

                      const Divider(height: Dimens.largePadding * 2),

                      // Reviews overview
                      _buildRatingSection(appTypography, appColor, product),

                      const Divider(height: Dimens.largePadding * 2),

                      // Reviews List & Input
                      _buildExpandableComments(appTypography, appColor),

                      const Divider(height: Dimens.largePadding * 2),

                      // Similar Products
                      Text(
                        "منتجات مشابهة",
                        style: (appTypography.bodyLarge as TextStyle).copyWith(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Dimens.padding),
                      Consumer<ProductsProvider>(
                        builder: (context, productsProvider, _) {
                          final similar = productsProvider.items.where((p) => p.categoryId == product.categoryId && p.id != product.id).toList();
                          if (similar.isEmpty) {
                            return const Text("لا توجد منتجات مشابهة");
                          }
                          return SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: similar.length < 5 ? similar.length : 5,
                              itemBuilder: (context, index) {
                                return _buildSimilarProductCard(appColor, appTypography, similar[index]);
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ),

            // 4. زر السلة الثابت
            _buildStickyBottomBar(appColor, appTypography, product),
          ],
        ),
      ),
    );
  }

  // (fontSize as double)

  Widget _buildRatingSection(dynamic typography, dynamic color, Product product) {
    return Consumer<ReviewsProvider>(
      builder: (context, reviewsProvider, child) {
        final avg = reviewsProvider.averageRating;
        final count = reviewsProvider.reviewsCount;
        final reviews = reviewsProvider.reviews;

        // حساب نسب كل تقييم ديناميكياً من المراجعات الحقيقية
        double _starPercent(int star) {
          if (reviews.isEmpty) return 0.0;
          final cnt = reviews.where((r) => r.rating == star).length;
          return cnt / reviews.length;
        }
        
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        avg.toStringAsFixed(1),
                        style: (typography.displayMedium as TextStyle).copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          fontSize: 45,
                        ),
                      ),
                      Text(
                        "من 5",
                        style: (typography.bodySmall as TextStyle).copyWith(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star_rounded,
                            color: index < avg.round()
                                ? Colors.amber
                                : Colors.grey[300],
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$count مراجعة",
                        style: (typography.bodySmall as TextStyle).copyWith(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildRatingBar("5", _starPercent(5)),
                      _buildRatingBar("4", _starPercent(4)),
                      _buildRatingBar("3", _starPercent(3)),
                      _buildRatingBar("2", _starPercent(2)),
                      _buildRatingBar("1", _starPercent(1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildRatingBar(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[100],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 45,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableComments(dynamic typography, dynamic color) {
    return Consumer<ReviewsProvider>(
      builder: (context, reviewsProvider, child) {
        final allComments = reviewsProvider.reviews;
        final isLoggedIn = context.read<AuthProvider>().status == AuthStatus.authenticated;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(horizontal: 10),
              iconColor: Colors.black,
              title: Text(
                "التعليقات والمراجعات (${allComments.length})",
                style: (typography.bodyLarge as TextStyle).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              children: [
                if (isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text("تقييمك: "),
                            Row(
                              children: List.generate(
                                5,
                                (index) => GestureDetector(
                                  onTap: () => setState(() => _userSelectedRating = index + 1),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: index < _userSelectedRating ? Colors.amber : Colors.grey[300],
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _reviewController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: "أضف رأيك هنا...",
                            hintStyle: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            prefixIcon: reviewsProvider.status == ReviewsStatus.submitting
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(strokeWidth: 2.0),
                                  )
                                : IconButton(
                                    icon: Icon(Icons.send_rounded, color: color.primary),
                                    onPressed: () async {
                                      if (_reviewController.text.trim().isEmpty) return;
                                      try {
                                        await reviewsProvider.submitReview(
                                          productId: widget.productId,
                                          rating: _userSelectedRating,
                                          comment: _reviewController.text.trim(),
                                        );
                                        _reviewController.clear();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                                      }
                                    },
                                  ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Comments List
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      if (allComments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("لا توجد تعليقات حتى الآن."),
                        ),
                      ...allComments
                          .take(_visibleCommentsCount)
                          .map(
                            (item) => ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              leading: CircleAvatar(
                                backgroundColor: (color.primary as Color).withValues(alpha:0.1),
                                child: Text(
                                  (item.userName ?? "م")[0].toUpperCase(),
                                  style: TextStyle(color: color.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.userName ?? "مستخدم غير معروف",
                                    style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    item.createdAt != null ? "${item.createdAt!.year}/${item.createdAt!.month}/${item.createdAt!.day}" : "",
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: i < item.rating
                                            ? Colors.amber
                                            : Colors.grey[200],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  if (item.comment != null && item.comment!.isNotEmpty)
                                    Text(
                                      item.comment!,
                                      style: const TextStyle(fontSize: 12.0, color: Colors.black87, height: 1.4),
                                    ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_visibleCommentsCount < allComments.length)
                        TextButton.icon(
                          onPressed: () => setState(() => _visibleCommentsCount += 5),
                          icon: const Icon(Icons.expand_more, size: 18),
                          label: const Text("عرض المزيد", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      if (_visibleCommentsCount > 5)
                        TextButton.icon(
                          onPressed: () => setState(() => _visibleCommentsCount = 5),
                          icon: const Icon(Icons.expand_less, size: 18),
                          label: const Text("عرض أقل", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // (fontSize as double)
  Widget _buildSimilarProductCard(dynamic color, dynamic typography, Product similarProduct) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: similarProduct.id)),
        );
      },
      child: Container(
        width: 130.0,
        margin: const EdgeInsets.only(left: Dimens.padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimens.corners),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Dimens.corners),
              ),
              child: similarProduct.mainImage != null
                  ? Image.network(
                      similarProduct.mainImage!.startsWith('http') ? similarProduct.mainImage! : '${ApiConstants.baseUrl}${similarProduct.mainImage}',
                      height: 90.0,
                      width: 130.0,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], height: 90, width: 130),
                    )
                  : Container(
                      height: 90.0,
                      width: 130.0,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    similarProduct.name,
                    style: (typography.bodyMedium as TextStyle).copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${similarProduct.price.toStringAsFixed(2)} ر.س",
                    style: (typography.bodyLarge as TextStyle).copyWith(
                      fontSize: 12.0,
                      color: color.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalImageNetwork(BuildContext context, String path) {
    return GestureDetector(
      onTap: () => _showFullImage(context, path, isNetwork: true),
      child: Container(
        width: 100.0,
        margin: const EdgeInsets.only(left: Dimens.padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.corners),
          image: DecorationImage(
            image: NetworkImage(path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildSellerCard(dynamic typography, dynamic color, Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color.primary as Color).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.primary.withValues(alpha: 0.2),
            child: Icon(Icons.storefront, color: color.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.storeName ?? product.sellerName ?? "اسم المتجر غير متوفر",
                  style: (typography.bodyLarge as TextStyle).copyWith(fontWeight: FontWeight.bold),
                ),
                if (product.sellerPhone != null && product.sellerPhone!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "الهاتف: ${product.sellerPhone}",
                      style: (typography.bodyMedium as TextStyle).copyWith(color: Colors.grey[700]),
                    ),
                  ),
                if (product.storeLocation != null && product.storeLocation!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      product.storeLocation!,
                      style: (typography.bodyMedium as TextStyle).copyWith(color: Colors.grey[600], fontSize: 12),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(dynamic appColor, dynamic appTypography, Product product) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 112.0,
        color: appColor.primary,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${product.price.toStringAsFixed(2)} ر.س",
              style: (appTypography.bodyLarge as TextStyle).copyWith(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(
              width: 222.0,
              child: AppButton(
                title: "أضف إلى السلة",
                onPressed: _addToCart,
                color: Colors.white,
                textStyle: (appTypography.bodyLarge as TextStyle).copyWith(
                  color: appColor.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16.0,
                ),
                iconPath: Assets.icons.shoppingCart,
                iconColor: appColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String path, {bool isNetwork = false}) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: isNetwork ? Image.network(path) : Image.asset(path),
              ),
            ),
            Positioned(
              top: 40.0,
              right: 20.0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30.0),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    if (_product != null) {
      context.read<CartProvider>().addToCart(_product!.id, quantity: 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${_product!.name} تم الاضافة الئ السلة")),
      );
    }
  }
}
