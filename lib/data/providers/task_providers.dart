import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../repositories/task_repository_impl.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl();
});

/// Provider pour la liste de toutes les tâches
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getAllTasks();
});

/// Provider pour les tâches par statut
final tasksByStatusProvider = FutureProvider.family<List<Task>, TaskStatus>((ref, status) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksByStatus(status);
});

/// Provider pour les tâches d'un projet spécifique
final tasksByProjectProvider = FutureProvider.family<List<Task>, String>((ref, projectId) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksByProjectId(projectId);
});

/// Provider pour les tâches actives d'un projet
final activeTasksByProjectProvider = FutureProvider.family<List<Task>, String>((ref, projectId) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getActiveTasksForProject(projectId);
});

/// Provider pour les tâches terminées d'un projet
final completedTasksByProjectProvider = FutureProvider.family<List<Task>, String>((ref, projectId) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getCompletedTasksForProject(projectId);
});

/// Provider pour les tâches urgentes
final urgentTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getUrgentTasks();
});

/// Provider pour les tâches en retard
final overdueTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getOverdueTasks();
});

/// Provider pour les tâches d'aujourd'hui
final todayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTodayTasks();
});

/// Provider pour les tâches de la semaine
final weekTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getWeekTasks();
});

/// Permet de modifier les données et notifier les widgets
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  TaskNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  final TaskRepository _repository;

  /// Charge toutes les tâches
  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _repository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Crée une nouvelle tâche
  Future<String?> createTask({
    required String title,
    required String description,
    required String projectId,
    DateTime? deadline,
    bool isUrgent = false,
  }) async {
    try {
      final id = await _repository.createTask(
        title: title,
        description: description,
        projectId: projectId,
        deadline: deadline,
        isUrgent: isUrgent,
      );
      await loadTasks(); // Recharge la liste
      return id;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  /// Met à jour une tâche existante
  Future<bool> updateTask(Task task) async {
    try {
      await _repository.updateTask(task);
      await loadTasks(); // Recharge la liste
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Change le statut d'une tâche
  Future<bool> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final task = await _repository.getTaskById(taskId);
      if (task == null) return false;

      final updatedTask = task.copyWith(status: newStatus);
      return await updateTask(updatedTask);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Marque une tâche comme terminée
  Future<bool> completeTask(String taskId) async {
    return await updateTaskStatus(taskId, TaskStatus.completed);
  }

  /// Met une tâche en cours
  Future<bool> startTask(String taskId) async {
    return await updateTaskStatus(taskId, TaskStatus.inProgress);
  }

  /// Remet une tâche à faire
  Future<bool> resetTask(String taskId) async {
    return await updateTaskStatus(taskId, TaskStatus.todo);
  }

  /// Toggle l'urgence d'une tâche
  Future<bool> toggleUrgent(String taskId) async {
    try {
      final task = await _repository.getTaskById(taskId);
      if (task == null) return false;

      final updatedTask = task.copyWith(isUrgent: !task.isUrgent);
      return await updateTask(updatedTask);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Supprime une tâche
  Future<bool> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      await loadTasks(); // Recharge la liste
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

/// Provider pour le TaskNotifier
final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return TaskNotifier(repository);
});
