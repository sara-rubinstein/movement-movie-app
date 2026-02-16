import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchMovies extends SearchEvent {
  final String query;
  final bool isNewSearch;

  const SearchMovies(this.query, {this.isNewSearch = true});

  @override
  List<Object?> get props => [query, isNewSearch];
}

class LoadMoreMovies extends SearchEvent {
  const LoadMoreMovies();
}

class LoadSearchHistory extends SearchEvent {
  const LoadSearchHistory();
}

class RemoveFromSearchHistory extends SearchEvent {
  final String query;

  const RemoveFromSearchHistory(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchHistory extends SearchEvent {
  const ClearSearchHistory();
}
