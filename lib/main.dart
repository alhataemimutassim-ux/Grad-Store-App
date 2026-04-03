import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_store_app/features/cart_feature/data/data_source/local/fake_products.dart';
import 'package:grad_store_app/features/cart_feature/presentation/bloc/cart_cubit.dart';
import 'core/theme/theme.dart';
import 'features/home_feature/presentation/bloc/theme_cubit.dart';
import 'features/favorites_feature/presentation/favorites_cubit.dart';
import 'features/home_feature/presentation/screens/splash_screen.dart';
import 'features/home_feature/presentation/screens/home_screen.dart';
import 'features/home_feature/presentation/widgets/login_a_page.dart';
import 'features/home_feature/presentation/widgets/login_m_page.dart';
import 'features/home_feature/presentation/widgets/register_m_page.dart';
import 'features/home_feature/presentation/widgets/register_a_page.dart'
    as register_a;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (final BuildContext context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode?>(
        builder: (final BuildContext context, final ThemeMode? themeMode) {
          return App(themeMode: themeMode);
        },
      ),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key, this.themeMode});

  final ThemeMode? themeMode;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  CartCubit()
                    ..loadCart()
                    ..addItem(FakeProducts.products[0])
                    ..addItem(FakeProducts.products[1])
                    ..addItem(FakeProducts.products[4])
                    ..addItem(FakeProducts.products[6]),
        ),
        BlocProvider(create: (context) => FavoritesCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/login_a': (context) => const LoginaPage(),
          '/login_m': (context) => const LoginMPage(),
          '/register': (context) => RegisterMPage(),
          '/register_a': (context) => register_a.RegisterAPage(),
        },
      ),
    );
  }
}
