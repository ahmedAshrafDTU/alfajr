enum GameCategory {
  quran,
  salah,
  wudu,
  manners,
  knowledge,
  seerah,
  prophets
}

enum GameDifficulty {
  easy,
  medium,
  hard
}

class GameMetadata {
  final String id;
  final String title;
  final String description;
  final GameCategory category;
  final GameDifficulty difficulty;
  final int minAge;
  final int maxAge;
  final int rewardStars;

  const GameMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.minAge,
    required this.maxAge,
    required this.rewardStars,
  });
}

class GameProgress {
  final String gameId;
  final int highestScore;
  final bool isCompleted;
  final DateTime lastPlayed;

  GameProgress({
    required this.gameId,
    required this.highestScore,
    required this.isCompleted,
    required this.lastPlayed,
  });

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'highestScore': highestScore,
    'isCompleted': isCompleted,
    'lastPlayed': lastPlayed.toIso8601String(),
  };

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    return GameProgress(
      gameId: json['gameId'],
      highestScore: json['highestScore'],
      isCompleted: json['isCompleted'],
      lastPlayed: DateTime.parse(json['lastPlayed']),
    );
  }
}
