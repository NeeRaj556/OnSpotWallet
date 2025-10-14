import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/const/app_constant.dart';
import 'app/config/size_config.dart';
import 'app/providers/app_providers.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/neon_theme.dart';
import 'core/notifiers/theme/theme_notifiers.dart';
import 'core/widgets/connectivity_guard.dart';
import 'init.dart';

void main() async {
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ConnectivityGuard(
      child: MultiProvider(
        providers: AppProvider.providers,
        child: Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, child) {
            // Convert AppThemeMode to ThemeMode
            ThemeMode flutterThemeMode;
            switch (themeNotifier.themeMode.name) {
              case 'light':
                flutterThemeMode = ThemeMode.light;
                break;
              case 'dark':
                flutterThemeMode = ThemeMode.dark;
                break;
              case 'system':
              default:
                flutterThemeMode = ThemeMode.system;
                break;
            }

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: AppConstant.appName,
              routerConfig: router,
              // Electric Blue Theme with dynamic switching
              theme: NeonBlueTheme.lightTheme,
              darkTheme: NeonBlueTheme.darkTheme,
              themeMode: flutterThemeMode, // Dynamic theme switching
            );
          },
        ),
      ),
    );
  }
}
