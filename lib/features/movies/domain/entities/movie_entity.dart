import 'package:equatable/equatable.dart';

/// Domain entity for a movie.
class MovieEntity extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;

  const MovieEntity({
    required this.id,
    required this.title,
    this.overview = '',
    this.posterPath = '',
    this.backdropPath = '',
    this.releaseDate = '',
    this.voteAverage = 0.0,
    this.voteCount = 0,
  });

  String get year {
    if (releaseDate.length >= 4) return releaseDate.substring(0, 4);
    return '';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        backdropPath,
        releaseDate,
        voteAverage,
        voteCount,
      ];
}
