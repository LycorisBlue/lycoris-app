import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_routes.dart';

void main() {
  runApp(const ProviderScope(child: MyLifeApp()));
}

class MyLifeApp extends ConsumerWidget {
  const MyLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Lycoris',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,

          // Configuration du routing
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRouter.generateRoute,

          // Gestion des routes inconnues
          onUnknownRoute: (settings) => AppPageRoute(child: const NotFoundScreen()),
        );
      },
    );
  }
}
