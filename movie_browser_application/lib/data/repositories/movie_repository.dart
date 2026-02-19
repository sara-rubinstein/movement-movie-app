import 'package:hive/hive.dart';
import '../../core/error.dart';
import '../../core/constants.dart';
import '../../core/api_client.dart';
import '../models/movie_model.dart';
import '../models/movie_details_model.dart';

class MovieRepository {
  final ApiClient _apiClient;

  MovieRepository(this._apiClient);

  // Search Movies
  Future<(List<MovieModel>,int)> searchMovies(String query, int page) async {
    if (query.trim().isEmpty) {
      throw EmptySearchError();
    }
final data = await _apiClient.searchMovies(query, page);
  final List<dynamic> results = data['Search'] ?? [];
  final int total = int.tryParse(data['totalResults'] ?? '0') ?? 0; // ✅ grab total
  final movies = results.map((json) => MovieModel.fromJson(json)).toList();
  return (movies, total); // ✅ return both
  }

  // Get Movie Details
  Future<MovieDetailsModel> getMovieDetails(String imdbId) async {
    try {
      final data = await _apiClient.getMovieDetails(imdbId);
      final movieDetails = MovieDetailsModel.fromJson(data);
      
      // Cache movie details
      await _cacheMovieDetails(movieDetails);
      
      return movieDetails;
    } catch (e) {
      // Try to get cached data if network fails
      if (e is NetworkError || e is ApiError) {
        final cachedMovie = await getCachedMovieDetails(imdbId);
        if (cachedMovie != null) {
          return cachedMovie;
        }
      }
      rethrow;
    }
  }

  // Cache movie details
  Future<void> _cacheMovieDetails(MovieDetailsModel movie) async {
    final box = await Hive.openBox<MovieDetailsModel>(AppConstants.movieDetailsBox);
    await box.put(movie.imdbId, movie);
  }

  // Get cached movie details
  Future<MovieDetailsModel?> getCachedMovieDetails(String imdbId) async {
    final box = await Hive.openBox<MovieDetailsModel>(AppConstants.movieDetailsBox);
    return box.get(imdbId);
  }

  // Favorites
  Future<void> addToFavorites(MovieModel movie) async {
    final box = await Hive.openBox<MovieModel>(AppConstants.favoritesBox);
    await box.put(movie.imdbId, movie);
  }

  Future<void> removeFromFavorites(String imdbId) async {
    final box = await Hive.openBox<MovieModel>(AppConstants.favoritesBox);
    await box.delete(imdbId);
  }

  Future<bool> isFavorite(String imdbId) async {
    final box = await Hive.openBox<MovieModel>(AppConstants.favoritesBox);
    return box.containsKey(imdbId);
  }

  Future<List<MovieModel>> getFavorites() async {
    final box = await Hive.openBox<MovieModel>(AppConstants.favoritesBox);
    return box.values.toList();
  }

  // Search History
  Future<void> addToSearchHistory(String query) async {
    final box = await Hive.openBox<String>(AppConstants.searchHistoryBox);
    final history = box.values.toList();
    
    // Remove if already exists
    history.remove(query);
    
    // Add to beginning
    history.insert(0, query);
    
    // Keep only last 20 searches
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    
    // Clear and add all
    await box.clear();
    for (var i = 0; i < history.length; i++) {
      await box.add(history[i]);
    }
  }

  Future<List<String>> getSearchHistory() async {
    final box = await Hive.openBox<String>(AppConstants.searchHistoryBox);
    return box.values.toList();
  }

  Future<void> removeFromSearchHistory(String query) async {
    final box = await Hive.openBox<String>(AppConstants.searchHistoryBox);
    final history = box.values.toList();
    history.remove(query);
    
    await box.clear();
    for (var item in history) {
      await box.add(item);
    }
  }

  Future<void> clearSearchHistory() async {
    final box = await Hive.openBox<String>(AppConstants.searchHistoryBox);
    await box.clear();
  }
}