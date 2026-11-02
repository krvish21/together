class ReminderModel {
  final String id;
  final String coupleId;
  final String title;
  final String? note;
  final String? scheduledAt;
  final bool isRecurring;
  final String recurrenceRule;
  final String assignedTo;
  final String style;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? reaction;
  final DateTime? createdAt;

  ReminderModel({
    required this.id,
    required this.coupleId,
    required this.title,
    this.note,
    this.scheduledAt,
    this.isRecurring = false,
    this.recurrenceRule = 'none',
    this.assignedTo = 'both',
    this.style = 'gentle',
    this.isCompleted = false,
    this.completedAt,
    this.reaction,
    this.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] ?? '',
      coupleId: json['couple_id'] ?? '',
      title: json['title'] ?? '',
      note: json['note'],
      scheduledAt: json['scheduled_at'],
      isRecurring: json['is_recurring'] == true,
      recurrenceRule: json['recurrence_rule'] ?? 'none',
      assignedTo: json['assigned_to'] ?? 'both',
      style: json['style'] ?? 'gentle',
      isCompleted: json['is_completed'] == true,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
      reaction: json['reaction'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  String get styleIcon {
    switch (style) {
      case 'hug':
        return '🫂';
      case 'playful':
        return '🐱';
      case 'urgent':
        return '⚡';
      case 'gentle':
      default:
        return '🌸';
    }
  }
}
