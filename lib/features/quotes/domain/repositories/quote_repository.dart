import 'package:dartz/dartz.dart';
import 'package:quote_vault/core/error/failures.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';

abstract class QuoteRepository {
  Future<Either<Failure, List<QuoteEntity>>> getQuotes({
    int limit = 20,
    int offset = 0,
    String? category,
    String? query,
    String? author,
  });

  Future<Either<Failure, List<QuoteEntity>>> getQuotesByIds(List<String> ids);
  Future<Either<Failure, QuoteEntity>> getQuoteOfTheDay();
}
