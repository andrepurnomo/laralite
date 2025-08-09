import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';
import '../helpers/database_helper.dart';

// Example migrations for testing
class CreateUsersTableMigration extends Migration {
  @override
  Future<void> up() async {
    await Schema.create('users', (table) {
      table.id();
      table.string('name').notNull();
      table.string('email').unique();
      table.timestamps();
    });
  }

  @override
  Future<void> down() async {
    await Schema.drop('users');
  }
}

class CreatePostsTableMigration extends Migration {
  @override
  Future<void> up() async {
    await Schema.create('posts', (table) {
      table.id();
      table.string('title').notNull();
      table.text('content');
      table.foreignId('user_id').notNull();
      table.timestamps();

      table.foreign('user_id', 'users.id');
    });
  }

  @override
  Future<void> down() async {
    await Schema.drop('posts');
  }
}

class AddAgeToUsersTableMigration extends Migration {
  @override
  Future<void> up() async {
    await Schema.table('users', (table) {
      table.integer('age').nullable();
    });
  }

  @override
  Future<void> down() async {
    // SQLite doesn't support dropping columns easily
    // In real scenarios, you might recreate the table
    throw UnimplementedError('Cannot drop column in SQLite');
  }
}

void main() {
  group('Migration System Tests', () {
    setUp(() async {
      await DatabaseHelper.initializeTestDatabase();
      MigrationRegistry.clear(); // Clear previous registrations
    });

    tearDown(() async {
      await DatabaseHelper.closeTestDatabase();
    });

    group('Migration Base Class', () {
      test('migration has correct name', () {
        final migration = CreateUsersTableMigration();
        expect(migration.name, equals('CreateUsersTableMigration'));
      });

      test('migration has default batch number', () {
        final migration = CreateUsersTableMigration();
        expect(migration.batch, equals(1));
      });
    });

    group('MigrationRunner', () {
      test('runs single migration successfully', () async {
        final migration = CreateUsersTableMigration();

        expect(await Schema.hasTable('users'), isFalse);

        await MigrationRunner.runMigration(migration);

        expect(await Schema.hasTable('users'), isTrue);
        expect(
          await MigrationRunner.hasRun('CreateUsersTableMigration'),
          isTrue,
        );
      });

      test('prevents running same migration twice', () async {
        final migration = CreateUsersTableMigration();

        await MigrationRunner.runMigration(migration);

        expect(
          () => MigrationRunner.runMigration(migration),
          throwsA(isA<StateError>()),
        );
      });

      test('rollback migration successfully', () async {
        final migration = CreateUsersTableMigration();

        // Run migration
        await MigrationRunner.runMigration(migration);
        expect(await Schema.hasTable('users'), isTrue);

        // Rollback migration
        await MigrationRunner.rollbackMigration(migration);
        expect(await Schema.hasTable('users'), isFalse);
        expect(
          await MigrationRunner.hasRun('CreateUsersTableMigration'),
          isFalse,
        );
      });

      test('prevents rolling back non-existent migration', () async {
        final migration = CreateUsersTableMigration();

        expect(
          () => MigrationRunner.rollbackMigration(migration),
          throwsA(isA<StateError>()),
        );
      });

      test('runs multiple migrations in order', () async {
        final usersMigration = CreateUsersTableMigration();
        final postsMigration = CreatePostsTableMigration();

        await MigrationRunner.runMigrations([usersMigration, postsMigration]);

        expect(await Schema.hasTable('users'), isTrue);
        expect(await Schema.hasTable('posts'), isTrue);
        expect(
          await MigrationRunner.hasRun('CreateUsersTableMigration'),
          isTrue,
        );
        expect(
          await MigrationRunner.hasRun('CreatePostsTableMigration'),
          isTrue,
        );
      });

      test('migration status tracking', () async {
        final migration = CreateUsersTableMigration();

        await MigrationRunner.runMigration(migration);

        final status = await MigrationRunner.getStatus();
        expect(status.length, equals(1));
        expect(status.first['migration'], equals('CreateUsersTableMigration'));
        expect(status.first['batch'], equals(1));
        expect(status.first['executed_at'], isNotNull);
      });

      test('migration table is created automatically', () async {
        final migration = CreateUsersTableMigration();

        await MigrationRunner.runMigration(migration);

        expect(await Schema.hasTable('migrations'), isTrue);

        final columns = await Schema.getColumnListing('migrations');
        final columnNames = columns.map((c) => c['name']).toList();
        expect(columnNames, contains('id'));
        expect(columnNames, contains('migration'));
        expect(columnNames, contains('batch'));
        expect(columnNames, contains('executed_at'));
      });

      test('reset clears migration history', () async {
        final migration = CreateUsersTableMigration();

        await MigrationRunner.runMigration(migration);
        expect(await Schema.hasTable('migrations'), isTrue);

        await MigrationRunner.reset();
        expect(await Schema.hasTable('migrations'), isFalse);
      });

      test('fresh runs all migrations after reset', () async {
        final usersMigration = CreateUsersTableMigration();
        final postsMigration = CreatePostsTableMigration();

        // Run initial migration
        await MigrationRunner.runMigration(usersMigration);

        // Fresh should reset and run all (with cleanup)
        await MigrationRunner.freshWithCleanup(
          [usersMigration, postsMigration],
          tablesToDrop: ['users', 'posts'],
        );

        expect(await Schema.hasTable('users'), isTrue);
        expect(await Schema.hasTable('posts'), isTrue);

        final status = await MigrationRunner.getStatus();
        expect(status.length, equals(2));
      });

      test('handles migration errors with rollback', () async {
        // Create a migration that will fail
        final badMigration = _BadMigration();

        expect(
          () => MigrationRunner.runMigration(badMigration),
          throwsException,
        );

        // Migration should not be recorded on failure
        expect(await MigrationRunner.hasRun('_BadMigration'), isFalse);
      });
    });

    group('MigrationRegistry', () {
      test('registers and retrieves migrations', () {
        final migration1 = CreateUsersTableMigration();
        final migration2 = CreatePostsTableMigration();

        MigrationRegistry.register(migration1);
        MigrationRegistry.register(migration2);

        final all = MigrationRegistry.all;
        expect(all.length, equals(2));
        expect(all, contains(migration1));
        expect(all, contains(migration2));
      });

      test('gets migration by name', () {
        final migration = CreateUsersTableMigration();
        MigrationRegistry.register(migration);

        final found = MigrationRegistry.getByName('CreateUsersTableMigration');
        expect(found, equals(migration));

        final notFound = MigrationRegistry.getByName('NonExistentMigration');
        expect(notFound, isNull);
      });

      test('runs all registered migrations', () async {
        final migration1 = CreateUsersTableMigration();
        final migration2 = CreatePostsTableMigration();

        MigrationRegistry.register(migration1);
        MigrationRegistry.register(migration2);

        await MigrationRegistry.runAll();

        expect(await Schema.hasTable('users'), isTrue);
        expect(await Schema.hasTable('posts'), isTrue);
      });

      test('gets pending migrations', () async {
        final migration1 = CreateUsersTableMigration();
        final migration2 = CreatePostsTableMigration();
        final migration3 = AddAgeToUsersTableMigration();

        MigrationRegistry.register(migration1);
        MigrationRegistry.register(migration2);
        MigrationRegistry.register(migration3);

        // Run only first migration
        await MigrationRunner.runMigration(migration1);

        final pending = await MigrationRegistry.getPending();
        expect(pending.length, equals(2));
        expect(pending, contains(migration2));
        expect(pending, contains(migration3));
        expect(pending, isNot(contains(migration1)));
      });

      test('clears registry', () {
        final migration = CreateUsersTableMigration();
        MigrationRegistry.register(migration);

        expect(MigrationRegistry.all.length, equals(1));

        MigrationRegistry.clear();
        expect(MigrationRegistry.all.length, equals(0));
      });
    });

    group('Real-world Migration Scenarios', () {
      test('sequential table creation with dependencies', () async {
        final usersMigration = CreateUsersTableMigration();
        final postsMigration = CreatePostsTableMigration();

        await MigrationRunner.runMigrations([usersMigration, postsMigration]);

        // Test that we can actually use the tables with foreign keys
        await Database.execute(
          'INSERT INTO users (name, email) VALUES (?, ?)',
          ['John Doe', 'john@example.com'],
        );

        await Database.execute(
          'INSERT INTO posts (title, content, user_id) VALUES (?, ?, ?)',
          ['Test Post', 'This is a test post', 1],
        );

        final posts = await Database.query(
          'SELECT p.*, u.name as author_name FROM posts p JOIN users u ON p.user_id = u.id',
        );

        expect(posts.length, equals(1));
        expect(posts.first['title'], equals('Test Post'));
        expect(posts.first['author_name'], equals('John Doe'));
      });

      test('table alteration migration', () async {
        // Create initial table
        await MigrationRunner.runMigration(CreateUsersTableMigration());

        // Add column
        await MigrationRunner.runMigration(AddAgeToUsersTableMigration());

        // Verify new column exists
        expect(await Schema.hasColumn('users', 'age'), isTrue);

        // Test inserting data with new column
        await Database.execute(
          'INSERT INTO users (name, email, age) VALUES (?, ?, ?)',
          ['Jane Doe', 'jane@example.com', 30],
        );

        final result = await Database.query(
          'SELECT * FROM users WHERE name = ?',
          ['Jane Doe'],
        );
        expect(result.first['age'], equals(30));
      });
    });
  });
}

// Helper migration that will fail for testing error handling
class _BadMigration extends Migration {
  @override
  Future<void> up() async {
    throw Exception('Intentional migration failure');
  }

  @override
  Future<void> down() async {
    // No-op
  }
}
