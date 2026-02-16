import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
class MovieModel extends Equatable {
  @HiveField(0)
  final String imdbId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String year;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String poster;

  const MovieModel({
    required this.imdbId,
    required this.title,
    required this.year,
    required this.type,
    required this.poster,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      imdbId: json['imdbID'] ?? '',
      title: json['Title'] ?? 'N/A',
      year: json['Year'] ?? 'N/A',
      type: json['Type'] ?? 'N/A',
      poster: json['Poster'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imdbID': imdbId,
      'Title': title,
      'Year': year,
      'Type': type,
      'Poster': poster,
    };
  }

  @override
  List<Object?> get props => [imdbId, title, year, type, poster];
}
