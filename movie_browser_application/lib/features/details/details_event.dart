import 'package:equatable/equatable.dart';

abstract class DetailsEvent extends Equatable {
  const DetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMovieDetails extends DetailsEvent {
  final String imdbId;

  const LoadMovieDetails(this.imdbId);

  @override
  List<Object?> get props => [imdbId];
}

class ToggleFavorite extends DetailsEvent {
  const ToggleFavorite();
}
