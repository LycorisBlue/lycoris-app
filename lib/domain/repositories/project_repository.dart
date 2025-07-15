import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getAllProjects();

  Future<Project?> getProjectById(String id);

  Future<String> createProject({
    required String title,
    required String description,
    required String goalId,
    required DateTime deadline,
  });

  Future<void> updateProject(Project project);

  Future<void> deleteProject(String id);

  Future<List<Project>> getProjectsByGoalId(String goalId);

  Future<List<Project>> getActiveProjects();

  Future<List<Project>> getOverdueProjects();

  Future<List<Project>> getCompletedProjects();
}
