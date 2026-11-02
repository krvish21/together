import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../models/couple_model.dart';
import '../models/question_model.dart';
import '../models/game_model.dart';
import '../models/plan_model.dart';
import '../models/reminder_model.dart';
import '../models/cute_message_model.dart';
import '../models/memory_model.dart';
import '../models/journal_model.dart';
import '../models/wishlist_model.dart';

class ApiService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // COUPLE
  static Future<Map<String, dynamic>> createCouple({
    required String partner1Name,
    String? anniversaryDate,
    String? relationshipStatus,
    String? themeColor,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/couples/create');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'partner1Name': partner1Name,
        'anniversaryDate': anniversaryDate,
        'relationshipStatus': relationshipStatus,
        'themeColor': themeColor,
      }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception(jsonDecode(resp.body)['error'] ?? 'Failed to create couple space');
  }

  static Future<Map<String, dynamic>> joinCouple({
    required String spaceCode,
    required String partner2Name,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/couples/join');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'spaceCode': spaceCode,
        'partner2Name': partner2Name,
      }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception(jsonDecode(resp.body)['error'] ?? 'Failed to join couple space');
  }

  static Future<CoupleModel> getCouple(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/couples/$coupleId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return CoupleModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to fetch couple');
  }

  static Future<CoupleModel> updateCouple({
    required String coupleId,
    String? partner1Name,
    String? partner2Name,
    String? anniversaryDate,
    String? relationshipStatus,
    String? themeColor,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/couples/$coupleId');
    final resp = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode({
        'partner1Name': partner1Name,
        'partner2Name': partner2Name,
        'anniversaryDate': anniversaryDate,
        'relationshipStatus': relationshipStatus,
        'themeColor': themeColor,
      }),
    );
    if (resp.statusCode == 200) {
      return CoupleModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to update couple profile');
  }

  // SYNC
  static Future<Map<String, dynamic>> getFullSync(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/sync/$coupleId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }
    throw Exception('Failed to sync couple state');
  }

  // QUESTIONS
  static Future<QuestionModel> getDailyQuestion(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/questions/$coupleId/daily');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return QuestionModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to fetch daily question');
  }

  static Future<QuestionModel> answerQuestion({
    required String coupleId,
    required String questionId,
    required String partner,
    required String answer,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/questions/$coupleId/answer');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'questionId': questionId,
        'partner': partner,
        'answer': answer,
      }),
    );
    if (resp.statusCode == 200) {
      return QuestionModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to submit answer');
  }

  static Future<QuestionModel> addCustomQuestion({
    required String coupleId,
    required String questionText,
    required String category,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/questions/$coupleId/custom');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'questionText': questionText,
        'category': category,
      }),
    );
    if (resp.statusCode == 200) {
      return QuestionModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to add custom question');
  }

  static Future<QuestionModel> toggleSaveQuestion({
    required String coupleId,
    required String questionId,
    required bool isSaved,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/questions/$coupleId/$questionId/save');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'isSaved': isSaved}),
    );
    if (resp.statusCode == 200) {
      return QuestionModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to bookmark question');
  }

  // INTERCONNECTED: Save Q&A as Journal Entry
  static Future<JournalModel> convertQuestionToJournal({
    required String coupleId,
    required String questionId,
    required String authorPartner,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/questions/$coupleId/$questionId/to-journal');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'authorPartner': authorPartner}),
    );
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      return JournalModel.fromJson(json['journalEntry']);
    }
    throw Exception('Failed to convert question to journal entry');
  }

  // GAMES
  static Future<List<GameModel>> getGames(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/games/$coupleId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((g) => GameModel.fromJson(g)).toList();
    }
    throw Exception('Failed to fetch games');
  }

  static Future<GameModel> createGame({
    required String coupleId,
    required String gameType,
    required String title,
    required Map<String, dynamic> gameData,
    required String starterPartner,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/games/$coupleId/create');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'gameType': gameType,
        'title': title,
        'gameData': gameData,
        'starterPartner': starterPartner,
      }),
    );
    if (resp.statusCode == 200) {
      return GameModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to create game');
  }

  static Future<GameModel> playTurn({
    required String coupleId,
    required String gameId,
    required String partner,
    required Map<String, dynamic> moveData,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/games/$coupleId/$gameId/turn');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'partner': partner,
        'moveData': moveData,
      }),
    );
    if (resp.statusCode == 200) {
      return GameModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to play turn');
  }

  // PLANS
  static Future<List<PlanModel>> getPlans(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/plans/$coupleId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((p) => PlanModel.fromJson(p)).toList();
    }
    throw Exception('Failed to fetch plans');
  }

  static Future<PlanModel> createPlan({
    required String coupleId,
    required String title,
    required String planType,
    required String startDate,
    String? endDate,
    String? location,
    String? notes,
    double budget = 0.0,
    List<Map<String, dynamic>>? itinerary,
    List<Map<String, dynamic>>? expenses,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/plans/$coupleId');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'planType': planType,
        'startDate': startDate,
        'endDate': endDate,
        'location': location,
        'notes': notes,
        'budget': budget,
        'itinerary': itinerary ?? [],
        'expenses': expenses ?? [],
      }),
    );
    if (resp.statusCode == 200) {
      return PlanModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to create plan');
  }

  static Future<PlanModel> updatePlan({
    required String coupleId,
    required String planId,
    String? title,
    String? planType,
    String? startDate,
    String? endDate,
    String? location,
    String? notes,
    double? budget,
    List<Map<String, dynamic>>? itinerary,
    List<Map<String, dynamic>>? expenses,
    bool? isCompleted,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/plans/$coupleId/$planId');
    final resp = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'planType': planType,
        'startDate': startDate,
        'endDate': endDate,
        'location': location,
        'notes': notes,
        'budget': budget,
        'itinerary': itinerary,
        'expenses': expenses,
        'isCompleted': isCompleted,
      }),
    );
    if (resp.statusCode == 200) {
      return PlanModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to update plan');
  }

  // INTERCONNECTED: Convert Plan to Memory
  static Future<MemoryModel> convertPlanToMemory({
    required String coupleId,
    required String planId,
    String? caption,
    List<String>? photoUrls,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/plans/$coupleId/$planId/to-memory');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'caption': caption,
        'photoUrls': photoUrls ?? [],
      }),
    );
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      return MemoryModel.fromJson(json['memory']);
    }
    throw Exception('Failed to preserve plan as memory');
  }

  // REMINDERS
  static Future<List<ReminderModel>> getReminders(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/reminders/$coupleId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((r) => ReminderModel.fromJson(r)).toList();
    }
    throw Exception('Failed to fetch reminders');
  }

  static Future<ReminderModel> createReminder({
    required String coupleId,
    required String title,
    String? note,
    String? scheduledAt,
    bool isRecurring = false,
    String recurrenceRule = 'none',
    String assignedTo = 'both',
    String style = 'gentle',
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/reminders/$coupleId');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'note': note,
        'scheduledAt': scheduledAt,
        'isRecurring': isRecurring,
        'recurrenceRule': recurrenceRule,
        'assignedTo': assignedTo,
        'style': style,
      }),
    );
    if (resp.statusCode == 200) {
      return ReminderModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to create reminder');
  }

  static Future<ReminderModel> toggleReminder({
    required String coupleId,
    required String reminderId,
    required bool isCompleted,
    String? reaction,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/reminders/$coupleId/$reminderId/toggle');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'isCompleted': isCompleted,
        'reaction': reaction,
      }),
    );
    if (resp.statusCode == 200) {
      return ReminderModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to toggle reminder');
  }

  // CUTE MESSAGES
  static Future<List<CuteMessageModel>> getCuteMessages(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/cute-messages/$coupleId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((m) => CuteMessageModel.fromJson(m)).toList();
    }
    throw Exception('Failed to fetch cute messages');
  }

  static Future<CuteMessageModel> sendCuteMessage({
    required String coupleId,
    required String senderPartner,
    required String messageType,
    String? content,
    bool isSurprise = false,
    String? revealAt,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/cute-messages/$coupleId/send');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'senderPartner': senderPartner,
        'messageType': messageType,
        'content': content,
        'isSurprise': isSurprise,
        'revealAt': revealAt,
      }),
    );
    if (resp.statusCode == 200) {
      return CuteMessageModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to send affection');
  }

  static Future<CuteMessageModel> reactToCuteMessage({
    required String coupleId,
    required String messageId,
    required String reaction,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/cute-messages/$coupleId/$messageId/react');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'reaction': reaction}),
    );
    if (resp.statusCode == 200) {
      return CuteMessageModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to react to message');
  }

  // MEMORIES
  static Future<List<MemoryModel>> getMemories(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/memories/$coupleId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((m) => MemoryModel.fromJson(m)).toList();
    }
    throw Exception('Failed to fetch memories');
  }

  static Future<List<MemoryModel>> getOnThisDay(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/memories/$coupleId/on-this-day');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((m) => MemoryModel.fromJson(m)).toList();
    }
    return [];
  }

  static Future<MemoryModel> createMemory({
    required String coupleId,
    required String title,
    String? caption,
    required String memoryDate,
    List<String>? mediaUrls,
    String? location,
    List<String>? tags,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/memories/$coupleId');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'caption': caption,
        'memoryDate': memoryDate,
        'mediaUrls': mediaUrls ?? [],
        'location': location,
        'tags': tags ?? [],
      }),
    );
    if (resp.statusCode == 200) {
      return MemoryModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to create memory');
  }

  // JOURNAL
  static Future<List<JournalModel>> getJournalEntries(String coupleId, {String? mood, String? search}) async {
    String query = '';
    if (mood != null && mood != 'All') query += 'mood=${Uri.encodeComponent(mood)}&';
    if (search != null && search.isNotEmpty) query += 'search=${Uri.encodeComponent(search)}&';
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/journal/$coupleId?$query');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((j) => JournalModel.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch journal entries');
  }

  static Future<JournalModel> createJournalEntry({
    required String coupleId,
    required String authorPartner,
    required String title,
    required String content,
    String mood = 'Happy',
    String? reflectionPrompt,
    List<String>? tags,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/journal/$coupleId');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'authorPartner': authorPartner,
        'title': title,
        'content': content,
        'mood': mood,
        'reflectionPrompt': reflectionPrompt,
        'tags': tags ?? [],
      }),
    );
    if (resp.statusCode == 200) {
      return JournalModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to create journal entry');
  }

  // WISHLIST
  static Future<List<WishlistModel>> getWishlist(String coupleId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/wishlist/$coupleId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((w) => WishlistModel.fromJson(w)).toList();
    }
    throw Exception('Failed to fetch wishlist');
  }

  static Future<WishlistModel> addWishlistItem({
    required String coupleId,
    required String title,
    required String category,
    String? notes,
    String? linkUrl,
    String? imageUrl,
    String priority = 'medium',
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/wishlist/$coupleId');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'category': category,
        'notes': notes,
        'linkUrl': linkUrl,
        'imageUrl': imageUrl,
        'priority': priority,
      }),
    );
    if (resp.statusCode == 200) {
      return WishlistModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to add wishlist item');
  }

  static Future<WishlistModel> toggleWishlistItem({
    required String coupleId,
    required String itemId,
    required bool isCompleted,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/wishlist/$coupleId/$itemId/toggle');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'isCompleted': isCompleted}),
    );
    if (resp.statusCode == 200) {
      return WishlistModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to toggle wishlist item');
  }

  // INTERCONNECTED: Turn Wishlist item into a Date Plan
  static Future<PlanModel> convertWishlistToPlan({
    required String coupleId,
    required String itemId,
    required String startDate,
    String? notes,
    String? planType,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/wishlist/$coupleId/$itemId/to-plan');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'startDate': startDate,
        'notes': notes,
        'planType': planType,
      }),
    );
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      return PlanModel.fromJson(json['plan']);
    }
    throw Exception('Failed to turn wishlist item into date plan');
  }
}
