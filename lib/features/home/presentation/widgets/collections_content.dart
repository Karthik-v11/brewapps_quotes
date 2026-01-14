import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CollectionsContent extends StatelessWidget {
  const CollectionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> collections = [
      {
        'title': 'Stoic Wisdom',
        'count': 12,
        'gradient': const [Color(0xFF001F3F), Color(0xFF0074D9)],
      },
      {
        'title': 'Morning Motivation',
        'count': 28,
        'gradient': const [Color(0xFF1B4D3E), Color(0xFF7FB069)],
      },
      {
        'title': 'On Success',
        'count': 7,
        'gradient': const [Color(0xFF2C3E50), Color(0xFFBDC3C7)],
      },
      {
        'title': 'Deep Thoughts',
        'count': 19,
        'gradient': const [Color(0xFF4A90E2), Color(0xFFD0021B)],
      },
      {
        'title': 'Mindfulness',
        'count': 5,
        'gradient': const [Color(0xFFE67E22), Color(0xFFF1C40F)],
      },
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text(
              'Collections',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: collections.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCreateNewCard();
                }
                final collection = collections[index - 1];
                return _buildCollectionCard(
                  collection['title'],
                  collection['count'],
                  collection['gradient'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: Colors.white24,
          strokeWidth: 2,
          gap: 6,
          radius: 24,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24),
            child: const Center(
              child: Text(
                'Create New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionCard(String title, int count, List<Color> colors) {
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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count Quotes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(radius)),
      );

    final dashPath = Path();
    double distance = 0.0;
    for (ui.PathMetric measure in path.computeMetrics()) {
      while (distance < measure.length) {
        dashPath.addPath(
          measure.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
