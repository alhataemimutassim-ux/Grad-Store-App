import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/app_svg_viewer.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/tabs/cart_tab.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/tabs/orders_tab.dart';
import 'package:grad_store_app/features/home_feature/presentation/widgets/tabs/profile_tab.dart ';
import 'package:grad_store_app/features/home_feature/presentation/widgets/tabs/home_tab.dart';

import '../../../../core/gen/assets.gen.dart';
import '../bloc/bottom_navigation_cubit.dart';
import '../widgets/home_app_bar.dart';
import '../screens/add_product_page.dart';

class HomeScreen extends StatelessWidget {
  final bool isVendor;
  const HomeScreen({super.key, this.isVendor = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BottomNavigationCubit>(
      create: (context) => BottomNavigationCubit(),
      child: _HomeScreen(isVendor: isVendor),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  final bool isVendor;
  const _HomeScreen({required this.isVendor});

  @override
  Widget build(BuildContext context) {
    final watch = context.watch<BottomNavigationCubit>();
    final read = context.read<BottomNavigationCubit>();
    final Color primaryAppColor = const Color(0xFF21776C); // لونك الخاص المعتمد

    final List<Widget> tabs = [
      const HomeTab(),
      const CartTab(),
      const OrdersTab(),
      const ProfileTab(),
    ];

    return AppScaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: watch.state.selectedIndex == 0 ? HomeAppBar() : null,
      body: tabs[watch.state.selectedIndex],
      padding: EdgeInsets.zero,
      bottomNavigationBar: CustomSpotLightNavigationBar(
        watch: watch,
        read: read,
        primaryColor: primaryAppColor,
        isVendor: isVendor,
      ),
    );
  }
}

class CustomSpotLightNavigationBar extends StatelessWidget {
  final dynamic watch;
  final dynamic read;
  final Color primaryColor;
  final bool isVendor;

  const CustomSpotLightNavigationBar({
    super.key, 
    required this.watch, 
    required this.read, 
    required this.primaryColor,
    required this.isVendor
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> navIcons = [
      Assets.icons.home2,
      Assets.icons.shoppingCart,
      Assets.icons.receipt,
      Assets.icons.user,
    ];

    return Container(
      color: Colors.transparent, 
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            //(Glow Effect)
            BoxShadow(
              color: primaryColor.withOpacity(0.15), // شفافية عالية للظل ليكون ناعم
              blurRadius: 20, // تشتت واسع للظل
              spreadRadius: 2, // انتشار بسيط
              offset: const Offset(0, 8), // إزاحة للأسفل ليعطي عمق
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, navIcons[0]),
            _buildNavItem(1, navIcons[1]),
            
            if (isVendor) 
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage())),
                child: Icon(Icons.add_circle_outline, color: Colors.grey[400], size: 30),
              ),

            _buildNavItem(2, navIcons[2]),
            _buildNavItem(3, navIcons[3]),
          ],
        ),
      ),
    );
  }



  Widget _buildNavItem(int index, dynamic asset) {
    bool isActive = watch.state.selectedIndex == index;

    return GestureDetector(
      onTap: () => read.onItemTap(index: index),
      child: SizedBox(
        width: 55,
        child: Column(
          children: [
            // الخط العلوي المضيء
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              width: isActive ? 28 : 0,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow:
                    isActive
                        ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ]
                        : [],
              ),
            ),

            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // رسم الإضاءة المخروطية (Spotlight) بدقة الصورة
                  if (isActive)
                    CustomPaint(
                      size: const Size(50, double.infinity),
                      painter: LightSpotPainter(color: primaryColor),
                    ),

                  // الأيقونة بلونك الجديد #21776C
                  AppSvgViewer(
                    asset,
                    color: isActive ? primaryColor : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// كلاس لرسم الإضاءة بشكل مخروطي (Trapezoid) متلاشي
class LightSpotPainter extends CustomPainter {
  final Color color;
  LightSpotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.25), // تبدأ الإضاءة خفيفة من الأعلى
              Colors.transparent, // وتتلاشى تماماً للأسفل
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    // رسم شكل مخروطي (يبدأ ضيق من الأعلى ويتوسع للأسفل مثل كشاف الضوء)
    path.moveTo(size.width * 0.35, 0); // الزاوية العلوية اليسرى
    path.lineTo(size.width * 0.65, 0); // الزاوية العلوية اليمنى
    path.lineTo(size.width * 0.9, size.height * 0.8); // الزاوية السفلية اليمنى
    path.lineTo(size.width * 0.1, size.height * 0.8); // الزاوية السفلية اليسرى
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
