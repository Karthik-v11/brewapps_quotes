import 'package:flutter/material.dart';
import 'package:quote_vault/features/home/presentation/widgets/favorites_content.dart';
import 'package:quote_vault/features/home/presentation/widgets/collections_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:quote_vault/core/constants/app_strings.dart';

class LibraryContent extends StatefulWidget {
  const LibraryContent({super.key});

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  children: [
                    Text(
                      AppStrings.libraryTitle,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.displaySmall?.color,
                        letterSpacing: -1,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: themeState.accentColor,
              indicatorWeight: 3,
              labelColor: Theme.of(context).textTheme.bodyLarge?.color,
              unselectedLabelColor: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.5),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: AppStrings.favorites),
                Tab(text: AppStrings.collections),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [FavoritesContent(), CollectionsContent()],
              ),
            ),
          ],
        );
      },
    );
  }
}
