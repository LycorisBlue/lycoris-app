import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_routes.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) {
        _updateTime();
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: "dashboard"),
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(
                _currentTime,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.padding),
          child: Column(
            children: [
              // Section asymétrique : 1 grand bloc + 2 petits verticaux
              SizedBox(
                height: 200.h,
                child: Row(
                  children: [
                    // Bloc principal (moitié gauche)
                    Expanded(
                      flex: 1,
                      child: _MainBlock(title: 'Objectifs', onTap: () => AppNavigator.goTo(context, AppRoutes.goals)),
                    ),
                    SizedBox(width: 12.w),
                    // Colonne des 2 blocs droits
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            child: _SmallBlock(
                              title: 'Tâches',
                              subtitle: '1/3',
                              onTap: () => AppNavigator.goTo(context, AppRoutes.tasks),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Expanded(
                            child: _SmallBlock(
                              title: 'Habitudes',
                              subtitle: '3 jours',
                              onTap: () => AppNavigator.goTo(context, AppRoutes.habits),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Section liste horizontale
              _ListSection(),

              SizedBox(height: 24.h),

              // Section style page d'accueil (3 colonnes)
              _HomeStyleSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainBlock extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MainBlock({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18.sp)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '65%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 48.sp, fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 4.h,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r)),
                  child: FractionallySizedBox(
                    widthFactor: 0.65,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(2.r)),
                    ),
                  ),
                ),
              ],
            ),
            Text('3 objectifs actifs', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _SmallBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SmallBlock({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28.sp, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text('Activité récente', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp)),
        ),
        Column(
          children: [
            _ListItem(title: 'Objectif "Apprendre Flutter" mis à jour', time: 'Il y a 2h', icon: Icons.track_changes_outlined),
            _ListItem(title: 'Tâche "Réviser le code" terminée', time: 'Il y a 3h', icon: Icons.check_circle_outline),
            _ListItem(title: 'Nouvelle note "Idées projet" ajoutée', time: 'Hier', icon: Icons.note_add_outlined),
          ],
        ),
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const _ListItem({required this.title, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 2.h),
                Text(time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeStyleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text('Actions rapides', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp)),
        ),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.edit_outlined,
                label: 'Note',
                onTap: () => AppNavigator.goTo(context, AppRoutes.notes),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _QuickAction(
                icon: Icons.add_task_outlined,
                label: 'Tâche',
                onTap: () => AppNavigator.goTo(context, AppRoutes.tasks),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _QuickAction(
                icon: Icons.alarm_outlined,
                label: 'Rappel',
                onTap: () => AppNavigator.goTo(context, AppRoutes.reminders),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24.sp),
            SizedBox(height: 8.h),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}