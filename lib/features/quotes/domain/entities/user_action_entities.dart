import 'package:equatable/equatable.dart';

class FavoriteEntity extends Equatable {
  final String id;
  final String userId;
  final String quoteId;
  final DateTime createdAt;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.quoteId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, quoteId, createdAt];
}

class CollectionEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final List<String> quoteIds;
  final bool isPublic;
  final String? userName;

  const CollectionEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.createdAt,
    this.quoteIds = const [],
    this.isPublic = false,
    this.userName,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    createdAt,
    quoteIds,
    isPublic,
    userName,
  ];
}
