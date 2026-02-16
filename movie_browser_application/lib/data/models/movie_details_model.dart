import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'movie_details_model.g.dart';

@HiveType(typeId: 1)
class MovieDetailsModel extends Equatable {
  @HiveField(0)
  final String imdbId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String year;

  @HiveField(3)
  final String rated;

  @HiveField(4)
  final String released;

  @HiveField(5)
  final String runtime;

  @HiveField(6)
  final String genre;

  @HiveField(7)
  final String director;

  @HiveField(8)
  final String actors;

  @HiveField(9)
  final String plot;

  @HiveField(10)
  final String language;

  @HiveField(11)
  final String country;

  @HiveField(12)
  final String awards;

  @HiveField(13)
  final String poster;

  @HiveField(14)
  final String imdbRating;

  @HiveField(15)
  final String type;

  const MovieDetailsModel({
    required this.imdbId,
    required this.title,
    required this.year,
    required this.rated,
    required this.released,
    required this.runtime,
    required this.genre,
    required this.director,
    required this.actors,
    required this.plot,
    required this.language,
    required this.country,
    required this.awards,
    required this.poster,
    required this.imdbRating,
    required this.type,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailsModel(
      imdbId: json['imdbID'] ?? '',
      title: json['Title'] ?? 'N/A',
      year: json['Year'] ?? 'N/A',
      rated: json['Rated'] ?? 'N/A',
      released: json['Released'] ?? 'N/A',
      runtime: json['Runtime'] ?? 'N/A',
      genre: json['Genre'] ?? 'N/A',
      director: json['Director'] ?? 'N/A',
      actors: json['Actors'] ?? 'N/A',
      plot: json['Plot'] ?? 'N/A',
      language: json['Language'] ?? 'N/A',
      country: json['Country'] ?? 'N/A',
      awards: json['Awards'] ?? 'N/A',
      poster: json['Poster'] ?? '',
      imdbRating: json['imdbRating'] ?? 'N/A',
      type: json['Type'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imdbID': imdbId,
      'Title': title,
      'Year': year,
      'Rated': rated,
      'Released': released,
      'Runtime': runtime,
      'Genre': genre,
      'Director': director,
      'Actors': actors,
      'Plot': plot,
      'Language': language,
      'Country': country,
      'Awards': awards,
      'Poster': poster,
      'imdbRating': imdbRating,
      'Type': type,
    };
  }

  @override
  List<Object?> get props => [
        imdbId,
        title,
        year,
        rated,
        released,
        runtime,
        genre,
        director,
        actors,
        plot,
        language,
        country,
        awards,
        poster,
        imdbRating,
        type,
      ];
}
