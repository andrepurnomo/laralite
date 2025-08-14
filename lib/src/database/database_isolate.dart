import 'dart:isolate';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

/// Types of database requests
enum DatabaseRequestType { query, execute, transaction, close }

/// Data structure for initializing the database isolate
class DatabaseIsolateInit {
  final SendPort sendPort;
  final String databasePath;
  final String? encryptionKey;

  DatabaseIsolateInit({
    required this.sendPort,
    required this.databasePath,
    this.encryptionKey,
  });
}

/// Data structure for database requests
class DatabaseRequest {
  final DatabaseRequestType type;
  final String? sql;
  final List<dynamic>? parameters;
  final List<String>? statements;
  final SendPort responsePort;

  DatabaseRequest({
    required this.type,
    this.sql,
    this.parameters,
    this.statements,
    required this.responsePort,
  });
}

/// Data structure for database responses
class DatabaseResponse {
  final dynamic result;
  final String? error;

  DatabaseResponse({this.result, this.error});
}

/// Database isolate that handles SQLite operations
class DatabaseIsolate {
  late Database _database;
  late ReceivePort _receivePort;

  /// Entry point for the database isolate
  static void entryPoint(DatabaseIsolateInit init) {
    final isolate = DatabaseIsolate._();
    isolate._initialize(init);
  }

  DatabaseIsolate._();

  /// Initialize the isolate with database connection
  void _initialize(DatabaseIsolateInit init) {
    try {
      // Setup SQLCipher for Android if encryption key is provided
      if (init.encryptionKey != null &&
          init.encryptionKey!.isNotEmpty &&
          Platform.isAndroid) {
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      }

      // Open SQLite database with SQLCipher
      _database = sqlite3.open(init.databasePath);

      // Set encryption key if provided
      if (init.encryptionKey != null && init.encryptionKey!.isNotEmpty) {
        _database.execute('PRAGMA key = "${init.encryptionKey}";');

        // Verify SQLCipher is working
        final result = _database.select('PRAGMA cipher_version;');
        if (result.isEmpty || result.first.values.isEmpty) {
          throw StateError(
            'SQLCipher library is not available, please check your dependencies!',
          );
        }
      }

      // Enable foreign keys
      _database.execute('PRAGMA foreign_keys = ON');

      // Set up receive port for handling requests
      _receivePort = ReceivePort();

      // Send back our send port to the main isolate
      init.sendPort.send(_receivePort.sendPort);

      // Listen for requests
      _receivePort.listen(_handleRequest);
    } catch (e) {
      init.sendPort.send(DatabaseResponse(error: e.toString()));
    }
  }

  /// Handle incoming database requests
  void _handleRequest(dynamic message) {
    if (message is DatabaseRequest) {
      try {
        switch (message.type) {
          case DatabaseRequestType.query:
            _handleQuery(message);
            break;
          case DatabaseRequestType.execute:
            _handleExecute(message);
            break;
          case DatabaseRequestType.transaction:
            _handleTransaction(message);
            break;
          case DatabaseRequestType.close:
            _handleClose(message);
            break;
        }
      } catch (e) {
        message.responsePort.send(DatabaseResponse(error: e.toString()));
      }
    }
  }

  /// Handle query requests
  void _handleQuery(DatabaseRequest request) {
    try {
      final stmt = _database.prepare(request.sql!);
      final results = <Map<String, dynamic>>[];

      final resultSet = stmt.select(request.parameters ?? []);
      for (final row in resultSet) {
        results.add(Map<String, dynamic>.from(row));
      }

      stmt.dispose();

      request.responsePort.send(DatabaseResponse(result: results));
    } catch (e) {
      request.responsePort.send(DatabaseResponse(error: e.toString()));
    }
  }

  /// Handle execute requests (INSERT, UPDATE, DELETE)
  void _handleExecute(DatabaseRequest request) {
    try {
      final stmt = _database.prepare(request.sql!);
      stmt.execute(request.parameters ?? []);
      final changes = _database.updatedRows;
      stmt.dispose();

      request.responsePort.send(DatabaseResponse(result: changes));
    } catch (e) {
      request.responsePort.send(DatabaseResponse(error: e.toString()));
    }
  }

  /// Handle transaction requests
  void _handleTransaction(DatabaseRequest request) {
    try {
      _database.execute('BEGIN TRANSACTION');

      for (final statement in request.statements!) {
        _database.execute(statement);
      }

      _database.execute('COMMIT');

      request.responsePort.send(DatabaseResponse(result: null));
    } catch (e) {
      try {
        _database.execute('ROLLBACK');
      } catch (_) {
        // Ignore rollback errors
      }
      request.responsePort.send(DatabaseResponse(error: e.toString()));
    }
  }

  /// Handle close request - dispose DB cleanly
  void _handleClose(DatabaseRequest request) {
    try {
      _database.dispose();
      request.responsePort.send(DatabaseResponse(result: true));
      // After disposing, we can stop listening; the main isolate will kill us
      _receivePort.close();
    } catch (e) {
      request.responsePort.send(DatabaseResponse(error: e.toString()));
    }
  }
}
