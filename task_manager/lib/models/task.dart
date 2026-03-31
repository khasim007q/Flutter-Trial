class Task {
  final int id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String status;
  final int? blockedById;
  final bool isRecurring;
  final String? recurrenceType;
  final DateTime createdAt;
  Task? blockedByTask;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
    this.isRecurring = false,
    this.recurrenceType,
    required this.createdAt,
    this.blockedByTask,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      blockedById: json['blocked_by_id'],
      isRecurring: json['is_recurring'] ?? false,
      recurrenceType: json['recurrence_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'status': status,
      'blocked_by_id': blockedById,
      'is_recurring': isRecurring,
      'recurrence_type': recurrenceType,
    };
  }
}
