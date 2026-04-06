import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme.dart';
import 'features/home_feature/presentation/bloc/theme_cubit.dart';
import 'features/home_feature/presentation/screens/splash_screen.dart';
import 'features/home_feature/presentation/screens/home_screen.dart';
import 'features/home_feature/presentation/widgets/login_a_page.dart';
import 'features/home_feature/presentation/widgets/login_m_page.dart';
import 'features/home_feature/presentation/widgets/register_a_page.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:grad_store_app/core/di/injection_container.dart';

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
    
    return MultiProvider(
      providers: InjectionContainer.init(),
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
          '/register': (context) => const RegisterAPage(),
          '/register_a': (context) => const RegisterAPage(),
          '/register_m': (context) => const RegisterAPage(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          // Note: reset_password should usually be navigation via deep link with dynamic route,
          // but if we register it loosely:
          // '/reset_password': (context) => const ResetPasswordScreen(token: ''),
        },
      ),
    );
  }
}
