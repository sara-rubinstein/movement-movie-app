import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';
import '../../core/error.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MovieRepository _repository;
  String _currentQuery = '';
  int _currentPage = 1;
  List<MovieModel> _currentMovies = [];

  SearchBloc(this._repository) : super(const SearchInitial()) {
    on<SearchMovies>(_onSearchMovies);
    on<LoadMoreMovies>(_onLoadMoreMovies);
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<RemoveFromSearchHistory>(_onRemoveFromSearchHistory);
    on<ClearSearchHistory>(_onClearSearchHistory);
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<SearchState> emit,
  ) async {
    if (event.isNewSearch) {
      _currentQuery = event.query;
      _currentPage = 1;
      _currentMovies = [];
      emit(const SearchLoading());
    } else {
      emit(SearchLoading(currentMovies: _currentMovies, isLoadingMore: false));
    }

    try {
      final movies = await _repository.searchMovies(_currentQuery, _currentPage);
      
      if (event.isNewSearch) {
        _currentMovies = movies;
        await _repository.addToSearchHistory(_currentQuery);
      } else {
        _currentMovies.addAll(movies);
      }

      emit(SearchSuccess(
        movies: List.from(_currentMovies),
        query: _currentQuery,
        currentPage: _currentPage,
        hasMore: movies.length == 10, // Assuming 10 results per page
      ));
    } on AppError catch (e) {
      emit(SearchError(e, currentMovies: _currentMovies));
    } catch (e) {
      emit(SearchError(GenericError(e.toString()), currentMovies: _currentMovies));
    }
  }

  Future<void> _onLoadMoreMovies(
    LoadMoreMovies event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchSuccess) {
      final currentState = state as SearchSuccess;
      
      if (!currentState.hasMore) return;

      emit(SearchLoading(currentMovies: _currentMovies, isLoadingMore: true));

      try {
        _currentPage++;
        final movies = await _repository.searchMovies(_currentQuery, _currentPage);
        _currentMovies.addAll(movies);

        emit(SearchSuccess(
          movies: List.from(_currentMovies),
          query: _currentQuery,
          currentPage: _currentPage,
          hasMore: movies.length == 10,
        ));
      } on AppError catch (e) {
        _currentPage--; // Rollback page increment
        emit(SearchError(e, currentMovies: _currentMovies));
        emit(SearchSuccess(
          movies: List.from(_currentMovies),
          query: _currentQuery,
          currentPage: _currentPage,
          hasMore: true,
        ));
      } catch (e) {
        _currentPage--;
        emit(SearchError(GenericError(e.toString()), currentMovies: _currentMovies));
        emit(SearchSuccess(
          movies: List.from(_currentMovies),
          query: _currentQuery,
          currentPage: _currentPage,
          hasMore: true,
        ));
      }
    }
  }

  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final history = await _repository.getSearchHistory();
      emit(SearchInitial(searchHistory: history));
    } catch (e) {
      emit(const SearchInitial());
    }
  }

  Future<void> _onRemoveFromSearchHistory(
    RemoveFromSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.removeFromSearchHistory(event.query);
      final history = await _repository.getSearchHistory();
      emit(SearchInitial(searchHistory: history));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.clearSearchHistory();
      emit(const SearchInitial(searchHistory: []));
    } catch (e) {
      // Handle error silently
    }
  }
}
