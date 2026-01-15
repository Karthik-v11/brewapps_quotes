import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/quotes/domain/entities/user_action_entities.dart';
import 'package:quote_vault/features/quotes/domain/repositories/user_action_repository.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class FetchFavoritesRequested extends FavoritesEvent {}

class FetchCollectionsRequested extends FavoritesEvent {}

class ToggleFavoriteRequested extends FavoritesEvent {
  final QuoteEntity quote;
  const ToggleFavoriteRequested(this.quote);
  @override
  List<Object?> get props => [quote];
}

class CreateCollectionRequested extends FavoritesEvent {
  final String name;
  final String? description;
  final bool isPublic;
  const CreateCollectionRequested({
    required this.name,
    this.description,
    this.isPublic = false,
  });
  @override
  List<Object?> get props => [name, description, isPublic];
}

class ToggleCollectionPublicRequested extends FavoritesEvent {
  final String collectionId;
  final bool isPublic;
  const ToggleCollectionPublicRequested(this.collectionId, this.isPublic);
  @override
  List<Object?> get props => [collectionId, isPublic];
}

class FetchPublicCollectionsRequested extends FavoritesEvent {}

class AddQuoteToCollectionRequested extends FavoritesEvent {
  final String collectionId;
  final String quoteId;
  const AddQuoteToCollectionRequested(this.collectionId, this.quoteId);
  @override
  List<Object?> get props => [collectionId, quoteId];
}

class RemoveQuoteFromCollectionRequested extends FavoritesEvent {
  final String collectionId;
  final String quoteId;
  const RemoveQuoteFromCollectionRequested(this.collectionId, this.quoteId);
  @override
  List<Object?> get props => [collectionId, quoteId];
}

// States
class FavoritesState extends Equatable {
  final List<QuoteEntity> favorites;
  final List<CollectionEntity> collections;
  final List<CollectionEntity> publicCollections;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.collections = const [],
    this.publicCollections = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<QuoteEntity>? favorites,
    List<CollectionEntity>? collections,
    List<CollectionEntity>? publicCollections,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      collections: collections ?? this.collections,
      publicCollections: publicCollections ?? this.publicCollections,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    favorites,
    collections,
    publicCollections,
    isLoading,
    error,
  ];
}

// Bloc
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final UserActionRepository _repository;

  FavoritesBloc({required UserActionRepository repository})
    : _repository = repository,
      super(const FavoritesState()) {
    on<FetchFavoritesRequested>(_onFetchFavoritesRequested);
    on<FetchCollectionsRequested>(_onFetchCollectionsRequested);
    on<ToggleFavoriteRequested>(_onToggleFavoriteRequested);
    on<CreateCollectionRequested>(_onCreateCollectionRequested);
    on<AddQuoteToCollectionRequested>(_onAddQuoteToCollectionRequested);
    on<RemoveQuoteFromCollectionRequested>(
      _onRemoveQuoteFromCollectionRequested,
    );
    on<ToggleCollectionPublicRequested>(_onToggleCollectionPublicRequested);
    on<FetchPublicCollectionsRequested>(_onFetchPublicCollectionsRequested);
  }

  Future<void> _onFetchFavoritesRequested(
    FetchFavoritesRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repository.getFavorites();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (quotes) => emit(state.copyWith(isLoading: false, favorites: quotes)),
    );
  }

  Future<void> _onFetchCollectionsRequested(
    FetchCollectionsRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repository.getCollections();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (collections) =>
          emit(state.copyWith(isLoading: false, collections: collections)),
    );
  }

  Future<void> _onToggleFavoriteRequested(
    ToggleFavoriteRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await _repository.toggleFavorite(event.quote.id);
    result.fold((failure) => emit(state.copyWith(error: failure.message)), (
      isFavNow,
    ) {
      final List<QuoteEntity> newFavs = List.from(state.favorites);
      if (isFavNow) {
        newFavs.add(event.quote);
      } else {
        newFavs.removeWhere((q) => q.id == event.quote.id);
      }
      emit(state.copyWith(favorites: newFavs));
    });
  }

  Future<void> _onCreateCollectionRequested(
    CreateCollectionRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await _repository.createCollection(
      event.name,
      event.description,
      isPublic: event.isPublic,
    );
    result.fold((failure) => emit(state.copyWith(error: failure.message)), (
      collection,
    ) {
      emit(
        state.copyWith(
          collections: List.from(state.collections)..add(collection),
        ),
      );
    });
  }

  Future<void> _onToggleCollectionPublicRequested(
    ToggleCollectionPublicRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await _repository.toggleCollectionPublic(
      event.collectionId,
      event.isPublic,
    );
    result.fold((failure) => emit(state.copyWith(error: failure.message)), (_) {
      add(FetchCollectionsRequested());
    });
  }

  Future<void> _onFetchPublicCollectionsRequested(
    FetchPublicCollectionsRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repository.getPublicCollections();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (collections) => emit(
        state.copyWith(isLoading: false, publicCollections: collections),
      ),
    );
  }

  Future<void> _onAddQuoteToCollectionRequested(
    AddQuoteToCollectionRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await _repository.addQuoteToCollection(
      event.collectionId,
      event.quoteId,
    );
    result.fold((failure) => emit(state.copyWith(error: failure.message)), (_) {
      // Refresh collections or update local state
      add(FetchCollectionsRequested());
    });
  }

  Future<void> _onRemoveQuoteFromCollectionRequested(
    RemoveQuoteFromCollectionRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await _repository.removeQuoteFromCollection(
      event.collectionId,
      event.quoteId,
    );
    result.fold((failure) => emit(state.copyWith(error: failure.message)), (_) {
      // Refresh collections
      add(FetchCollectionsRequested());
    });
  }
}
