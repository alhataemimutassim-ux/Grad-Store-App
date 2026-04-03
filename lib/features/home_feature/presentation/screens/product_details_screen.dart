import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/sized_context.dart';
import 'package:grad_store_app/core/widgets/app_button.dart ';
import 'package:grad_store_app/core/widgets/app_choice_chip.dart';
import 'package:grad_store_app/core/widgets/app_icon_buttons.dart';
import 'package:grad_store_app/core/widgets/app_read_more_text.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/rate_widget.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/user_profile_image.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:grad_store_app/core/widgets/app_svg_viewer.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/theme/dimens.dart';
import '../../../cart_feature/data/data_source/local/fake_products.dart';
import '../../../cart_feature/presentation/bloc/cart_cubit.dart';
import '../../data/data_source/local/sample_data.dart';
import '../widgets/product_details_app_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedWeight = weights[4];
  final product = FakeProducts.products[2];
  int _userSelectedRating = 5;
  int _visibleCommentsCount = 0;

  @override
  Widget build(BuildContext context) {
    final appColor = context.theme.appColors;
    final appTypography = context.theme.appTypography;

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
              child: Assets.images.bigCake.image(
                width: context.widthPx,
                height: context.heightPx * 0.45,
                fit: BoxFit.cover,
              ),
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
                          Text(
                            "جهاز مراقبة طبي",
                            style: (appTypography.bodyLarge as TextStyle)
                                .copyWith(fontSize: 18.0),
                          ),
                          RateWidget(rate: "9.10"),
                        ],
                      ),
                      const SizedBox(height: Dimens.largePadding),
                      AppReadMoreText(productDescription),

                      const Divider(height: Dimens.largePadding * 2),

                      //(تفاعلية)
                      Text(
                        "صور إضافية",
                        style: (appTypography.bodyLarge as TextStyle).copyWith(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: Dimens.padding),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) =>
                              _buildAdditionalImage(context),
                        ),
                      ),

                      const Divider(height: Dimens.largePadding * 2),

                      // (Stars UI)
                      _buildRatingSection(appTypography, appColor),

                      const Divider(height: Dimens.largePadding * 2),

                      // ( قسم التعليقات)
                      _buildExpandableComments(appTypography, appColor),

                      const Divider(height: Dimens.largePadding * 2),

                      // قسم منتجات مشابهة
                      Text(
                        "منتجات مشابهة",
                        style: (appTypography.bodyLarge as TextStyle).copyWith(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Dimens.padding),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) =>
                              _buildSimilarProductCard(appColor, appTypography),
                        ),
                      ),

                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ),

            // 4. زر السلة الثابت
            _buildStickyBottomBar(appColor, appTypography),
          ],
        ),
      ),
    );
  }

  // (fontSize as double)

  Widget _buildRatingSection(dynamic typography, dynamic color) {
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
                    "4.3",
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
                      (index) => GestureDetector(
                        onTap: () =>
                            setState(() => _userSelectedRating = index + 1),
                        child: Icon(
                          Icons.star_rounded,
                          color: index < _userSelectedRating
                              ? Colors.amber
                              : Colors.grey[300],
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "128 مراجعة",
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
                  _buildRatingBar("5", 0.85),
                  _buildRatingBar("4", 0.10),
                  _buildRatingBar("3", 0.03),
                  _buildRatingBar("2", 0.01),
                  _buildRatingBar("1", 0.01),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final List<Map<String, String>> allComments = List.generate(
      20,
      (index) => {
        "name": "العميل المتميز ${index + 1}",
        "comment":
            "المنتج جبار ورهيب، التغليف ممتاز جداً والجودة فاخرة.. يستحق التقييم الكامل! ✨",
        "date": "منذ ${index + 1} أيام",
        "rating": "${(index % 2 == 0) ? 5 : 4}",
        "likes": "${(index * 2) + 7}",
      },
    );

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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "أضف رأيك الفخم هنا...",
                  hintStyle: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                  // أيقونة الإرسال في اليسار تلقائياً بسبب الـ RTL
                  prefixIcon: IconButton(
                    icon: Icon(Icons.send_rounded, color: color.primary),
                    onPressed: () {},
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // (عرض المزيد / عرض أقل)
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  ...allComments
                      .take(_visibleCommentsCount)
                      .map(
                        (item) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: (color.primary as Color)
                                .withOpacity(0.1),
                            child: Text(
                              item['name']![0],
                              style: TextStyle(
                                color: color.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['name']!,
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item['date']!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
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
                                    color: i < int.parse(item['rating']!)
                                        ? Colors.amber
                                        : Colors.grey[200],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item['comment']!,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    item['likes']!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.thumb_up_alt_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
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
                      onPressed: () =>
                          setState(() => _visibleCommentsCount += 5),
                      icon: const Icon(Icons.expand_more, size: 18),
                      label: const Text(
                        "عرض المزيد",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (_visibleCommentsCount > 5)
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _visibleCommentsCount -= 5),
                      icon: const Icon(Icons.expand_less, size: 18),
                      label: const Text(
                        "عرض أقل",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
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

  // (fontSize as double)
  Widget _buildSimilarProductCard(dynamic color, dynamic typography) {
    return Container(
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
            child: Assets.images.bigCake.image(
              height: 90.0,
              width: 130.0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "منتج طبي",
                  style: (typography.bodyMedium as TextStyle).copyWith(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                Text(
                  "\$45.0",
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
    );
  }

  Widget _buildAdditionalImage(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(context, Assets.images.bigCake.path),
      child: Container(
        width: 100.0,
        margin: const EdgeInsets.only(left: Dimens.padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.corners),
          image: DecorationImage(
            image: Assets.images.bigCake.provider(),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(dynamic appColor, dynamic appTypography) {
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
              "\$50.00",
              style: (appTypography.bodyLarge as TextStyle).copyWith(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(
              width: 222.0,
              child: AppButton(
                title: "اضف الئ السلة",
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

  void _showFullImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        body: Stack(
          children: [
            Center(child: InteractiveViewer(child: Image.asset(path))),
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
    context.read<CartCubit>().addItem(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product.name} تم الاضافة الئ السلة")),
    );
  }
}
