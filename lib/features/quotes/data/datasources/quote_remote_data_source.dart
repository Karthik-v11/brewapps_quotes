import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quote_vault/features/quotes/data/models/quote_model.dart';

abstract class QuoteRemoteDataSource {
  Future<List<QuoteModel>> getQuotes({
    int limit = 20,
    int offset = 0,
    String? category,
    String? query,
    String? author,
  });

  Future<List<QuoteModel>> getQuotesByIds(List<String> ids);

  Future<QuoteModel> getQuoteOfTheDay();
}

class QuoteRemoteDataSourceImpl implements QuoteRemoteDataSource {
  final SupabaseClient supabaseClient;

  QuoteRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<QuoteModel>> getQuotesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final data = await supabaseClient
        .from('quotes')
        .select()
        .inFilter('id', ids);
    return (data as List).map((json) => QuoteModel.fromJson(json)).toList();
  }

  @override
  Future<List<QuoteModel>> getQuotes({
    int limit = 20,
    int offset = 0,
    String? category,
    String? query,
    String? author,
  }) async {
    var request = supabaseClient.from('quotes').select();

    if (category != null && category != 'All') {
      request = request.eq('category', category);
    }

    if (query != null && query.isNotEmpty) {
      request = request.or('content.ilike.%$query%,author.ilike.%$query%');
    }

    if (author != null && author.isNotEmpty) {
      request = request.eq('author', author);
    }

    final data = await request
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((json) => QuoteModel.fromJson(json)).toList();
  }

  @override
  Future<QuoteModel> getQuoteOfTheDay() async {
    // For now, deterministic random based on date
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    final countResponse = await supabaseClient
        .from('quotes')
        .select('id')
        .count(CountOption.exact);
    final count = countResponse.count;

    final index = dayOfYear % count;

    final data = await supabaseClient
        .from('quotes')
        .select()
        .range(index, index)
        .single();

    return QuoteModel.fromJson(data);
  }
}
