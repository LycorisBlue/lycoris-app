/// Entité métier Project - Représente un projet lié à un objectif.
/// Entity pure sans dépendances externes, contient la logique métier.
/// Progression calculée automatiquement selon les tâches terminées.
class Project {
  final String id;
  final String title;
  final String description;
  final String goalId;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isCompleted;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.goalId,
    required this.deadline,
    required this.createdAt,
    this.updatedAt,
    required this.isCompleted,
  });

  bool get isOverdue => DateTime.now().isAfter(deadline) && !isCompleted;
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  String get status {
    if (isCompleted) return 'Terminé';
    if (isOverdue) return 'En retard';
    return 'En cours';
  }

  bool get isValid => title.trim().isNotEmpty && goalId.trim().isNotEmpty;

  Project copyWith({String? title, String? description, String? goalId, DateTime? deadline, bool? isCompleted}) {
    return Project(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      goalId: goalId ?? this.goalId,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
