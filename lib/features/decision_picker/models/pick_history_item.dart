class PickHistoryItem {
  const PickHistoryItem({
    required this.groupId,
    required this.groupName,
    required this.groupEmoji,
    required this.choice,
    required this.createdAt,
  });

  final String groupId;
  final String groupName;
  final String groupEmoji;
  final String choice;
  final DateTime createdAt;
}
