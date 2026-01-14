import 'package:flutter/material.dart';

class BrowseContent extends StatelessWidget {
  const BrowseContent({super.key});

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

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text(
              'Browse',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2832),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search quotes, authors, topics...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withOpacity(0.4),
                    size: 26,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Categories Grid
          Expanded(
            child: GridView.builder(
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
                  category['title'] as String,
                  category['colors'] as List<Color>,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, List<Color> colors) {
    return Container(
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
          const Positioned(
            left: 20,
            bottom: 20,
            child: Text(
              '', // Hidden, title moved below
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
    );
  }
}
