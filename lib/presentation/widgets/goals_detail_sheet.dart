import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../domain/entities/goal.dart';
import '../../data/providers/goal_providers.dart';
import 'goals_create_form.dart';

class GoalsDetailSheet extends ConsumerStatefulWidget {
  final Goal goal;

  const GoalsDetailSheet({super.key, required this.goal});

  @override
  ConsumerState<GoalsDetailSheet> createState() => _GoalsDetailSheetState();
}

class _GoalsDetailSheetState extends ConsumerState<GoalsDetailSheet> {
  late double _currentProgress;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.goal.progress;
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildHeader(),
                  SizedBox(height: 20.h),

                  // Informations principales
                  _buildMainInfo(),
                  SizedBox(height: 24.h),

                  // Section progression
                  _buildProgressSection(),
                  SizedBox(height: 24.h),

                  // Section projets liés
                  _buildProjectsSection(),
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
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(6.r)),
          child: Icon(_getGoalIcon(), color: AppColors.textSecondary, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.goal.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20.sp,
                  decoration: widget.goal.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    widget.goal.isCompleted
                        ? Icons.check_circle_outline
                        : widget.goal.isOverdue
                        ? Icons.warning_outlined
                        : Icons.schedule_outlined,
                    color: AppColors.textSecondary,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    widget.goal.status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
          Text(widget.goal.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),

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
                      _formatDate(widget.goal.createdAt),
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
                      _formatDate(widget.goal.deadline),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (widget.goal.updatedAt != null) ...[
            SizedBox(height: 12.h),
            Text(
              'Modifié le ${_formatDate(widget.goal.updatedAt!)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progression', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(
                '${(_currentProgress * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          // Slider de progression (seulement si non terminé)
          if (!widget.goal.isCompleted) ...[
            SizedBox(height: 16.h),
            Slider(
              value: _currentProgress,
              onChanged: (value) => setState(() => _currentProgress = value),
              onChangeEnd: _updateProgress,
              activeColor: AppColors.textPrimary,
              inactiveColor: AppColors.border,
              thumbColor: AppColors.textPrimary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0%', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                Text('100%', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_outlined, color: AppColors.textSecondary, size: 16.sp),
            SizedBox(width: 8.w),
            Text('Projets liés', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton.icon(
              onPressed: _addProject,
              icon: Icon(Icons.add, color: AppColors.textSecondary, size: 16.sp),
              label: Text('Ajouter', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // État "aucun projet" avec design épuré
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: AppColors.border, width: 1, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              Icon(Icons.folder_open_outlined, color: AppColors.textTertiary, size: 32.sp),
              SizedBox(height: 12.h),
              Text(
                'Aucun projet',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4.h),
              Text(
                'Créez des projets pour organiser cet objectif',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    // Si l'objectif est terminé, aucune action disponible
    if (widget.goal.isCompleted) {
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
                'Objectif terminé',
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
        // Bouton marquer comme terminé
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _completeGoal,
            icon: Icon(Icons.check_circle_outline, size: 20.sp),
            label: const Text('Marquer comme terminé'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: AppColors.background,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Actions secondaires : Modifier (large) + Supprimer (icône)
        Row(
          children: [
            // Bouton modifier (prend la place principale)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _editGoal,
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

            // Bouton supprimer (juste icône)
            OutlinedButton(
              onPressed: _deleteGoal,
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

  IconData _getGoalIcon() {
    final titleLower = widget.goal.title.toLowerCase();
    if (titleLower.contains('flutter') || titleLower.contains('code')) {
      return Icons.code_outlined;
    } else if (titleLower.contains('sport') || titleLower.contains('fitness')) {
      return Icons.fitness_center_outlined;
    } else if (titleLower.contains('livre') || titleLower.contains('lire')) {
      return Icons.book_outlined;
    } else if (titleLower.contains('piano') || titleLower.contains('musique')) {
      return Icons.music_note_outlined;
    }
    return Icons.track_changes_outlined;
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _updateProgress(double value) async {
    setState(() => _isUpdating = true);

    final success = await ref.read(goalNotifierProvider.notifier).updateProgress(widget.goal.id, value);

    if (success) {
      _showMessage('Progression mise à jour');
    } else {
      setState(() => _currentProgress = widget.goal.progress);
      _showMessage('Erreur lors de la mise à jour');
    }

    setState(() => _isUpdating = false);
  }

  Future<void> _completeGoal() async {
    final success = await ref.read(goalNotifierProvider.notifier).completeGoal(widget.goal.id);

    if (success) {
      setState(() => _currentProgress = 1.0);
      _showMessage('Objectif terminé !');
    } else {
      _showMessage('Erreur lors de la finalisation');
    }
  }

  void _editGoal() {
    Navigator.pop(context); // Fermer le bottom sheet
    showDialog(
      context: context,
      builder: (context) => GoalsCreateForm(goalToEdit: widget.goal),
    );
  }

  void _deleteGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Supprimer l\'objectif', style: Theme.of(context).textTheme.titleMedium),
        content: Text(
          'Cette action est irréversible. Tous les projets et tâches liés seront également supprimés.',
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

              final success = await ref.read(goalNotifierProvider.notifier).deleteGoal(widget.goal.id);
              if (success) {
                _showMessage('Objectif supprimé');
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

  void _addProject() {
    print('Ajouter projet pour objectif: ${widget.goal.id}');
    // Future: Navigation vers formulaire de création de projet
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.textSecondary));
  }
}
