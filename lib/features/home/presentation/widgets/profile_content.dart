import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:quote_vault/service_locator.dart';
import 'package:quote_vault/core/services/notification_service.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = authState.user;

        return BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, favState) {
            return BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Top Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.color,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.settings_outlined,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeState.accentColor.withOpacity(
                                        0.1,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: themeState.accentColor,
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? Text(
                                          (user.name ?? user.email)[0]
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 40,
                                            color: Theme.of(context)
                                                .primaryTextTheme
                                                .headlineMedium
                                                ?.color,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                user.name ?? 'User',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Stats Card
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(context, '0', 'Quotes'),
                              _buildDivider(context),
                              _buildStatItem(
                                context,
                                favState.collections.length.toString(),
                                'Collections',
                              ),
                              _buildDivider(context),
                              _buildStatItem(
                                context,
                                favState.favorites.length.toString(),
                                'Favorites',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Personalization Header
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Personalization',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Theme Toggle
                        _buildSettingCard(
                          context,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.dark_mode_outlined,
                                    color: Theme.of(
                                      context,
                                    ).iconTheme.color?.withOpacity(0.7),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    'Dark Mode',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: themeState.isDarkMode,
                                activeColor: themeState.accentColor,
                                onChanged: (val) {
                                  context.read<ThemeBloc>().add(
                                    ThemeToggleRequested(val),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Accent Color Picker
                        _buildSettingCard(
                          context,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Accent Color',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 40,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _buildColorOption(
                                      context,
                                      Colors.deepPurpleAccent,
                                      themeState,
                                    ),
                                    _buildColorOption(
                                      context,
                                      Colors.blueAccent,
                                      themeState,
                                    ),
                                    _buildColorOption(
                                      context,
                                      Colors.greenAccent,
                                      themeState,
                                    ),
                                    _buildColorOption(
                                      context,
                                      Colors.orangeAccent,
                                      themeState,
                                    ),
                                    _buildColorOption(
                                      context,
                                      Colors.pinkAccent,
                                      themeState,
                                    ),
                                    _buildColorOption(
                                      context,
                                      Colors.redAccent,
                                      themeState,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        _buildSettingCard(
                          context,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Font Size',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${themeState.fontSize.toInt()}px',
                                    style: TextStyle(
                                      color: themeState.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: themeState.fontSize,
                                min: 14,
                                max: 32,
                                activeColor: themeState.accentColor,
                                inactiveColor: themeState.accentColor
                                    .withOpacity(0.2),
                                onChanged: (val) {
                                  context.read<ThemeBloc>().add(
                                    ThemeFontSizeChanged(val),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Daily Reminder Time
                        _buildSettingCard(
                          context,
                          child: InkWell(
                            onTap: () async {
                              final parts = themeState.notificationTime.split(
                                ':',
                              );
                              final initialTime = TimeOfDay(
                                hour: int.tryParse(parts[0]) ?? 9,
                                minute: int.tryParse(parts[1]) ?? 0,
                              );
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: themeState.accentColor,
                                        onPrimary: Colors.white,
                                        surface: Theme.of(context).cardColor,
                                        onSurface:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color ??
                                            Colors.black,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                final timeStr =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                context.read<ThemeBloc>().add(
                                  ThemeNotificationTimeChanged(timeStr),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_active_outlined,
                                      color: Theme.of(
                                        context,
                                      ).iconTheme.color?.withOpacity(0.7),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      'Daily Reminder',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: themeState.accentColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    themeState.notificationTime,
                                    style: TextStyle(
                                      color: themeState.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Account Header
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Account & App',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Settings List
                        _buildActionRow(
                          context,
                          Icons.person_outline,
                          'Edit Profile',
                          onTap: () =>
                              _showEditProfileDialog(context, user.name ?? ''),
                        ),
                        _buildActionRow(
                          context,
                          Icons.lock_outline_rounded,
                          'Change Password',
                          onTap: () {
                            context.read<AuthBloc>().add(
                              AuthPasswordResetRequested(user.email),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password reset email sent'),
                                backgroundColor: Colors.deepPurpleAccent,
                              ),
                            );
                          },
                        ),
                        _buildActionRow(
                          context,
                          Icons.notifications_none_rounded,
                          'Notifications',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification settings updated'),
                              ),
                            );
                          },
                        ),
                        _buildActionRow(
                          context,
                          Icons.notifications_active,
                          'Test Notification',
                          onTap: () {
                            sl<NotificationService>().showImmediateNotification(
                              title: 'Test Notification',
                              body:
                                  'This is a test notification from QuoteVault.',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification sent!'),
                              ),
                            );
                          },
                        ),
                        _buildActionRow(
                          context,
                          Icons.help_outline_rounded,
                          'Help & Support',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Support ticket created'),
                              ),
                            );
                          },
                        ),
                        _buildActionRow(
                          context,
                          Icons.logout_rounded,
                          'Logout',
                          color: Colors.redAccent,
                          onTap: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                        ),
                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AuthBloc>().add(
                  AuthUpdateProfileRequested(name: controller.text.trim()),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildSettingCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    Color color,
    ThemeState themeState,
  ) {
    final isSelected = themeState.accentColor.value == color.value;
    return GestureDetector(
      onTap: () {
        context.read<ThemeBloc>().add(ThemeAccentColorChanged(color));
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    IconData icon,
    String label, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final effectiveColor =
        color ?? Theme.of(context).textTheme.bodyLarge?.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (effectiveColor ?? Colors.grey).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: effectiveColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: effectiveColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: (effectiveColor ?? Colors.grey).withOpacity(0.3),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
