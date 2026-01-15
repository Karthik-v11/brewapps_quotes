import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/quotes/domain/repositories/quote_repository.dart';
import 'package:quote_vault/core/services/widget_service.dart';

// Events
abstract class QuoteEvent extends Equatable {
  const QuoteEvent();
  @override
  List<Object?> get props => [];
}

class FetchQuotesRequested extends QuoteEvent {
  final bool isRefresh;
  final String? category;
  final String? query;
  final String? author;
  const FetchQuotesRequested({
    this.isRefresh = false,
    this.category,
    this.query,
    this.author,
  });
  @override
  List<Object?> get props => [isRefresh, category, query, author];
}

class FetchQuoteOfTheDayRequested extends QuoteEvent {}

// States
abstract class QuoteState extends Equatable {
  const QuoteState();
  @override
  List<Object?> get props => [];
}

class QuoteInitial extends QuoteState {}

class QuoteLoading extends QuoteState {
  final List<QuoteEntity> oldQuotes;
  final bool isFirstFetch;
  final QuoteEntity? quoteOfTheDay; // Added
  const QuoteLoading(
    this.oldQuotes, {
    this.isFirstFetch = false,
    this.quoteOfTheDay,
  });
  @override
  List<Object?> get props => [oldQuotes, isFirstFetch, quoteOfTheDay];
}

class QuotesLoaded extends QuoteState {
  final List<QuoteEntity> quotes;
  final bool hasReachedMax;
  final QuoteEntity? quoteOfTheDay;
  const QuotesLoaded({
    required this.quotes,
    this.hasReachedMax = false,
    this.quoteOfTheDay,
  });
  @override
  List<Object?> get props => [quotes, hasReachedMax, quoteOfTheDay];
}

class QuoteError extends QuoteState {
  final String message;
  const QuoteError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final QuoteRepository _repository;
  final WidgetService _widgetService;
  int _offset = 0;
  final int _limit = 20;

  QuoteBloc({
    required QuoteRepository repository,
    required WidgetService widgetService,
  }) : _repository = repository,
       _widgetService = widgetService,
       super(QuoteInitial()) {
    on<FetchQuotesRequested>(_onFetchQuotesRequested);
    on<FetchQuoteOfTheDayRequested>(_onFetchQuoteOfTheDayRequested);
  }

  Future<void> _onFetchQuotesRequested(
    FetchQuotesRequested event,
    Emitter<QuoteState> emit,
  ) async {
    if (event.isRefresh) {
      _offset = 0;
    }

    final currentState = state;
    List<QuoteEntity> oldQuotes = [];
    QuoteEntity? qod;

    if (currentState is QuotesLoaded) {
      if (!event.isRefresh) {
        oldQuotes = currentState.quotes;
      }
      qod = currentState.quoteOfTheDay;
    } else if (currentState is QuoteLoading) {
      oldQuotes = currentState.oldQuotes;
      qod = currentState.quoteOfTheDay;
    }

    emit(
      QuoteLoading(oldQuotes, isFirstFetch: _offset == 0, quoteOfTheDay: qod),
    );

    final result = await _repository.getQuotes(
      offset: _offset,
      limit: _limit,
      category: event.category,
      query: event.query,
      author: event.author,
    );

    result.fold((failure) => emit(QuoteError(failure.message)), (newQuotes) {
      _offset += newQuotes.length;
      final hasReachedMax = newQuotes.length < _limit;

      // Check if QOD was updated while we were waiting
      if (state is QuotesLoaded &&
          (state as QuotesLoaded).quoteOfTheDay != null) {
        qod = (state as QuotesLoaded).quoteOfTheDay;
      } else if (state is QuoteLoading &&
          (state as QuoteLoading).quoteOfTheDay != null) {
        qod = (state as QuoteLoading).quoteOfTheDay;
      }

      emit(
        QuotesLoaded(
          quotes: oldQuotes + newQuotes,
          hasReachedMax: hasReachedMax,
          quoteOfTheDay: qod,
        ),
      );
    });
  }

  Future<void> _onFetchQuoteOfTheDayRequested(
    FetchQuoteOfTheDayRequested event,
    Emitter<QuoteState> emit,
  ) async {
    final result = await _repository.getQuoteOfTheDay();
    result.fold(
      (failure) {}, // Silently fail or keep current state
      (quote) {
        _widgetService.updateWidget(quote);

        List<QuoteEntity> currentQuotes = [];
        bool hasReachedMax = false;

        if (state is QuotesLoaded) {
          final s = state as QuotesLoaded;
          currentQuotes = s.quotes;
          hasReachedMax = s.hasReachedMax;
        } else if (state is QuoteLoading) {
          final s = state as QuoteLoading;
          currentQuotes = s.oldQuotes;
        }

        emit(
          QuotesLoaded(
            quotes: currentQuotes,
            hasReachedMax: hasReachedMax,
            quoteOfTheDay: quote,
          ),
        );
      },
    );
  }
}
