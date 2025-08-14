import 'database/database.dart';

/// Main Laralite class providing a unified API for database operations
///
/// This class serves as the main entry point for Laralite ORM,
/// providing initialization and configuration methods.
class Laralite {
  static bool _initialized = false;

  /// Initialize Laralite with database configuration
  ///
  /// The database file will be created in the application's documents directory
  /// if [databasePath] is not provided.
  ///
  /// Example:
  /// ```dart
  /// await Laralite.initialize(databaseName: 'app.db');
  /// ```
  static Future<void> initialize({
    String? databasePath,
    String databaseName = 'laralite.db',
    String? encryptionKey,
  }) async {
    if (_initialized) {
      throw StateError('Laralite already initialized');
    }

    await Database.initialize(
      databasePath: databasePath,
      databaseName: databaseName,
      encryptionKey: encryptionKey,
    );

    _initialized = true;
  }

  /// Execute a raw SQL query and return results
  ///
  /// Example:
  /// ```dart
  /// final users = await Laralite.query('SELECT * FROM users WHERE age > ?', [18]);
  /// ```
  static Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? parameters,
  ]) async {
    _ensureInitialized();
    return await Database.query(sql, parameters);
  }

  /// Execute a raw SQL statement (INSERT, UPDATE, DELETE)
  /// Returns the number of affected rows
  ///
  /// Example:
  /// ```dart
  /// final affected = await Laralite.execute('UPDATE users SET name = ? WHERE id = ?', ['John', 1]);
  /// ```
  static Future<int> execute(String sql, [List<dynamic>? parameters]) async {
    _ensureInitialized();
    return await Database.execute(sql, parameters);
  }

  /// Execute multiple statements in a transaction
  ///
  /// Example:
  /// ```dart
  /// await Laralite.transaction([
  ///   'INSERT INTO users (name) VALUES ("John")',
  ///   'INSERT INTO posts (title, user_id) VALUES ("Post", 1)',
  /// ]);
  /// ```
  static Future<void> transaction(List<String> statements) async {
    _ensureInitialized();
    return await Database.transaction(statements);
  }

  /// Execute a function within a transaction context
  ///
  /// Automatically commits on success and rolls back on error.
  /// Returns the result of the callback function.
  ///
  /// Example:
  /// ```dart
  /// final result = await Laralite.withTransaction(() async {
  ///   final user = User()..name = 'John';
  ///   await user.save();
  ///   return user;
  /// });
  /// ```
  static Future<T> withTransaction<T>(Future<T> Function() callback) async {
    _ensureInitialized();
    return await Database.withTransaction(callback);
  }

  /// Check if a table exists
  ///
  /// Example:
  /// ```dart
  /// final exists = await Laralite.tableExists('users');
  /// ```
  static Future<bool> tableExists(String tableName) async {
    _ensureInitialized();
    return await Database.tableExists(tableName);
  }

  /// Get table schema information
  ///
  /// Example:
  /// ```dart
  /// final columns = await Laralite.getTableInfo('users');
  /// ```
  static Future<List<Map<String, dynamic>>> getTableInfo(
    String tableName,
  ) async {
    _ensureInitialized();
    return await Database.getTableInfo(tableName);
  }

  /// Close the database connection
  ///
  /// Example:
  /// ```dart
  /// await Laralite.close();
  /// ```
  static Future<void> close() async {
    if (!_initialized) return;

    await Database.close();
    _initialized = false;
  }

  /// Reset Laralite (useful for testing)
  ///
  /// Example:
  /// ```dart
  /// Laralite.reset(); // For testing purposes
  /// ```
  static void reset() {
    Database.reset();
    _initialized = false;
  }

  /// Get the database file path
  static String? get databasePath => Database.databasePath;

  /// Check if Laralite is initialized
  static bool get isInitialized => _initialized;

  /// Ensure Laralite is initialized before operations
  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'Laralite not initialized. Call Laralite.initialize() first.',
      );
    }
  }
}
