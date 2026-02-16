import 'package:equatable/equatable.dart';
import '../../data/models/movie_details_model.dart';
import '../../core/error.dart';

abstract class DetailsState extends Equatable {
  const DetailsState();

  @override
  List<Object?> get props => [];
}

class DetailsInitial extends DetailsState {
  const DetailsInitial();
}

class DetailsLoading extends DetailsState {
  const DetailsLoading();
}

class DetailsSuccess extends DetailsState {
  final MovieDetailsModel movie;
  final bool isFavorite;
  final bool isFromCache;

  const DetailsSuccess({
    required this.movie,
    required this.isFavorite,
    this.isFromCache = false,
  });

  DetailsSuccess copyWith({
    MovieDetailsModel? movie,
    bool? isFavorite,
    bool? isFromCache,
  }) {
    return DetailsSuccess(
      movie: movie ?? this.movie,
      isFavorite: isFavorite ?? this.isFavorite,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [movie, isFavorite, isFromCache];
}

class DetailsError extends DetailsState {
  final AppError error;

  const DetailsError(this.error);

  @override
  List<Object?> get props => [error];
}
