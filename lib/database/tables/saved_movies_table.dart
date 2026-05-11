import 'package:drift/drift.dart';
import 'users_table.dart';
import 'movies_table.dart';

/// Join table linking users to their saved movies.
class SavedMovies extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get movieId => integer().references(Movies, #id)();
  DateTimeColumn get savedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, movieId},
      ];
}
