/// Model pour la conversion entre Entity Project et base de données.
/// Gère la sérialisation/désérialisation vers SQLite (Map<String, dynamic>).
/// Types adaptés pour la DB : String pour DateTime, int pour bool.
import '../../domain/entities/project.dart';

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String goalId;
  final String deadline; // DateTime → String pour SQLite
  final String createdAt; // DateTime → String pour SQLite
  final String? updatedAt; // DateTime? → String? pour SQLite
  final int isCompleted; // bool → int pour SQLite (0/1)

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.goalId,
    required this.deadline,
    required this.createdAt,
    this.updatedAt,
    required this.isCompleted,
  });

  /// Convertit le Model vers l'Entity métier
  Project toEntity() {
    return Project(
      id: id,
      title: title,
      description: description,
      goalId: goalId,
      deadline: DateTime.parse(deadline),
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      isCompleted: isCompleted == 1,
    );
  }

  /// Crée un Model depuis une Entity
  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      title: project.title,
      description: project.description,
      goalId: project.goalId,
      deadline: project.deadline.toIso8601String(),
      createdAt: project.createdAt.toIso8601String(),
      updatedAt: project.updatedAt?.toIso8601String(),
      isCompleted: project.isCompleted ? 1 : 0,
    );
  }

  /// Convertit vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goalId': goalId,
      'deadline': deadline,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isCompleted': isCompleted,
    };
  }

  /// Crée un Model depuis une Map SQLite
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      goalId: map['goalId'] as String,
      deadline: map['deadline'] as String,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String?,
      isCompleted: map['isCompleted'] as int,
    );
  }

  @override
  String toString() {
    return 'ProjectModel(id: $id, title: $title)';
  }
}
