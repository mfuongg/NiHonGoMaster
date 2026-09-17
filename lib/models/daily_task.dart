class DailyTask {
  final String id;
  final String type;
  final String icon;
  final String title;
  final String description;
  final int target;
  final int rewardXp;
  final int progress;
  final bool isClaimed;

  const DailyTask({
    required this.id,
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
    required this.target,
    required this.rewardXp,
    this.progress = 0,
    this.isClaimed = false,
  });

  bool get isCompleted => progress >= target;

  double get completionRate {
    if (target <= 0) return 0;
    return (progress / target).clamp(0.0, 1.0).toDouble();
  }

  DailyTask copyWith({
    String? id,
    String? type,
    String? icon,
    String? title,
    String? description,
    int? target,
    int? rewardXp,
    int? progress,
    bool? isClaimed,
  }) {
    return DailyTask(
      id: id ?? this.id,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      target: target ?? this.target,
      rewardXp: rewardXp ?? this.rewardXp,
      progress: progress ?? this.progress,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'icon': icon,
      'title': title,
      'description': description,
      'target': target,
      'rewardXp': rewardXp,
      'progress': progress,
      'isClaimed': isClaimed,
    };
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      icon: map['icon'] as String? ?? '🎯',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      target: map['target'] as int? ?? 1,
      rewardXp: map['rewardXp'] as int? ?? 0,
      progress: map['progress'] as int? ?? 0,
      isClaimed: map['isClaimed'] as bool? ?? false,
    );
  }
}
