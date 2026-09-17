class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String provider;
  final DateTime createdAt;
  final int streak;
  final int totalXp;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.provider,
    required this.createdAt,
    this.photoUrl,
    this.streak = 0,
    this.totalXp = 0,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Học viên NihonGo',
      provider: map['provider'] as String? ?? 'email',
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      streak: map['streak'] as int? ?? 0,
      totalXp: map['totalXp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
      'streak': streak,
      'totalXp': totalXp,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? provider,
    DateTime? createdAt,
    int? streak,
    int? totalXp,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      streak: streak ?? this.streak,
      totalXp: totalXp ?? this.totalXp,
    );
  }
}
