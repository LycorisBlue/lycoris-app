import 'package:uuid/uuid.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../models/goal_model.dart';
import '../services/database_service.dart';

class GoalRepositoryImpl implements GoalRepository {
  static const _uuid = Uuid();

  @override
  Future<List<Goal>> getAllGoals() async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('goals', orderBy: 'createdAt DESC');
      return maps.map((map) => GoalModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs: $e');
    }
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('goals', where: 'id = ?', whereArgs: [id], limit: 1);

      if (maps.isEmpty) return null;
      return GoalModel.fromMap(maps.first).toEntity();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'objectif $id: $e');
    }
  }

  @override
  Future<String> createGoal({required String title, required String description, required DateTime deadline}) async {
    try {
      final id = _uuid.v4();
      final goal = Goal(
        id: id,
        title: title,
        description: description,
        deadline: deadline,
        progress: 0.0,
        createdAt: DateTime.now(),
        updatedAt: null,
        isCompleted: false,
      );

      final model = GoalModel.fromEntity(goal);
      final db = await DatabaseService.database;
      await db.insert('goals', model.toMap());

      return id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'objectif: $e');
    }
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      final db = await DatabaseService.database;

      final rowsAffected = await db.update('goals', model.toMap(), where: 'id = ?', whereArgs: [goal.id]);

      if (rowsAffected == 0) {
        throw Exception('Objectif avec l\'ID ${goal.id} introuvable');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'objectif: $e');
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      final db = await DatabaseService.database;

      final rowsAffected = await db.delete('goals', where: 'id = ?', whereArgs: [id]);

      if (rowsAffected == 0) {
        throw Exception('Objectif avec l\'ID $id introuvable');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'objectif: $e');
    }
  }

  @override
  Future<List<Goal>> getActiveGoals() async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('goals', where: 'isCompleted = ?', whereArgs: [0], orderBy: 'deadline ASC');
      return maps.map((map) => GoalModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs actifs: $e');
    }
  }

  @override
  Future<List<Goal>> getOverdueGoals() async {
    try {
      final db = await DatabaseService.database;
      final now = DateTime.now().toIso8601String();
      final maps = await db.query(
        'goals',
        where: 'deadline < ? AND isCompleted = ?',
        whereArgs: [now, 0],
        orderBy: 'deadline ASC',
      );
      return maps.map((map) => GoalModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs en retard: $e');
    }
  }

  @override
  Future<List<Goal>> getCompletedGoals() async {
    try {
      final db = await DatabaseService.database;
      final maps = await db.query('goals', where: 'isCompleted = ?', whereArgs: [1], orderBy: 'updatedAt DESC');
      return maps.map((map) => GoalModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs terminés: $e');
    }
  }
}
