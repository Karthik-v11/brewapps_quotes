import 'package:flutter/material.dart';

class FavoritesContent extends StatefulWidget {
  const FavoritesContent({super.key});

  @override
  State<FavoritesContent> createState() => _FavoritesContentState();
}

class _FavoritesContentState extends State<FavoritesContent> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'By Author', 'By Topic'];

  final List<Map<String, String>> _favoriteQuotes = [
    {
      'text': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
    {
      'text':
          'In three words I can sum up everything I’ve learned about life: it goes on.',
      'author': 'Robert Frost',
    },
    {
      'text':
          'The future belongs to those who believe in the beauty of their dreams.',
      'author': 'E. Roosevelt',
    },
    {
      'text': 'Strive not to be a success, but rather to be of value.',
      'author': 'A. Einstein',
    },
    {
      'text': 'The mind is everything. What you think you become.',
      'author': 'Buddha',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Split quotes into two columns for pseudo-masonry effect
    final leftColumnQuotes = <Map<String, String>>[];
    final rightColumnQuotes = <Map<String, String>>[];

    for (var i = 0; i < _favoriteQuotes.length; i++) {
      if (i % 2 == 0) {
        leftColumnQuotes.add(_favoriteQuotes[i]);
      } else {
        rightColumnQuotes.add(_favoriteQuotes[i]);
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 24),
              child: Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ),
            // Filters
            Row(
              children: _filters
                  .map((filter) => _buildFilterPill(filter))
                  .toList(),
            ),
            const SizedBox(height: 32),
            // Masonry-like Grid using Row of Columns
            Row(
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
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
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
              : const Color(0xFF1E2832).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, String> quote) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
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
            quote['text']!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
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
                  '— ${quote['author']!}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.favorite_rounded,
                size: 20,
                color: Colors.white.withOpacity(0.15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
