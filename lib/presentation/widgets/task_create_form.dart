/// Widget formulaire de création/édition de tâche en popup.
/// Mode création si taskToEdit = null, mode édition sinon.
/// Design épuré avec même fond que tasks_screen et marges identiques.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../domain/entities/task.dart';
import '../../data/providers/task_providers.dart';
import '../../data/providers/project_providers.dart';

class TaskCreateForm extends ConsumerStatefulWidget {
  final Task? taskToEdit;

  const TaskCreateForm({super.key, this.taskToEdit});

  @override
  ConsumerState<TaskCreateForm> createState() => _TaskCreateFormState();
}

class _TaskCreateFormState extends ConsumerState<TaskCreateForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedProjectId;
  bool _isUrgent = false;
  bool _isLoading = false;

  bool get isEditMode => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Pré-remplir les champs en mode édition
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description;
      _selectedDate = widget.taskToEdit!.deadline;
      _selectedProjectId = widget.taskToEdit!.projectId;
      _isUrgent = widget.taskToEdit!.isUrgent;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(activeProjectsProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(AppSizes.padding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(isEditMode ? Icons.edit_outlined : Icons.add_task_outlined, color: AppColors.textSecondary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  isEditMode ? 'Modifier la tâche' : 'Créer une tâche',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18.sp),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColors.textSecondary, size: 20.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Sélection de projet
            Text('Projet parent', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            projectsAsync.when(
              loading: () => Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Text(
                  'Chargement...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                ),
              ),
              error: (err, stack) => Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Text(
                  'Erreur chargement projets',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                ),
              ),
              data: (projects) {
                if (projects.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Text(
                      'Aucun projet actif disponible',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedProjectId,
                    decoration: InputDecoration(
                      hintText: 'Sélectionner un projet',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                    dropdownColor: AppColors.cardBackground,
                    style: Theme.of(context).textTheme.bodyMedium,
                    items: projects.map((project) {
                      return DropdownMenuItem<String>(
                        value: project.id,
                        child: Text(
                          project.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedProjectId = value),
                  ),
                );
              },
            ),

            SizedBox(height: 16.h),

            // Titre
            Text('Titre', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: TextField(
                controller: _titleController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Ex: Créer interface principale',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Description
            Text('Description', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Décrivez la tâche en détail...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Date limite (optionnelle)
            Text(
              'Date limite (optionnelle)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: AppColors.textTertiary, size: 16.sp),
                          SizedBox(width: 8.w),
                          Text(
                            _selectedDate != null ? _formatDate(_selectedDate!) : 'Aucune échéance',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _selectedDate != null ? AppColors.textPrimary : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_selectedDate != null) ...[
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: () => setState(() => _selectedDate = null),
                    icon: Icon(Icons.clear, color: AppColors.textTertiary, size: 16.sp),
                  ),
                ],
              ],
            ),

            SizedBox(height: 16.h),

            // Urgence
            Row(
              children: [
                Text('Tâche urgente', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Switch(
                  value: _isUrgent,
                  onChanged: (value) => setState(() => _isUrgent = value),
                  activeColor: AppColors.textPrimary,
                  inactiveThumbColor: AppColors.textTertiary,
                  inactiveTrackColor: AppColors.border,
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Annuler',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
                            ),
                          )
                        : Text(
                            isEditMode ? 'Modifier' : 'Créer',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.background),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.textPrimary, surface: AppColors.cardBackground),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _saveTask() async {
    // Validation
    if (_selectedProjectId == null) {
      _showError('Veuillez sélectionner un projet parent');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showError('Le titre est obligatoire');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showError('La description est obligatoire');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEditMode) {
        // Mode édition : mettre à jour la tâche existante
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          projectId: _selectedProjectId!,
          deadline: _selectedDate,
          isUrgent: _isUrgent,
        );

        final success = await ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);

        if (success && mounted) {
          Navigator.pop(context);
          _showSuccess('Tâche modifiée avec succès !');
        } else {
          _showError('Erreur lors de la modification');
        }
      } else {
        // Mode création : créer une nouvelle tâche
        final taskId = await ref
            .read(taskNotifierProvider.notifier)
            .createTask(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              projectId: _selectedProjectId!,
              deadline: _selectedDate,
              isUrgent: _isUrgent,
            );

        if (taskId != null && mounted) {
          Navigator.pop(context);
          _showSuccess('Tâche créée avec succès !');
        } else {
          _showError('Erreur lors de la création');
        }
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.textPrimary));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.textSecondary));
  }
}
