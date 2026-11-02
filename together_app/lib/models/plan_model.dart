import 'dart:convert';

class ItineraryItem {
  final String id;
  final String time;
  final String title;
  final String notes;
  final bool isCompleted;

  ItineraryItem({
    required this.id,
    required this.time,
    required this.title,
    this.notes = '',
    this.isCompleted = false,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'] ?? '',
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      notes: json['notes'] ?? '',
      isCompleted: json['is_completed'] == true || json['isCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'title': title,
      'notes': notes,
      'is_completed': isCompleted,
    };
  }
}

class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String paidBy; // 'partner1', 'partner2', 'split'
  final String category;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    this.category = 'General',
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      paidBy: json['paid_by'] ?? json['paidBy'] ?? 'split',
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'paid_by': paidBy,
      'category': category,
    };
  }
}

class PlanModel {
  final String id;
  final String coupleId;
  final String title;
  final String planType; // 'trip', 'date', 'vacation', 'celebration'
  final String startDate;
  final String? endDate;
  final String? location;
  final String? notes;
  final double budget;
  final List<ItineraryItem> itinerary;
  final List<ExpenseItem> expenses;
  final bool isCompleted;
  final DateTime? createdAt;

  PlanModel({
    required this.id,
    required this.coupleId,
    required this.title,
    required this.planType,
    required this.startDate,
    this.endDate,
    this.location,
    this.notes,
    this.budget = 0.0,
    required this.itinerary,
    required this.expenses,
    this.isCompleted = false,
    this.createdAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    List<ItineraryItem> itItems = [];
    if (json['itinerary'] != null) {
      final dynamic raw = json['itinerary'];
      final list = raw is String ? (jsonDecode(raw) as List) : (raw as List);
      itItems = list.map((i) => ItineraryItem.fromJson(Map<String, dynamic>.from(i))).toList();
    }

    List<ExpenseItem> expItems = [];
    if (json['expenses'] != null) {
      final dynamic raw = json['expenses'];
      final list = raw is String ? (jsonDecode(raw) as List) : (raw as List);
      expItems = list.map((e) => ExpenseItem.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    return PlanModel(
      id: json['id'] ?? '',
      coupleId: json['couple_id'] ?? '',
      title: json['title'] ?? '',
      planType: json['plan_type'] ?? 'date',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      location: json['location'],
      notes: json['notes'],
      budget: (json['budget'] is num) ? (json['budget'] as num).toDouble() : 0.0,
      itinerary: itItems,
      expenses: expItems,
      isCompleted: json['is_completed'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  double get totalExpenses {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }
}
