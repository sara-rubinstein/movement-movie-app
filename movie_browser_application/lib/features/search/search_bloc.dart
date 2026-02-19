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
  int _totalResults = 0;
  List<MovieModel> _currentMovies = [];

  // ✅ Guard against duplicate LoadMore calls while already loading
  bool _isLoadingMore = false;

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
    _currentQuery = event.query;
    _currentPage = 1;
    _currentMovies = [];
    _totalResults = 0;
    _isLoadingMore = false;

    emit(const SearchLoading());

    try {
      // ✅ Repository now returns a record with movies + totalResults
      final (movies,total) = await _repository.searchMovies(_currentQuery, _currentPage);
      _currentMovies = movies;
      _totalResults = total;

      await _repository.addToSearchHistory(_currentQuery);

      emit(SearchSuccess(
        movies: List.from(_currentMovies),
        query: _currentQuery,
        currentPage: _currentPage,
        totalResults: _totalResults,
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
    // ✅ Prevent duplicate concurrent loads
    if (_isLoadingMore) return;

    final currentState = state;
    if (currentState is! SearchSuccess || !currentState.hasMore) return;

    _isLoadingMore = true;
    emit(SearchLoading(currentMovies: _currentMovies, isLoadingMore: true));

    try {
      _currentPage++;
      final (movies, total) = await _repository.searchMovies(_currentQuery, _currentPage);
      _currentMovies.addAll(movies);
      _totalResults = total;

      emit(SearchSuccess(
        movies: List.from(_currentMovies),
        query: _currentQuery,
        currentPage: _currentPage,
        totalResults: _totalResults,
      ));
    } on AppError catch (e) {
      _currentPage--;
      // ✅ Single emit — no double emit crash
      emit(SearchError(e, currentMovies: _currentMovies));
    } catch (e) {
      _currentPage--;
      emit(SearchError(GenericError(e.toString()), currentMovies: _currentMovies));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final history = await _repository.getSearchHistory();
      emit(SearchInitial(searchHistory: history));
    } catch (_) {
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
    } catch (_) {}
  }

  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.clearSearchHistory();
      emit(const SearchInitial(searchHistory: []));
    } catch (_) {}
  }
}