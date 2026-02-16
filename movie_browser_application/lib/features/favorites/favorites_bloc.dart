import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/movie_repository.dart';
import '../../core/error.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final MovieRepository _repository;

  FavoritesBloc(this._repository) : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    try {
      final favorites = await _repository.getFavorites();
      emit(FavoritesSuccess(favorites));
    } catch (e) {
      emit(FavoritesError(GenericError(e.toString())));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _repository.removeFromFavorites(event.imdbId);
      final favorites = await _repository.getFavorites();
      emit(FavoritesSuccess(favorites));
    } catch (e) {
      emit(FavoritesError(GenericError(e.toString())));
    }
  }
}