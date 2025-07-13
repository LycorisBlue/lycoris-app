import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_routes.dart';
import '../widgets/app_drawer.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
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
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Projets'),
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
        child: Column(
          children: [
            // Section stats en haut
            Container(
              margin: EdgeInsets.all(AppSizes.padding),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(value: '5', label: 'Actifs'),
                  ),
                  Container(width: 1, height: 40.h, color: AppColors.border),
                  Expanded(
                    child: _StatItem(value: '24', label: 'Tâches'),
                  ),
                  Container(width: 1, height: 40.h, color: AppColors.border),
                  Expanded(
                    child: _StatItem(value: '3', label: 'Terminés'),
                  ),
                ],
              ),
            ),

            // Liste des projets
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
                children: [
                  _ProjectItem(
                    title: 'App TodoList',
                    goalName: 'Apprendre Flutter',
                    completedTasks: 6,
                    totalTasks: 8,
                    deadline: 'Dans 3 semaines',
                    isUrgent: false,
                    icon: Icons.phone_android_outlined,
                    onTap: () => AppNavigator.goTo(context, AppRoutes.tasks),
                  ),
                  SizedBox(height: 12.h),
                  _ProjectItem(
                    title: 'App Animations',
                    goalName: 'Apprendre Flutter',
                    completedTasks: 2,
                    totalTasks: 5,
                    deadline: 'Dans 1 mois',
                    isUrgent: false,
                    icon: Icons.animation_outlined,
                    onTap: () => AppNavigator.goTo(context, AppRoutes.tasks),
                  ),
                  SizedBox(height: 12.h),
                  _ProjectItem(
                    title: 'Programme fitness',
                    goalName: 'Perdre 5kg',
                    completedTasks: 3,
                    totalTasks: 5,
                    deadline: 'Dans 1 semaine',
                    isUrgent: true,
                    icon: Icons.fitness_center_outlined,
                    onTap: () => AppNavigator.goTo(context, AppRoutes.tasks),
                  ),
                  SizedBox(height: 12.h),
                  _ProjectItem(
                    title: 'Setup lecture',
                    goalName: 'Lire 12 livres',
                    completedTasks: 3,
                    totalTasks: 3,
                    deadline: 'Terminé',
                    isUrgent: false,
                    icon: Icons.book_outlined,
                    onTap: () => AppNavigator.goTo(context, AppRoutes.tasks),
                  ),
                  SizedBox(height: 12.h),
                  _ProjectItem(
                    title: 'Recherche piano',
                    goalName: 'Apprendre le piano',
                    completedTasks: 1,
                    totalTasks: 4,
                    deadline: 'Dans 2 jours',
                    isUrgent: true,
                    icon: Icons.music_note_outlined,
                    onTap: () => AppNavigator.goTo(context, AppRoutes.tasks),
                  ),
                  SizedBox(height: 80.h), // Espace pour le FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProject(),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addProject() {
    print('Action: Ajouter un nouveau projet');
    // Future: Navigation vers formulaire de création avec sélection d'objectif
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28.sp, fontWeight: FontWeight.w300),
        ),
        SizedBox(height: 4.h),
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

class _ProjectItem extends StatelessWidget {
  final String title;
  final String goalName;
  final int completedTasks;
  final int totalTasks;
  final String deadline;
  final bool isUrgent;
  final IconData icon;
  final VoidCallback onTap;

  const _ProjectItem({
    required this.title,
    required this.goalName,
    required this.completedTasks,
    required this.totalTasks,
    required this.deadline,
    required this.isUrgent,
    required this.icon,
    required this.onTap,
  });

  double get progress => totalTasks > 0 ? completedTasks / totalTasks : 0;
  bool get isCompleted => completedTasks == totalTasks && totalTasks > 0;

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
            // Header avec badge objectif
            Row(
              children: [
                // Badge objectif parent
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    goalName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontSize: 10.sp),
                  ),
                ),
                const Spacer(),
                if (isUrgent && !isCompleted)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            // Titre avec icône
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(6.r)),
                  child: Icon(icon, color: AppColors.textSecondary, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 16.sp,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$completedTasks/$totalTasks tâches',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                if (!isCompleted)
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
              ],
            ),

            if (!isCompleted) ...[
              SizedBox(height: 16.h),

              // Barre de progression (seulement si pas terminé)
              Container(
                height: 6.h,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(3.r)),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(3.r)),
                  ),
                ),
              ),
            ],

            SizedBox(height: 12.h),

            // Footer avec échéance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_outline : Icons.schedule_outlined,
                      color: isCompleted
                          ? AppColors.textSecondary
                          : isUrgent
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      deadline,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isCompleted
                            ? AppColors.textSecondary
                            : isUrgent
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                        fontWeight: isUrgent ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 16.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
