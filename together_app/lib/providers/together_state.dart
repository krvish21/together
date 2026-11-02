import 'dart:async';
import 'package:flutter/material.dart';
import '../models/couple_model.dart';
import '../models/question_model.dart';
import '../models/game_model.dart';
import '../models/plan_model.dart';
import '../models/reminder_model.dart';
import '../models/cute_message_model.dart';
import '../models/memory_model.dart';
import '../models/journal_model.dart';
import '../models/wishlist_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/websocket_service.dart';
import '../constants/api_config.dart';

class TogetherState extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription? _wsSubscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  CoupleModel? _couple;
  CoupleModel? get couple => _couple;

  String _myRole = 'partner1'; // 'partner1' or 'partner2'
  String get myRole => _myRole;

  bool get isPartnerOnline => _isPartnerOnline;
  bool _isPartnerOnline = false;

  // Active Alert / Toast for real-time surprises
  String? _realtimeToast;
  String? get realtimeToast => _realtimeToast;

  // Live heart animation trigger counter
  int _heartAnimationTrigger = 0;
  int get heartAnimationTrigger => _heartAnimationTrigger;

  // Data Collections
  QuestionModel? _dailyQuestion;
  QuestionModel? get dailyQuestion => _dailyQuestion;

  List<QuestionModel> _questions = [];
  List<QuestionModel> get questions => _questions;

  List<GameModel> _games = [];
  List<GameModel> get games => _games;

  List<PlanModel> _plans = [];
  List<PlanModel> get plans => _plans;

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;

  List<CuteMessageModel> _cuteMessages = [];
  List<CuteMessageModel> get cuteMessages => _cuteMessages;

  List<MemoryModel> _memories = [];
  List<MemoryModel> get memories => _memories;

  List<MemoryModel> _onThisDay = [];
  List<MemoryModel> get onThisDay => _onThisDay;

  List<JournalModel> _journalEntries = [];
  List<JournalModel> get journalEntries => _journalEntries;

  List<WishlistModel> _wishlist = [];
  List<WishlistModel> get wishlist => _wishlist;

  bool get isPaired => _couple != null && _couple!.partner2Name != null && _couple!.partner2Name!.isNotEmpty;

  // Helper getters
  String get myDisplayName => _couple?.getMyDisplayName(_myRole) ?? 'Me';
  String get partnerDisplayName => _couple?.getPartnerDisplayName(_myRole) ?? 'Partner';
  int get daysTogether => _couple?.daysTogether ?? 0;

  // Initialize and check saved session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedUrl = await StorageService.getServerUrl();
      if (savedUrl != null && savedUrl.isNotEmpty) {
        ApiConfig.setCustomBaseUrl(savedUrl);
      }

      final session = await StorageService.getCoupleSession();
      final coupleId = session['coupleId'];
      final savedRole = session['myRole'];

      if (coupleId != null && coupleId.isNotEmpty) {
        _myRole = savedRole ?? 'partner1';
        await refreshAll(coupleId);
        _connectWebSocket(coupleId);
      }
    } catch (e) {
      debugPrint('[TogetherState Init Error] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Space
  Future<void> createSpace({
    required String partner1Name,
    String? anniversaryDate,
    String? relationshipStatus,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.createCouple(
        partner1Name: partner1Name,
        anniversaryDate: anniversaryDate,
        relationshipStatus: relationshipStatus,
      );
      _couple = CoupleModel.fromJson(res['couple']);
      _myRole = 'partner1';

      await StorageService.saveCoupleSession(
        coupleId: _couple!.id,
        spaceCode: _couple!.spaceCode,
        myRole: _myRole,
      );

      await refreshAll(_couple!.id);
      _connectWebSocket(_couple!.id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Join Space
  Future<void> joinSpace({
    required String spaceCode,
    required String partner2Name,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.joinCouple(
        spaceCode: spaceCode,
        partner2Name: partner2Name,
      );
      _couple = CoupleModel.fromJson(res['couple']);
      _myRole = 'partner2';

      await StorageService.saveCoupleSession(
        coupleId: _couple!.id,
        spaceCode: _couple!.spaceCode,
        myRole: _myRole,
      );

      await refreshAll(_couple!.id);
      _connectWebSocket(_couple!.id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Partner Switcher (Simulation / Dual Testing)
  Future<void> switchPartnerRole() async {
    _myRole = (_myRole == 'partner1') ? 'partner2' : 'partner1';
    await StorageService.setMyRole(_myRole);
    _wsService.updatePartner(_myRole);
    _showToast('Switched view to $myDisplayName ($myRole)');
    notifyListeners();
  }

  // Refresh All State
  Future<void> refreshAll([String? coupleId]) async {
    final cId = coupleId ?? _couple?.id;
    if (cId == null) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final sync = await ApiService.getFullSync(cId);
      _couple = CoupleModel.fromJson(sync['couple']);
      if (sync['dailyQuestion'] != null) {
        _dailyQuestion = QuestionModel.fromJson(sync['dailyQuestion']);
      }
      _questions = (sync['questions'] as List).map((q) => QuestionModel.fromJson(q)).toList();
      _games = (sync['games'] as List).map((g) => GameModel.fromJson(g)).toList();
      _plans = (sync['plans'] as List).map((p) => PlanModel.fromJson(p)).toList();
      _reminders = (sync['reminders'] as List).map((r) => ReminderModel.fromJson(r)).toList();
      _cuteMessages = (sync['cuteMessages'] as List).map((m) => CuteMessageModel.fromJson(m)).toList();
      _memories = (sync['memories'] as List).map((m) => MemoryModel.fromJson(m)).toList();
      _journalEntries = (sync['journalEntries'] as List).map((j) => JournalModel.fromJson(j)).toList();
      _wishlist = (sync['wishlist'] as List).map((w) => WishlistModel.fromJson(w)).toList();

      if (sync['roomStatus'] != null) {
        _isPartnerOnline = (sync['roomStatus']['onlineCount'] ?? 0) > 1;
      }

      // Check on this day memories
      _onThisDay = await ApiService.getOnThisDay(cId);
    } catch (e) {
      debugPrint('[TogetherState Refresh Error] $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _connectWebSocket(String coupleId) {
    _wsSubscription?.cancel();
    _wsService.connect(coupleId: coupleId, partner: _myRole);
    _wsSubscription = _wsService.events.listen(_handleWsEvent);
  }

  void _handleWsEvent(Map<String, dynamic> event) {
    final type = event['type'] ?? '';
    debugPrint('[TogetherState Handling Event] $type');

    switch (type) {
      case 'PRESENCE_UPDATE':
        final sender = event['sender'];
        final online = event['online'] == true;
        if (sender != _myRole) {
          _isPartnerOnline = online;
          if (online) {
            _showToast('$partnerDisplayName is now online ❤️');
          }
        }
        notifyListeners();
        break;

      case 'QUESTION_ANSWERED':
      case 'QUESTION_REVEALED':
      case 'NEW_DAILY_QUESTION':
      case 'CUSTOM_QUESTION_ADDED':
        if (event['message'] != null) _showToast(event['message']);
        if (type == 'QUESTION_REVEALED') _triggerHeartAnimation();
        refreshAll();
        break;

      case 'GAME_TURN_PLAYED':
      case 'GAME_COMPLETED':
      case 'GAME_STARTED':
        if (event['message'] != null) _showToast(event['message']);
        refreshAll();
        break;

      case 'CUTE_MESSAGE_RECEIVED':
        final sender = event['senderPartner'];
        if (sender != _myRole) {
          _triggerHeartAnimation();
          _showToast('$partnerDisplayName ${event['alertText'] ?? 'sent affection! ❤️'}');
        }
        refreshAll();
        break;

      case 'CUTE_MESSAGE_REACTED':
      case 'PLAN_CREATED':
      case 'PLAN_UPDATED':
      case 'REMINDER_ADDED':
      case 'REMINDER_TOGGLED':
      case 'MEMORY_ADDED':
      case 'JOURNAL_ENTRY_ADDED':
      case 'WISHLIST_ITEM_ADDED':
      case 'WISHLIST_ITEM_TOGGLED':
        if (event['message'] != null) _showToast(event['message']);
        refreshAll();
        break;

      case 'INTERACTION_EVENT':
        final sender = event['sender'];
        final action = event['action'];
        if (sender != _myRole) {
          if (action == 'pulse_hug') {
            _triggerHeartAnimation();
            _showToast('🫂 $partnerDisplayName is squeezing you right now!');
          } else if (action == 'kiss_kiss') {
            _triggerHeartAnimation();
            _showToast('💋 Mwah! A kiss from $partnerDisplayName!');
          }
        }
        break;
    }
  }

  void _showToast(String message) {
    _realtimeToast = message;
    notifyListeners();
    Timer(const Duration(seconds: 4), () {
      if (_realtimeToast == message) {
        _realtimeToast = null;
        notifyListeners();
      }
    });
  }

  void _triggerHeartAnimation() {
    _heartAnimationTrigger++;
    notifyListeners();
  }

  // QUESTIONS ACTIONS
  Future<void> submitAnswer(String questionId, String answer) async {
    if (_couple == null) return;
    try {
      final updated = await ApiService.answerQuestion(
        coupleId: _couple!.id,
        questionId: questionId,
        partner: _myRole,
        answer: answer,
      );

      final idx = _questions.indexWhere((q) => q.id == questionId);
      if (idx != -1) {
        _questions[idx] = updated;
      }
      if (_dailyQuestion?.id == questionId) {
        _dailyQuestion = updated;
      }
      if (updated.isRevealed) {
        _triggerHeartAnimation();
      }
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  Future<void> addCustomQuestion(String text, String category) async {
    if (_couple == null) return;
    try {
      final q = await ApiService.addCustomQuestion(
        coupleId: _couple!.id,
        questionText: text,
        category: category,
      );
      _questions.insert(0, q);
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // INTERCONNECTED: Question to Journal
  Future<void> convertQuestionToJournal(String questionId) async {
    if (_couple == null) return;
    try {
      final journal = await ApiService.convertQuestionToJournal(
        coupleId: _couple!.id,
        questionId: questionId,
        authorPartner: _myRole,
      );
      _journalEntries.insert(0, journal);
      _showToast('Saved Q&A to your private shared journal! 📖');
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // GAMES ACTIONS
  Future<void> playTurn(String gameId, Map<String, dynamic> moveData) async {
    if (_couple == null) return;
    try {
      final updated = await ApiService.playTurn(
        coupleId: _couple!.id,
        gameId: gameId,
        partner: _myRole,
        moveData: moveData,
      );
      final idx = _games.indexWhere((g) => g.id == gameId);
      if (idx != -1) {
        _games[idx] = updated;
      }
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  Future<void> createGame(String gameType, String title, Map<String, dynamic> gameData) async {
    if (_couple == null) return;
    try {
      final created = await ApiService.createGame(
        coupleId: _couple!.id,
        gameType: gameType,
        title: title,
        gameData: gameData,
        starterPartner: _myRole,
      );
      _games.insert(0, created);
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // CUTE MESSAGES ACTIONS
  Future<void> sendQuickAffection(String messageType, [String? content]) async {
    if (_couple == null) return;
    try {
      final created = await ApiService.sendCuteMessage(
        coupleId: _couple!.id,
        senderPartner: _myRole,
        messageType: messageType,
        content: content,
      );
      _cuteMessages.insert(0, created);
      _triggerHeartAnimation();

      if (messageType == 'hug') {
        _wsService.sendInteraction('pulse_hug');
      } else if (messageType == 'kiss') {
        _wsService.sendInteraction('kiss_kiss');
      }

      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // PLANS ACTIONS
  Future<void> createPlan({
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
    if (_couple == null) return;
    try {
      final plan = await ApiService.createPlan(
        coupleId: _couple!.id,
        title: title,
        planType: planType,
        startDate: startDate,
        endDate: endDate,
        location: location,
        notes: notes,
        budget: budget,
        itinerary: itinerary,
        expenses: expenses,
      );
      _plans.add(plan);
      _plans.sort((a, b) => a.startDate.compareTo(b.startDate));
      _showToast('Created new plan: $title 🗓️');
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // INTERCONNECTED: Plan to Memory
  Future<void> convertPlanToMemory(String planId, {String? caption, List<String>? photoUrls}) async {
    if (_couple == null) return;
    try {
      final mem = await ApiService.convertPlanToMemory(
        coupleId: _couple!.id,
        planId: planId,
        caption: caption,
        photoUrls: photoUrls,
      );
      _memories.insert(0, mem);

      final pIdx = _plans.indexWhere((p) => p.id == planId);
      if (pIdx != -1) {
        await refreshAll();
      }
      _triggerHeartAnimation();
      _showToast('Saved to Memories scrapbook! 📸');
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // REMINDERS ACTIONS
  Future<void> createReminder({
    required String title,
    String? note,
    String? scheduledAt,
    bool isRecurring = false,
    String recurrenceRule = 'none',
    String assignedTo = 'both',
    String style = 'gentle',
  }) async {
    if (_couple == null) return;
    try {
      final r = await ApiService.createReminder(
        coupleId: _couple!.id,
        title: title,
        note: note,
        scheduledAt: scheduledAt,
        isRecurring: isRecurring,
        recurrenceRule: recurrenceRule,
        assignedTo: assignedTo,
        style: style,
      );
      _reminders.insert(0, r);
      _showToast('Reminder added! ⏰');
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  Future<void> toggleReminder(String reminderId, bool isCompleted, [String? reaction]) async {
    if (_couple == null) return;
    try {
      final updated = await ApiService.toggleReminder(
        coupleId: _couple!.id,
        reminderId: reminderId,
        isCompleted: isCompleted,
        reaction: reaction,
      );
      final idx = _reminders.indexWhere((r) => r.id == reminderId);
      if (idx != -1) {
        _reminders[idx] = updated;
      }
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // MEMORIES ACTIONS
  Future<void> createMemory({
    required String title,
    String? caption,
    required String memoryDate,
    List<String>? mediaUrls,
    String? location,
    List<String>? tags,
  }) async {
    if (_couple == null) return;
    try {
      final m = await ApiService.createMemory(
        coupleId: _couple!.id,
        title: title,
        caption: caption,
        memoryDate: memoryDate,
        mediaUrls: mediaUrls,
        location: location,
        tags: tags,
      );
      _memories.insert(0, m);
      _triggerHeartAnimation();
      _showToast('Preserved new memory! 📸');
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // JOURNAL ACTIONS
  Future<void> createJournalEntry({
    required String title,
    required String content,
    String mood = 'Happy',
    String? reflectionPrompt,
    List<String>? tags,
  }) async {
    if (_couple == null) return;
    try {
      final j = await ApiService.createJournalEntry(
        coupleId: _couple!.id,
        authorPartner: _myRole,
        title: title,
        content: content,
        mood: mood,
        reflectionPrompt: reflectionPrompt,
        tags: tags,
      );
      _journalEntries.insert(0, j);
      _showToast('Journal entry saved 📖');
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // WISHLIST ACTIONS
  Future<void> addWishlistItem({
    required String title,
    required String category,
    String? notes,
    String? linkUrl,
    String? imageUrl,
    String priority = 'medium',
  }) async {
    if (_couple == null) return;
    try {
      final w = await ApiService.addWishlistItem(
        coupleId: _couple!.id,
        title: title,
        category: category,
        notes: notes,
        linkUrl: linkUrl,
        imageUrl: imageUrl,
        priority: priority,
      );
      _wishlist.insert(0, w);
      _showToast('Added to wishlist ✨');
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  Future<void> toggleWishlistItem(String itemId, bool isCompleted) async {
    if (_couple == null) return;
    try {
      final updated = await ApiService.toggleWishlistItem(
        coupleId: _couple!.id,
        itemId: itemId,
        isCompleted: isCompleted,
      );
      final idx = _wishlist.indexWhere((w) => w.id == itemId);
      if (idx != -1) {
        _wishlist[idx] = updated;
      }
      if (isCompleted) {
        _triggerHeartAnimation();
      }
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // INTERCONNECTED: Turn Wishlist to Plan
  Future<void> convertWishlistToPlan(String itemId, {required String startDate, String? notes, String? planType}) async {
    if (_couple == null) return;
    try {
      final plan = await ApiService.convertWishlistToPlan(
        coupleId: _couple!.id,
        itemId: itemId,
        startDate: startDate,
        notes: notes,
        planType: planType,
      );
      _plans.add(plan);
      _plans.sort((a, b) => a.startDate.compareTo(b.startDate));
      _showToast('Wishlist item scheduled as a date! 🗓️');
      notifyListeners();
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  // Disconnect & Logout
  Future<void> logout() async {
    _wsService.disconnect();
    _wsSubscription?.cancel();
    await StorageService.clearSession();
    _couple = null;
    _questions = [];
    _games = [];
    _plans = [];
    _reminders = [];
    _cuteMessages = [];
    _memories = [];
    _journalEntries = [];
    _wishlist = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    _wsSubscription?.cancel();
    super.dispose();
  }
}
