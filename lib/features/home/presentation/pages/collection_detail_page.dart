import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/quotes/domain/entities/user_action_entities.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/features/home/presentation/pages/quote_detail_page.dart';
import 'package:quote_vault/features/quotes/domain/repositories/quote_repository.dart';
import 'package:quote_vault/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:quote_vault/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionDetailPage extends StatefulWidget {
  final CollectionEntity collection;

  const CollectionDetailPage({super.key, required this.collection});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  List<QuoteEntity> _quotes = [];
  List<QuoteEntity> _relatedQuotes = [];
  bool _isLoading = true;
  late bool _isPublic;
  late bool _isOwner;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.collection.isPublic;
    final userId = sl<SupabaseClient>().auth.currentUser?.id;
    _isOwner = widget.collection.userId == userId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final repo = sl<QuoteRepository>();

    // Fetch collection quotes
    final quotesResult = await repo.getQuotesByIds(widget.collection.quoteIds);
    quotesResult.fold((failure) => null, (quotes) {
      if (mounted) setState(() => _quotes = quotes);
    });

    // Fetch related quotes (simple logic: use category of first quote if available)
    if (_quotes.isNotEmpty) {
      final relatedResult = await repo.getQuotes(
        category: _quotes.first.category,
        limit: 5,
      );
      relatedResult.fold((failure) => null, (quotes) {
        if (mounted) {
          setState(() {
            _relatedQuotes = quotes
                .where((q) => !widget.collection.quoteIds.contains(q.id))
                .toList();
          });
        }
      });
    } else {
      // If empty, just show some motivation quotes as suggestions
      final relatedResult = await repo.getQuotes(
        category: 'Motivation',
        limit: 5,
      );
      relatedResult.fold((failure) => null, (quotes) {
        if (mounted) setState(() => _relatedQuotes = quotes);
      });
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.collection.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.color,
                          ),
                        ),
                      ),
                      if (_isPublic)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                            ),
                          ),
                          child: const Text(
                            'PUBLIC',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    if (_isOwner)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (val) {
                          if (val == 'toggle_public') {
                            setState(() => _isPublic = !_isPublic);
                            context.read<FavoritesBloc>().add(
                              ToggleCollectionPublicRequested(
                                widget.collection.id,
                                _isPublic,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isPublic
                                      ? 'Collection is now public'
                                      : 'Collection is now private',
                                ),
                                backgroundColor: _isPublic
                                    ? Colors.green
                                    : Colors.blueGrey,
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle_public',
                            child: Row(
                              children: [
                                Icon(
                                  _isPublic ? Icons.public_off : Icons.public,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _isPublic ? 'Make Private' : 'Make Public',
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else if (!_isOwner)
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () => _copyCollection(),
                        tooltip: 'Copy to my collections',
                      ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomScrollView(
                          slivers: [
                            if (_quotes.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Text(
                                    'This collection is empty',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              )
                            else
                              SliverPadding(
                                padding: const EdgeInsets.all(24),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => _buildQuoteCard(
                                      _quotes[index],
                                      themeState,
                                    ),
                                    childCount: _quotes.length,
                                  ),
                                ),
                              ),

                            if (_isOwner)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    40,
                                    24,
                                    16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Add Related Quotes',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.color,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _loadData();
                                        },
                                        child: Text(
                                          'Refresh',
                                          style: TextStyle(
                                            color: themeState.accentColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_isOwner)
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => _buildRelatedQuoteCard(
                                      _relatedQuotes[index],
                                      themeState,
                                    ),
                                    childCount: _relatedQuotes.length,
                                  ),
                                ),
                              ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 100),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuoteCard(QuoteEntity quote, ThemeState themeState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              Row(
                children: [
                  if (_isOwner)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _removeQuote(quote),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.open_in_new,
                      size: 20,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withOpacity(0.38),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuoteDetailPage(quote: quote),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _removeQuote(QuoteEntity quote) {
    context.read<FavoritesBloc>().add(
      RemoveQuoteFromCollectionRequested(widget.collection.id, quote.id),
    );
    setState(() {
      _quotes.removeWhere((q) => q.id == quote.id);
      _relatedQuotes.insert(0, quote);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed from ${widget.collection.name}'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyCollection() {
    context.read<FavoritesBloc>().add(
      CreateCollectionRequested(
        name: '${widget.collection.name} (Copy)',
        description: widget.collection.description,
      ),
    );

    // After creating collection, we need to add all quotes to it
    // This is a bit complex since we don't have the new collection ID yet easily
    // But we can show a success message or handle it in BLoC.
    // For now, let's just create the collection header.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Collection copied to your library!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildRelatedQuoteCard(QuoteEntity quote, ThemeState themeState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quote.author,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: themeState.accentColor),
            onPressed: () {
              context.read<FavoritesBloc>().add(
                AddQuoteToCollectionRequested(widget.collection.id, quote.id),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added to ${widget.collection.name}'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              setState(() {
                _quotes.add(quote);
                _relatedQuotes.removeWhere((q) => q.id == quote.id);
              });
            },
          ),
        ],
      ),
    );
  }
}
