import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Text('Life.', style: Theme.of(context).textTheme.titleMedium),
            ),

            // Navigation Items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      title: 'Dashboard',
                      onTap: () => _navigateTo(context, '/dashboard'),
                    ),

                    _buildSeparator(),

                    _DrawerItem(
                      icon: Icons.track_changes_outlined,
                      title: 'Objectifs',
                      onTap: () => _navigateTo(context, '/goals'),
                    ),

                    _DrawerItem(icon: Icons.folder_outlined, title: 'Projets', onTap: () => _navigateTo(context, '/projects')),

                    _DrawerItem(icon: Icons.check_box_outlined, title: 'Tâches', onTap: () => _navigateTo(context, '/tasks')),

                    _buildSeparator(),

                    _DrawerItem(icon: Icons.repeat_outlined, title: 'Habitudes', onTap: () => _navigateTo(context, '/habits')),

                    _DrawerItem(icon: Icons.book_outlined, title: 'Journal', onTap: () => _navigateTo(context, '/journal')),

                    _buildSeparator(),

                    _DrawerItem(icon: Icons.note_outlined, title: 'Notes', onTap: () => _navigateTo(context, '/notes')),

                    _DrawerItem(
                      icon: Icons.notifications_outlined,
                      title: 'Rappels',
                      onTap: () => _navigateTo(context, '/reminders'),
                    ),

                    _buildSeparator(),

                    _DrawerItem(icon: Icons.access_time_outlined, title: 'Outils', onTap: () => _navigateTo(context, '/tools')),
                  ],
                ),
              ),
            ),

            Container(height: 1, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 16)),

            // Settings at bottom
            _DrawerItem(icon: Icons.settings_outlined, title: 'Paramètres', onTap: () => _navigateTo(context, '/settings')),
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
    print('Navigation vers: $route');
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 16),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
