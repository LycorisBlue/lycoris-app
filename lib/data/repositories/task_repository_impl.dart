import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';

class TaskRepositoryImpl implements TaskRepository {
  static const _uuid = Uuid();

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('tasks', orderBy: 'createdAt DESC');
      return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches: $e');
    }
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id], limit: 1);

      if (maps.isEmpty) return null;
      return TaskModel.fromMap(maps.first).toEntity();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la tâche $id: $e');
    }
  }

  @override
  Future<String> createTask({
    required String title,
    required String description,
    required String projectId,
    DateTime? deadline,
    bool isUrgent = false,
  }) async {
    try {
      final id = _uuid.v4();
      final task = Task(
        id: id,
        title: title,
        description: description,
        projectId: projectId,
        status: TaskStatus.todo,
        deadline: deadline,
        createdAt: DateTime.now(),
        updatedAt: null,
        isUrgent: isUrgent,
      );

      final model = TaskModel.fromEntity(task);
      final db = await DatabaseService.database;
      await db.insert('tasks', model.toMap());

      return id;
    } catch (e) {
      throw Exception('Erreur lors de la création de la tâche: $e');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task);
      final db = await DatabaseService.database;

      final rowsAffected = await db.update('tasks', model.toMap(), where: 'id = ?', whereArgs: [task.id]);

      if (rowsAffected == 0) {
        throw Exception('Tâche avec l\'ID ${task.id} introuvable');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la tâche: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final db = await DatabaseService.database;

      final rowsAffected = await db.delete('tasks', where: 'id = ?', whereArgs: [id]);

      if (rowsAffected == 0) {
        throw Exception('Tâche avec l\'ID $id introuvable');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la tâche: $e');
    }
  }

  @override
  Future<List<Task>> getTasksByProjectId(String projectId) async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('tasks', where: 'projectId = ?', whereArgs: [projectId], orderBy: 'createdAt ASC');
      return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches pour le projet $projectId: $e');
    }
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('tasks', where: 'status = ?', whereArgs: [status.index], orderBy: 'createdAt ASC');
      return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches par statut: $e');
    }
  }

  @override
  Future<List<Task>> getActiveTasksForProject(String projectId) async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query(
        'tasks',
        where: 'projectId = ? AND status != ?',
        whereArgs: [projectId, TaskStatus.completed.index],
        orderBy: 'createdAt ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches actives: $e');
    }
  }

  @override
  Future<List<Task>> getCompletedTasksForProject(String projectId) async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query(
        'tasks',
        where: 'projectId = ? AND status = ?',
        whereArgs: [projectId, TaskStatus.completed.index],
        orderBy: 'updatedAt DESC',
      );
      return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches terminées: $e');
    }
  }

  @override
  Future<List<Task>> getUrgentTasks() async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query(
        'tasks',
        where: 'isUrgent = ? AND status != ?',
        whereArgs: [1, TaskStatus.completed.index],
        orderBy: 'deadline ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches urgentes: $e');
    }
  }

  @override
  Future<List<Task>> getOverdueTasks() async {
    try {
      final db = await DatabaseService.database;
      final now = DateTime.now().toIso8601String();
      final maps = await db.query(
        'tasks',
        where: 'deadline < ? AND status != ?',
        whereArgs: [now, TaskStatus.completed.index],
        orderBy: 'deadline ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches en retard: $e');
    }
  }

  @override
  Future<List<Task>> getTodayTasks() async {
    try {
      final db = await DatabaseService.database;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

      final maps = await db.query(
        'tasks',
        where: 'deadline >= ? AND deadline <= ?',
        whereArgs: [startOfDay, endOfDay],
        orderBy: 'deadline ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches d\'aujourd\'hui: $e');
    }
  }

  @override
  Future<List<Task>> getWeekTasks() async {
    try {
      final db = await DatabaseService.database;
      final now = DateTime.now();
      final weekEnd = now.add(const Duration(days: 7)).toIso8601String();

      final maps = await db.query(
        'tasks',
        where: 'deadline <= ? AND status != ?',
        whereArgs: [weekEnd, TaskStatus.completed.index],
        orderBy: 'deadline ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches de la semaine: $e');
    }
  }
}
