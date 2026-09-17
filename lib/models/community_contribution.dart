class CommunityContribution {
  final String id;
  final String itemType;
  final String itemId;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  const CommunityContribution({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
  });

  factory CommunityContribution.fromMap(Map<String, dynamic> map) {
    return CommunityContribution(
      id: map['id'] as String? ?? '',
      itemType: map['itemType'] as String? ?? 'vocabulary',
      itemId: map['itemId'] as String? ?? '',
      userId: map['userId'] as String? ?? 'guest',
      userName: map['userName'] as String? ?? 'Học viên NihonGo',
      message: map['message'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemType': itemType,
      'itemId': itemId,
      'userId': userId,
      'userName': userName,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
