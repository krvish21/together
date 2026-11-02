class WishlistModel {
  final String id;
  final String coupleId;
  final String title;
  final String category; // 'place', 'restaurant', 'movie', 'product', 'experience'
  final String? notes;
  final String? linkUrl;
  final String? imageUrl;
  final String priority; // 'low', 'medium', 'high'
  final bool isCompleted;
  final DateTime? completedAt;
  final String? convertedToPlanId;
  final DateTime? createdAt;

  WishlistModel({
    required this.id,
    required this.coupleId,
    required this.title,
    required this.category,
    this.notes,
    this.linkUrl,
    this.imageUrl,
    this.priority = 'medium',
    this.isCompleted = false,
    this.completedAt,
    this.convertedToPlanId,
    this.createdAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'] ?? '',
      coupleId: json['couple_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'experience',
      notes: json['notes'],
      linkUrl: json['link_url'],
      imageUrl: json['image_url'],
      priority: json['priority'] ?? 'medium',
      isCompleted: json['is_completed'] == true,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
      convertedToPlanId: json['converted_to_plan_id'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  String get categoryIcon {
    switch (category) {
      case 'place':
        return '✈️';
      case 'restaurant':
        return '🍷';
      case 'movie':
        return '🎬';
      case 'product':
        return '🎁';
      case 'experience':
      default:
        return '✨';
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'place':
        return 'Places to Visit';
      case 'restaurant':
        return 'Restaurants to Try';
      case 'movie':
        return 'Movies to Watch';
      case 'product':
        return 'Things to Buy';
      case 'experience':
      default:
        return 'Experiences';
    }
  }
}
