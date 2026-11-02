class QuestionModel {
  final String id;
  final String coupleId;
  final String questionText;
  final String category;
  final String? p1Answer;
  final String? p2Answer;
  final DateTime? p1AnsweredAt;
  final DateTime? p2AnsweredAt;
  final bool isRevealed;
  final bool isSaved;
  final bool isDaily;
  final String? dailyDate;
  final DateTime? createdAt;

  QuestionModel({
    required this.id,
    required this.coupleId,
    required this.questionText,
    required this.category,
    this.p1Answer,
    this.p2Answer,
    this.p1AnsweredAt,
    this.p2AnsweredAt,
    this.isRevealed = false,
    this.isSaved = false,
    this.isDaily = false,
    this.dailyDate,
    this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      coupleId: json['couple_id'] ?? '',
      questionText: json['question_text'] ?? '',
      category: json['category'] ?? 'Deep',
      p1Answer: json['p1_answer'],
      p2Answer: json['p2_answer'],
      p1AnsweredAt: json['p1_answered_at'] != null ? DateTime.tryParse(json['p1_answered_at']) : null,
      p2AnsweredAt: json['p2_answered_at'] != null ? DateTime.tryParse(json['p2_answered_at']) : null,
      isRevealed: json['is_revealed'] == true,
      isSaved: json['is_saved'] == true,
      isDaily: json['is_daily'] == true,
      dailyDate: json['daily_date'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  bool hasAnswered(String partnerRole) {
    if (partnerRole == 'partner1') {
      return p1Answer != null && p1Answer!.isNotEmpty;
    }
    return p2Answer != null && p2Answer!.isNotEmpty;
  }

  bool hasPartnerAnswered(String partnerRole) {
    if (partnerRole == 'partner1') {
      return p2Answer != null && p2Answer!.isNotEmpty;
    }
    return p1Answer != null && p1Answer!.isNotEmpty;
  }

  String? getMyAnswer(String partnerRole) {
    return partnerRole == 'partner1' ? p1Answer : p2Answer;
  }

  String? getPartnerAnswer(String partnerRole) {
    return partnerRole == 'partner1' ? p2Answer : p1Answer;
  }

  bool get bothAnswered => (p1Answer != null && p1Answer!.isNotEmpty) &&
                           (p2Answer != null && p2Answer!.isNotEmpty);
}
