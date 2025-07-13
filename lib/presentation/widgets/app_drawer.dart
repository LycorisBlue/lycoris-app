import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupérer la route actuelle
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? AppRoutes.home;

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
                    color: currentRoute == AppRoutes.home ? AppColors.textPrimary : AppColors.textSecondary,
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
                      route: AppRoutes.dashboard,
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.dashboard),
                    ),

                    _buildSeparator(),

                    _DrawerItem(
                      icon: Icons.track_changes_outlined,
                      title: 'Objectifs',
                      route: AppRoutes.goals,
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.goals),
                    ),

                    _DrawerItem(
                      icon: Icons.folder_outlined,
                      title: 'Projets',
                      route: AppRoutes.projects,
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.projects),
                    ),

                    _DrawerItem(
                      icon: Icons.check_box_outlined,
                      title: 'Tâches',
                      route: AppRoutes.tasks,
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.tasks),
                    ),

                    _buildSeparator(),

                    _DrawerItem(
                      icon: Icons.repeat_outlined,
                      title: 'Habitudes',
                      route: AppRoutes.habits,
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.habits),
                    ),

                    _DrawerItem(
                      icon: Icons.book_outlined,
                      title: 'Journal',
                      route: AppRoutes.journal,
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.journal),
                    ),

                    _buildSeparator(),

                    _DrawerItem(
                      icon: Icons.note_outlined,
                      title: 'Notes',
                      route: AppRoutes.notes,
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.notes),
                    ),

                    _DrawerItem(
                      icon: Icons.notifications_outlined,
                      title: 'Rappels',
                      route: AppRoutes.reminders,
                      currentRoute: currentRoute,
                      onTap: () => _navigateTo(context, AppRoutes.reminders),
                    ),

                    _buildSeparator(),

                    _DrawerItem(
                      icon: Icons.access_time_outlined,
                      title: 'Outils',
                      route: AppRoutes.tools,
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
              route: AppRoutes.settings,
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
    AppNavigator.goTo(context, route);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pop(context);
    AppNavigator.goToHome(context);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  bool get isSelected => currentRoute == route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.hover,
                border: Border(left: BorderSide(color: AppColors.textPrimary, width: 3)),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
