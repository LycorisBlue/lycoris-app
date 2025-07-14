import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lycoris/presentation/widgets/goals_detail_sheet.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/providers/goal_providers.dart';
import '../widgets/app_drawer.dart';
import '../widgets/goals_create_form.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
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
    final goalsAsync = ref.watch(goalNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: "goals"),
      appBar: AppBar(
        title: const Text('Objectifs'),
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
              child: goalsAsync.when(
                loading: () => Row(
                  children: [
                    Expanded(
                      child: _StatItem(value: '-', label: 'Actifs'),
                    ),
                    Container(width: 1, height: 40.h, color: AppColors.border),
                    Expanded(
                      child: _StatItem(value: '-', label: 'Moyen'),
                    ),
                    Container(width: 1, height: 40.h, color: AppColors.border),
                    Expanded(
                      child: _StatItem(value: '-', label: 'Terminés'),
                    ),
                  ],
                ),
                error: (err, stack) => Row(
                  children: [
                    Expanded(
                      child: _StatItem(value: '!', label: 'Erreur'),
                    ),
                    Container(width: 1, height: 40.h, color: AppColors.border),
                    Expanded(
                      child: _StatItem(value: '!', label: 'Erreur'),
                    ),
                    Container(width: 1, height: 40.h, color: AppColors.border),
                    Expanded(
                      child: _StatItem(value: '!', label: 'Erreur'),
                    ),
                  ],
                ),
                data: (goals) {
                  final stats = _calculateStats(goals);
                  return Row(
                    children: [
                      Expanded(
                        child: _StatItem(value: stats['active']!, label: 'Actifs'),
                      ),
                      Container(width: 1, height: 40.h, color: AppColors.border),
                      Expanded(
                        child: _StatItem(value: stats['average']!, label: 'Moyen'),
                      ),
                      Container(width: 1, height: 40.h, color: AppColors.border),
                      Expanded(
                        child: _StatItem(value: stats['completed']!, label: 'Terminés'),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Liste des objectifs
            Expanded(
              child: goalsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.textTertiary, size: 48.sp),
                      SizedBox(height: 16.h),
                      Text(
                        'Erreur lors du chargement',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => ref.refresh(goalNotifierProvider),
                        child: Text('Réessayer', style: TextStyle(color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                data: (goals) {
                  if (goals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.track_changes_outlined, color: AppColors.textTertiary, size: 48.sp),
                          SizedBox(height: 16.h),
                          Text(
                            'Aucun objectif',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Créez votre premier objectif pour commencer',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _GoalItem(
                          title: goal.title,
                          description: goal.description,
                          progress: goal.progress,
                          deadline: _formatDeadline(goal.deadline),
                          icon: _getGoalIcon(goal.title),
                          isCompleted: goal.isCompleted,
                          isOverdue: goal.isOverdue,
                          onTap: () => _viewGoalDetails(goal.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, String> _calculateStats(List<dynamic> goals) {
    if (goals.isEmpty) {
      return {'active': '0', 'average': '0%', 'completed': '0'};
    }

    final active = goals.where((g) => !g.isCompleted).length;
    final completed = goals.where((g) => g.isCompleted).length;
    final avgProgress = goals.map((g) => g.progress).reduce((a, b) => a + b) / goals.length;

    return {'active': active.toString(), 'average': '${(avgProgress * 100).round()}%', 'completed': completed.toString()};
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (difference < 0) {
      return 'En retard';
    } else if (difference == 0) {
      return 'Aujourd\'hui';
    } else if (difference == 1) {
      return 'Demain';
    } else if (difference < 7) {
      return 'Dans $difference jours';
    } else if (difference < 30) {
      final weeks = (difference / 7).round();
      return 'Dans $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      final months = (difference / 30).round();
      return 'Dans $months mois';
    }
  }

  IconData _getGoalIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('flutter') || titleLower.contains('code') || titleLower.contains('dev')) {
      return Icons.code_outlined;
    } else if (titleLower.contains('sport') || titleLower.contains('fitness') || titleLower.contains('kg')) {
      return Icons.fitness_center_outlined;
    } else if (titleLower.contains('livre') || titleLower.contains('lire') || titleLower.contains('lecture')) {
      return Icons.book_outlined;
    } else if (titleLower.contains('piano') || titleLower.contains('musique')) {
      return Icons.music_note_outlined;
    } else {
      return Icons.track_changes_outlined;
    }
  }

  void _addGoal() {
    showDialog(context: context, builder: (context) => const GoalsCreateForm());
  }

  void _viewGoalDetails(String goalId) async {
    // Récupérer l'objectif complet depuis le repository
    final goal = await ref.read(goalRepositoryProvider).getGoalById(goalId);

    if (goal != null && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => GoalsDetailSheet(goal: goal),
      );
    } else {
      // Gestion d'erreur si l'objectif n'est pas trouvé
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Objectif introuvable'), backgroundColor: AppColors.textPrimary));
    }
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

class _GoalItem extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final String deadline;
  final IconData icon;
  final bool isCompleted;
  final bool isOverdue;
  final VoidCallback onTap;

  const _GoalItem({
    required this.title,
    required this.description,
    required this.progress,
    required this.deadline,
    required this.icon,
    required this.isCompleted,
    required this.isOverdue,
    required this.onTap,
  });

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
          border: Border.all(
            color: isOverdue && !isCompleted ? AppColors.textPrimary : AppColors.border,
            width: isOverdue && !isCompleted ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec icône et titre
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
                      Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            if (!isCompleted) ...[
              SizedBox(height: 16.h),

              // Barre de progression
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
                          : isOverdue
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
                            : isOverdue
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
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
