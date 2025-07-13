import 'package:flutter/material.dart';
import 'package:lycoris/presentation/screens/dashboard_screen.dart';
import 'package:lycoris/presentation/screens/goals_screen.dart';
import 'package:lycoris/presentation/screens/habits_screen.dart';
import 'package:lycoris/presentation/screens/journal_screen.dart';
import 'package:lycoris/presentation/screens/notes_screen.dart';
import 'package:lycoris/presentation/screens/projects_screen.dart';
import 'package:lycoris/presentation/screens/reminders_screen.dart';
import 'package:lycoris/presentation/screens/settings_screen.dart';
import 'package:lycoris/presentation/screens/tasks_screen.dart';
import 'package:lycoris/presentation/screens/tools_screen.dart';
import '../../presentation/screens/home_screen.dart';

/// Constantes pour toutes les routes de l'application
class AppRoutes {
  // Route d'accueil (écran principal avec horloge)
  static const String home = '/';

  // Routes principales du drawer - à implémenter dans les phases suivantes
  static const String dashboard = '/dashboard';
  static const String goals = '/goals';
  static const String projects = '/projects';
  static const String tasks = '/tasks';
  static const String habits = '/habits';
  static const String journal = '/journal';
  static const String notes = '/notes';
  static const String reminders = '/reminders';
  static const String tools = '/tools';
  static const String settings = '/settings';
}

/// Page route personnalisée avec animation fade pour cohérence visuelle
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  AppPageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Animation fade simple et élégante
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      );
}

/// Écran temporaire pour les routes non implémentées
class ComingSoonScreen extends StatelessWidget {
  final String screenName;

  const ComingSoonScreen({super.key, required this.screenName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(screenName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_outlined, size: 64, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('À venir', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Cette section sera disponible prochainement',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Écran d'erreur pour les routes introuvables
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Page introuvable', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'La page demandée n\'existe pas',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Générateur principal des routes de l'application
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? AppRoutes.home;

    switch (routeName) {
      case AppRoutes.home:
        return AppPageRoute(child: const HomeScreen());

      case AppRoutes.dashboard:
        return AppPageRoute(child: const DashboardScreen());

      case AppRoutes.goals:
        return AppPageRoute(child: const GoalsScreen());

      case AppRoutes.projects:
        return AppPageRoute(child: const ProjectsScreen());

      case AppRoutes.tasks:
        return AppPageRoute(child: const TasksScreen());

      case AppRoutes.habits:
        return AppPageRoute(child: const HabitsScreen());

      case AppRoutes.journal:
        return AppPageRoute(child: const JournalScreen());

      case AppRoutes.notes:
        return AppPageRoute(child: const NotesScreen());

      case AppRoutes.reminders:
        return AppPageRoute(child: const RemindersScreen());

      case AppRoutes.tools:
        return AppPageRoute(child: const ToolsScreen());
      
      case AppRoutes.settings:
        return AppPageRoute(child: const SettingsScreen());

      default:
        return AppPageRoute(child: const NotFoundScreen());
    }
  }
}

/// Helpers pour simplifier la navigation dans l'application
class AppNavigator {
  /// Naviguer vers une nouvelle route
  static Future<T?> goTo<T extends Object?>(BuildContext context, String routeName) {
    return Navigator.pushNamed<T>(context, routeName);
  }

  /// Remplacer la route actuelle
  static Future<T?> replace<T extends Object?>(BuildContext context, String routeName) {
    return Navigator.pushReplacementNamed<T, dynamic>(context, routeName);
  }

  /// Retourner à la page précédente
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Retourner à l'accueil en supprimant toutes les routes précédentes
  static Future<T?> goToHome<T extends Object?>(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil<T>(context, AppRoutes.home, (route) => false);
  }
}
