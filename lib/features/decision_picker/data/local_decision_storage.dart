import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/decision_group.dart';

class LocalDecisionStorage {
  LocalDecisionStorage({required SharedPreferences preferences})
    : _preferences = preferences;

  static const String customGroupsKey = 'decision_maker.custom_groups.v1';
  static const String groupOrderKey = 'decision_maker.group_order.v1';

  final SharedPreferences _preferences;

  List<DecisionGroup> loadCustomGroups() {
    final rawJson = _preferences.getString(customGroupsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawJson);
    if (decoded is! List<dynamic>) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(DecisionGroup.fromJson)
        .where((group) => group.id.isNotEmpty && !group.isDefault)
        .toList();
  }

  Future<void> saveCustomGroups(List<DecisionGroup> groups) {
    final customGroups = groups.where((group) => !group.isDefault).toList();
    final rawJson = jsonEncode(
      customGroups.map((group) => group.toJson()).toList(),
    );
    return _preferences.setString(customGroupsKey, rawJson);
  }

  List<String> loadGroupOrder() {
    return _preferences.getStringList(groupOrderKey) ?? [];
  }

  Future<void> saveGroupOrder(List<String> groupIds) {
    return _preferences.setStringList(groupOrderKey, groupIds);
  }
}
