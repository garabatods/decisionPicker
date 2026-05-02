import '../models/decision_group.dart';

final DateTime _seedDate = DateTime.utc(2026);

final List<DecisionGroup> defaultDecisionGroups = [
  DecisionGroup(
    id: 'default-food',
    name: 'Food Picker',
    emoji: '🍕',
    choices: const ['Pizza', 'Sushi', 'Burgers', 'Tacos', 'Ramen', 'Pasta'],
    isDefault: true,
    createdAt: _seedDate,
    updatedAt: _seedDate,
  ),
  DecisionGroup(
    id: 'default-movie-genre',
    name: 'Movie Genre Picker',
    emoji: '🎬',
    choices: const [
      'Action',
      'Comedy',
      'Horror',
      'Sci-Fi',
      'Drama',
      'Animation',
    ],
    isDefault: true,
    createdAt: _seedDate,
    updatedAt: _seedDate,
  ),
  DecisionGroup(
    id: 'default-truth-or-dare',
    name: 'Truth or Dare: Safe Edition',
    emoji: '🎲',
    choices: const [
      'Truth: What’s your favorite memory?',
      'Dare: Do 10 pushups',
      'Truth: What’s your dream job?',
      'Dare: Sing a song',
      'Truth: What food could you eat forever?',
      'Dare: Do your best movie trailer voice',
    ],
    isDefault: true,
    createdAt: _seedDate,
    updatedAt: _seedDate,
  ),
  DecisionGroup(
    id: 'default-game-night',
    name: 'Game Night Picker',
    emoji: '🎮',
    choices: const [
      'Mario Kart',
      'Smash Bros',
      'Board Game',
      'Card Game',
      'Trivia',
      'Co-op Game',
    ],
    isDefault: true,
    createdAt: _seedDate,
    updatedAt: _seedDate,
  ),
  DecisionGroup(
    id: 'default-weekend',
    name: 'Weekend Activity Picker',
    emoji: '🌤️',
    choices: const [
      'Coffee run',
      'Movie night',
      'Walk outside',
      'Try a new restaurant',
      'Game night',
      'Mini road trip',
    ],
    isDefault: true,
    createdAt: _seedDate,
    updatedAt: _seedDate,
  ),
];
