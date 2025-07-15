import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lycoris/presentation/widgets/project_detail_sheet.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/providers/project_providers.dart';
import '../../data/providers/task_providers.dart';
import '../../data/providers/goal_providers.dart';
import '../../domain/entities/project.dart';
import '../widgets/app_drawer.dart';
import '../widgets/project_create_form.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
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
    final projectsAsync = ref.watch(projectNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: "projects"),
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
              child: projectsAsync.when(
                loading: () => Row(
                  children: [
                    Expanded(
                      child: _StatItem(value: '-', label: 'Actifs'),
                    ),
                    Container(width: 1, height: 40.h, color: AppColors.border),
                    Expanded(
                      child: _StatItem(value: '-', label: 'Tâches'),
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
                data: (projects) => _buildStatsRow(projects),
              ),
            ),

            // Liste des projets
            Expanded(
              child: projectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildErrorState(),
                data: (projects) {
                  if (projects.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildProjectsList(projects);
                },
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

  Widget _buildStatsRow(List<Project> projects) {
    final activeProjects = projects.where((p) => !p.isCompleted).length;
    final completedProjects = projects.where((p) => p.isCompleted).length;

    // Pour calculer le total des tâches, on utilise un FutureBuilder
    return FutureBuilder<int>(
      future: _calculateTotalTasks(projects),
      builder: (context, snapshot) {
        final totalTasks = snapshot.data ?? 0;

        return Row(
          children: [
            Expanded(
              child: _StatItem(value: activeProjects.toString(), label: 'Actifs'),
            ),
            Container(width: 1, height: 40.h, color: AppColors.border),
            Expanded(
              child: _StatItem(value: totalTasks.toString(), label: 'Tâches'),
            ),
            Container(width: 1, height: 40.h, color: AppColors.border),
            Expanded(
              child: _StatItem(value: completedProjects.toString(), label: 'Terminés'),
            ),
          ],
        );
      },
    );
  }

  Future<int> _calculateTotalTasks(List<Project> projects) async {
    int total = 0;
    for (final project in projects) {
      try {
        final tasks = await ref.read(tasksByProjectProvider(project.id).future);
        total += tasks.length;
      } catch (e) {
        // Ignore les erreurs pour un projet spécifique
      }
    }
    return total;
  }

  Widget _buildErrorState() {
    return Center(
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
            onPressed: () => ref.refresh(projectNotifierProvider),
            child: Text('Réessayer', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, color: AppColors.textTertiary, size: 48.sp),
          SizedBox(height: 16.h),
          Text('Aucun projet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 8.h),
          Text(
            'Créez votre premier projet pour commencer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(List<Project> projects) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _ProjectItemWithTasks(project: project, onTap: () => _viewProjectDetails(project.id)),
        );
      },
    );
  }

  void _addProject() {
    showDialog(context: context, builder: (context) => const ProjectCreateForm());
  }

void _viewProjectDetails(String projectId) async {
    // Récupérer le projet complet depuis le repository
    final project = await ref.read(projectRepositoryProvider).getProjectById(projectId);

    if (project != null && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ProjectDetailSheet(project: project),
      );
    } else {
      // Gestion d'erreur si le projet n'est pas trouvé
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Projet introuvable'), backgroundColor: AppColors.textPrimary));
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

class _ProjectItemWithTasks extends ConsumerWidget {
  final Project project;
  final VoidCallback onTap;

  const _ProjectItemWithTasks({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByProjectProvider(project.id));

    return tasksAsync.when(
      loading: () => _ProjectItemWithGoal(project: project, completedTasks: 0, totalTasks: 0, onTap: onTap),
      error: (err, stack) => _ProjectItemWithGoal(project: project, completedTasks: 0, totalTasks: 0, onTap: onTap),
      data: (tasks) {
        final completedTasks = tasks.where((t) => t.isCompleted).length;
        return _ProjectItemWithGoal(project: project, completedTasks: completedTasks, totalTasks: tasks.length, onTap: onTap);
      },
    );
  }
}

class _ProjectItemWithGoal extends ConsumerWidget {
  final Project project;
  final int completedTasks;
  final int totalTasks;
  final VoidCallback onTap;

  const _ProjectItemWithGoal({
    required this.project,
    required this.completedTasks,
    required this.totalTasks,
    required this.onTap,
  });

  double get progress => totalTasks > 0 ? completedTasks / totalTasks : 0;
  bool get isCompleted => project.isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalByIdProvider(project.goalId));

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
            // Header avec badge objectif DYNAMIQUE
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: goalAsync.when(
                    loading: () => Text(
                      'Chargement...',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontSize: 10.sp),
                    ),
                    error: (err, stack) => Text(
                      'Objectif inconnu',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontSize: 10.sp),
                    ),
                    data: (goal) => Text(
                      goal?.title ?? 'Objectif supprimé',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontSize: 10.sp),
                    ),
                  ),
                ),
                const Spacer(),
                if (project.isOverdue && !isCompleted)
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
                  child: Icon(_getProjectIcon(), color: AppColors.textSecondary, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
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
                          : project.isOverdue
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDeadline(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isCompleted
                            ? AppColors.textSecondary
                            : project.isOverdue
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                        fontWeight: project.isOverdue ? FontWeight.w600 : FontWeight.w400,
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

  IconData _getProjectIcon() {
    final titleLower = project.title.toLowerCase();
    if (titleLower.contains('app') || titleLower.contains('flutter') || titleLower.contains('dev')) {
      return Icons.phone_android_outlined;
    } else if (titleLower.contains('fitness') || titleLower.contains('sport')) {
      return Icons.fitness_center_outlined;
    } else if (titleLower.contains('livre') || titleLower.contains('lecture')) {
      return Icons.book_outlined;
    } else if (titleLower.contains('piano') || titleLower.contains('musique')) {
      return Icons.music_note_outlined;
    }
    return Icons.folder_outlined;
  }

  String _formatDeadline() {
    if (isCompleted) return 'Terminé';

    final now = DateTime.now();
    final difference = project.deadline.difference(now).inDays;

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
}
