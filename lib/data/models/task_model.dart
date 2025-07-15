/// Model pour la conversion entre Entity Task et base de données.
/// Gère la sérialisation/désérialisation vers SQLite (Map<String, dynamic>).
/// Types adaptés pour la DB : String pour DateTime, int pour enum et bool.
import '../../domain/entities/task.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final int status; // TaskStatus → int pour SQLite
  final String? deadline; // DateTime? → String? pour SQLite
  final String createdAt; // DateTime → String pour SQLite
  final String? updatedAt; // DateTime? → String? pour SQLite
  final int isUrgent; // bool → int pour SQLite (0/1)

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.status,
    this.deadline,
    required this.createdAt,
    this.updatedAt,
    required this.isUrgent,
  });

  /// Convertit le Model vers l'Entity métier
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      projectId: projectId,
      status: TaskStatus.values[status],
      deadline: deadline != null ? DateTime.parse(deadline!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      isUrgent: isUrgent == 1,
    );
  }

  /// Crée un Model depuis une Entity
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      status: task.status.index,
      deadline: task.deadline?.toIso8601String(),
      createdAt: task.createdAt.toIso8601String(),
      updatedAt: task.updatedAt?.toIso8601String(),
      isUrgent: task.isUrgent ? 1 : 0,
    );
  }

  /// Convertit vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectId': projectId,
      'status': status,
      'deadline': deadline,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isUrgent': isUrgent,
    };
  }

  /// Crée un Model depuis une Map SQLite
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      projectId: map['projectId'] as String,
      status: map['status'] as int,
      deadline: map['deadline'] as String?,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String?,
      isUrgent: map['isUrgent'] as int,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title)';
  }
}
