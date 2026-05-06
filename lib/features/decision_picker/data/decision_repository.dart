import '../models/decision_group.dart';
import 'default_decision_groups.dart';
import 'local_decision_storage.dart';

class DecisionRepository {
  DecisionRepository({required LocalDecisionStorage storage})
    : _storage = storage;

  final LocalDecisionStorage _storage;

  List<DecisionGroup> loadGroups() {
    final customGroups = _storage.loadCustomGroups()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final savedGroupIds = customGroups.map((group) => group.id).toSet();
    final availableDefaults = defaultDecisionGroups
        .where((group) => !savedGroupIds.contains(group.id))
        .toList();
    final groups = [...customGroups, ...availableDefaults];
    final order = _storage.loadGroupOrder();
    if (order.isEmpty) {
      return groups;
    }

    final orderIndex = {
      for (var index = 0; index < order.length; index++) order[index]: index,
    };
    groups.sort((a, b) {
      final aIndex = orderIndex[a.id];
      final bIndex = orderIndex[b.id];
      if (aIndex != null && bIndex != null) {
        return aIndex.compareTo(bIndex);
      }
      if (aIndex != null) {
        return -1;
      }
      if (bIndex != null) {
        return 1;
      }
      return 0;
    });
    return groups;
  }

  Future<void> saveCustomGroups(List<DecisionGroup> groups) {
    return _storage.saveCustomGroups(groups);
  }

  Future<void> saveGroupOrder(List<DecisionGroup> groups) {
    return _storage.saveGroupOrder(groups.map((group) => group.id).toList());
  }
}
