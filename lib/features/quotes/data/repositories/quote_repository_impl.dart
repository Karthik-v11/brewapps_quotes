import 'package:dartz/dartz.dart';
import 'package:quote_vault/core/error/failures.dart';
import 'package:quote_vault/features/quotes/data/datasources/quote_remote_data_source.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/quotes/domain/repositories/quote_repository.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteRemoteDataSource remoteDataSource;

  QuoteRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<QuoteEntity>>> getQuotes({
    int limit = 20,
    int offset = 0,
    String? category,
    String? query,
    String? author,
  }) async {
    try {
      final quotes = await remoteDataSource.getQuotes(
        limit: limit,
        offset: offset,
        category: category,
        query: query,
        author: author,
      );
      return Right(quotes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuoteEntity>>> getQuotesByIds(
    List<String> ids,
  ) async {
    try {
      final quotes = await remoteDataSource.getQuotesByIds(ids);
      return Right(quotes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuoteEntity>> getQuoteOfTheDay() async {
    try {
      final quote = await remoteDataSource.getQuoteOfTheDay();
      return Right(quote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
