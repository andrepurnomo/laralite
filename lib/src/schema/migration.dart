import '../database/database.dart';

/// Base class for database migrations.
/// 
/// Example migration:
/// ```dart
/// class CreateUsersTable extends Migration {
///   @override
///   Future<void> up() async {
///     await Schema.create('users', (table) {
///       table.id();
///       table.string('name');
///       table.string('email').unique();
///       table.timestamps();
///     });
///   }
///   
///   @override
///   Future<void> down() async {
///     await Schema.drop('users');
///   }
/// }
/// ```
abstract class Migration {
  /// Run the migration
  Future<void> up();
  
  /// Reverse the migration
  Future<void> down();
  
  /// Get the migration name (used for tracking)
  String get name => runtimeType.toString();
  
  /// Get migration batch number (for grouping)
  int get batch => 1;
}

/// Migration runner that handles execution and tracking
class MigrationRunner {
  static const String _migrationsTable = 'migrations';
  
  /// Initialize the migrations table
  static Future<void> _ensureMigrationsTable() async {
    await Database.execute('''
      CREATE TABLE IF NOT EXISTS $_migrationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        migration TEXT NOT NULL,
        batch INTEGER NOT NULL,
        executed_at TEXT NOT NULL
      )
    ''');
  }
  
  /// Run a single migration
  static Future<void> runMigration(Migration migration) async {
    await _ensureMigrationsTable();
    
    // Check if migration already ran
    final existing = await Database.query(
      'SELECT * FROM $_migrationsTable WHERE migration = ?',
      [migration.name],
    );
    
    if (existing.isNotEmpty) {
      throw StateError('Migration ${migration.name} has already been run');
    }
    
    // Execute migration in transaction
    await Database.execute('BEGIN TRANSACTION');
    try {
      await migration.up();
      
      // Record migration
      await Database.execute(
        'INSERT INTO $_migrationsTable (migration, batch, executed_at) VALUES (?, ?, ?)',
        [migration.name, migration.batch, DateTime.now().toIso8601String()],
      );
      
      await Database.execute('COMMIT');
      print('Migrated: ${migration.name}');
    } catch (e) {
      await Database.execute('ROLLBACK');
      rethrow;
    }
  }
  
  /// Run multiple migrations
  static Future<void> runMigrations(List<Migration> migrations) async {
    for (final migration in migrations) {
      await runMigration(migration);
    }
  }
  
  /// Rollback a single migration
  static Future<void> rollbackMigration(Migration migration) async {
    await _ensureMigrationsTable();
    
    // Check if migration exists
    final existing = await Database.query(
      'SELECT * FROM $_migrationsTable WHERE migration = ?',
      [migration.name],
    );
    
    if (existing.isEmpty) {
      throw StateError('Migration ${migration.name} has not been run');
    }
    
    // Execute rollback in transaction
    await Database.execute('BEGIN TRANSACTION');
    try {
      await migration.down();
      
      // Remove migration record
      await Database.execute(
        'DELETE FROM $_migrationsTable WHERE migration = ?',
        [migration.name],
      );
      
      await Database.execute('COMMIT');
      print('Rolled back: ${migration.name}');
    } catch (e) {
      await Database.execute('ROLLBACK');
      rethrow;
    }
  }
  
  /// Rollback last batch of migrations
  static Future<void> rollbackLastBatch() async {
    await _ensureMigrationsTable();
    
    // Get the last batch number
    final lastBatchResult = await Database.query(
      'SELECT MAX(batch) as max_batch FROM $_migrationsTable',
    );
    
    final lastBatch = lastBatchResult.first['max_batch'] as int?;
    if (lastBatch == null) {
      print('No migrations to rollback');
      return;
    }
    
    // Get migrations from last batch
    final migrations = await Database.query(
      'SELECT migration FROM $_migrationsTable WHERE batch = ? ORDER BY id DESC',
      [lastBatch],
    );
    
    print('Rolling back batch $lastBatch (${migrations.length} migrations)');
    
    // Note: This requires the actual Migration objects to rollback
    // In a real implementation, you'd need a registry of migrations
    for (final migrationRow in migrations) {
      print('Would rollback: ${migrationRow['migration']}');
    }
  }
  
  /// Get migration status
  static Future<List<Map<String, dynamic>>> getStatus() async {
    await _ensureMigrationsTable();
    
    return await Database.query(
      'SELECT * FROM $_migrationsTable ORDER BY batch, id',
    );
  }
  
  /// Check if migration has been run
  static Future<bool> hasRun(String migrationName) async {
    await _ensureMigrationsTable();
    
    final result = await Database.query(
      'SELECT COUNT(*) as count FROM $_migrationsTable WHERE migration = ?',
      [migrationName],
    );
    
    return (result.first['count'] as int) > 0;
  }
  
  /// Reset all migrations (drop migrations table)
  static Future<void> reset() async {
    await Database.execute('DROP TABLE IF EXISTS $_migrationsTable');
    print('Migration table reset');
  }
  
  /// Fresh migration (reset + run all)
  static Future<void> fresh(List<Migration> migrations) async {
    await reset();
    await runMigrations(migrations);
  }
  
  /// Fresh migration with table cleanup (useful for testing)
  static Future<void> freshWithCleanup(List<Migration> migrations, {List<String>? tablesToDrop}) async {
    // Drop specified tables first
    if (tablesToDrop != null) {
      for (final table in tablesToDrop) {
        await Database.execute('DROP TABLE IF EXISTS $table');
      }
    }
    
    await reset();
    await runMigrations(migrations);
  }
}

/// Migration registry for organizing migrations
class MigrationRegistry {
  static final List<Migration> _migrations = [];
  
  /// Register a migration
  static void register(Migration migration) {
    _migrations.add(migration);
  }
  
  /// Get all registered migrations
  static List<Migration> get all => List.unmodifiable(_migrations);
  
  /// Get migration by name
  static Migration? getByName(String name) {
    try {
      return _migrations.firstWhere((m) => m.name == name);
    } catch (e) {
      return null;
    }
  }
  
  /// Clear registry (useful for testing)
  static void clear() {
    _migrations.clear();
  }
  
  /// Run all registered migrations
  static Future<void> runAll() async {
    await MigrationRunner.runMigrations(_migrations);
  }
  
  /// Get pending migrations
  static Future<List<Migration>> getPending() async {
    final pending = <Migration>[];
    
    for (final migration in _migrations) {
      if (!await MigrationRunner.hasRun(migration.name)) {
        pending.add(migration);
      }
    }
    
    return pending;
  }
}
