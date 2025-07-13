import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/counter_provider.dart';

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
        return MaterialApp(title: 'MyLife Dashboard', theme: AppTheme.darkTheme, home: const HomeScreen());
      },
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MyLife Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: $count', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () => ref.read(counterProvider.notifier).decrement(), child: const Text('-')),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: () => ref.read(counterProvider.notifier).increment(), child: const Text('+')),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: () => ref.read(counterProvider.notifier).reset(), child: const Text('Reset')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
