import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/app_drawer.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late String _currentTime;
  int _selectedMood = 3; // 1-5, défaut neutre
  int _selectedEnergy = 3; // 1-5, défaut moyen
  final TextEditingController _journalController = TextEditingController();

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
    _journalController.dispose();
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
      drawer: const AppDrawer(currentRoute: "journal"),
      appBar: AppBar(
        title: const Text('Journal'),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section stats en haut
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(value: '15', label: 'Jours'),
                    ),
                    Container(width: 1, height: 40.h, color: AppColors.border),
                    Expanded(
                      child: _StatItem(value: '4.2/5', label: 'Humeur'),
                    ),
                    Container(width: 1, height: 40.h, color: AppColors.border),
                    Expanded(
                      child: _StatItem(value: '28', label: 'Entrées'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Bilan du jour
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.today_outlined, color: AppColors.textSecondary, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text('Aujourd\'hui', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp)),
                        const Spacer(),
                        Text(
                          _getCurrentDate(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Sélecteur d'humeur
                    Text(
                      'Comment te sens-tu ?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMood = index + 1),
                          child: _MoodButton(level: index + 1, isSelected: _selectedMood == index + 1),
                        );
                      }),
                    ),

                    SizedBox(height: 20.h),

                    // Niveau d'énergie
                    Text(
                      'Niveau d\'énergie',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: List.generate(5, (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedEnergy = index + 1),
                            child: Container(
                              height: 8.h,
                              margin: EdgeInsets.only(right: index < 4 ? 4.w : 0),
                              decoration: BoxDecoration(
                                color: index < _selectedEnergy ? AppColors.textPrimary : AppColors.border,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _getEnergyLabel(_selectedEnergy),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                    ),

                    SizedBox(height: 20.h),

                    // Zone de texte
                    Text(
                      'Comment s\'est passée ta journée ?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: TextField(
                        controller: _journalController,
                        maxLines: 4,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Écris tes pensées, ressentis, événements marquants...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Bouton sauvegarder
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: _saveEntry, child: const Text('Sauvegarder')),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Historique
              Text('Entrées récentes', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp)),
              SizedBox(height: 12.h),

              ..._getJournalEntries().map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _JournalEntry(
                    date: entry.date,
                    mood: entry.mood,
                    energy: entry.energy,
                    text: entry.text,
                    onTap: () => _viewFullEntry(entry),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${now.day} ${months[now.month - 1]}';
  }

  String _getEnergyLabel(int energy) {
    switch (energy) {
      case 1:
        return 'Très faible';
      case 2:
        return 'Faible';
      case 3:
        return 'Moyen';
      case 4:
        return 'Élevé';
      case 5:
        return 'Très élevé';
      default:
        return 'Moyen';
    }
  }

  List<_JournalEntryData> _getJournalEntries() {
    return [
      _JournalEntryData(
        date: 'Hier',
        mood: 4,
        energy: 3,
        text:
            'Journée productive au travail. J\'ai terminé le projet Flutter et commencé à planifier la prochaine phase. Soirée relaxante avec un bon livre.',
      ),
      _JournalEntryData(
        date: 'Il y a 2 jours',
        mood: 5,
        energy: 4,
        text:
            'Excellente journée ! Course matinale très énergisante, puis séance de travail concentrée. Dîner avec des amis le soir.',
      ),
      _JournalEntryData(
        date: 'Il y a 3 jours',
        mood: 2,
        energy: 2,
        text:
            'Journée difficile. Réveil tardif, motivation en berne. Quelques problèmes techniques sur le projet. Heureusement ça s\'arrange en fin de journée.',
      ),
    ];
  }

  void _saveEntry() {
    print('Sauvegarde entrée: Humeur=$_selectedMood, Énergie=$_selectedEnergy, Texte=${_journalController.text}');
    // Future: Sauvegarde en base de données
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrée sauvegardée !')));
  }

  void _viewFullEntry(_JournalEntryData entry) {
    print('Voir entrée complète: ${entry.date}');
    // Future: Navigation vers vue détaillée
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24.sp, fontWeight: FontWeight.w300),
        ),
        SizedBox(height: 4.h),
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

class _MoodButton extends StatelessWidget {
  final int level;
  final bool isSelected;

  const _MoodButton({required this.level, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.textPrimary : Colors.transparent,
        border: Border.all(color: isSelected ? AppColors.textPrimary : AppColors.border, width: 2),
        shape: BoxShape.circle,
      ),
      child: Icon(_getMoodIcon(level), color: isSelected ? AppColors.background : AppColors.textSecondary, size: 20.sp),
    );
  }

  IconData _getMoodIcon(int level) {
    switch (level) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}

class _JournalEntry extends StatelessWidget {
  final String date;
  final int mood;
  final int energy;
  final String text;
  final VoidCallback onTap;

  const _JournalEntry({required this.date, required this.mood, required this.energy, required this.text, required this.onTap});

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
            Row(
              children: [
                Text(date, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                // Indicateurs
                Row(
                  children: [
                    Icon(_getMoodIcon(mood), color: AppColors.textSecondary, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text('$mood/5', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                    SizedBox(width: 12.w),
                    Icon(Icons.battery_charging_full, color: AppColors.textSecondary, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text('$energy/5', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              text.length > 100 ? '${text.substring(0, 100)}...' : text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMoodIcon(int level) {
    switch (level) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}

class _JournalEntryData {
  final String date;
  final int mood;
  final int energy;
  final String text;

  _JournalEntryData({required this.date, required this.mood, required this.energy, required this.text});
}
