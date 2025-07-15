import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lycoris/presentation/widgets/task_create_form.dart';
import 'package:lycoris/presentation/widgets/task_detail_sheet.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/providers/task_providers.dart';
import '../../data/providers/project_providers.dart';
import '../../domain/entities/task.dart';
import '../widgets/app_drawer.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> with SingleTickerProviderStateMixin {
  late String _currentTime;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateTime();
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) {
        _updateTime();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final allTasksAsync = ref.watch(taskNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: "tasks"),
      appBar: AppBar(
        title: const Text('Tâches'),
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
              child: allTasksAsync.when(
                loading: () => Row(
                  children: [
                    Expanded(
                      child: _StatItem(value: '-', label: 'À faire'),
                    ),
                    Container(width: 1, height: 40.h, color: AppColors.border),
                    Expanded(
                      child: _StatItem(value: '-', label: 'En cours'),
                    ),
                    Container(width: 1, height: 40.h, color: AppColors.border),
                    Expanded(
                      child: _StatItem(value: '-', label: 'Terminées'),
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
                data: (tasks) => _buildStatsRow(tasks),
              ),
            ),

            // Onglets de filtrage
            Container(
              margin: EdgeInsets.symmetric(horizontal: AppSizes.padding),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorColor: AppColors.textPrimary,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
                tabs: const [
                  Tab(text: 'Aujourd\'hui'),
                  Tab(text: 'Cette semaine'),
                  Tab(text: 'Toutes'),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Liste des tâches avec filtres
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTasksTab(ref.watch(todayTasksProvider), 'aujourd\'hui'),
                  _buildTasksTab(ref.watch(weekTasksProvider), 'cette semaine'),
                  _buildTasksTab(allTasksAsync, 'toutes'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsRow(List<Task> tasks) {
    final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).length;
    final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;

    return Row(
      children: [
        Expanded(
          child: _StatItem(value: todoTasks.toString(), label: 'À faire'),
        ),
        Container(width: 1, height: 40.h, color: AppColors.border),
        Expanded(
          child: _StatItem(value: inProgressTasks.toString(), label: 'En cours'),
        ),
        Container(width: 1, height: 40.h, color: AppColors.border),
        Expanded(
          child: _StatItem(value: completedTasks.toString(), label: 'Terminées'),
        ),
      ],
    );
  }

  Widget _buildTasksTab(AsyncValue<List<Task>> tasksAsync, String tabName) {
    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorState(),
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyState(tabName);
        }
        return _buildTasksList(tasks);
      },
    );
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
            onPressed: () => ref.refresh(taskNotifierProvider),
            child: Text('Réessayer', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_box_outlined, color: AppColors.textTertiary, size: 48.sp),
          SizedBox(height: 16.h),
          Text('Aucune tâche $tabName', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 8.h),
          Text(
            'Créez votre première tâche pour commencer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: _TaskItemWithProject(
            task: task,
            onTap: () => _viewTaskDetails(task.id),
            onStatusChanged: (newStatus) => _updateTaskStatus(task, newStatus),
          ),
        );
      },
    );
  }

  Future<void> _updateTaskStatus(Task task, TaskStatus newStatus) async {
    final success = await ref.read(taskNotifierProvider.notifier).updateTaskStatus(task.id, newStatus);
    if (success) {
      _showMessage('Statut mis à jour');
    } else {
      _showMessage('Erreur lors de la mise à jour');
    }
  }

void _viewTaskDetails(String taskId) async {
    // Récupérer la tâche complète depuis le repository
    final task = await ref.read(taskRepositoryProvider).getTaskById(taskId);

    if (task != null && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => TaskDetailSheet(task: task),
      );
    } else {
      // Gestion d'erreur si la tâche n'est pas trouvée
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tâche introuvable'), backgroundColor: AppColors.textPrimary));
    }
  }

void _addTask() {
    showDialog(context: context, builder: (context) => const TaskCreateForm());
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.textSecondary));
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

class _TaskItemWithProject extends ConsumerWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(TaskStatus) onStatusChanged;

  const _TaskItemWithProject({required this.task, required this.onTap, required this.onStatusChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectsByGoalProvider(''));

    return FutureBuilder(
      future: ref.read(projectRepositoryProvider).getProjectById(task.projectId),
      builder: (context, projectSnapshot) {
        final project = projectSnapshot.data;

        return _TaskItem(
          task: task,
          projectName: project?.title ?? 'Projet inconnu',
          goalName: 'Objectif lié', // Future: récupérer via project.goalId
          onTap: onTap,
          onStatusChanged: onStatusChanged,
        );
      },
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final String projectName;
  final String goalName;
  final VoidCallback onTap;
  final Function(TaskStatus) onStatusChanged;

  const _TaskItem({
    required this.task,
    required this.projectName,
    required this.goalName,
    required this.onTap,
    required this.onStatusChanged,
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
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges hiérarchie
            Row(
              children: [
                // Badge objectif
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(3.r),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    goalName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontSize: 9.sp),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 10.sp),
                SizedBox(width: 4.w),
                // Badge projet
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(3.r),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    projectName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontSize: 9.sp),
                  ),
                ),
                const Spacer(),
                if (task.isUrgent && !task.isCompleted)
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            // Titre avec checkbox
            Row(
              children: [
                GestureDetector(
                  onTap: () => _cycleStatus(),
                  child: _TaskCheckbox(status: task.status),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                      color: _getStatusColor(context),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Footer avec échéance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getDeadlineIcon(), color: _getDeadlineColor(), size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDeadline(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getDeadlineColor(),
                        fontWeight: task.isUrgent ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 14.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _cycleStatus() {
    switch (task.status) {
      case TaskStatus.todo:
        onStatusChanged(TaskStatus.inProgress);
        break;
      case TaskStatus.inProgress:
        onStatusChanged(TaskStatus.completed);
        break;
      case TaskStatus.completed:
        onStatusChanged(TaskStatus.todo);
        break;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (task.status) {
      case TaskStatus.todo:
        return AppColors.textSecondary;
      case TaskStatus.inProgress:
        return AppColors.textPrimary;
      case TaskStatus.completed:
        return AppColors.textTertiary;
    }
  }

  Color _getDeadlineColor() {
    if (task.status == TaskStatus.completed) return AppColors.textTertiary;
    return task.isUrgent ? AppColors.textPrimary : AppColors.textTertiary;
  }

  IconData _getDeadlineIcon() {
    if (task.status == TaskStatus.completed) return Icons.check_circle_outline;
    return Icons.schedule_outlined;
  }

  String _formatDeadline() {
    if (task.deadline == null) return 'Pas d\'échéance';

    final now = DateTime.now();
    final difference = task.deadline!.difference(now).inDays;

    if (difference < 0) {
      return 'En retard';
    } else if (difference == 0) {
      return 'Aujourd\'hui';
    } else if (difference == 1) {
      return 'Demain';
    } else if (difference < 7) {
      return 'Dans $difference jours';
    } else {
      return 'Dans ${(difference / 7).round()} semaines';
    }
  }
}

class _TaskCheckbox extends StatelessWidget {
  final TaskStatus status;

  const _TaskCheckbox({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(color: _getBorderColor(), width: 1.5),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: _getIcon(),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case TaskStatus.todo:
        return Colors.transparent;
      case TaskStatus.inProgress:
        return AppColors.textPrimary.withOpacity(0.2);
      case TaskStatus.completed:
        return AppColors.textPrimary;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.border;
      case TaskStatus.inProgress:
      case TaskStatus.completed:
        return AppColors.textPrimary;
    }
  }

  Widget? _getIcon() {
    switch (status) {
      case TaskStatus.todo:
        return null;
      case TaskStatus.inProgress:
        return Icon(Icons.more_horiz, color: AppColors.textPrimary, size: 12.sp);
      case TaskStatus.completed:
        return Icon(Icons.check, color: AppColors.background, size: 14.sp);
    }
  }
}
