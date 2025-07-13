import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/app_drawer.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late String _currentTime;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Toutes';
  String _searchQuery = '';

  final List<String> _categories = ['Toutes', 'Travail', 'Personnel', 'Idées', 'Apprentissage', 'Projets'];

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
      items: _categories.map((category) {
        return PopupMenuItem<String>(
          value: category,
          child: Row(
            children: [
              if (category == _selectedCategory)
                Icon(Icons.check, color: AppColors.textPrimary, size: 16.sp)
              else
                SizedBox(width: 16.w),
              SizedBox(width: 8.w),
              Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: category == _selectedCategory ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() => _selectedCategory = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _getFilteredNotes();
    final pinnedNotes = filteredNotes.where((note) => note.isPinned).toList();
    final regularNotes = filteredNotes.where((note) => !note.isPinned).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Notes'),
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
            // Barre de recherche et filtres sur la même ligne

            // Barre de recherche et filtres sur la même ligne
            Container(
              margin: EdgeInsets.all(AppSizes.padding), // Ajout de margin top
              child: Row(
                children: [
                  // Barre de recherche
                  Expanded(
                    flex: 2,
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
                          hintText: 'Rechercher...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                          prefixIcon: Icon(Icons.search_outlined, color: AppColors.textTertiary, size: 20.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Bouton filtres avec menu contextuel
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

            SizedBox(height: 16.h),

            // Liste des notes
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
                children: [
                  // Notes épinglées
                  if (pinnedNotes.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.push_pin_outlined, color: AppColors.textSecondary, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text('Épinglées', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ...pinnedNotes.map(
                      (note) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _NoteItem(
                          note: note,
                          searchQuery: _searchQuery,
                          onTap: () => _editNote(note),
                          onLongPress: () => _showNoteOptions(note),
                        ),
                      ),
                    ),

                    if (regularNotes.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Container(height: 1, color: AppColors.border),
                      SizedBox(height: 16.h),
                    ],
                  ],

                  // Notes régulières
                  ...regularNotes.map(
                    (note) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _NoteItem(
                        note: note,
                        searchQuery: _searchQuery,
                        onTap: () => _editNote(note),
                        onLongPress: () => _showNoteOptions(note),
                      ),
                    ),
                  ),

                  SizedBox(height: 80.h), // Espace pour le FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNote(),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<_NoteData> _getFilteredNotes() {
    List<_NoteData> notes = _getAllNotes();

    // Filtrer par catégorie
    if (_selectedCategory != 'Toutes') {
      notes = notes.where((note) => note.category == _selectedCategory).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      notes = notes
          .where(
            (note) =>
                note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                note.content.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return notes;
  }

  List<_NoteData> _getAllNotes() {
    return [
      _NoteData(
        title: 'Idées app Flutter',
        content: 'Features à ajouter:\n- Mode sombre\n- Notifications push\n- Sync cloud\n- Export données',
        category: 'Projets',
        modifiedDate: 'Hier',
        isPinned: true,
      ),
      _NoteData(
        title: 'Liste courses',
        content: 'Pommes, bananes, lait, pain, œufs, fromage, tomates, salade',
        category: 'Personnel',
        modifiedDate: 'Aujourd\'hui',
        isPinned: true,
      ),
      _NoteData(
        title: 'Concepts Clean Architecture',
        content:
            'Séparation en couches:\n- Domain (entités, use cases)\n- Data (repositories, sources)\n- Presentation (UI, state)',
        category: 'Apprentissage',
        modifiedDate: 'Il y a 2 jours',
        isPinned: false,
      ),
      _NoteData(
        title: 'Réunion équipe - Points clés',
        content: 'Nouvelles priorités Q1:\n- Migration Flutter 3.0\n- Tests automatisés\n- Documentation API',
        category: 'Travail',
        modifiedDate: 'Il y a 3 jours',
        isPinned: false,
      ),
      _NoteData(
        title: 'Citations inspirantes',
        content: '"Le succès c\'est tomber sept fois et se relever huit fois" - Proverbe japonais',
        category: 'Personnel',
        modifiedDate: 'Il y a 1 semaine',
        isPinned: false,
      ),
      _NoteData(
        title: 'API REST best practices',
        content:
            'Bonnes pratiques:\n- Utiliser les verbes HTTP appropriés\n- Versionner les APIs\n- Gérer les erreurs proprement',
        category: 'Apprentissage',
        modifiedDate: 'Il y a 2 semaines',
        isPinned: false,
      ),
    ];
  }

  void _editNote(_NoteData note) {
    print('Éditer note: ${note.title}');
    // Future: Navigation vers éditeur
  }

  void _showNoteOptions(_NoteData note) {
    print('Options pour note: ${note.title}');
    // Future: Menu contextuel (épingler, supprimer, changer catégorie)
  }

  void _createNote() {
    print('Action: Créer nouvelle note');
    // Future: Navigation vers éditeur vide
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

class _NoteItem extends StatelessWidget {
  final _NoteData note;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NoteItem({required this.note, required this.searchQuery, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: AppColors.border, width: note.isPinned ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec titre et épingle
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                if (note.isPinned) Icon(Icons.push_pin, color: AppColors.textSecondary, size: 16.sp),
              ],
            ),

            SizedBox(height: 8.h),

            // Badge catégorie et date
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    note.category,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontSize: 10.sp),
                  ),
                ),
                const Spacer(),
                Text(note.modifiedDate, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
              ],
            ),

            SizedBox(height: 8.h),

            // Aperçu du contenu
            Text(
              note.content.length > 100 ? '${note.content.substring(0, 100)}...' : note.content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteData {
  final String title;
  final String content;
  final String category;
  final String modifiedDate;
  final bool isPinned;

  _NoteData({
    required this.title,
    required this.content,
    required this.category,
    required this.modifiedDate,
    required this.isPinned,
  });
}
