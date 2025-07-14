import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _currentTime;
  late String _currentDate;

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
      _currentDate = _formatDate(now);
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

    return "${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: "home"),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Si l'utilisateur glisse de gauche à droite (vitesse positive en x)
          if (details.primaryVelocity! > 0) {
            // Sur la page d'accueil, ouvrir le drawer au lieu de retourner
            _scaffoldKey.currentState?.openDrawer();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Heure principale
              Text(
                _currentTime,
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(fontSize: 72, fontWeight: FontWeight.w300, letterSpacing: -2),
              ),

              const SizedBox(height: 8),

              // Date
              Text(
                _currentDate,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, fontSize: 16),
              ),

              const Spacer(flex: 3),

              // Actions rapides
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(icon: Icons.edit_outlined, label: 'Note', onTap: () => _quickNote()),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickAction(icon: Icons.add_task_outlined, label: 'Tâche', onTap: () => _quickTask()),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickAction(icon: Icons.alarm_outlined, label: 'Rappel', onTap: () => _quickReminder()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _quickNote() {
    print('Action: Prise de note rapide');
  }

  void _quickTask() {
    print('Action: Création de tâche rapide');
  }

  void _quickReminder() {
    print('Action: Création de rappel rapide');
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
