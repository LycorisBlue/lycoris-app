import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../repositories/project_repository_impl.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl();
});

/// Provider pour la liste de tous les projets
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getAllProjects();
});

/// Provider pour les projets actifs uniquement
final activeProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getActiveProjects();
});

/// Provider pour les projets en retard
final overdueProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getOverdueProjects();
});

/// Provider pour les projets terminés
final completedProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getCompletedProjects();
});

/// Provider pour les projets d'un objectif spécifique
final projectsByGoalProvider = FutureProvider.family<List<Project>, String>((ref, goalId) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getProjectsByGoalId(goalId);
});

/// Permet de modifier les données et notifier les widgets
class ProjectNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  ProjectNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProjects();
  }

  final ProjectRepository _repository;

  /// Charge tous les projets
  Future<void> loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _repository.getAllProjects();
      state = AsyncValue.data(projects);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Crée un nouveau projet
  Future<String?> createProject({
    required String title,
    required String description,
    required String goalId,
    required DateTime deadline,
  }) async {
    try {
      final id = await _repository.createProject(title: title, description: description, goalId: goalId, deadline: deadline);
      await loadProjects(); // Recharge la liste
      return id;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  /// Met à jour un projet existant
  Future<bool> updateProject(Project project) async {
    try {
      await _repository.updateProject(project);
      await loadProjects(); // Recharge la liste
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Marque un projet comme terminé
  Future<bool> completeProject(String projectId) async {
    try {
      final project = await _repository.getProjectById(projectId);
      if (project == null) return false;

      final completedProject = project.copyWith(isCompleted: true);
      return await updateProject(completedProject);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Supprime un projet
  Future<bool> deleteProject(String projectId) async {
    try {
      await _repository.deleteProject(projectId);
      await loadProjects(); // Recharge la liste
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

/// Provider pour le ProjectNotifier
final projectNotifierProvider = StateNotifierProvider<ProjectNotifier, AsyncValue<List<Project>>>((ref) {
  final repository = ref.read(projectRepositoryProvider);
  return ProjectNotifier(repository);
});
