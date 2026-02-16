import 'package:equatable/equatable.dart';
import '../../data/models/movie_model.dart';
import '../../core/error.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesSuccess extends FavoritesState {
  final List<MovieModel> movies;

  const FavoritesSuccess(this.movies);

  @override
  List<Object?> get props => [movies];
}

class FavoritesError extends FavoritesState {
  final AppError error;

  const FavoritesError(this.error);

  @override
  List<Object?> get props => [error];
}
