import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/home/presentation/pages/quote_detail_page.dart';

class BrowseContent extends StatefulWidget {
  final Function(int)? onTabChange;
  const BrowseContent({super.key, this.onTabChange});

  @override
  State<BrowseContent> createState() => _BrowseContentState();
}

class _BrowseContentState extends State<BrowseContent> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String? _currentQuery;
  String? _currentAuthor;
  bool _isAuthorSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && (_currentQuery != null || _currentAuthor != null)) {
      context.read<QuoteBloc>().add(
        FetchQuotesRequested(query: _currentQuery, author: _currentAuthor),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final trimmedQuery = query.trim();
      setState(() {
        _currentQuery = trimmedQuery.isEmpty ? null : trimmedQuery;
      });

      context.read<QuoteBloc>().add(
        FetchQuotesRequested(
          isRefresh: true,
          query: _isAuthorSearch ? null : _currentQuery,
          author: _isAuthorSearch ? _currentQuery : null,
        ),
      );
    });
  }

  void _onSearchSubmitted(String query) {
    _debounce?.cancel();
    final trimmedQuery = query.trim();
    setState(() {
      _currentQuery = trimmedQuery.isEmpty ? null : trimmedQuery;
    });

    context.read<QuoteBloc>().add(
      FetchQuotesRequested(
        isRefresh: true,
        query: _isAuthorSearch ? null : _currentQuery,
        author: _isAuthorSearch ? _currentQuery : null,
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = null;
      _currentAuthor = null;
    });
    // Optional: Refresh or clear results in bloc if desired
    // For now, just letting it show categories again when currentQuery is null
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Motivation',
        'colors': [const Color(0xFF8E8E8E), const Color(0xFFC4B69E)],
      },
      {
        'title': 'Love',
        'colors': [const Color(0xFFB88A5B), const Color(0xFFD4A373)],
      },
      {
        'title': 'Success',
        'colors': [const Color(0xFFD35400), const Color(0xFFE67E22)],
      },
      {
        'title': 'Wisdom',
        'colors': [const Color(0xFF1B2D2D), const Color(0xFF4B6B6B)],
      },
      {
        'title': 'Humor',
        'colors': [
          const Color(0xFF2C3E50),
          const Color(0xFF9B59B6),
          const Color(0xFFF1C40F),
        ],
      },
      {
        'title': 'Life',
        'colors': [const Color(0xFF8B4513), const Color(0xFFCD853F)],
      },
    ];

    final List<Map<String, dynamic>> authors = [
      {'name': 'Albert Einstein', 'color': Colors.blueAccent},
      {'name': 'Marcus Aurelius', 'color': Colors.brown},
      {'name': 'Maya Angelou', 'color': Colors.deepOrangeAccent},
      {'name': 'Oscar Wilde', 'color': Colors.purpleAccent},
      {'name': 'Rumi', 'color': Colors.teal},
      {'name': 'Steve Jobs', 'color': Colors.blueGrey},
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text(
              'Browse',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: _onSearchSubmitted,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: _isAuthorSearch
                            ? 'Search by author...'
                            : 'Search quotes, topics...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                        prefixIcon: Icon(
                          _isAuthorSearch
                              ? Icons.person_search_rounded
                              : Icons.search_rounded,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withOpacity(0.4),
                          size: 26,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: Theme.of(
                                    context,
                                  ).iconTheme.color?.withOpacity(0.54),
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAuthorSearch = !_isAuthorSearch;
                      if (_currentQuery != null) {
                        _onSearchSubmitted(_currentQuery!);
                      }
                    });
                  },
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: _isAuthorSearch
                          ? Colors.deepPurpleAccent
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: _isAuthorSearch
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter Chips
          if (_currentQuery == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildFilterChip('Categories', !_isAuthorSearch),
                  const SizedBox(width: 12),
                  _buildFilterChip('Authors', _isAuthorSearch),
                ],
              ),
            ),

          const SizedBox(height: 24),
          // Content Area
          Expanded(
            child: _currentQuery == null && _currentAuthor == null
                ? (_isAuthorSearch
                      ? _buildAuthorsList(authors)
                      : _buildCategoriesGrid(categories))
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(List<Map<String, dynamic>> categories) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(
          context,
          category['title'] as String,
          category['colors'] as List<Color>,
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<QuoteBloc, QuoteState>(
      builder: (context, state) {
        if (state is QuoteInitial ||
            (state is QuoteLoading && state.isFirstFetch)) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 5,
            itemBuilder: (context, index) => _buildQuoteShimmer(),
          );
        }

        List<QuoteEntity> quotes = [];
        bool hasReachedMax = false;

        if (state is QuotesLoaded) {
          quotes = state.quotes;
          hasReachedMax = state.hasReachedMax;
        } else if (state is QuoteLoading) {
          quotes = state.oldQuotes;
        }

        if (quotes.isEmpty && state is! QuoteLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                SizedBox(height: 16),
                Text(
                  'No results found',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.54),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: quotes.length + (hasReachedMax ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= quotes.length) {
              return _buildQuoteShimmer();
            }
            final quote = quotes[index];
            return BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, favState) {
                final isFavorite = favState.favorites.any(
                  (f) => f.id == quote.id,
                );
                return _buildQuoteCard(quote, isFavorite);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildQuoteShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Theme.of(context).highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(QuoteEntity quote, bool isFavorite) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuoteDetailPage(quote: quote),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quote.author,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.4),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<FavoritesBloc>().add(
                          ToggleFavoriteRequested(quote),
                        );
                      },
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 22,
                        color: isFavorite
                            ? Colors.red
                            : Theme.of(
                                context,
                              ).iconTheme.color?.withOpacity(0.24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showAddToCollectionBottomSheet(quote),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 22,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToCollectionBottomSheet(QuoteEntity quote) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Save to Collection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    title: Text(
                      'Create New Collection',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateCollectionDialog();
                    },
                  ),
                  Divider(color: Theme.of(context).dividerColor),
                  Expanded(
                    child: state.collections.isEmpty
                        ? Center(
                            child: Text(
                              'No collections yet',
                              style: TextStyle(
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: state.collections.length,
                            itemBuilder: (context, index) {
                              final collection = state.collections[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.folder_outlined,
                                    color: Theme.of(
                                      context,
                                    ).iconTheme.color?.withOpacity(0.7),
                                  ),
                                ),
                                title: Text(
                                  collection.name,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                subtitle: Text(
                                  '${collection.quoteIds.length} quotes',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.38),
                                  ),
                                ),
                                onTap: () {
                                  context.read<FavoritesBloc>().add(
                                    AddQuoteToCollectionRequested(
                                      collection.id,
                                      quote.id,
                                    ),
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added to ${collection.name}',
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateCollectionDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'New Collection',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: 'Collection name',
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurpleAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<FavoritesBloc>().add(
                    CreateCollectionRequested(name: controller.text),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(color: Colors.deepPurpleAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    List<Color> colors,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentQuery = title;
          _searchController.text = title;
        });
        context.read<QuoteBloc>().add(
          FetchQuotesRequested(isRefresh: true, category: title),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAuthorSearch = label == 'Authors';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurpleAccent
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.54),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorsList(List<Map<String, dynamic>> authors) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: authors.length,
      itemBuilder: (context, index) {
        final author = authors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () {
              setState(() {
                _currentAuthor = author['name'];
                _searchController.text = _currentAuthor!;
              });
              context.read<QuoteBloc>().add(
                FetchQuotesRequested(isRefresh: true, author: _currentAuthor),
              );
            },
            leading: CircleAvatar(
              backgroundColor: author['color'],
              child: Text(
                author['name'][0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              author['name'],
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.24),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: Theme.of(context).cardColor,
          ),
        );
      },
    );
  }
}
