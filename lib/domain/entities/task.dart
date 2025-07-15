/// Statuts possibles d'une tâche
enum TaskStatus {
  todo,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case TaskStatus.todo:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.completed:
        return 'Terminée';
    }
  }
}

/// Entité métier Task - Représente une tâche liée à un projet.
/// Entity pure sans dépendances externes, contient la logique métier.
class Task {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final TaskStatus status;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isUrgent;

  const Task({
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

  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue => deadline != null && DateTime.now().isAfter(deadline!) && !isCompleted;
  int get daysRemaining => deadline?.difference(DateTime.now()).inDays ?? 0;

  String get statusDisplay => status.displayName;

  bool get isValid => title.trim().isNotEmpty && projectId.trim().isNotEmpty;

  Task copyWith({String? title, String? description, String? projectId, TaskStatus? status, DateTime? deadline, bool? isUrgent}) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $statusDisplay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
