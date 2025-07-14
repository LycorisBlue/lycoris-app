/// Model pour la conversion entre Entity Goal et base de données.
/// Gère la sérialisation/désérialisation vers SQLite (Map<String, dynamic>).
/// Types adaptés pour la DB : String pour DateTime, int pour bool.
import '../../domain/entities/goal.dart';

class GoalModel {
  final String id;
  final String title;
  final String description;
  final String deadline; // DateTime → String pour SQLite
  final double progress;
  final String createdAt; // DateTime → String pour SQLite
  final String? updatedAt; // DateTime? → String? pour SQLite
  final int isCompleted; // bool → int pour SQLite (0/1)

  const GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.progress,
    required this.createdAt,
    this.updatedAt,
    required this.isCompleted,
  });

  /// Convertit le Model vers l'Entity métier
  Goal toEntity() {
    return Goal(
      id: id,
      title: title,
      description: description,
      deadline: DateTime.parse(deadline),
      progress: progress,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      isCompleted: isCompleted == 1,
    );
  }

  /// Crée un Model depuis une Entity
  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      deadline: goal.deadline.toIso8601String(),
      progress: goal.progress,
      createdAt: goal.createdAt.toIso8601String(),
      updatedAt: goal.updatedAt?.toIso8601String(),
      isCompleted: goal.isCompleted ? 1 : 0,
    );
  }

  /// Convertit vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline,
      'progress': progress,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isCompleted': isCompleted,
    };
  }

  /// Crée un Model depuis une Map SQLite
  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      deadline: map['deadline'] as String,
      progress: map['progress'] as double,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String?,
      isCompleted: map['isCompleted'] as int,
    );
  }

  @override
  String toString() {
    return 'GoalModel(id: $id, title: $title)';
  }
}
