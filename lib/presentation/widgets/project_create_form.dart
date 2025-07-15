/// Widget formulaire de création/édition de projet en popup.
/// Mode création si projectToEdit = null, mode édition sinon.
/// Design épuré avec même fond que projects_screen et marges identiques.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../domain/entities/project.dart';
import '../../data/providers/project_providers.dart';
import '../../data/providers/goal_providers.dart';

class ProjectCreateForm extends ConsumerStatefulWidget {
  final Project? projectToEdit;

  const ProjectCreateForm({super.key, this.projectToEdit});

  @override
  ConsumerState<ProjectCreateForm> createState() => _ProjectCreateFormState();
}

class _ProjectCreateFormState extends ConsumerState<ProjectCreateForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGoalId;
  bool _isLoading = false;

  bool get isEditMode => widget.projectToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Pré-remplir les champs en mode édition
      _titleController.text = widget.projectToEdit!.title;
      _descriptionController.text = widget.projectToEdit!.description;
      _selectedDate = widget.projectToEdit!.deadline;
      _selectedGoalId = widget.projectToEdit!.goalId;
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
    final goalsAsync = ref.watch(activeGoalsProvider);

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
                Icon(isEditMode ? Icons.edit_outlined : Icons.add_circle_outline, color: AppColors.textSecondary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  isEditMode ? 'Modifier le projet' : 'Créer un projet',
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

            // Sélection d'objectif
            Text('Objectif parent', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            goalsAsync.when(
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
                  'Erreur chargement objectifs',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                ),
              ),
              data: (goals) {
                if (goals.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Text(
                      'Aucun objectif actif disponible',
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
                    value: _selectedGoalId,
                    decoration: InputDecoration(
                      hintText: 'Sélectionner un objectif',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                    dropdownColor: AppColors.cardBackground,
                    style: Theme.of(context).textTheme.bodyMedium,
                    items: goals.map((goal) {
                      return DropdownMenuItem<String>(
                        value: goal.id,
                        child: Text(goal.title, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGoalId = value),
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
                  hintText: 'Ex: App TodoList',
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
                  hintText: 'Décrivez votre projet en détail...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Date limite
            Text('Date limite', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              child: Container(
                width: double.infinity,
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
                      _selectedDate != null ? _formatDate(_selectedDate!) : 'Sélectionner une date',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _selectedDate != null ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
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
                    onPressed: _isLoading ? null : _saveProject,
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
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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

  Future<void> _saveProject() async {
    // Validation
    if (_selectedGoalId == null) {
      _showError('Veuillez sélectionner un objectif parent');
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
    if (_selectedDate == null) {
      _showError('La date limite est obligatoire');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEditMode) {
        // Mode édition : mettre à jour le projet existant
        final updatedProject = widget.projectToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          goalId: _selectedGoalId!,
          deadline: _selectedDate!,
        );

        final success = await ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);

        if (success && mounted) {
          Navigator.pop(context);
          _showSuccess('Projet modifié avec succès !');
        } else {
          _showError('Erreur lors de la modification');
        }
      } else {
        // Mode création : créer un nouveau projet
        final projectId = await ref
            .read(projectNotifierProvider.notifier)
            .createProject(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              goalId: _selectedGoalId!,
              deadline: _selectedDate!,
            );

        if (projectId != null && mounted) {
          Navigator.pop(context);
          _showSuccess('Projet créé avec succès !');
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
