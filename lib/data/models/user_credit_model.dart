import 'package:cloud_firestore/cloud_firestore.dart';

class UserCreditModel {
  final int balance;
  final int totalSpent;
  final DateTime? lastDailyGrant;

  UserCreditModel({
    required this.balance,
    required this.totalSpent,
    this.lastDailyGrant,
  });

  factory UserCreditModel.initial() {
    return UserCreditModel(
      balance: 0,
      totalSpent: 0,
      lastDailyGrant: null,
    );
  }

  factory UserCreditModel.fromJson(Map<String, dynamic> json) {
    return UserCreditModel(
      balance: json['balance'] ?? 0,
      totalSpent: json['totalSpent'] ?? 0,
      lastDailyGrant: json['lastDailyGrant'] != null
          ? (json['lastDailyGrant'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'totalSpent': totalSpent,
      'lastDailyGrant': lastDailyGrant != null
          ? Timestamp.fromDate(lastDailyGrant!)
          : null,
    };
  }

  UserCreditModel copyWith({
    int? balance,
    int? totalSpent,
    DateTime? lastDailyGrant,
  }) {
    return UserCreditModel(
      balance: balance ?? this.balance,
      totalSpent: totalSpent ?? this.totalSpent,
      lastDailyGrant: lastDailyGrant ?? this.lastDailyGrant,
    );
  }

  @override
  String toString() {
    return 'UserCreditModel(balance: $balance, totalSpent: $totalSpent, lastDailyGrant: $lastDailyGrant)';
  }
}
