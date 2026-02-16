// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_details_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieDetailsModelAdapter extends TypeAdapter<MovieDetailsModel> {
  @override
  final int typeId = 1;

  @override
  MovieDetailsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieDetailsModel(
      imdbId: fields[0] as String,
      title: fields[1] as String,
      year: fields[2] as String,
      rated: fields[3] as String,
      released: fields[4] as String,
      runtime: fields[5] as String,
      genre: fields[6] as String,
      director: fields[7] as String,
      actors: fields[8] as String,
      plot: fields[9] as String,
      language: fields[10] as String,
      country: fields[11] as String,
      awards: fields[12] as String,
      poster: fields[13] as String,
      imdbRating: fields[14] as String,
      type: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MovieDetailsModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.imdbId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.rated)
      ..writeByte(4)
      ..write(obj.released)
      ..writeByte(5)
      ..write(obj.runtime)
      ..writeByte(6)
      ..write(obj.genre)
      ..writeByte(7)
      ..write(obj.director)
      ..writeByte(8)
      ..write(obj.actors)
      ..writeByte(9)
      ..write(obj.plot)
      ..writeByte(10)
      ..write(obj.language)
      ..writeByte(11)
      ..write(obj.country)
      ..writeByte(12)
      ..write(obj.awards)
      ..writeByte(13)
      ..write(obj.poster)
      ..writeByte(14)
      ..write(obj.imdbRating)
      ..writeByte(15)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieDetailsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
