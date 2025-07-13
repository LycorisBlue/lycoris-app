import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/app_drawer.dart';

enum HabitType { good, bad }

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
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
        title: const Text('Habitudes'),
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
                    child: _StatItem(value: '6', label: 'Actives'),
                  ),
                  Container(width: 1, height: 40.h, color: AppColors.border),
                  Expanded(
                    child: _StatItem(value: '12', label: 'Record'),
                  ),
                  Container(width: 1, height: 40.h, color: AppColors.border),
                  Expanded(
                    child: _StatItem(value: '85%', label: 'Réussite'),
                  ),
                ],
              ),
            ),

            // Légende des jours
            Container(
              margin: EdgeInsets.symmetric(horizontal: AppSizes.padding),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DayLabel('L'),
                  _DayLabel('M'),
                  _DayLabel('M'),
                  _DayLabel('J'),
                  _DayLabel('V'),
                  _DayLabel('S'),
                  _DayLabel('D'),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Liste des habitudes
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
                children: [
                  // Bonnes habitudes
                  _HabitItem(
                    title: 'Boire 2L d\'eau',
                    icon: Icons.water_drop_outlined,
                    type: HabitType.good,
                    currentStreak: 5,
                    weekProgress: [true, true, true, true, true, false, false],
                    onDayTap: (dayIndex) => _toggleDay('water', dayIndex),
                    onTap: () => _viewHabitDetails('Boire 2L d\'eau'),
                  ),
                  SizedBox(height: 12.h),
                  _HabitItem(
                    title: 'Lire 30min',
                    icon: Icons.book_outlined,
                    type: HabitType.good,
                    currentStreak: 3,
                    weekProgress: [true, true, true, false, false, false, false],
                    onDayTap: (dayIndex) => _toggleDay('reading', dayIndex),
                    onTap: () => _viewHabitDetails('Lire 30min'),
                  ),
                  SizedBox(height: 12.h),
                  _HabitItem(
                    title: 'Course matinale',
                    icon: Icons.directions_run_outlined,
                    type: HabitType.good,
                    currentStreak: 2,
                    weekProgress: [false, true, true, false, false, false, false],
                    onDayTap: (dayIndex) => _toggleDay('running', dayIndex),
                    onTap: () => _viewHabitDetails('Course matinale'),
                  ),
                  SizedBox(height: 12.h),
                  _HabitItem(
                    title: 'Méditation 10min',
                    icon: Icons.self_improvement_outlined,
                    type: HabitType.good,
                    currentStreak: 7,
                    weekProgress: [true, true, true, true, true, true, true],
                    onDayTap: (dayIndex) => _toggleDay('meditation', dayIndex),
                    onTap: () => _viewHabitDetails('Méditation 10min'),
                  ),
                  SizedBox(height: 20.h),

                  // Séparateur pour mauvaises habitudes
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: AppColors.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'À éviter',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: AppColors.border)),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Mauvaises habitudes
                  _HabitItem(
                    title: 'Réseaux sociaux >2h',
                    icon: Icons.smartphone_outlined,
                    type: HabitType.bad,
                    currentStreak: 0,
                    weekProgress: [false, true, false, false, true, false, false],
                    onDayTap: (dayIndex) => _toggleDay('social', dayIndex),
                    onTap: () => _viewHabitDetails('Réseaux sociaux >2h'),
                  ),
                  SizedBox(height: 12.h),
                  _HabitItem(
                    title: 'Fast food',
                    icon: Icons.fastfood_outlined,
                    type: HabitType.bad,
                    currentStreak: 4,
                    weekProgress: [false, false, false, true, false, false, false],
                    onDayTap: (dayIndex) => _toggleDay('fastfood', dayIndex),
                    onTap: () => _viewHabitDetails('Fast food'),
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addHabit(),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _toggleDay(String habitId, int dayIndex) {
    print('Toggle habitude $habitId jour $dayIndex');
    // Future: Mise à jour en base de données
  }

  void _viewHabitDetails(String habitName) {
    print('Voir détails habitude: $habitName');
    // Future: Navigation vers historique complet
  }

  void _addHabit() {
    print('Action: Ajouter une nouvelle habitude');
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

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontSize: 10.sp),
    );
  }
}

class _HabitItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final HabitType type;
  final int currentStreak;
  final List<bool> weekProgress;
  final Function(int) onDayTap;
  final VoidCallback onTap;

  const _HabitItem({
    required this.title,
    required this.icon,
    required this.type,
    required this.currentStreak,
    required this.weekProgress,
    required this.onDayTap,
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
            color: AppColors.border,
            width: 1,
            style: type == HabitType.bad ? BorderStyle.solid : BorderStyle.solid,
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
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6.r),
                    border: type == HabitType.bad ? Border.all(color: AppColors.border, width: 1) : null,
                  ),
                  child: Icon(icon, color: AppColors.textSecondary, size: 18.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 15.sp)),
                ),
                // Streak
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(4.r)),
                  child: Text(
                    _getStreakText(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Grille des 7 jours
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                return GestureDetector(
                  onTap: () => onDayTap(index),
                  child: _DayDot(
                    isCompleted: _isDayCompleted(index),
                    isToday: index == 4, // Simulation: vendredi = aujourd'hui
                    type: type,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getStreakText() {
    if (type == HabitType.good) {
      return currentStreak > 0 ? '${currentStreak}j' : '0j';
    } else {
      // Pour mauvaises habitudes, on compte les jours sans échec
      return currentStreak > 0 ? '${currentStreak}j' : 'Échec';
    }
  }

  bool _isDayCompleted(int dayIndex) {
    if (type == HabitType.good) {
      return weekProgress[dayIndex];
    } else {
      // Pour mauvaises habitudes, "complété" = pas fait (donc bien)
      return !weekProgress[dayIndex];
    }
  }
}

class _DayDot extends StatelessWidget {
  final bool isCompleted;
  final bool isToday;
  final HabitType type;

  const _DayDot({required this.isCompleted, required this.isToday, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.textPrimary : Colors.transparent,
        border: Border.all(
          color: isToday
              ? AppColors.textPrimary
              : isCompleted
              ? AppColors.textPrimary
              : AppColors.border,
          width: isToday ? 2 : 1,
          style: type == HabitType.bad && !isCompleted ? BorderStyle.solid : BorderStyle.solid,
        ),
        shape: BoxShape.circle,
      ),
      child: isCompleted
          ? Icon(Icons.check, color: AppColors.background, size: 16.sp)
          : isToday
          ? Center(
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}
