import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/app_drawer.dart';

enum ReminderType { once, recurring }

enum ReminderUrgency { urgent, upcoming, recurring }

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late String _currentTime;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous';
  String _searchQuery = '';

  final List<String> _filters = ['Tous', 'Aujourd\'hui', 'Cette semaine', 'Récurrents', 'Expirés'];

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

  @override
  void dispose() {
    _searchController.dispose();
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
    final filteredReminders = _getFilteredReminders();
    final urgentReminders = filteredReminders.where((r) => r.urgency == ReminderUrgency.urgent).toList();
    final upcomingReminders = filteredReminders.where((r) => r.urgency == ReminderUrgency.upcoming).toList();
    final recurringReminders = filteredReminders.where((r) => r.urgency == ReminderUrgency.recurring).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Rappels'),
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
            // Barre de recherche et filtres
            Container(
              margin: EdgeInsets.all(AppSizes.padding),
              child: Row(
                children: [
                  // Barre de recherche
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Rechercher dans les rappels...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                          prefixIcon: Icon(Icons.search_outlined, color: AppColors.textTertiary, size: 20.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Bouton filtres
                  GestureDetector(
                    onTap: () => _showFilterMenu(context),
                    child: Container(
                      width: 40.h,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Icon(Icons.filter_list_outlined, color: AppColors.textSecondary, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),

            // Alerte rappels urgents
            if (urgentReminders.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(horizontal: AppSizes.padding),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: AppColors.textPrimary, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_outlined, color: AppColors.textPrimary, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      '${urgentReminders.length} rappel${urgentReminders.length > 1 ? 's' : ''} urgent${urgentReminders.length > 1 ? 's' : ''}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

            SizedBox(height: urgentReminders.isNotEmpty ? 16.h : 0),

            // Liste des rappels
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
                children: [
                  // Rappels urgents
                  if (urgentReminders.isNotEmpty) ...[
                    _SectionHeader(title: 'Urgents', icon: Icons.schedule_outlined, color: AppColors.textPrimary),
                    SizedBox(height: 12.h),
                    ...urgentReminders.map(
                      (reminder) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ReminderItem(
                          reminder: reminder,
                          onToggle: (value) => _toggleReminder(reminder, value),
                          onTap: () => _editReminder(reminder),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Rappels à venir
                  if (upcomingReminders.isNotEmpty) ...[
                    _SectionHeader(title: 'À venir', icon: Icons.upcoming_outlined, color: AppColors.textSecondary),
                    SizedBox(height: 12.h),
                    ...upcomingReminders.map(
                      (reminder) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ReminderItem(
                          reminder: reminder,
                          onToggle: (value) => _toggleReminder(reminder, value),
                          onTap: () => _editReminder(reminder),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Rappels récurrents
                  if (recurringReminders.isNotEmpty) ...[
                    _SectionHeader(title: 'Récurrents', icon: Icons.repeat_outlined, color: AppColors.textSecondary),
                    SizedBox(height: 12.h),
                    ...recurringReminders.map(
                      (reminder) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ReminderItem(
                          reminder: reminder,
                          onToggle: (value) => _toggleReminder(reminder, value),
                          onTap: () => _editReminder(reminder),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 80.h), // Espace pour le FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createReminder(),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<_ReminderData> _getFilteredReminders() {
    List<_ReminderData> reminders = _getAllReminders();

    // Filtrer par filtre sélectionné
    switch (_selectedFilter) {
      case 'Aujourd\'hui':
        reminders = reminders.where((r) => r.urgency == ReminderUrgency.urgent).toList();
        break;
      case 'Cette semaine':
        reminders = reminders.where((r) => r.urgency != ReminderUrgency.recurring).toList();
        break;
      case 'Récurrents':
        reminders = reminders.where((r) => r.type == ReminderType.recurring).toList();
        break;
      case 'Expirés':
        // Pour la démo, on n'a pas de rappels expirés
        reminders = [];
        break;
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      reminders = reminders.where((reminder) => reminder.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return reminders;
  }

  List<_ReminderData> _getAllReminders() {
    return [
      // Urgents
      _ReminderData(
        title: 'Appeler dentiste',
        time: 'Dans 2h',
        type: ReminderType.once,
        urgency: ReminderUrgency.urgent,
        isActive: true,
      ),
      _ReminderData(
        title: 'Réunion client',
        time: 'Dans 4h',
        type: ReminderType.once,
        urgency: ReminderUrgency.urgent,
        isActive: true,
      ),

      // À venir
      _ReminderData(
        title: 'Payer facture électricité',
        time: 'Demain 10h',
        type: ReminderType.once,
        urgency: ReminderUrgency.upcoming,
        isActive: true,
      ),
      _ReminderData(
        title: 'Sport - Course',
        time: 'Demain 7h',
        type: ReminderType.recurring,
        urgency: ReminderUrgency.upcoming,
        isActive: true,
      ),
      _ReminderData(
        title: 'Révision Flutter',
        time: 'Dans 3 jours',
        type: ReminderType.recurring,
        urgency: ReminderUrgency.upcoming,
        isActive: false,
      ),

      // Récurrents
      _ReminderData(
        title: 'Boire de l\'eau',
        time: 'Toutes les 2h',
        type: ReminderType.recurring,
        urgency: ReminderUrgency.recurring,
        isActive: true,
      ),
      _ReminderData(
        title: 'Pause écran',
        time: 'Toutes les heures',
        type: ReminderType.recurring,
        urgency: ReminderUrgency.recurring,
        isActive: true,
      ),
      _ReminderData(
        title: 'Backup projet',
        time: 'Chaque dimanche 20h',
        type: ReminderType.recurring,
        urgency: ReminderUrgency.recurring,
        isActive: false,
      ),
    ];
  }

  void _showFilterMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      items: _filters.map((filter) {
        return PopupMenuItem<String>(
          value: filter,
          child: Row(
            children: [
              if (filter == _selectedFilter)
                Icon(Icons.check, color: AppColors.textPrimary, size: 16.sp)
              else
                SizedBox(width: 16.w),
              SizedBox(width: 8.w),
              Text(
                filter,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: filter == _selectedFilter ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() => _selectedFilter = value);
      }
    });
  }

  void _toggleReminder(_ReminderData reminder, bool value) {
    print('Toggle rappel: ${reminder.title} → $value');
    // Future: Mise à jour en base de données
  }

  void _editReminder(_ReminderData reminder) {
    print('Éditer rappel: ${reminder.title}');
    // Future: Navigation vers éditeur
  }

  void _createReminder() {
    print('Action: Créer nouveau rappel');
    // Future: Navigation vers formulaire de création
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final _ReminderData reminder;
  final Function(bool) onToggle;
  final VoidCallback onTap;

  const _ReminderItem({required this.reminder, required this.onToggle, required this.onTap});

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
            color: reminder.urgency == ReminderUrgency.urgent ? AppColors.textPrimary : AppColors.border,
            width: reminder.urgency == ReminderUrgency.urgent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icône type
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(4.r)),
              child: Icon(
                reminder.type == ReminderType.recurring ? Icons.repeat_outlined : Icons.notifications_outlined,
                color: AppColors.textSecondary,
                size: 16.sp,
              ),
            ),

            SizedBox(width: 12.w),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: reminder.urgency == ReminderUrgency.urgent ? AppColors.textPrimary : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(reminder.time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),

            // Switch
            Switch(
              value: reminder.isActive,
              onChanged: onToggle,
              activeColor: AppColors.textPrimary,
              inactiveThumbColor: AppColors.textTertiary,
              inactiveTrackColor: AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderData {
  final String title;
  final String time;
  final ReminderType type;
  final ReminderUrgency urgency;
  final bool isActive;

  _ReminderData({required this.title, required this.time, required this.type, required this.urgency, required this.isActive});
}
