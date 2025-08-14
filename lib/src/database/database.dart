import 'dart:io';
import 'package:path/path.dart' as path;
import 'database_connection.dart';

/// Main database class for laralite
class Database {
  static bool _initialized = false;

  /// Initialize the database with the given database name
  ///
  /// The database file will be created in the application's documents directory
  /// if [databasePath] is not provided.
  static Future<void> initialize({
    String? databasePath,
    String databaseName = 'laralite.db',
    String? encryptionKey,
  }) async {
    if (_initialized) {
      throw StateError('Database already initialized');
    }

    String dbPath;
    if (databasePath != null) {
      dbPath = databasePath;
    } else {
      // Default to current directory for now
      // In a real app, this would use application documents directory
      dbPath = path.join(Directory.current.path, databaseName);
    }

    await DatabaseConnection.initialize(dbPath, encryptionKey: encryptionKey);
    _initialized = true;
  }

  /// Execute a raw SQL query and return results
  static Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? parameters,
  ]) async {
    _ensureInitialized();
    return await DatabaseConnection.instance.query(sql, parameters);
  }

  /// Execute a raw SQL statement (INSERT, UPDATE, DELETE)
  /// Returns the number of affected rows
  static Future<int> execute(String sql, [List<dynamic>? parameters]) async {
    _ensureInitialized();
    return await DatabaseConnection.instance.execute(sql, parameters);
  }

  /// Execute multiple statements in a transaction
  static Future<void> transaction(List<String> statements) async {
    _ensureInitialized();
    return await DatabaseConnection.instance.transaction(statements);
  }

  /// Execute a function within a transaction context
  ///
  /// Automatically commits on success and rolls back on error.
  /// Returns the result of the callback function.
  static Future<T> withTransaction<T>(Future<T> Function() callback) async {
    _ensureInitialized();
    return await DatabaseConnection.instance.withTransaction(callback);
  }

  /// Check if a table exists
  static Future<bool> tableExists(String tableName) async {
    _ensureInitialized();

    final result = await query(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );

    return result.isNotEmpty;
  }

  /// Get table schema information
  static Future<List<Map<String, dynamic>>> getTableInfo(
    String tableName,
  ) async {
    _ensureInitialized();
    return await query('PRAGMA table_info($tableName)');
  }

  /// Close the database connection
  static Future<void> close() async {
    if (!_initialized) return;

    await DatabaseConnection.instance.close();
    _initialized = false;
  }

  /// Reset the database (useful for testing)
  static void reset() {
    DatabaseConnection.reset();
    _initialized = false;
  }

  /// Get the database file path
  static String? get databasePath => DatabaseConnection.databasePath;

  /// Check if database is initialized
  static bool get isInitialized => _initialized;

  /// Ensure database is initialized before operations
  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'Database not initialized. Call Database.initialize() first.',
      );
    }
  }
}
