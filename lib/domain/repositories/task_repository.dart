import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();

  Future<Task?> getTaskById(String id);

  Future<String> createTask({
    required String title,
    required String description,
    required String projectId,
    DateTime? deadline,
    bool isUrgent = false,
  });

  Future<void> updateTask(Task task);

  Future<void> deleteTask(String id);

  Future<List<Task>> getTasksByProjectId(String projectId);

  Future<List<Task>> getTasksByStatus(TaskStatus status);

  Future<List<Task>> getActiveTasksForProject(String projectId);

  Future<List<Task>> getCompletedTasksForProject(String projectId);

  Future<List<Task>> getUrgentTasks();

  Future<List<Task>> getOverdueTasks();

  Future<List<Task>> getTodayTasks();

  Future<List<Task>> getWeekTasks();
}
