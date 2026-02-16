import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';
import '../../core/error.dart';
import 'details_event.dart';
import 'details_state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final MovieRepository _repository;
  String? _currentImdbId;

  DetailsBloc(this._repository) : super(const DetailsInitial()) {
    on<LoadMovieDetails>(_onLoadMovieDetails);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetails event,
    Emitter<DetailsState> emit,
  ) async {
    _currentImdbId = event.imdbId;
    emit(const DetailsLoading());

    try {
      final movieDetails = await _repository.getMovieDetails(event.imdbId);
      final isFavorite = await _repository.isFavorite(event.imdbId);

      emit(DetailsSuccess(
        movie: movieDetails,
        isFavorite: isFavorite,
      ));
    } on NetworkError catch (e) {
      // Try to get cached data
      final cachedMovie = await _repository.getCachedMovieDetails(event.imdbId);
      if (cachedMovie != null) {
        final isFavorite = await _repository.isFavorite(event.imdbId);
        emit(DetailsSuccess(
          movie: cachedMovie,
          isFavorite: isFavorite,
          isFromCache: true,
        ));
      } else {
        emit(DetailsError(e));
      }
    } on AppError catch (e) {
      // Try to get cached data for other errors too
      final cachedMovie = await _repository.getCachedMovieDetails(event.imdbId);
      if (cachedMovie != null) {
        final isFavorite = await _repository.isFavorite(event.imdbId);
        emit(DetailsSuccess(
          movie: cachedMovie,
          isFavorite: isFavorite,
          isFromCache: true,
        ));
      } else {
        emit(DetailsError(e));
      }
    } catch (e) {
      emit(DetailsError(GenericError(e.toString())));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<DetailsState> emit,
  ) async {
    if (state is DetailsSuccess && _currentImdbId != null) {
      final currentState = state as DetailsSuccess;
      
      try {
        if (currentState.isFavorite) {
          await _repository.removeFromFavorites(_currentImdbId!);
        } else {
          final movie = MovieModel(
            imdbId: currentState.movie.imdbId,
            title: currentState.movie.title,
            year: currentState.movie.year,
            type: currentState.movie.type,
            poster: currentState.movie.poster,
          );
          await _repository.addToFavorites(movie);
        }

        emit(currentState.copyWith(isFavorite: !currentState.isFavorite));
      } catch (e) {
        // Handle error silently or show a snackbar
      }
    }
  }
}
