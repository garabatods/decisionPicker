import 'package:flutter/foundation.dart';

import '../data/decision_repository.dart';
import '../models/decision_group.dart';
import '../models/pick_history_item.dart';

class DecisionGroupsController extends ChangeNotifier {
  DecisionGroupsController({required DecisionRepository repository})
    : _repository = repository;

  final DecisionRepository _repository;

  List<DecisionGroup> _groups = [];
  final List<PickHistoryItem> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DecisionGroup> get groups => List.unmodifiable(_groups);
  List<PickHistoryItem> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadGroups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = _repository.loadGroups();
    } catch (_) {
      _errorMessage = 'Could not load your pickers.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DecisionGroup? findById(String id) {
    for (final group in _groups) {
      if (group.id == id) {
        return group;
      }
    }
    return null;
  }

  Future<DecisionGroup> addCustomGroup({
    required String name,
    required String emoji,
    required List<String> choices,
  }) async {
    final now = DateTime.now();
    final group = DecisionGroup(
      id: 'custom-${now.microsecondsSinceEpoch}',
      name: name.trim(),
      emoji: emoji.trim().isEmpty ? '🎯' : emoji.trim(),
      choices: _cleanChoices(choices),
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    _groups = [group, ..._groups];
    await _repository.saveCustomGroups(_groups);
    await _repository.saveGroupOrder(_groups);
    notifyListeners();
    return group;
  }

  Future<DecisionGroup?> updateCustomGroup({
    required String id,
    required String name,
    required String emoji,
    required List<String> choices,
  }) async {
    final group = findById(id);
    if (group == null) {
      return null;
    }

    final updatedGroup = group.copyWith(
      name: name.trim(),
      emoji: emoji.trim().isEmpty ? '🎯' : emoji.trim(),
      choices: _cleanChoices(choices),
      isDefault: false,
      updatedAt: DateTime.now(),
    );

    _groups = _groups
        .map((candidate) => candidate.id == id ? updatedGroup : candidate)
        .toList();
    await _repository.saveCustomGroups(_groups);
    await _repository.saveGroupOrder(_groups);
    notifyListeners();
    return updatedGroup;
  }

  Future<void> deleteCustomGroup(String id) async {
    final group = findById(id);
    if (group == null || group.isDefault) {
      return;
    }

    _groups = _groups.where((candidate) => candidate.id != id).toList();
    await _repository.saveCustomGroups(_groups);
    await _repository.saveGroupOrder(_groups);
    notifyListeners();
  }

  Future<void> reorderGroups(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _groups.length) {
      return;
    }

    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (adjustedNewIndex < 0 || adjustedNewIndex >= _groups.length) {
      return;
    }

    final nextGroups = [..._groups];
    final movedGroup = nextGroups.removeAt(oldIndex);
    nextGroups.insert(adjustedNewIndex, movedGroup);
    _groups = nextGroups;
    await _repository.saveCustomGroups(_groups);
    await _repository.saveGroupOrder(_groups);
    notifyListeners();
  }

  void recordPick({required DecisionGroup group, required String choice}) {
    _history.insert(
      0,
      PickHistoryItem(
        groupId: group.id,
        groupName: group.name,
        groupEmoji: group.emoji,
        choice: choice,
        createdAt: DateTime.now(),
      ),
    );

    if (_history.length > 30) {
      _history.removeRange(30, _history.length);
    }

    notifyListeners();
  }

  Future<DecisionGroup> addSharedPicker(DecisionGroup sharedPicker) async {
    final now = DateTime.now();
    final group = DecisionGroup(
      id: 'custom-${now.microsecondsSinceEpoch}',
      name: sharedPicker.name,
      emoji: sharedPicker.emoji,
      choices: sharedPicker.choices,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    _groups = [group, ..._groups];
    await _repository.saveCustomGroups(_groups);
    await _repository.saveGroupOrder(_groups);
    notifyListeners();
    return group;
  }

  static List<String> _cleanChoices(List<String> choices) {
    final seen = <String>{};
    final cleaned = <String>[];

    for (final choice in choices) {
      final trimmed = choice.trim();
      final normalized = trimmed.toLowerCase();
      if (trimmed.isEmpty || seen.contains(normalized)) {
        continue;
      }
      seen.add(normalized);
      cleaned.add(trimmed);
    }

    return cleaned;
  }
}
