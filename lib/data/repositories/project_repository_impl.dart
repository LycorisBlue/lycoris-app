import 'package:uuid/uuid.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';
import '../services/database_service.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  static const _uuid = Uuid();

  @override
  Future<List<Project>> getAllProjects() async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('projects', orderBy: 'createdAt DESC');
      return maps.map((map) => ProjectModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des projets: $e');
    }
  }

  @override
  Future<Project?> getProjectById(String id) async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('projects', where: 'id = ?', whereArgs: [id], limit: 1);

      if (maps.isEmpty) return null;
      return ProjectModel.fromMap(maps.first).toEntity();
    } catch (e) {
      throw Exception('Erreur lors de la récupération du projet $id: $e');
    }
  }

  @override
  Future<String> createProject({
    required String title,
    required String description,
    required String goalId,
    required DateTime deadline,
  }) async {
    try {
      final id = _uuid.v4();
      final project = Project(
        id: id,
        title: title,
        description: description,
        goalId: goalId,
        deadline: deadline,
        createdAt: DateTime.now(),
        updatedAt: null,
        isCompleted: false,
      );

      final model = ProjectModel.fromEntity(project);
      final db = await DatabaseService.database;
      await db.insert('projects', model.toMap());

      return id;
    } catch (e) {
      throw Exception('Erreur lors de la création du projet: $e');
    }
  }

  @override
  Future<void> updateProject(Project project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      final db = await DatabaseService.database;

      final rowsAffected = await db.update('projects', model.toMap(), where: 'id = ?', whereArgs: [project.id]);

      if (rowsAffected == 0) {
        throw Exception('Projet avec l\'ID ${project.id} introuvable');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du projet: $e');
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      final db = await DatabaseService.database;

      final rowsAffected = await db.delete('projects', where: 'id = ?', whereArgs: [id]);

      if (rowsAffected == 0) {
        throw Exception('Projet avec l\'ID $id introuvable');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du projet: $e');
    }
  }

  @override
  Future<List<Project>> getProjectsByGoalId(String goalId) async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('projects', where: 'goalId = ?', whereArgs: [goalId], orderBy: 'deadline ASC');
      return maps.map((map) => ProjectModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des projets pour l\'objectif $goalId: $e');
    }
  }

  @override
  Future<List<Project>> getActiveProjects() async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('projects', where: 'isCompleted = ?', whereArgs: [0], orderBy: 'deadline ASC');
      return maps.map((map) => ProjectModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des projets actifs: $e');
    }
  }

  @override
  Future<List<Project>> getOverdueProjects() async {
    try {
      final db = await DatabaseService.database;
      final now = DateTime.now().toIso8601String();
      final maps = await db.query(
        'projects',
        where: 'deadline < ? AND isCompleted = ?',
        whereArgs: [now, 0],
        orderBy: 'deadline ASC',
      );
      return maps.map((map) => ProjectModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des projets en retard: $e');
    }
  }

  @override
  Future<List<Project>> getCompletedProjects() async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('projects', where: 'isCompleted = ?', whereArgs: [1], orderBy: 'updatedAt DESC');
      return maps.map((map) => ProjectModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des projets terminés: $e');
    }
  }
}
