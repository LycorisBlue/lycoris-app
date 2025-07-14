import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'lycoris.db';
  static const int _databaseVersion = 1;

  /// Accès singleton à la base de données
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données
  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  /// Crée toutes les tables lors de la première installation
  static Future<void> _onCreate(Database db, int version) async {
    await _createGoalsTable(db);
    await _createProjectsTable(db);
    await _createTasksTable(db);
    await _createHabitsTable(db);
    await _createNotesTable(db);
    await _createRemindersTable(db);
    await _createJournalEntriesTable(db);
    await _createHabitEntriesTable(db);
  }

  /// Gère les migrations de version
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // TODO: Gérer les migrations futures
    if (oldVersion < 2) {
      // Exemple future migration
      // await _addNewColumnToGoals(db);
    }
  }

  /// Table des objectifs
  static Future<void> _createGoalsTable(Database db) async {
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        deadline TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0.0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Table des projets (liés aux objectifs)
  static Future<void> _createProjectsTable(Database db) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        goalId TEXT NOT NULL,
        deadline TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Table des tâches (liées aux projets)
  static Future<void> _createTasksTable(Database db) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        projectId TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        deadline TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isUrgent INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Table des habitudes
  static Future<void> _createHabitsTable(Database db) async {
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        type INTEGER NOT NULL,
        currentStreak INTEGER NOT NULL DEFAULT 0,
        bestStreak INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  /// Table des entrées d'habitudes (historique quotidien)
  static Future<void> _createHabitEntriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE habit_entries (
        id TEXT PRIMARY KEY,
        habitId TEXT NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habits (id) ON DELETE CASCADE,
        UNIQUE(habitId, date)
      )
    ''');
  }

  /// Table des notes
  static Future<void> _createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'Personnel',
        isPinned INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  /// Table des rappels
  static Future<void> _createRemindersTable(Database db) async {
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        scheduledTime TEXT NOT NULL,
        type INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringPattern TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  /// Table des entrées de journal
  static Future<void> _createJournalEntriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        mood INTEGER NOT NULL,
        energy INTEGER NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  /// Ferme la base de données
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Supprime complètement la base de données (pour tests/debug)
  static Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
