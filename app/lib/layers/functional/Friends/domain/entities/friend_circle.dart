import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';

class FriendCircle {
  const FriendCircle({this.friends = const [], this.reviews = const []});

  final List<Friend> friends;
  final List<GameReview> reviews;

  FriendCircle copyWith({List<Friend>? friends, List<GameReview>? reviews}) =>
      FriendCircle(
        friends: friends ?? this.friends,
        reviews: reviews ?? this.reviews,
      );

  Map<String, Object?> toJson() => {
    'friends': friends.map((f) => f.toJson()).toList(),
    'reviews': reviews.map((r) => r.toJson()).toList(),
  };

  factory FriendCircle.fromJson(Map<String, dynamic> j) => FriendCircle(
    friends: _list(j['friends'], Friend.fromJson),
    reviews: _list(j['reviews'], GameReview.fromJson),
  );
}

List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) parse) =>
    (raw as List? ?? const [])
        .map((v) => parse(Map<String, dynamic>.from(v as Map)))
        .toList();
