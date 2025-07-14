/// Entité métier Goal - Représente un objectif SMART dans l'application.
/// Entity pure sans dépendances externes, contient la logique métier.
/// Progress: 0.0 à 1.0, Status calculés automatiquement.
class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final double progress;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isCompleted;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.progress,
    required this.createdAt,
    this.updatedAt,
    required this.isCompleted,
  });

  bool get isOverdue => DateTime.now().isAfter(deadline) && !isCompleted;
  int get progressPercentage => (progress * 100).round();
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;
  String get status {
    if (isCompleted) return 'Terminé';
    if (isOverdue) return 'En retard';
    return 'En cours';
  }

  bool get isValid => title.trim().isNotEmpty && progress >= 0.0 && progress <= 1.0;

  Goal copyWith({String? title, String? description, DateTime? deadline, double? progress, bool? isCompleted}) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      progress: progress ?? this.progress,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    // ignore: unnecessary_brace_in_string_interps
    return 'Goal(id: $id, title: $title, progress: ${progressPercentage}%, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
