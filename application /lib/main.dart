import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/const/app_constant.dart';
import 'app/config/size_config.dart';
import 'app/providers/app_providers.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/neon_theme.dart';
import 'core/notifiers/theme/theme_notifiers.dart';
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
    return MultiProvider(
      providers: AppProvider.providers,
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: AppConstant.appName,
            routerConfig: router,
            // Use Neon Blue Theme
            theme: NeonBlueTheme.lightTheme,
            darkTheme: NeonBlueTheme.lightTheme, // Keep neon for dark mode too
            themeMode: ThemeMode.light, // Always use light with neon theme
          );
        },
      ),
    );
  }
}
