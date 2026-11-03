class GameReview {
  const GameReview({
    required this.id,
    required this.sessionId,
    required this.reviewer,
    required this.stars,
    this.gameTitle = '',
    this.templateId = '',
    this.comment = '',
    this.createdAt = 0,
  });

  final String id, sessionId, reviewer, gameTitle, templateId, comment;
  final int stars, createdAt;

  bool concerns(String title, List<String> templateIds) =>
      gameTitle.toLowerCase() == title.toLowerCase() ||
      (templateId.isNotEmpty && templateIds.contains(templateId));

  Map<String, Object?> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'reviewer': reviewer,
    'stars': stars,
    'gameTitle': gameTitle,
    'templateId': templateId,
    'comment': comment,
    'createdAt': createdAt,
  };

  factory GameReview.fromJson(Map<String, dynamic> j) {
    final stars = j['stars'] as int;
    final comment = j['comment'] as String? ?? '';
    if (stars < 1 || stars > 5 || comment.length > 500) {
      throw const FormatException('Avis invalide');
    }
    return GameReview(
      id: j['id'] as String,
      sessionId: j['sessionId'] as String,
      reviewer: j['reviewer'] as String,
      stars: stars,
      gameTitle: j['gameTitle'] as String? ?? '',
      templateId: j['templateId'] as String? ?? '',
      comment: comment,
      createdAt: j['createdAt'] as int? ?? 0,
    );
  }
}

double? averageStars(Iterable<GameReview> reviews) {
  if (reviews.isEmpty) return null;
  return reviews.fold<int>(0, (sum, r) => sum + r.stars) / reviews.length;
}
