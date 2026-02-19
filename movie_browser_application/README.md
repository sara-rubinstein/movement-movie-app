# Movie Browser Application

A Flutter application that allows users to search for movies using the OMDb API, view movie details, and manage favorites.

## Features

✅ **Search Screen**
- Text input field and search button
- Pagination (load more movies)
- Search history with ability to:
  - Save search queries
  - Remove individual items
  - Clear all history
  - Stored locally using Hive

✅ **Results List**
- Display movie cards with:
  - Title
  - Year
  - Type
  - Poster image
- Tap to navigate to Details Screen

✅ **Details Screen**
- Load and display full movie details
- Cache fallback: Shows last saved movie details from Hive if network fails
- Add/Remove movies from favorites
- Visual indicator when showing cached data

✅ **Favorites Screen**
- Display saved favorite movies
- Remove from favorites
- Navigate to Details Screen

✅ **Error Handling**
- Empty search results
- Network errors
- API errors
- All errors properly localized

✅ **Localization**
- Using `intl` package
- All user-facing text from JSON asset
- No hardcoded UI strings

## Technical Stack

### Required Dependencies
- **State Management**: `flutter_bloc` with BLoC pattern
- **Local Storage**: `hive` and `hive_flutter`
- **HTTP Requests**: `dio`
- **Localization**: `intl`
- **UI**: Material Design

### Optional Dependencies
- **Local UI State**: `flutter_hooks`
- **Image Caching**: `cached_network_image`

## Project Structure

```
lib/
├── core/
│   ├── api_client.dart          # Dio HTTP client
│   ├── constants.dart           # App constants
│   ├── error.dart               # Custom error classes
│   └── localization.dart        # Localization helper
├── data/
│   ├── models/
│   │   ├── movie_model.dart              # Movie model
│   │   ├── movie_model.g.dart            # Hive adapter
│   │   ├── movie_details_model.dart      # Movie details model
│   │   └── movie_details_model.g.dart    # Hive adapter
│   └── repositories/
│       └── movie_repository.dart         # Data repository
├── features/
│   ├── search/
│   │   ├── search_bloc.dart      # Search BLoC
│   │   ├── search_event.dart     # Search events
│   │   ├── search_state.dart     # Search states
│   │   └── search_screen.dart    # Search UI
│   ├── details/
│   │   ├── details_bloc.dart     # Details BLoC
│   │   ├── details_event.dart    # Details events
│   │   ├── details_state.dart    # Details states
│   │   └── details_screen.dart   # Details UI
│   └── favorites/
│       ├── favorites_bloc.dart   # Favorites BLoC
│       ├── favorites_event.dart  # Favorites events
│       ├── favorites_state.dart  # Favorites states
│       └── favorites_screen.dart # Favorites UI
└── main.dart                     # App entry point

assets/
└── i18n/
    └── en.json                   # English translations
```

## How to Run

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- An OMDb API key (get one at https://www.omdbapi.com/apikey.aspx)

### Setup Steps

1. **Clone the repository**
   ```bash
    git clone  https://github.com/sara-rubinstein/movement-movie-app.git
    cd movie_browser_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add your API key**
   
   Open `lib/core/constants.dart` and replace `YOUR_API_KEY_HERE` with your actual OMDb API key:
   ```dart
   static const String apiKey = 'your_actual_api_key';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Generate Code (if needed)
If you make changes to Hive models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Architecture Decisions

### BLoC Pattern
- **Why**: Provides clear separation between business logic and UI
- **Implementation**: Using `flutter_bloc` package with proper event/state management
- **Benefits**: Testable, maintainable, and follows reactive programming principles

### Repository Pattern
- **Why**: Abstracts data sources (API and local storage)
- **Implementation**: Single `MovieRepository` handles both network and local data
- **Benefits**: Easy to test, swap data sources, and maintain

### Hive for Local Storage
- **Why**: Fast, lightweight, and pure Dart NoSQL database
- **Implementation**: Three boxes for favorites, search history, and movie details cache
- **Benefits**: No native dependencies, excellent performance

### Error Handling Strategy
- **Custom Error Classes**: Type-safe error handling with `AppError` hierarchy
- **Localized Messages**: All error messages translated via localization keys
- **Graceful Degradation**: Cache fallback when network fails

### Cache Strategy
- **Details Screen**: Automatically caches movie details on successful fetch
- **Fallback Mechanism**: Shows cached data when network request fails
- **User Feedback**: Visual indicator when displaying cached data

## Features Not Implemented

All required features have been implemented. Optional bonus features:

### Implemented:
- ✅ Cache fallback for movie details
- ✅ Proper error handling
- ✅ Pagination
- ✅ Search history management

### Could Be Added (Beyond Scope):
- Unit tests for BLoCs (mentioned as bonus)
- Accessibility features (large text scaling, semantics)
- Advanced filtering options
- Movie recommendations
- Share functionality

## Testing

To run tests:
```bash
flutter test
```

## Known Limitations

1. **API Key**: You must provide your own OMDb API key
2. **Free API Tier**: Limited to 1000 requests per day on free tier
3. **Pagination**: OMDb returns max 10 results per page
4. **No Authentication**: App doesn't require user login

## Performance Optimizations

- Image caching using `cached_network_image`
- Hive for fast local data access
- Efficient pagination with scroll controller
- Debouncing not implemented (could be added for search input)

## Future Improvements

1. Add comprehensive unit and widget tests
2. Implement accessibility features
3. Add more localization languages
4. Implement advanced search filters
5. Add dark mode support
6. Offline-first architecture with sync
7. Performance monitoring and analytics

