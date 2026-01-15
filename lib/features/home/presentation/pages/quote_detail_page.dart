import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/core/services/export_service.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_export_template.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

class QuoteDetailPage extends StatelessWidget {
  final QuoteEntity quote;
  final ExportService _exportService = ExportService();

  QuoteDetailPage({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              AppStrings.quote,
              style: TextStyle(
                color: Theme.of(context).textTheme.headlineSmall?.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).textTheme.headlineSmall?.color,
                size: 32,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              children: [
                const Spacer(),
                // Quote Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 60,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          quote.content,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                themeState.fontSize + 10, // Larger in detail
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.color,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          quote.author,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            quote.category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.3),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BlocBuilder<FavoritesBloc, FavoritesState>(
                        builder: (context, state) {
                          final isFav = state.favorites.any(
                            (q) => q.id == quote.id,
                          );
                          return _buildActionButton(
                            context,
                            isFav ? Icons.favorite : Icons.favorite_border,
                            AppStrings.favorite,
                            color: isFav
                                ? Colors.redAccent
                                : Theme.of(context).iconTheme.color!,
                            onTap: () {
                              context.read<FavoritesBloc>().add(
                                ToggleFavoriteRequested(quote),
                              );
                            },
                          );
                        },
                      ),
                      _buildActionButton(
                        context,
                        Icons.bookmark_border_rounded,
                        AppStrings.save,
                        onTap: () => _showAddToCollectionBottomSheet(context),
                      ),
                      _buildActionButton(
                        context,
                        Icons.ios_share,
                        AppStrings.share,
                        onTap: () => _showShareStylePicker(context),
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

  void _showAddToCollectionBottomSheet(BuildContext context) {
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
                      _showCreateCollectionDialog(context);
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

  void _showCreateCollectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
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
                  Navigator.pop(dialogContext);
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

  void _showShareStylePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.chooseShareStyle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStyleOption(
                    context,
                    AppStrings.classic,
                    ExportTemplate.classic,
                    Colors.amber.shade100,
                  ),
                  _buildStyleOption(
                    context,
                    AppStrings.modern,
                    ExportTemplate.modern,
                    const Color(0xFF1F2B36),
                  ),
                  _buildStyleOption(
                    context,
                    AppStrings.minimal,
                    ExportTemplate.minimal,
                    Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStyleOption(
    BuildContext context,
    String label,
    ExportTemplate template,
    Color previewColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _exportService.shareQuoteImage(
          QuoteExportTemplate(
            content: quote.content,
            author: quote.author,
            template: template,
          ),
          '${quote.content} - ${quote.author}',
        );
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: previewColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(
              Icons.image_outlined,
              color: template == ExportTemplate.minimal
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final effectiveColor = color ?? Theme.of(context).iconTheme.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(36),
              child: Icon(icon, color: effectiveColor, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
