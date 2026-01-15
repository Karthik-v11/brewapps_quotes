import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/features/home/presentation/pages/quote_detail_page.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

class FavoritesContent extends StatefulWidget {
  const FavoritesContent({super.key});

  @override
  State<FavoritesContent> createState() => _FavoritesContentState();
}

class _FavoritesContentState extends State<FavoritesContent> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'By Author', 'By Topic'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final favorites = state.favorites;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<FavoritesBloc>().add(FetchFavoritesRequested());
          },
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters
                          .map((filter) => _buildFilterPill(filter))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (favorites.isEmpty && !state.isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text(
                          AppStrings.noFavorites,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    _buildFilteredContent(favorites),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilteredContent(List<QuoteEntity> favorites) {
    if (_selectedFilter == 'All') {
      // Masonry Layout
      final leftColumnQuotes = <QuoteEntity>[];
      final rightColumnQuotes = <QuoteEntity>[];

      for (var i = 0; i < favorites.length; i++) {
        if (i % 2 == 0) {
          leftColumnQuotes.add(favorites[i]);
        } else {
          rightColumnQuotes.add(favorites[i]);
        }
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: leftColumnQuotes
                  .map((quote) => _buildFavoriteCard(quote))
                  .toList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: rightColumnQuotes
                  .map((quote) => _buildFavoriteCard(quote))
                  .toList(),
            ),
          ),
        ],
      );
    } else {
      // Grouped Layout
      final Map<String, List<QuoteEntity>> grouped = {};
      for (var quote in favorites) {
        final key = _selectedFilter == 'By Author'
            ? quote.author
            : quote.category;
        grouped.putIfAbsent(key, () => []).add(quote);
      }

      final sortedKeys = grouped.keys.toList()..sort();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedKeys.map((key) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 8),
                child: Text(
                  key,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...grouped[key]!.map((quote) => _buildFavoriteCard(quote)),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      );
    }
  }

  Widget _buildFilterPill(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.transparent
              : (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E2832).withOpacity(0.5)
                    : Colors.grey[300]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected
                ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                : Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.6),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(QuoteEntity quote) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuoteDetailPage(quote: quote),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quote.content,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '— ${quote.author}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.favorite_rounded,
                  size: 20,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
