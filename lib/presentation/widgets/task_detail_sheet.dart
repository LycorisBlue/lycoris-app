import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/goal.dart';
import '../../data/providers/task_providers.dart';
import '../../data/providers/project_providers.dart';
import '../../data/providers/goal_providers.dart';
import 'task_create_form.dart';

class TaskDetailSheet extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailSheet({super.key, required this.task});

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(goalByIdProvider('')); // On va récupérer via FutureBuilder

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
                  // Header avec titre et statut
                  _buildHeader(),
                  SizedBox(height: 20.h),

                  // Hiérarchie Objectif → Projet → Tâche
                  _buildHierarchySection(),
                  SizedBox(height: 24.h),

                  // Informations principales
                  _buildMainInfo(),
                  SizedBox(height: 24.h),

                  // Section statut et progression
                  _buildStatusSection(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        // Checkbox de statut
        GestureDetector(
          onTap: () => _cycleStatus(),
          child: _TaskCheckbox(status: widget.task.status),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20.sp,
                  decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                  color: widget.task.isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(_getStatusIcon(), color: _getStatusColor(), size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    widget.task.statusDisplay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getStatusColor()),
                  ),
                  if (widget.task.isUrgent) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(3.r)),
                      child: Text(
                        'URGENT',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.background,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildHierarchySection() {
    return FutureBuilder<Project?>(
      future: ref.read(projectRepositoryProvider).getProjectById(widget.task.projectId),
      builder: (context, projectSnapshot) {
        if (projectSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Center(
              child: Text(
                'Chargement de la hiérarchie...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
              ),
            ),
          );
        }

        final project = projectSnapshot.data;

        return FutureBuilder<Goal?>(
          future: project != null ? ref.read(goalRepositoryProvider).getGoalById(project.goalId) : null,
          builder: (context, goalSnapshot) {
            final goal = goalSnapshot.data;

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
                  Text('Hiérarchie', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  SizedBox(height: 12.h),

                  // Objectif
                  Row(
                    children: [
                      Icon(Icons.track_changes_outlined, color: AppColors.textSecondary, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          goal?.title ?? 'Objectif inconnu',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Flèche
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Icon(Icons.arrow_downward, color: AppColors.textTertiary, size: 16.sp),
                  ),
                  SizedBox(height: 8.h),

                  // Projet
                  Row(
                    children: [
                      Icon(Icons.folder_outlined, color: AppColors.textSecondary, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          project?.title ?? 'Projet inconnu',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Flèche
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Icon(Icons.arrow_downward, color: AppColors.textTertiary, size: 16.sp),
                  ),
                  SizedBox(height: 8.h),

                  // Tâche actuelle
                  Row(
                    children: [
                      Icon(Icons.check_box_outlined, color: AppColors.textPrimary, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
            widget.task.description.isNotEmpty ? widget.task.description : 'Aucune description',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.task.description.isNotEmpty ? AppColors.textSecondary : AppColors.textTertiary,
              fontStyle: widget.task.description.isEmpty ? FontStyle.italic : null,
            ),
          ),

          SizedBox(height: 16.h),
          Container(height: 1, color: AppColors.border),
          SizedBox(height: 16.h),

          // Dates et infos
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Créée le', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(widget.task.createdAt),
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
                      widget.task.deadline != null ? _formatDate(widget.task.deadline!) : 'Aucune',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.task.deadline != null ? AppColors.textSecondary : AppColors.textTertiary,
                        fontStyle: widget.task.deadline == null ? FontStyle.italic : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (widget.task.updatedAt != null) ...[
            SizedBox(height: 12.h),
            Text(
              'Modifiée le ${_formatDate(widget.task.updatedAt!)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
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
          Text('Statut de la tâche', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 16.h),

          // Sélecteurs de statut
          Row(
            children: [
              Expanded(
                child: _StatusButton(
                  status: TaskStatus.todo,
                  isSelected: widget.task.status == TaskStatus.todo,
                  onTap: () => _updateStatus(TaskStatus.todo),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatusButton(
                  status: TaskStatus.inProgress,
                  isSelected: widget.task.status == TaskStatus.inProgress,
                  onTap: () => _updateStatus(TaskStatus.inProgress),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatusButton(
                  status: TaskStatus.completed,
                  isSelected: widget.task.status == TaskStatus.completed,
                  onTap: () => _updateStatus(TaskStatus.completed),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Toggle urgence
          Row(
            children: [
              Text('Tâche urgente', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              const Spacer(),
              Switch(
                value: widget.task.isUrgent,
                onChanged: (value) => _toggleUrgent(value),
                activeColor: AppColors.textPrimary,
                inactiveThumbColor: AppColors.textTertiary,
                inactiveTrackColor: AppColors.border,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Actions secondaires : Modifier, Supprimer
        Row(
          children: [
            // Bouton modifier
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _editTask,
                icon: Icon(Icons.edit_outlined, size: 16.sp, color: AppColors.textSecondary),
                label: Text('Modifier', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Bouton supprimer
            OutlinedButton(
              onPressed: _deleteTask,
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

  IconData _getStatusIcon() {
    switch (widget.task.status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.more_horiz;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  Color _getStatusColor() {
    switch (widget.task.status) {
      case TaskStatus.todo:
        return AppColors.textSecondary;
      case TaskStatus.inProgress:
        return AppColors.textPrimary;
      case TaskStatus.completed:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _cycleStatus() {
    TaskStatus newStatus;
    switch (widget.task.status) {
      case TaskStatus.todo:
        newStatus = TaskStatus.inProgress;
        break;
      case TaskStatus.inProgress:
        newStatus = TaskStatus.completed;
        break;
      case TaskStatus.completed:
        newStatus = TaskStatus.todo;
        break;
    }
    _updateStatus(newStatus);
  }

  Future<void> _updateStatus(TaskStatus newStatus) async {
    if (widget.task.status == newStatus) return;

    setState(() => _isUpdating = true);

    final success = await ref.read(taskNotifierProvider.notifier).updateTaskStatus(widget.task.id, newStatus);

    if (success) {
      _showMessage('Statut mis à jour');
      // Le widget va se reconstruire automatiquement via les providers
    } else {
      _showMessage('Erreur lors de la mise à jour');
    }

    setState(() => _isUpdating = false);
  }

  Future<void> _toggleUrgent(bool value) async {
    final success = await ref.read(taskNotifierProvider.notifier).toggleUrgent(widget.task.id);

    if (success) {
      _showMessage(widget.task.isUrgent ? 'Tâche marquée normale' : 'Tâche marquée urgente');
    } else {
      _showMessage('Erreur lors de la mise à jour');
    }
  }

  void _editTask() {
    Navigator.pop(context); // Fermer le bottom sheet
    showDialog(
      context: context,
      builder: (context) => TaskCreateForm(taskToEdit: widget.task),
    );
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Supprimer la tâche', style: Theme.of(context).textTheme.titleMedium),
        content: Text(
          'Cette action est irréversible. Êtes-vous sûr de vouloir supprimer cette tâche ?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Ferme le dialog

              // Sauvegarder le contexte AVANT de fermer le bottom sheet
              final scaffoldContext = ScaffoldMessenger.of(context);

              Navigator.pop(context); // Ferme le bottom sheet

              // Maintenant on peut supprimer
              final success = await ref.read(taskNotifierProvider.notifier).deleteTask(widget.task.id);

              // Utiliser le contexte sauvegardé pour le message
              if (success) {
                scaffoldContext.showSnackBar(
                  SnackBar(content: Text('Tâche supprimée'), backgroundColor: AppColors.textSecondary),
                );
              } else {
                scaffoldContext.showSnackBar(
                  SnackBar(content: Text('Erreur lors de la suppression'), backgroundColor: AppColors.textPrimary),
                );
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

class _TaskCheckbox extends StatelessWidget {
  final TaskStatus status;

  const _TaskCheckbox({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(color: _getBorderColor(), width: 2),
        borderRadius: BorderRadius.circular(6.r),
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
        return Icon(Icons.more_horiz, color: AppColors.textPrimary, size: 14.sp);
      case TaskStatus.completed:
        return Icon(Icons.check, color: AppColors.background, size: 16.sp);
    }
  }
}

class _StatusButton extends StatelessWidget {
  final TaskStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({required this.status, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: isSelected ? AppColors.textPrimary : AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(_getStatusIcon(), color: isSelected ? AppColors.background : AppColors.textSecondary, size: 20.sp),
            SizedBox(height: 4.h),
            Text(
              status.displayName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? AppColors.background : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.more_horiz;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
    }
  }
}
