import 'package:cloud_firestore/cloud_firestore.dart';

class UserWalletModel {
  final int coins;
  final int totalSpent;
  final int totalEarned;
  final String? lastDailyRewardDate;

  UserWalletModel({
    required this.coins,
    required this.totalSpent,
    this.totalEarned = 0,
    this.lastDailyRewardDate,
  });

  factory UserWalletModel.initial() {
    return UserWalletModel(
      coins: 0,
      totalSpent: 0,
      totalEarned: 0,
      lastDailyRewardDate: null,
    );
  }

  factory UserWalletModel.fromJson(Map<String, dynamic> json) {
    return UserWalletModel(
      coins: json['coins'] ?? 0,
      totalSpent: json['totalSpent'] ?? 0,
      totalEarned: json['totalEarned'] ?? 0,
      lastDailyRewardDate: json['lastDailyRewardDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'totalSpent': totalSpent,
      'totalEarned': totalEarned,
      'lastDailyRewardDate': lastDailyRewardDate,
    };
  }

  UserWalletModel copyWith({
    int? coins,
    int? totalSpent,
    int? totalEarned,
    String? lastDailyRewardDate,
  }) {
    return UserWalletModel(
      coins: coins ?? this.coins,
      totalSpent: totalSpent ?? this.totalSpent,
      totalEarned: totalEarned ?? this.totalEarned,
      lastDailyRewardDate: lastDailyRewardDate ?? this.lastDailyRewardDate,
    );
  }

  @override
  String toString() {
    return 'UserWalletModel(coins: $coins, totalSpent: $totalSpent, totalEarned: $totalEarned, lastDailyRewardDate: $lastDailyRewardDate)';
  }
}
