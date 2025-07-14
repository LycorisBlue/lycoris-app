import '../entities/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getAllGoals();

  Future<Goal?> getGoalById(String id);

  Future<String> createGoal({required String title, required String description, required DateTime deadline});

  Future<void> updateGoal(Goal goal);

  Future<void> deleteGoal(String id);

  Future<List<Goal>> getActiveGoals();

  Future<List<Goal>> getOverdueGoals();

  Future<List<Goal>> getCompletedGoals();
}
