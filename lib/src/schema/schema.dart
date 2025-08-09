import '../database/database.dart';
import 'blueprint.dart';

/// Laravel-style schema builder for creating and altering database tables.
///
/// Example usage:
/// ```dart
/// await Schema.create('users', (table) {
///   table.id();
///   table.string('name');
///   table.string('email').unique();
///   table.timestamps();
/// });
///
/// await Schema.table('users', (table) {
///   table.integer('age').nullable();
/// });
/// ```
class Schema {
  /// Create a new table
  static Future<void> create(
    String tableName,
    Function(Blueprint) callback,
  ) async {
    // Check if table already exists
    if (await hasTable(tableName)) {
      return; // Table already exists, skip creation
    }

    final blueprint = Blueprint(tableName, isCreating: true);
    callback(blueprint);

    final sql = blueprint.toSql();
    await Database.execute(sql);

    // Execute any additional statements (indexes, etc.)
    for (final statement in blueprint.additionalStatements) {
      try {
        await Database.execute(statement);
      } catch (e) {
        // Ignore index already exists errors
        if (!e.toString().contains('already exists')) {
          rethrow;
        }
      }
    }
  }

  /// Create a new table with IF NOT EXISTS syntax
  static Future<void> createIfNotExists(
    String tableName,
    Function(Blueprint) callback,
  ) async {
    final blueprint = Blueprint(tableName, isCreating: true);
    callback(blueprint);

    final sql = blueprint.toSqlIfNotExists();
    await Database.execute(sql);

    // Execute any additional statements (indexes, etc.)
    for (final statement in blueprint.additionalStatements) {
      await Database.execute(statement);
    }
  }

  /// Alter an existing table
  static Future<void> table(
    String tableName,
    Function(Blueprint) callback,
  ) async {
    final blueprint = Blueprint(tableName, isCreating: false);
    callback(blueprint);

    // For SQLite, we need to handle ALTER TABLE limitations
    final statements = blueprint.toAlterStatements();
    for (final statement in statements) {
      await Database.execute(statement);
    }
  }

  /// Drop a table
  static Future<void> drop(String tableName) async {
    await Database.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Drop a table (fail if not exists)
  static Future<void> dropIfExists(String tableName) async {
    await Database.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Rename a table
  static Future<void> rename(String from, String to) async {
    await Database.execute('ALTER TABLE $from RENAME TO $to');
  }

  /// Check if table exists
  static Future<bool> hasTable(String tableName) async {
    final result = await Database.query(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// Check if column exists in table
  static Future<bool> hasColumn(String tableName, String columnName) async {
    final result = await Database.query('PRAGMA table_info($tableName)');
    return result.any((row) => row['name'] == columnName);
  }

  /// Get table columns info
  static Future<List<Map<String, dynamic>>> getColumnListing(
    String tableName,
  ) async {
    return await Database.query('PRAGMA table_info($tableName)');
  }

  /// Enable foreign key constraints
  static Future<void> enableForeignKeyConstraints() async {
    await Database.execute('PRAGMA foreign_keys = ON');
  }

  /// Disable foreign key constraints
  static Future<void> disableForeignKeyConstraints() async {
    await Database.execute('PRAGMA foreign_keys = OFF');
  }
}
