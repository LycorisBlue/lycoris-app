import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lycoris/domain/entities/goal.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_routes.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../../data/providers/project_providers.dart';
import '../../data/providers/task_providers.dart';
import '../../data/providers/goal_providers.dart';
import 'project_create_form.dart';

class ProjectDetailSheet extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailSheet({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailSheet> createState() => _ProjectDetailSheetState();
}

class _ProjectDetailSheetState extends ConsumerState<ProjectDetailSheet> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksByProjectProvider(widget.project.id));
    final goalAsync = ref.watch(goalByIdProvider(widget.project.goalId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.borderRadius * 2),
          topRight: Radius.circular(AppSizes.borderRadius * 2),
        ),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Handle du bottom sheet
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r)),
          ),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec titre et actions
                  _buildHeader(goalAsync),
                  SizedBox(height: 20.h),

                  // Informations principales
                  _buildMainInfo(),
                  SizedBox(height: 24.h),

                  // Section progression basée sur les tâches
                  _buildProgressSection(tasksAsync),
                  SizedBox(height: 24.h),

                  // Section tâches du projet
                  _buildTasksSection(tasksAsync),
                  SizedBox(height: 24.h),

                  // Actions principales
                  _buildActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AsyncValue<Goal?> goalAsync) {
    return Row(
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
                widget.project.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20.sp,
                  decoration: widget.project.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    widget.project.isCompleted
                        ? Icons.check_circle_outline
                        : widget.project.isOverdue
                        ? Icons.warning_outlined
                        : Icons.schedule_outlined,
                    color: AppColors.textSecondary,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    widget.project.status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(width: 8.w),
                  Text('•', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                  SizedBox(width: 8.w),
                  goalAsync.when(
                    loading: () =>
                        Text('...', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                    error: (err, stack) => Text(
                      'Objectif inconnu',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                    ),
                    data: (goal) => Text(
                      goal?.title ?? 'Objectif supprimé',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: AppColors.textSecondary, size: 20.sp),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildMainInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text('Description', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Text(
            widget.project.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),

          SizedBox(height: 16.h),
          Container(height: 1, color: AppColors.border),
          SizedBox(height: 16.h),

          // Dates
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Créé le', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(widget.project.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Échéance', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(widget.project.deadline),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (widget.project.updatedAt != null) ...[
            SizedBox(height: 12.h),
            Text(
              'Modifié le ${_formatDate(widget.project.updatedAt!)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection(AsyncValue<List<Task>> tasksAsync) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progression', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 16.h),

          tasksAsync.when(
            loading: () => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Chargement...', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                    Text('-%', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18.sp)),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  height: 6.h,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(3.r)),
                ),
              ],
            ),
            error: (err, stack) => Text(
              'Erreur lors du chargement des tâches',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
            ),
            data: (tasks) {
              final completedTasks = tasks.where((t) => t.isCompleted).length;
              final totalTasks = tasks.length;
              final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completedTasks sur $totalTasks tâches terminées',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(AsyncValue<List<Task>> tasksAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_box_outlined, color: AppColors.textSecondary, size: 16.sp),
            SizedBox(width: 8.w),
            Text('Tâches du projet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton.icon(
              onPressed: _addTask,
              icon: Icon(Icons.add, color: AppColors.textSecondary, size: 16.sp),
              label: Text('Ajouter', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        tasksAsync.when(
          loading: () => Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Center(
              child: Text(
                'Chargement des tâches...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
          error: (err, stack) => Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Center(
              child: Text(
                'Erreur lors du chargement',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined, color: AppColors.textTertiary, size: 32.sp),
                    SizedBox(height: 12.h),
                    Text(
                      'Aucune tâche',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Créez des tâches pour organiser ce projet',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: tasks
                  .map(
                    (task) => _TaskItem(
                      task: task,
                      onTap: () => _viewTaskDetails(task),
                      onStatusChanged: (newStatus) => _updateTaskStatus(task, newStatus),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions() {
    // Si le projet est terminé, aucune action de modification disponible
    if (widget.project.isCompleted) {
      return SizedBox(
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.textSecondary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Projet terminé',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Bouton voir toutes les tâches
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _viewAllTasks,
            icon: Icon(Icons.list_alt_outlined, size: 20.sp),
            label: const Text('Voir toutes les tâches'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: AppColors.background,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Actions secondaires : Modifier, Terminer, Supprimer
        Row(
          children: [
            // Bouton modifier
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _editProject,
                icon: Icon(Icons.edit_outlined, size: 16.sp, color: AppColors.textSecondary),
                label: Text('Modifier', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Bouton terminer
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _completeProject,
                icon: Icon(Icons.check_circle_outline, size: 16.sp, color: AppColors.textSecondary),
                label: Text('Terminer', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Bouton supprimer (juste icône)
            OutlinedButton(
              onPressed: _deleteProject,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.border),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                minimumSize: Size(40.w, 40.h),
              ),
              child: Icon(Icons.delete_outline, size: 16.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getProjectIcon() {
    final titleLower = widget.project.title.toLowerCase();
    if (titleLower.contains('app') || titleLower.contains('flutter')) {
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

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _viewAllTasks() {
    Navigator.pop(context); // Fermer le bottom sheet
    Navigator.pushNamed(context, AppRoutes.tasks, arguments: {'projectId': widget.project.id});
  }

  void _addTask() {
    print('Ajouter tâche pour projet: ${widget.project.id}');
    // Future: Navigation vers formulaire de création de tâche
  }

  void _viewTaskDetails(Task task) {
    print('Voir détails tâche: ${task.title}');
    // Future: Navigation vers détails de la tâche
  }

  Future<void> _updateTaskStatus(Task task, TaskStatus newStatus) async {
    final success = await ref.read(taskNotifierProvider.notifier).updateTaskStatus(task.id, newStatus);
    if (success) {
      _showMessage('Statut de tâche mis à jour');
      // Les providers vont automatiquement se rafraîchir
    } else {
      _showMessage('Erreur lors de la mise à jour');
    }
  }

Future<void> _completeProject() async {
    final success = await ref.read(projectNotifierProvider.notifier).completeProject(widget.project.id);
  }

void _editProject() {
    Navigator.pop(context); // Fermer le bottom sheet
    showDialog(
      context: context,
      builder: (context) => ProjectCreateForm(projectToEdit: widget.project),
    );
  }

  void _deleteProject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Supprimer le projet', style: Theme.of(context).textTheme.titleMedium),
        content: Text(
          'Cette action est irréversible. Toutes les tâches liées seront également supprimées.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context);

              final success = await ref.read(projectNotifierProvider.notifier).deleteProject(widget.project.id);
              if (success) {
                _showMessage('Projet supprimé');
              } else {
                _showMessage('Erreur lors de la suppression');
              }
            },
            child: Text('Supprimer', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.textSecondary));
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(TaskStatus) onStatusChanged;

  const _TaskItem({required this.task, required this.onTap, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Row(
          children: [
            // Checkbox de statut
            GestureDetector(
              onTap: () => _cycleStatus(),
              child: _TaskCheckbox(status: task.status),
            ),
            SizedBox(width: 12.w),
            // Contenu de la tâche
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Indicateurs
            if (task.isUrgent)
              Container(
                margin: EdgeInsets.only(left: 8.w),
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
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
