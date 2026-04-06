import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final int xp;
  final int level;
  final String rankTitle;
  final String? lastLoginBonusDate;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.xp = 0,
    this.level = 1,
    this.rankTitle = 'Starter',
    this.lastLoginBonusDate,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return UserProfileModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      rankTitle: json['rankTitle'] ?? 'Starter',
      lastLoginBonusDate: json['lastLoginBonusDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'xp': xp,
      'level': level,
      'rankTitle': rankTitle,
      'lastLoginBonusDate': lastLoginBonusDate,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    int? xp,
    int? level,
    String? rankTitle,
    String? lastLoginBonusDate,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      rankTitle: rankTitle ?? this.rankTitle,
      lastLoginBonusDate: lastLoginBonusDate ?? this.lastLoginBonusDate,
    );
  }
}
