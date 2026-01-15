import 'package:quote_vault/features/quotes/domain/entities/user_action_entities.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.id,
    required super.userId,
    required super.quoteId,
    required super.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      quoteId: json['quote_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CollectionModel extends CollectionEntity {
  const CollectionModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.createdAt,
    super.quoteIds,
    super.isPublic,
    super.userName,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      quoteIds: (json['collection_quotes'] as List? ?? [])
          .map((q) => q['quote_id'] as String)
          .toList(),
      isPublic: json['is_public'] as bool? ?? false,
      userName: json['profiles']?['username'] as String?,
    );
  }
}
