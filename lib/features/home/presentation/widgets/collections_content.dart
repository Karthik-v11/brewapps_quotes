import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'package:quote_vault/features/quotes/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/features/home/presentation/pages/collection_detail_page.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

class CollectionsContent extends StatelessWidget {
  const CollectionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          final collections = state.collections;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FavoritesBloc>().add(FetchCollectionsRequested());
            },
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                      itemCount: collections.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildCreateNewCard(context);
                        }
                        final collection = collections[index - 1];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CollectionDetailPage(
                                  collection: collection,
                                ),
                              ),
                            );
                          },
                          child: _buildCollectionCard(
                            collection.name,
                            collection.quoteIds.length,
                            _getGradientFromName(collection.name),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Color> _getGradientFromName(String name) {
    final List<List<Color>> gradients = [
      [const Color(0xFF001F3F), const Color(0xFF0074D9)],
      [const Color(0xFF1B4D3E), const Color(0xFF7FB069)],
      [const Color(0xFF2C3E50), const Color(0xFFBDC3C7)],
      [const Color(0xFF4A90E2), const Color(0xFFD0021B)],
      [const Color(0xFFE67E22), const Color(0xFFF1C40F)],
    ];
    return gradients[name.length % gradients.length];
  }

  Widget _buildCreateNewCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: Theme.of(context).dividerColor,
          strokeWidth: 2,
          gap: 6,
          radius: 24,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showCreateDialog(context),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  AppStrings.createNewCollection,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    bool isPublic = false;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          AppStrings.newCollection,
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.collectionName,
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                //   Row(
                //     children: [
                //       Text(
                //         AppStrings.makePublic,
                //         style: TextStyle(
                //           color: Theme.of(context).textTheme.bodyMedium?.color,
                //         ),
                //       ),
                //       const Spacer(),
                //       Switch(
                //         value: isPublic,
                //         onChanged: (val) {
                //           setDialogState(() => isPublic = val);
                //         },
                //         activeColor: Colors.deepPurpleAccent,
                //       ),
                //     ],
                //   ),
                //   Text(
                //     AppStrings.makePublicDesc,
                //     style: TextStyle(
                //       color: Theme.of(context).textTheme.bodySmall?.color,
                //       fontSize: 11,
                //     ),
                //   ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<FavoritesBloc>().add(
                  CreateCollectionRequested(
                    name: controller.text,
                    isPublic: isPublic,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text(AppStrings.create),
          ),
        ],
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
                  '$count ${AppStrings.quotes}',
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
