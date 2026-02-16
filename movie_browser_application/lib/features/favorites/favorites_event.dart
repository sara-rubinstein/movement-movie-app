import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

class RemoveFromFavorites extends FavoritesEvent {
  final String imdbId;

  const RemoveFromFavorites(this.imdbId);

  @override
  List<Object?> get props => [imdbId];
}
