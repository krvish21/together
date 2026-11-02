class CuteMessageModel {
  final String id;
  final String coupleId;
  final String senderPartner;
  final String messageType; // 'hug', 'kiss', 'miss_you', 'note', 'surprise'
  final String? content;
  final bool isSurprise;
  final DateTime? revealAt;
  final bool isOpened;
  final String? reaction;
  final DateTime? createdAt;

  CuteMessageModel({
    required this.id,
    required this.coupleId,
    required this.senderPartner,
    required this.messageType,
    this.content,
    this.isSurprise = false,
    this.revealAt,
    this.isOpened = true,
    this.reaction,
    this.createdAt,
  });

  factory CuteMessageModel.fromJson(Map<String, dynamic> json) {
    return CuteMessageModel(
      id: json['id'] ?? '',
      coupleId: json['couple_id'] ?? '',
      senderPartner: json['sender_partner'] ?? 'partner1',
      messageType: json['message_type'] ?? 'note',
      content: json['content'],
      isSurprise: json['is_surprise'] == true,
      revealAt: json['reveal_at'] != null ? DateTime.tryParse(json['reveal_at']) : null,
      isOpened: json['is_opened'] == true,
      reaction: json['reaction'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  String get typeIcon {
    switch (messageType) {
      case 'hug':
        return '🫂';
      case 'kiss':
        return '💋';
      case 'miss_you':
        return '🥺';
      case 'surprise':
        return '🎁';
      case 'note':
      default:
        return '💌';
    }
  }

  String get typeTitle {
    switch (messageType) {
      case 'hug':
        return 'Warm Virtual Hug';
      case 'kiss':
        return 'Sweet Virtual Kiss';
      case 'miss_you':
        return 'I Miss You!';
      case 'surprise':
        return 'Surprise Note';
      case 'note':
      default:
        return 'Love Note';
    }
  }
}
