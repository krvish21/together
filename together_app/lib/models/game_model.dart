import 'dart:convert';

class GameModel {
  final String id;
  final String coupleId;
  final String gameType;
  final String title;
  final String status; // 'active', 'completed'
  final String currentTurnPartner; // 'partner1', 'partner2', 'both'
  final int streakCount;
  final Map<String, dynamic> gameData;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  GameModel({
    required this.id,
    required this.coupleId,
    required this.gameType,
    required this.title,
    required this.status,
    required this.currentTurnPartner,
    required this.streakCount,
    required this.gameData,
    this.updatedAt,
    this.createdAt,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> parsedData = {};
    if (json['game_data'] != null) {
      if (json['game_data'] is Map) {
        parsedData = Map<String, dynamic>.from(json['game_data']);
      } else if (json['game_data'] is String) {
        try {
          parsedData = Map<String, dynamic>.from(jsonDecode(json['game_data']));
        } catch (_) {}
      }
    }

    return GameModel(
      id: json['id'] ?? '',
      coupleId: json['couple_id'] ?? '',
      gameType: json['game_type'] ?? 'would_you_rather',
      title: json['title'] ?? 'Game',
      status: json['status'] ?? 'active',
      currentTurnPartner: json['current_turn_partner'] ?? 'both',
      streakCount: json['streak_count'] ?? 0,
      gameData: parsedData,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  bool isMyTurn(String myRole) {
    if (status == 'completed') return false;
    if (currentTurnPartner == 'both') return true;
    return currentTurnPartner == myRole;
  }

  String get gameTypeIcon {
    switch (gameType) {
      case 'would_you_rather':
        return '🤔';
      case 'this_or_that':
        return '⚖️';
      case 'truth_or_dare':
        return '🎭';
      case 'guess_my_answer':
        return '🎯';
      case 'who_knows_better':
        return '🏆';
      default:
        return '🎲';
    }
  }

  String get gameTypeLabel {
    switch (gameType) {
      case 'would_you_rather':
        return 'Would You Rather?';
      case 'this_or_that':
        return 'This or That';
      case 'truth_or_dare':
        return 'Truth or Dare';
      case 'guess_my_answer':
        return 'Guess My Answer';
      case 'who_knows_better':
        return 'Who Knows Better?';
      default:
        return 'Couple Game';
    }
  }
}
