import 'dart:convert';

class JournalModel {
  final String id;
  final String coupleId;
  final String authorPartner;
  final String title;
  final String content;
  final String mood;
  final String? reflectionPrompt;
  final List<String> tags;
  final List<String> photos;
  final String? linkedQuestionId;
  final DateTime? createdAt;

  JournalModel({
    required this.id,
    required this.coupleId,
    required this.authorPartner,
    required this.title,
    required this.content,
    this.mood = 'Happy',
    this.reflectionPrompt,
    required this.tags,
    required this.photos,
    this.linkedQuestionId,
    this.createdAt,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    List<String> tagList = [];
    if (json['tags'] != null) {
      final dynamic raw = json['tags'];
      final list = raw is String ? (jsonDecode(raw) as List) : (raw as List);
      tagList = list.map((e) => e.toString()).toList();
    }

    List<String> photoList = [];
    if (json['photos'] != null) {
      final dynamic raw = json['photos'];
      final list = raw is String ? (jsonDecode(raw) as List) : (raw as List);
      photoList = list.map((e) => e.toString()).toList();
    }

    return JournalModel(
      id: json['id'] ?? '',
      coupleId: json['couple_id'] ?? '',
      authorPartner: json['author_partner'] ?? 'both',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      mood: json['mood'] ?? 'Happy',
      reflectionPrompt: json['reflection_prompt'],
      tags: tagList,
      photos: photoList,
      linkedQuestionId: json['linked_question_id'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  String get moodEmoji {
    switch (mood) {
      case 'Loved':
        return '❤️';
      case 'Cozy':
        return '☕';
      case 'Adventurous':
        return '🏕️';
      case 'Grateful':
        return '🙏';
      case 'Playful':
        return '✨';
      case 'Happy':
      default:
        return '😊';
    }
  }
}
