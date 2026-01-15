import 'package:dartz/dartz.dart';
import 'package:quote_vault/core/error/failures.dart';
import 'package:quote_vault/features/quotes/data/datasources/user_action_remote_data_source.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/quotes/domain/entities/user_action_entities.dart';
import 'package:quote_vault/features/quotes/domain/repositories/user_action_repository.dart';

class UserActionRepositoryImpl implements UserActionRepository {
  final UserActionRemoteDataSource remoteDataSource;

  UserActionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<QuoteEntity>>> getFavorites() async {
    try {
      final quotes = await remoteDataSource.getFavorites();
      return Right(quotes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(String quoteId) async {
    try {
      final isFav = await remoteDataSource.toggleFavorite(quoteId);
      return Right(isFav);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String quoteId) async {
    try {
      final result = await remoteDataSource.isFavorite(quoteId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> getCollections() async {
    try {
      final collections = await remoteDataSource.getCollections();
      return Right(collections);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> createCollection(
    String name,
    String? description, {
    bool isPublic = false,
  }) async {
    try {
      final collection = await remoteDataSource.createCollection(
        name,
        description,
        isPublic: isPublic,
      );
      return Right(collection);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCollectionPublic(
    String collectionId,
    bool isPublic,
  ) async {
    try {
      await remoteDataSource.setPublic(collectionId, isPublic);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> getPublicCollections() async {
    try {
      final collections = await remoteDataSource.getPublicCollections();
      return Right(collections);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addQuoteToCollection(
    String collectionId,
    String quoteId,
  ) async {
    try {
      await remoteDataSource.addQuoteToCollection(collectionId, quoteId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeQuoteFromCollection(
    String collectionId,
    String quoteId,
  ) async {
    try {
      await remoteDataSource.removeQuoteFromCollection(collectionId, quoteId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String collectionId) async {
    try {
      await remoteDataSource.deleteCollection(collectionId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
