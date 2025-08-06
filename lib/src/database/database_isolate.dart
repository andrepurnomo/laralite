import 'dart:isolate';
import 'package:sqlite3/sqlite3.dart';

/// Types of database requests
enum DatabaseRequestType {
  query,
  execute,
  transaction,
}

/// Data structure for initializing the database isolate
class DatabaseIsolateInit {
  final SendPort sendPort;
  final String databasePath;
  
  DatabaseIsolateInit({
    required this.sendPort,
    required this.databasePath,
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
  
  DatabaseResponse({
    this.result,
    this.error,
  });
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
      // Open SQLite database
      _database = sqlite3.open(init.databasePath);
      
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
}
