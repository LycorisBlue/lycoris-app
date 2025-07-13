import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currentTime;

  // États des préférences
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationsEnabled = true;
  bool _animationsEnabled = true;
  bool _autoBackup = true;
  String _fontSize = 'Normale';
  String _userName = 'Utilisateur';
  String _userEmail = 'user@example.com';

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
        title: const Text('Paramètres'),
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
              // Section Profil
              _SettingsSection(
                title: 'Profil utilisateur',
                icon: Icons.person_outline,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 25.r,
                          backgroundColor: AppColors.surfaceElevated,
                          child: Text(
                            _userName[0].toUpperCase(),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Infos
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_userName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp)),
                              SizedBox(height: 2.h),
                              Text(
                                _userEmail,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        // Bouton modifier
                        TextButton(
                          onPressed: () => _editProfile(),
                          child: Text(
                            'Modifier',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Section Apparence
              _SettingsSection(
                title: 'Apparence',
                icon: Icons.palette_outlined,
                children: [
                  _SettingsTile(
                    title: 'Thème',
                    subtitle: 'Sombre',
                    trailing: Icon(Icons.dark_mode_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: () => _showThemeSelector(),
                  ),
                  _SettingsTile(
                    title: 'Taille de police',
                    subtitle: _fontSize,
                    trailing: Icon(Icons.text_fields_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: () => _showFontSizeSelector(),
                  ),
                  _SettingsTile(
                    title: 'Animations',
                    subtitle: 'Transitions fluides',
                    trailing: Switch(
                      value: _animationsEnabled,
                      onChanged: (value) => setState(() => _animationsEnabled = value),
                      activeColor: AppColors.textPrimary,
                    ),
                    onTap: null,
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Section Notifications
              _SettingsSection(
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                children: [
                  _SettingsTile(
                    title: 'Notifications push',
                    subtitle: 'Rappels et alertes',
                    trailing: Switch(
                      value: _pushNotifications,
                      onChanged: (value) => setState(() => _pushNotifications = value),
                      activeColor: AppColors.textPrimary,
                    ),
                    onTap: null,
                  ),
                  _SettingsTile(
                    title: 'Sons',
                    subtitle: 'Alertes sonores',
                    trailing: Switch(
                      value: _soundEnabled,
                      onChanged: (value) => setState(() => _soundEnabled = value),
                      activeColor: AppColors.textPrimary,
                    ),
                    onTap: null,
                  ),
                  _SettingsTile(
                    title: 'Vibrations',
                    subtitle: 'Feedback haptique',
                    trailing: Switch(
                      value: _vibrationsEnabled,
                      onChanged: (value) => setState(() => _vibrationsEnabled = value),
                      activeColor: AppColors.textPrimary,
                    ),
                    onTap: null,
                  ),
                  _SettingsTile(
                    title: 'Heures silencieuses',
                    subtitle: '22h - 7h',
                    trailing: Icon(Icons.schedule_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: () => _configureSilentHours(),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Section Données
              _SettingsSection(
                title: 'Données',
                icon: Icons.storage_outlined,
                children: [
                  _SettingsTile(
                    title: 'Sauvegarde automatique',
                    subtitle: 'Sauvegarde quotidienne',
                    trailing: Switch(
                      value: _autoBackup,
                      onChanged: (value) => setState(() => _autoBackup = value),
                      activeColor: AppColors.textPrimary,
                    ),
                    onTap: null,
                  ),
                  _SettingsTile(
                    title: 'Exporter les données',
                    subtitle: 'JSON, CSV',
                    trailing: Icon(Icons.file_download_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: () => _exportData(),
                  ),
                  _SettingsTile(
                    title: 'Importer des données',
                    subtitle: 'Depuis un fichier',
                    trailing: Icon(Icons.file_upload_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: () => _importData(),
                  ),
                  _SettingsTile(
                    title: 'Réinitialiser',
                    subtitle: 'Supprimer toutes les données',
                    trailing: Icon(
                      Icons.delete_outline,
                      color: AppColors.textPrimary, // Rouge en monochrome
                      size: 20.sp,
                    ),
                    onTap: () => _resetData(),
                    isDestructive: true,
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Section À propos
              _SettingsSection(
                title: 'À propos',
                icon: Icons.info_outline,
                children: [
                  _SettingsTile(
                    title: 'Version de l\'app',
                    subtitle: '1.0.0 (1)',
                    trailing: Icon(Icons.app_settings_alt_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: null,
                  ),
                  _SettingsTile(
                    title: 'Développeur',
                    subtitle: 'Lycoris Team',
                    trailing: Icon(Icons.code_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: () => _showDeveloperInfo(),
                  ),
                  _SettingsTile(
                    title: 'Conditions d\'utilisation',
                    subtitle: 'Termes et conditions',
                    trailing: Icon(Icons.description_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: () => _openTerms(),
                  ),
                  _SettingsTile(
                    title: 'Politique de confidentialité',
                    subtitle: 'Protection des données',
                    trailing: Icon(Icons.privacy_tip_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: () => _openPrivacyPolicy(),
                  ),
                  _SettingsTile(
                    title: 'Signaler un bug',
                    subtitle: 'Aide et support',
                    trailing: Icon(Icons.bug_report_outlined, color: AppColors.textTertiary, size: 20.sp),
                    onTap: () => _reportBug(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Actions du profil
  void _editProfile() {
    print('Modifier profil utilisateur');
    // Future: Modal/page d'édition profil
  }

  // Actions apparence
  void _showThemeSelector() {
    print('Sélecteur de thème');
    // Future: Modal avec choix clair/sombre
  }

  void _showFontSizeSelector() {
    print('Sélecteur taille police');
    // Future: Modal avec preview des tailles
  }

  // Actions notifications
  void _configureSilentHours() {
    print('Configuration heures silencieuses');
    // Future: Time picker pour début/fin
  }

  // Actions données
  void _exportData() {
    print('Export des données');
    // Future: Génération fichier + partage
  }

  void _importData() {
    print('Import des données');
    // Future: File picker + parsing
  }

  void _resetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Réinitialiser les données', style: Theme.of(context).textTheme.titleMedium),
        content: Text(
          'Cette action supprimera définitivement toutes vos données. Continuer ?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('Données réinitialisées');
              // Future: Suppression effective
            },
            child: Text('Confirmer', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  // Actions à propos
  void _showDeveloperInfo() {
    print('Infos développeur');
    // Future: Modal avec infos équipe
  }

  void _openTerms() {
    print('Ouverture conditions d\'utilisation');
    // Future: WebView ou navigateur externe
  }

  void _openPrivacyPolicy() {
    print('Ouverture politique confidentialité');
    // Future: WebView ou navigateur externe
  }

  void _reportBug() {
    print('Signalement de bug');
    // Future: Formulaire ou email
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de section
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        // Contenu de section
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? AppColors.textPrimary : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
