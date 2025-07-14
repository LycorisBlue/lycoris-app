import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/app_drawer.dart';

enum TaskStatus { todo, inProgress, completed }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
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
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(value: '12', label: 'À faire'),
                  ),
                  Container(width: 1, height: 40.h, color: AppColors.border),
                  Expanded(
                    child: _StatItem(value: '8', label: 'En cours'),
                  ),
                  Container(width: 1, height: 40.h, color: AppColors.border),
                  Expanded(
                    child: _StatItem(value: '15', label: 'Terminées'),
                  ),
                ],
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

            // Liste des tâches
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildTaskList(_getTodayTasks()), _buildTaskList(_getWeekTasks()), _buildTaskList(_getAllTasks())],
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

  Widget _buildTaskList(List<_TaskData> tasks) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: _TaskItem(
            title: task.title,
            projectName: task.projectName,
            goalName: task.goalName,
            status: task.status,
            deadline: task.deadline,
            isUrgent: task.isUrgent,
            onStatusChanged: (newStatus) => _updateTaskStatus(task, newStatus),
            onTap: () => _viewTaskDetails(task),
          ),
        );
      },
    );
  }

  List<_TaskData> _getTodayTasks() {
    return _getAllTasks().where((task) => task.deadline == 'Aujourd\'hui').toList();
  }

  List<_TaskData> _getWeekTasks() {
    return _getAllTasks()
        .where((task) => task.deadline == 'Aujourd\'hui' || task.deadline == 'Demain' || task.deadline == 'Dans 2 jours')
        .toList();
  }

  List<_TaskData> _getAllTasks() {
    return [
      _TaskData(
        title: 'Créer interface principale',
        projectName: 'App TodoList',
        goalName: 'Apprendre Flutter',
        status: TaskStatus.inProgress,
        deadline: 'Aujourd\'hui',
        isUrgent: true,
      ),
      _TaskData(
        title: 'Acheter équipement fitness',
        projectName: 'Programme fitness',
        goalName: 'Perdre 5kg',
        status: TaskStatus.todo,
        deadline: 'Aujourd\'hui',
        isUrgent: true,
      ),
      _TaskData(
        title: 'Implémenter base de données',
        projectName: 'App TodoList',
        goalName: 'Apprendre Flutter',
        status: TaskStatus.todo,
        deadline: 'Demain',
        isUrgent: false,
      ),
      _TaskData(
        title: 'Planifier séances sport',
        projectName: 'Programme fitness',
        goalName: 'Perdre 5kg',
        status: TaskStatus.inProgress,
        deadline: 'Dans 2 jours',
        isUrgent: false,
      ),
      _TaskData(
        title: 'Configurer projet Flutter',
        projectName: 'App TodoList',
        goalName: 'Apprendre Flutter',
        status: TaskStatus.completed,
        deadline: 'Hier',
        isUrgent: false,
      ),
      _TaskData(
        title: 'Choisir premier livre',
        projectName: 'Setup lecture',
        goalName: 'Lire 12 livres',
        status: TaskStatus.completed,
        deadline: 'Il y a 2 jours',
        isUrgent: false,
      ),
      _TaskData(
        title: 'Rechercher professeur piano',
        projectName: 'Recherche piano',
        goalName: 'Apprendre le piano',
        status: TaskStatus.todo,
        deadline: 'Cette semaine',
        isUrgent: false,
      ),
    ];
  }

  void _updateTaskStatus(_TaskData task, TaskStatus newStatus) {
    print('Mise à jour statut tâche: ${task.title} → $newStatus');
    // Future: Mise à jour en base de données
  }

  void _viewTaskDetails(_TaskData task) {
    print('Voir détails tâche: ${task.title}');
    // Future: Navigation vers écran de détail
  }

  void _addTask() {
    print('Action: Ajouter une nouvelle tâche');
    // Future: Navigation vers formulaire de création avec sélection de projet
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

class _TaskItem extends StatelessWidget {
  final String title;
  final String projectName;
  final String goalName;
  final TaskStatus status;
  final String deadline;
  final bool isUrgent;
  final Function(TaskStatus) onStatusChanged;
  final VoidCallback onTap;

  const _TaskItem({
    required this.title,
    required this.projectName,
    required this.goalName,
    required this.status,
    required this.deadline,
    required this.isUrgent,
    required this.onStatusChanged,
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
                if (isUrgent && status != TaskStatus.completed)
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
                  child: _TaskCheckbox(status: status),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                      color: _getStatusColor(),
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
                      deadline,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getDeadlineColor(),
                        fontWeight: isUrgent ? FontWeight.w600 : FontWeight.w400,
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
    switch (status) {
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

  Color _getStatusColor() {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.textSecondary;
      case TaskStatus.inProgress:
        return AppColors.textPrimary;
      case TaskStatus.completed:
        return AppColors.textTertiary;
    }
  }

  Color _getDeadlineColor() {
    if (status == TaskStatus.completed) return AppColors.textTertiary;
    return isUrgent ? AppColors.textPrimary : AppColors.textTertiary;
  }

  IconData _getDeadlineIcon() {
    if (status == TaskStatus.completed) return Icons.check_circle_outline;
    return Icons.schedule_outlined;
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

class _TaskData {
  final String title;
  final String projectName;
  final String goalName;
  final TaskStatus status;
  final String deadline;
  final bool isUrgent;

  _TaskData({
    required this.title,
    required this.projectName,
    required this.goalName,
    required this.status,
    required this.deadline,
    required this.isUrgent,
  });
}
