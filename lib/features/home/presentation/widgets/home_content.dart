import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/features/home/presentation/pages/quote_detail_page.dart';
import 'package:quote_vault/features/settings/presentation/bloc/theme_bloc.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Motivation',
    'Love',
    'Success',
    'Wisdom',
    'Humor',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<QuoteBloc>().add(
        FetchQuotesRequested(
          category: _selectedCategory == 'All' ? null : _selectedCategory,
        ),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    context.read<QuoteBloc>().add(
      FetchQuotesRequested(
        isRefresh: true,
        category: category == 'All' ? null : category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<QuoteBloc>().add(
                FetchQuotesRequested(
                  isRefresh: true,
                  category: _selectedCategory == 'All'
                      ? null
                      : _selectedCategory,
                ),
              );
              context.read<QuoteBloc>().add(FetchQuoteOfTheDayRequested());
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).textTheme.displaySmall?.color,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // Quote of the Day Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.quoteOfTheDay,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.color,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<QuoteBloc, QuoteState>(
                          builder: (context, state) {
                            QuoteEntity? qod;
                            if (state is QuotesLoaded) {
                              qod = state.quoteOfTheDay;
                            } else if (state is QuoteLoading) {
                              qod = state.quoteOfTheDay;
                            }

                            if (qod != null) {
                              return BlocBuilder<FavoritesBloc, FavoritesState>(
                                builder: (context, favState) {
                                  final isFavorite = favState.favorites.any(
                                    (f) => f.id == qod!.id,
                                  );
                                  return _buildFeaturedCard(
                                    qod!,
                                    isFavorite,
                                    themeState,
                                  );
                                },
                              );
                            }
                            return _buildFeaturedShimmer();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryPill(
                            _categories[index],
                            themeState,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Quotes List
                BlocBuilder<QuoteBloc, QuoteState>(
                  builder: (context, state) {
                    if (state is QuoteInitial ||
                        (state is QuoteLoading && state.isFirstFetch)) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildQuoteShimmer(),
                            childCount: 5,
                          ),
                        ),
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

                    if (quotes.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            AppStrings.noQuotes,
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: BlocBuilder<FavoritesBloc, FavoritesState>(
                        builder: (context, favState) {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= quotes.length) {
                                  return hasReachedMax
                                      ? const SizedBox.shrink()
                                      : _buildQuoteShimmer();
                                }
                                final quote = quotes[index];
                                final isFavorite = favState.favorites.any(
                                  (f) => f.id == quote.id,
                                );
                                return _buildQuoteCard(
                                  quote,
                                  isFavorite,
                                  themeState,
                                );
                              },
                              childCount:
                                  quotes.length + (hasReachedMax ? 0 : 1),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCard(
    QuoteEntity quote,
    bool isFavorite,
    ThemeState themeState,
  ) {
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '“${quote.content}”',
                    style: TextStyle(
                      fontSize: themeState.fontSize + 6, // Larger for featured
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
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
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isFavorite
                              ? Colors.red.withOpacity(0.1)
                              : Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: isFavorite ? Colors.red : Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              quote.author,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF252525) : Colors.grey[300]!,
      highlightColor: isDark ? const Color(0xFF333333) : Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildQuoteShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[300]!,
      highlightColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String category, ThemeState themeState) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => _onCategorySelected(category),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? themeState.accentColor
              : (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A1A1A)
                    : Colors.grey[200]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeState.accentColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(
    QuoteEntity quote,
    bool isFavorite,
    ThemeState themeState,
  ) {
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
                fontSize: themeState.fontSize,
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
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
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
                                  ).iconTheme.color?.withOpacity(0.3) ??
                                  Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showAddToCollectionBottomSheet(quote),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 22,
                        color:
                            Theme.of(
                              context,
                            ).iconTheme.color?.withOpacity(0.3) ??
                            Colors.grey,
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
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
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
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppStrings.saveToCollection,
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
                    title: const Text(
                      AppStrings.createNewCollection,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateCollectionDialog();
                    },
                  ),
                  const Divider(color: Colors.white10),
                  Expanded(
                    child: state.collections.isEmpty
                        ? const Center(
                            child: Text(
                              AppStrings.noCollections,
                              style: TextStyle(color: Colors.white54),
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
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.folder_outlined,
                                    color: Colors.white70,
                                  ),
                                ),
                                title: Text(
                                  collection.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${collection.quoteIds.length} quotes',
                                  style: const TextStyle(color: Colors.white38),
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
                                        '${AppStrings.addedTo} ${collection.name}',
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
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            AppStrings.newCollection,
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: AppStrings.collectionName,
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
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
                AppStrings.cancel,
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
                AppStrings.create,
                style: TextStyle(color: Colors.deepPurpleAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
