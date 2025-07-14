import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec bouton retour à l'accueil
            Container(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () => _navigateToHome(context),
                child: Text(
                  'Lycoris.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: currentRoute == "home" ? AppColors.background : AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // Navigation Items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      title: 'Dashboard',
                      routeName: "dashboard",
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.dashboard),
                    ),

                    _buildSeparator(),

                    _DrawerItem(
                      icon: Icons.track_changes_outlined,
                      title: 'Objectifs',
                      routeName: "goals",
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.goals),
                    ),

                    _DrawerItem(
                      icon: Icons.folder_outlined,
                      title: 'Projets',
                      routeName: "projects",
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.projects),
                    ),

                    _DrawerItem(
                      icon: Icons.check_box_outlined,
                      title: 'Tâches',
                      routeName: "tasks",
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.tasks),
                    ),

                    _buildSeparator(),

                    _DrawerItem(
                      icon: Icons.repeat_outlined,
                      title: 'Habitudes',
                      routeName: "habits",
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.habits),
                    ),

                    _DrawerItem(
                      icon: Icons.book_outlined,
                      title: 'Journal',
                      routeName: "journal",
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.journal),
                    ),

                    _buildSeparator(),

                    _DrawerItem(
                      icon: Icons.note_outlined,
                      title: 'Notes',
                      routeName: "notes",
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.notes),
                    ),

                    _DrawerItem(
                      icon: Icons.notifications_outlined,
                      title: 'Rappels',
                      routeName: "reminders",
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.reminders),
                    ),

                    _buildSeparator(),

                    _DrawerItem(
                      icon: Icons.access_time_outlined,
                      title: 'Outils',
                      routeName: "tools",
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.tools),
                    ),
                  ],
                ),
              ),
            ),

            Container(height: 1, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 16)),

            // Settings at bottom
            _DrawerItem(
              icon: Icons.settings_outlined,
              title: 'Paramètres',
              routeName: "settings",
              currentRoute: currentRoute,
              onTap: () => _navigateTo(context, AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(height: 1, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String routeName;
  final String currentRoute;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.routeName,
    required this.currentRoute,
    required this.onTap,
  });

  bool get isSelected => currentRoute == routeName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.textPrimary, // Fond blanc pour l'item actif
                border: Border(left: BorderSide(color: AppColors.background, width: 3)),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.background : AppColors.textSecondary, // Icône noire si actif
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.background : AppColors.textSecondary, // Texte noir si actif
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
