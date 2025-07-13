import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/app_drawer.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  late String _currentTime;
  late String _currentSeconds;

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
      _currentSeconds = now.second.toString().padLeft(2, '0');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Outils'),
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
              // Grid principal des outils
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16.w,
                crossAxisSpacing: 16.w,
                childAspectRatio: 1.1,
                children: [
                  // Flip Clock
                  _ToolCard(
                    title: 'Flip Clock',
                    icon: Icons.access_time_outlined,
                    onTap: () => _openFlipClock(),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        Text(
                          _currentTime,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 28.sp, fontWeight: FontWeight.w300, letterSpacing: -1),
                        ),
                        Text(
                          _currentSeconds,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),

                  // Minuteur
                  _ToolCard(
                    title: 'Minuteur',
                    icon: Icons.timer_outlined,
                    onTap: () => _openTimer(),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 50.w,
                              height: 50.w,
                              child: CircularProgressIndicator(
                                value: 0.0, // Pas de timer en cours
                                strokeWidth: 3,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                              ),
                            ),
                            Text(
                              '00:00',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 11.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text('Prêt', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),

                  // Pomodoro
                  _ToolCard(
                    title: 'Pomodoro',
                    icon: Icons.spa_outlined,
                    onTap: () => _openPomodoro(),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PomodoroIndicator(isActive: false),
                            SizedBox(width: 4.w),
                            _PomodoroIndicator(isActive: false),
                            SizedBox(width: 4.w),
                            _PomodoroIndicator(isActive: false),
                            SizedBox(width: 4.w),
                            _PomodoroIndicator(isActive: false),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '25:00',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w400),
                        ),
                        Text('Session 1', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),

                  // Statistiques temps
                  _ToolCard(
                    title: 'Statistiques',
                    icon: Icons.bar_chart_outlined,
                    onTap: () => _openStats(),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatBar(height: 0.4),
                            _StatBar(height: 0.7),
                            _StatBar(height: 0.3),
                            _StatBar(height: 0.9),
                            _StatBar(height: 0.6),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text('4h 32min', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          'Aujourd\'hui',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Actions rapides
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Actions rapides', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp)),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(icon: Icons.edit_outlined, label: 'Note', onTap: () => _quickNote()),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _QuickAction(icon: Icons.add_task_outlined, label: 'Tâche', onTap: () => _quickTask()),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _QuickAction(icon: Icons.alarm_outlined, label: 'Rappel', onTap: () => _quickReminder()),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Utilitaires divers
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Utilitaires', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp)),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _UtilityCard(
                          icon: Icons.calculate_outlined,
                          title: 'Calculatrice',
                          onTap: () => _openCalculator(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _UtilityCard(icon: Icons.qr_code_outlined, title: 'QR Code', onTap: () => _openQRGenerator()),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Actions des outils principaux
  void _openFlipClock() {
    print('Ouverture Flip Clock plein écran');
    // Future: Modal ou nouvelle page avec horloge grande
  }

  void _openTimer() {
    print('Ouverture Minuteur');
    // Future: Modal avec interface timer complète
  }

  void _openPomodoro() {
    print('Ouverture Pomodoro');
    // Future: Interface Pomodoro avec cycles
  }

  void _openStats() {
    print('Ouverture Statistiques temps');
    // Future: Graphiques détaillés
  }

  // Actions rapides
  void _quickNote() {
    print('Action rapide: Nouvelle note');
    // Future: Navigation vers création note
  }

  void _quickTask() {
    print('Action rapide: Nouvelle tâche');
    // Future: Navigation vers création tâche
  }

  void _quickReminder() {
    print('Action rapide: Nouveau rappel');
    // Future: Navigation vers création rappel
  }

  // Utilitaires
  void _openCalculator() {
    print('Ouverture Calculatrice');
    // Future: Interface calculatrice simple
  }

  void _openQRGenerator() {
    print('Ouverture Générateur QR');
    // Future: Interface génération QR codes
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback onTap;

  const _ToolCard({required this.title, required this.icon, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                ),
              ],
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _PomodoroIndicator extends StatelessWidget {
  final bool isActive;

  const _PomodoroIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(color: isActive ? AppColors.textPrimary : AppColors.border, shape: BoxShape.circle),
    );
  }
}

class _StatBar extends StatelessWidget {
  final double height;

  const _StatBar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6.w,
      height: 30.h * height,
      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(3.r)),
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
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _UtilityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _UtilityCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 12.w),
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
