import 'package:drift/drift.dart';

/// Drift table for local user storage.
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  TextColumn get firstName => text().withLength(min: 1, max: 100)();
  TextColumn get lastName => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().withLength(min: 1, max: 200)();
  TextColumn get avatarUrl => text().withDefault(const Constant(''))();
  TextColumn get movieTaste => text().withDefault(const Constant(''))();
  BoolColumn get isLocal => boolean().withDefault(const Constant(false))();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
