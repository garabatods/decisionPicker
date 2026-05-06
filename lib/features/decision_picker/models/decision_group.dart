class DecisionGroup {
  final String id;
  final String name;
  final String emoji;
  final List<String> choices;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DecisionGroup({
    required this.id,
    required this.name,
    required this.emoji,
    required this.choices,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  DecisionGroup copyWith({
    String? id,
    String? name,
    String? emoji,
    List<String>? choices,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DecisionGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      choices: choices ?? this.choices,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'choices': choices,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DecisionGroup.fromJson(Map<String, dynamic> json) {
    return DecisionGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🎯',
      choices: (json['choices'] as List<dynamic>? ?? const [])
          .map((choice) => choice.toString())
          .where((choice) => choice.trim().isNotEmpty)
          .toList(),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
