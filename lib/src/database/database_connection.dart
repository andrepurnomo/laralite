import 'dart:isolate';
import 'database_isolate.dart';

/// Main database connection class that manages SQLite connections through isolates
class DatabaseConnection {
  static DatabaseConnection? _instance;
  static String? _databasePath;
  static String? _encryptionKey;

  SendPort? _isolateSendPort;
  Isolate? _isolate;
  ReceivePort? _receivePort;
  bool _inTransaction = false;

  DatabaseConnection._();

  /// Get singleton instance of database connection
  static DatabaseConnection get instance {
    _instance ??= DatabaseConnection._();
    return _instance!;
  }

  /// Initialize database with path and optional encryption key
  static Future<void> initialize(
    String databasePath, {
    String? encryptionKey,
  }) async {
    _databasePath = databasePath;
    _encryptionKey = encryptionKey;
    await instance._initializeIsolate();
  }

  /// Get the database path
  static String? get databasePath => _databasePath;

  /// Initialize the database isolate
  Future<void> _initializeIsolate() async {
    if (_isolate != null) return;

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      DatabaseIsolate.entryPoint,
      DatabaseIsolateInit(
        sendPort: _receivePort!.sendPort,
        databasePath: _databasePath!,
        encryptionKey: _encryptionKey,
      ),
    );

    // Wait for isolate to send back its SendPort
    await for (final message in _receivePort!) {
      if (message is SendPort) {
        _isolateSendPort = message;
        break;
      }
    }
  }

  /// Execute a query in the database isolate
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? parameters,
  ]) async {
    if (_isolateSendPort == null) {
      throw StateError(
        'Database not initialized. Call DatabaseConnection.initialize() first.',
      );
    }

    final responsePort = ReceivePort();
    final request = DatabaseRequest(
      type: DatabaseRequestType.query,
      sql: sql,
      parameters: parameters,
      responsePort: responsePort.sendPort,
    );

    _isolateSendPort!.send(request);

    final response = await responsePort.first as DatabaseResponse;
    responsePort.close();

    if (response.error != null) {
      throw Exception('Database query failed: ${response.error}');
    }

    return response.result as List<Map<String, dynamic>>;
  }

  /// Execute an insert/update/delete statement
  Future<int> execute(String sql, [List<dynamic>? parameters]) async {
    if (_isolateSendPort == null) {
      throw StateError(
        'Database not initialized. Call DatabaseConnection.initialize() first.',
      );
    }

    final responsePort = ReceivePort();
    final request = DatabaseRequest(
      type: DatabaseRequestType.execute,
      sql: sql,
      parameters: parameters,
      responsePort: responsePort.sendPort,
    );

    _isolateSendPort!.send(request);

    final response = await responsePort.first as DatabaseResponse;
    responsePort.close();

    if (response.error != null) {
      throw Exception('Database execute failed: ${response.error}');
    }

    return response.result as int;
  }

  /// Execute multiple statements in a transaction
  Future<void> transaction(List<String> statements) async {
    if (_isolateSendPort == null) {
      throw StateError(
        'Database not initialized. Call DatabaseConnection.initialize() first.',
      );
    }

    final responsePort = ReceivePort();
    final request = DatabaseRequest(
      type: DatabaseRequestType.transaction,
      statements: statements,
      responsePort: responsePort.sendPort,
    );

    _isolateSendPort!.send(request);

    final response = await responsePort.first as DatabaseResponse;
    responsePort.close();

    if (response.error != null) {
      throw Exception('Database transaction failed: ${response.error}');
    }
  }

  /// Execute a function within a transaction context
  ///
  /// Automatically commits on success and rolls back on error.
  /// Returns the result of the callback function.
  /// If already in a transaction, executes callback without creating nested transaction.
  Future<T> withTransaction<T>(Future<T> Function() callback) async {
    if (_isolateSendPort == null) {
      throw StateError(
        'Database not initialized. Call DatabaseConnection.initialize() first.',
      );
    }

    // If already in transaction, just execute callback
    if (_inTransaction) {
      return await callback();
    }

    // Begin transaction
    _inTransaction = true;
    await execute('BEGIN TRANSACTION');

    try {
      // Execute the callback
      final result = await callback();

      // Commit transaction on success
      await execute('COMMIT');
      _inTransaction = false;

      return result;
    } catch (error) {
      // Rollback transaction on error
      _inTransaction = false;
      try {
        await execute('ROLLBACK');
      } catch (rollbackError) {
        // Log rollback error but throw original error
        print('Warning: Failed to rollback transaction: $rollbackError');
      }

      // Rethrow the original error
      rethrow;
    }
  }

  /// Close the database connection and isolate
  Future<void> close() async {
    // Ask isolate to dispose the SQLite database cleanly first
    if (_isolateSendPort != null) {
      final responsePort = ReceivePort();
      final request = DatabaseRequest(
        type: DatabaseRequestType.close,
        responsePort: responsePort.sendPort,
      );
      _isolateSendPort!.send(request);
      // Wait for ack or error, but don't hang forever
      await responsePort.first;
      responsePort.close();
      // Ignore content; proceed to kill isolate regardless
    }

    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }

    _receivePort?.close();
    _receivePort = null;
    _isolateSendPort = null;
  }

  /// Reset the singleton instance (useful for testing)
  static void reset() {
    _instance?.close();
    _instance = null;
    _databasePath = null;
  }
}
