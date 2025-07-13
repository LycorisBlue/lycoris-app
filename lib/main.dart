import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(ProviderScope(child: const MyLifeApp()));
}

class MyLifeApp extends ConsumerWidget {
  const MyLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(title: 'MyLife Dashboard', debugShowCheckedModeBanner: false, theme: AppTheme.darkTheme, home: const HomeScreen());
      },
    );
  }
}
