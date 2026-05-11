import 'package:drift/drift.dart';

/// Drift table for caching movie data from TMDB.
class Movies extends Table {
  IntColumn get id => integer()(); // TMDB movie ID — not auto-increment
  TextColumn get title => text().withLength(min: 1, max: 300)();
  TextColumn get overview => text().withDefault(const Constant(''))();
  TextColumn get posterPath => text().withDefault(const Constant(''))();
  TextColumn get backdropPath => text().withDefault(const Constant(''))();
  TextColumn get releaseDate => text().withDefault(const Constant(''))();
  RealColumn get voteAverage => real().withDefault(const Constant(0.0))();
  IntColumn get voteCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get cachedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
