import 'package:equatable/equatable.dart';
import '../../data/models/movie_model.dart';
import '../../core/error.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<String> searchHistory;

  const SearchInitial({this.searchHistory = const []});

  @override
  List<Object?> get props => [searchHistory];
}

class SearchLoading extends SearchState {
  final List<MovieModel> currentMovies;
  final bool isLoadingMore;

  const SearchLoading({
    this.currentMovies = const [],
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [currentMovies, isLoadingMore];
}

class SearchSuccess extends SearchState {
  final List<MovieModel> movies;
  final String query;
  final int currentPage;
  final bool hasMore;

  const SearchSuccess({
    required this.movies,
    required this.query,
    required this.currentPage,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [movies, query, currentPage, hasMore];
}

class SearchError extends SearchState {
  final AppError error;
  final List<MovieModel> currentMovies;

  const SearchError(this.error, {this.currentMovies = const []});

  @override
  List<Object?> get props => [error, currentMovies];
}
