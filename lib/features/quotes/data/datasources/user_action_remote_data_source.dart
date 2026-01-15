import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quote_vault/features/quotes/data/models/quote_model.dart';
import 'package:quote_vault/features/quotes/data/models/user_action_models.dart';

abstract class UserActionRemoteDataSource {
  Future<List<QuoteModel>> getFavorites();
  Future<bool> toggleFavorite(String quoteId);
  Future<bool> isFavorite(String quoteId);
  Future<List<CollectionModel>> getCollections();
  Future<CollectionModel> createCollection(
    String name,
    String? description, {
    bool isPublic = false,
  });
  Future<void> setPublic(String collectionId, bool isPublic);
  Future<List<CollectionModel>> getPublicCollections();
  Future<void> addQuoteToCollection(String collectionId, String quoteId);
  Future<void> removeQuoteFromCollection(String collectionId, String quoteId);
  Future<void> deleteCollection(String collectionId);
}

class UserActionRemoteDataSourceImpl implements UserActionRemoteDataSource {
  final SupabaseClient supabaseClient;

  UserActionRemoteDataSourceImpl(this.supabaseClient);

  String get _userId => supabaseClient.auth.currentUser!.id;

  @override
  Future<List<QuoteModel>> getFavorites() async {
    final data = await supabaseClient
        .from('favorites')
        .select('*, quotes(*)')
        .eq('user_id', _userId);

    return (data as List).map((f) => QuoteModel.fromJson(f['quotes'])).toList();
  }

  @override
  Future<bool> toggleFavorite(String quoteId) async {
    final existing = await supabaseClient
        .from('favorites')
        .select()
        .eq('user_id', _userId)
        .eq('quote_id', quoteId)
        .maybeSingle();

    if (existing != null) {
      await supabaseClient
          .from('favorites')
          .delete()
          .eq('user_id', _userId)
          .eq('quote_id', quoteId);
      return false;
    } else {
      await supabaseClient.from('favorites').insert({
        'user_id': _userId,
        'quote_id': quoteId,
      });
      return true;
    }
  }

  @override
  Future<bool> isFavorite(String quoteId) async {
    final data = await supabaseClient
        .from('favorites')
        .select()
        .eq('user_id', _userId)
        .eq('quote_id', quoteId)
        .maybeSingle();
    return data != null;
  }

  @override
  Future<List<CollectionModel>> getCollections() async {
    final data = await supabaseClient
        .from('collections')
        .select('*, collection_quotes(quote_id)')
        .eq('user_id', _userId);

    return (data as List).map((c) => CollectionModel.fromJson(c)).toList();
  }

  @override
  Future<CollectionModel> createCollection(
    String name,
    String? description, {
    bool isPublic = false,
  }) async {
    final data = await supabaseClient
        .from('collections')
        .insert({
          'user_id': _userId,
          'name': name,
          'description': description,
          'is_public': isPublic,
        })
        .select()
        .single();
    return CollectionModel.fromJson(data);
  }

  @override
  Future<void> setPublic(String collectionId, bool isPublic) async {
    await supabaseClient
        .from('collections')
        .update({'is_public': isPublic})
        .eq('id', collectionId)
        .eq('user_id', _userId);
  }

  @override
  Future<List<CollectionModel>> getPublicCollections() async {
    final data = await supabaseClient
        .from('collections')
        .select('*, profiles(username), collection_quotes(quote_id)')
        .eq('is_public', true)
        .order('created_at', ascending: false);

    return (data as List).map((c) => CollectionModel.fromJson(c)).toList();
  }

  @override
  Future<void> addQuoteToCollection(String collectionId, String quoteId) async {
    await supabaseClient.from('collection_quotes').insert({
      'collection_id': collectionId,
      'quote_id': quoteId,
    });
  }

  @override
  Future<void> removeQuoteFromCollection(
    String collectionId,
    String quoteId,
  ) async {
    await supabaseClient
        .from('collection_quotes')
        .delete()
        .eq('collection_id', collectionId)
        .eq('quote_id', quoteId);
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    await supabaseClient
        .from('collections')
        .delete()
        .eq('id', collectionId)
        .eq('user_id', _userId);
  }
}
