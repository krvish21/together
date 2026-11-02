import 'dart:convert';

class MemoryModel {
  final String id;
  final String coupleId;
  final String title;
  final String? caption;
  final String memoryDate;
  final List<String> mediaUrls;
  final String? location;
  final List<String> tags;
  final String? linkedPlanId;
  final String? linkedWishlistId;
  final bool favorite;
  final DateTime? createdAt;

  MemoryModel({
    required this.id,
    required this.coupleId,
    required this.title,
    this.caption,
    required this.memoryDate,
    required this.mediaUrls,
    this.location,
    required this.tags,
    this.linkedPlanId,
    this.linkedWishlistId,
    this.favorite = false,
    this.createdAt,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    List<String> medias = [];
    if (json['media_urls'] != null) {
      final dynamic raw = json['media_urls'];
      final list = raw is String ? (jsonDecode(raw) as List) : (raw as List);
      medias = list.map((e) => e.toString()).toList();
    }

    List<String> tagList = [];
    if (json['tags'] != null) {
      final dynamic raw = json['tags'];
      final list = raw is String ? (jsonDecode(raw) as List) : (raw as List);
      tagList = list.map((e) => e.toString()).toList();
    }

    return MemoryModel(
      id: json['id'] ?? '',
      coupleId: json['couple_id'] ?? '',
      title: json['title'] ?? '',
      caption: json['caption'],
      memoryDate: json['memory_date'] ?? '',
      mediaUrls: medias,
      location: json['location'],
      tags: tagList,
      linkedPlanId: json['linked_plan_id'],
      linkedWishlistId: json['linked_wishlist_id'],
      favorite: json['favorite'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
