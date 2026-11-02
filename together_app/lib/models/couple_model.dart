class CoupleModel {
  final String id;
  final String spaceCode;
  final String partner1Name;
  final String? partner2Name;
  final String? anniversaryDate;
  final String? avatarP1;
  final String? avatarP2;
  final String relationshipStatus;
  final String themeColor;
  final DateTime? createdAt;

  CoupleModel({
    required this.id,
    required this.spaceCode,
    required this.partner1Name,
    this.partner2Name,
    this.anniversaryDate,
    this.avatarP1,
    this.avatarP2,
    this.relationshipStatus = 'In Love ❤️',
    this.themeColor = '#FF6584',
    this.createdAt,
  });

  factory CoupleModel.fromJson(Map<String, dynamic> json) {
    return CoupleModel(
      id: json['id'] ?? '',
      spaceCode: json['space_code'] ?? '',
      partner1Name: json['partner1_name'] ?? 'Partner 1',
      partner2Name: json['partner2_name'],
      anniversaryDate: json['anniversary_date'],
      avatarP1: json['avatar_p1'],
      avatarP2: json['avatar_p2'],
      relationshipStatus: json['relationship_status'] ?? 'In Love ❤️',
      themeColor: json['theme_color'] ?? '#FF6584',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'space_code': spaceCode,
      'partner1_name': partner1Name,
      'partner2_name': partner2Name,
      'anniversary_date': anniversaryDate,
      'avatar_p1': avatarP1,
      'avatar_p2': avatarP2,
      'relationship_status': relationshipStatus,
      'theme_color': themeColor,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  int get daysTogether {
    if (anniversaryDate == null || anniversaryDate!.isEmpty) return 0;
    try {
      final parsed = DateTime.parse(anniversaryDate!);
      return DateTime.now().difference(parsed).inDays;
    } catch (_) {
      return 0;
    }
  }

  String getPartnerDisplayName(String myRole) {
    if (myRole == 'partner1') {
      return partner2Name ?? 'Waiting for Partner...';
    }
    return partner1Name;
  }

  String getMyDisplayName(String myRole) {
    if (myRole == 'partner1') {
      return partner1Name;
    }
    return partner2Name ?? 'Partner 2';
  }
}
