import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:quote_vault/features/home/presentation/widgets/home_content.dart';
import 'package:quote_vault/features/home/presentation/widgets/browse_content.dart';
import 'package:quote_vault/features/home/presentation/widgets/community_content.dart';
import 'package:quote_vault/features/home/presentation/widgets/library_content.dart';
import 'package:quote_vault/features/home/presentation/widgets/profile_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onTabChange(int index) {
    setState(() => _selectedIndex = index);
  }

  List<Widget> get _pages => [
    const HomeContent(),
    BrowseContent(onTabChange: _onTabChange),
    //const CommunityContent(),
    const LibraryContent(),
    const ProfileContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          // Use scaffold text color style if needed or just let pages handle it
          body: _pages[_selectedIndex],
          bottomNavigationBar: _buildBottomNavBar(themeState),
        );
      },
    );
  }

  Widget _buildBottomNavBar(ThemeState themeState) {
    final navTheme = Theme.of(context).bottomNavigationBarTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: navTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'Home', 0, themeState),
          _buildNavItem(Icons.explore_outlined, 'Explore', 1, themeState),
          // _buildNavItem(
          //   Icons.people_outline_rounded,
          //   'Community',
          //   2,
          //   themeState,
          // ),
          _buildNavItem(Icons.library_books_outlined, 'Library', 2, themeState),
          _buildNavItem(Icons.person_outline_rounded, 'Profile', 3, themeState),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    ThemeState themeState,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? themeState.accentColor
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white38
                      : Colors.black38),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? themeState.accentColor
                  : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white38
                        : Colors.black38),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
