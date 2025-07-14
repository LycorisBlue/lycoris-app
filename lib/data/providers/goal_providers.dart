import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../repositories/goal_repository_impl.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl();
});

/// Provider pour la liste de tous les objectifs
final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repository = ref.read(goalRepositoryProvider);
  return repository.getAllGoals();
});

/// Provider pour les objectifs actifs uniquement
final activeGoalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repository = ref.read(goalRepositoryProvider);
  return repository.getActiveGoals();
});

/// Provider pour les objectifs en retard
final overdueGoalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repository = ref.read(goalRepositoryProvider);
  return repository.getOverdueGoals();
});

/// Provider pour les objectifs terminés
final completedGoalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repository = ref.read(goalRepositoryProvider);
  return repository.getCompletedGoals();
});

/// Permet de modifier les données et notifier les widgets
class GoalNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  GoalNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadGoals();
  }

  final GoalRepository _repository;

  /// Charge tous les objectifs
  Future<void> loadGoals() async {
    state = const AsyncValue.loading();
    try {
      final goals = await _repository.getAllGoals();
      state = AsyncValue.data(goals);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Crée un nouvel objectif
  Future<String?> createGoal({required String title, required String description, required DateTime deadline}) async {
    try {
      final id = await _repository.createGoal(title: title, description: description, deadline: deadline);
      await loadGoals(); // Recharge la liste
      return id;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  /// Met à jour un objectif existant
  Future<bool> updateGoal(Goal goal) async {
    try {
      await _repository.updateGoal(goal);
      await loadGoals(); // Recharge la liste
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Met à jour la progression d'un objectif
  Future<bool> updateProgress(String goalId, double progress) async {
    try {
      final goal = await _repository.getGoalById(goalId);
      if (goal == null) return false;

      final updatedGoal = goal.copyWith(progress: progress, isCompleted: progress >= 1.0);

      return await updateGoal(updatedGoal);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Marque un objectif comme terminé
  Future<bool> completeGoal(String goalId) async {
    try {
      final goal = await _repository.getGoalById(goalId);
      if (goal == null) return false;

      final completedGoal = goal.copyWith(isCompleted: true, progress: 1.0);

      return await updateGoal(completedGoal);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Supprime un objectif
  Future<bool> deleteGoal(String goalId) async {
    try {
      await _repository.deleteGoal(goalId);
      await loadGoals(); // Recharge la liste
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

/// Provider pour le GoalNotifier
final goalNotifierProvider = StateNotifierProvider<GoalNotifier, AsyncValue<List<Goal>>>((ref) {
  final repository = ref.read(goalRepositoryProvider);
  return GoalNotifier(repository);
});
