# QuoteVault

QuoteVault is a modern, feature-rich quote application built with Flutter and Supabase. It allows users to browse quotes, create collections, save favorites, and share beautiful quote images.

## Features

- **Browse Quotes**: Explore quotes by categories (Love, Success, Wisdom, etc.).
- **Daily Inspiration**: Get a "Quote of the Day" with daily notifications.
- **Collections**: Create and manage your own collections of quotes.
- **Community**: Discover public collections from other users.
- **Customization**: Dark mode, accent colors, and font size adjustments.
- **Sharing**: Share quotes as beautiful images with customizable templates (Classic, Modern, Minimal).

## Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or later)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/quote_vault.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Setup Environment Variables (Optional):
   The application comes with default Supabase configuration for development. To use your own Supabase project, you can provide the credentials using `--dart-define` when building or running the app.

   **Arguments:**
   - `SUPABASE_URL`: Your Supabase Project URL
   - `SUPABASE_ANON_KEY`: Your Supabase Anon/Public Key

   **Example:**
   ```bash
   flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
   ```

### Running the App

To run the app in debug mode on a connected device or emulator:

```bash
flutter run
```

### Architecture

The project follows a **Clean Architecture** approach with **BLoC** for state management.

- **Presentation Layer**: Pages, Widgets, BLoCs
- **Domain Layer**: Entities, UseCases, Repository Interfaces
- **Data Layer**: Models, DataSources, Repository Implementations

### Dependencies

- `flutter_bloc`: State management
- `supabase_flutter`: Backend as a Service
- `get_it`: Dependency Injection
- `equatable`: Value comparisons
- `shared_preferences`: Local storage
- `flutter_local_notifications`: Local notifications
- `share_plus`: Sharing functionality
- `path_provider`: File system access
- `google_fonts`: Typography
- `shimmer`: Loading effects
- `cached_network_image`: Image caching
- `intl`: Internationalization

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
