import 'package:dartz/dartz.dart';
import 'package:quote_vault/core/error/failures.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/quotes/domain/entities/user_action_entities.dart';

abstract class UserActionRepository {
  // Favorites
  Future<Either<Failure, List<QuoteEntity>>> getFavorites();
  Future<Either<Failure, bool>> toggleFavorite(String quoteId);
  Future<Either<Failure, bool>> isFavorite(String quoteId);

  // Collections
  Future<Either<Failure, List<CollectionEntity>>> getCollections();
  Future<Either<Failure, CollectionEntity>> createCollection(
    String name,
    String? description, {
    bool isPublic = false,
  });
  Future<Either<Failure, void>> toggleCollectionPublic(
    String collectionId,
    bool isPublic,
  );
  Future<Either<Failure, List<CollectionEntity>>> getPublicCollections();
  Future<Either<Failure, void>> addQuoteToCollection(
    String collectionId,
    String quoteId,
  );
  Future<Either<Failure, void>> removeQuoteFromCollection(
    String collectionId,
    String quoteId,
  );
  Future<Either<Failure, void>> deleteCollection(String collectionId);
}
