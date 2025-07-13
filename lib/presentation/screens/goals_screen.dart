import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/app_drawer.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
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
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(value: '3', label: 'Actifs'),
                  ),
                  Container(width: 1, height: 40.h, color: AppColors.border),
                  Expanded(
                    child: _StatItem(value: '65%', label: 'Moyen'),
                  ),
                  Container(width: 1, height: 40.h, color: AppColors.border),
                  Expanded(
                    child: _StatItem(value: '2', label: 'Terminés'),
                  ),
                ],
              ),
            ),

            // Liste des objectifs
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
                children: [
                  _GoalItem(
                    title: 'Apprendre Flutter',
                    description: 'Maîtriser le développement mobile',
                    progress: 0.8,
                    deadline: 'Dans 2 mois',
                    icon: Icons.code_outlined,
                  ),
                  SizedBox(height: 12.h),
                  _GoalItem(
                    title: 'Perdre 5kg',
                    description: 'Retrouver une forme physique optimale',
                    progress: 0.6,
                    deadline: 'Dans 3 semaines',
                    icon: Icons.fitness_center_outlined,
                  ),
                  SizedBox(height: 12.h),
                  _GoalItem(
                    title: 'Lire 12 livres',
                    description: 'Développer mes connaissances',
                    progress: 0.45,
                    deadline: 'Fin d\'année',
                    icon: Icons.book_outlined,
                  ),
                  SizedBox(height: 12.h),
                  _GoalItem(
                    title: 'Apprendre le piano',
                    description: 'Jouer mes morceaux préférés',
                    progress: 0.25,
                    deadline: 'Dans 6 mois',
                    icon: Icons.music_note_outlined,
                  ),
                  SizedBox(height: 80.h), // Espace pour le FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addGoal(),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addGoal() {
    print('Action: Ajouter un nouvel objectif');
    // Future: Navigation vers formulaire de création
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

  const _GoalItem({
    required this.title,
    required this.description,
    required this.progress,
    required this.deadline,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _viewGoalDetails(),
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
                      Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp)),
                      SizedBox(height: 2.h),
                      Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),

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

            SizedBox(height: 12.h),

            // Footer avec échéance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule_outlined, color: AppColors.textTertiary, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(deadline, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
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

  void _viewGoalDetails() {
    print('Action: Voir détails de l\'objectif');
    // Future: Navigation vers écran de détail
  }
}
