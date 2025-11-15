import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:portion_control/infrastructure/data_sources/local/database/database.dart';

Future<AppDatabase> init() async {
  return AppDatabase.forTesting(
    DatabaseConnection(
      NativeDatabase.memory(),
    ),
  );
}