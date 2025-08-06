import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';
import '../helpers/database_helper.dart';

void main() {
  group('Schema Builder Tests', () {
    setUp(() async {
      await DatabaseHelper.initializeTestDatabase();
    });

    tearDown(() async {
      await DatabaseHelper.closeTestDatabase();
    });

    group('Schema.create()', () {
      test('creates table with basic columns', () async {
        await Schema.create('test_table', (table) {
          table.id();
          table.string('name');
          table.integer('age');
        });

        expect(await Schema.hasTable('test_table'), isTrue);

        final columns = await Schema.getColumnListing('test_table');
        expect(columns.length, equals(3));
        
        final columnNames = columns.map((c) => c['name']).toList();
        expect(columnNames, contains('id'));
        expect(columnNames, contains('name'));
        expect(columnNames, contains('age'));
      });

      test('creates table with all column types', () async {
        await Schema.create('comprehensive_table', (table) {
          table.id();
          table.string('name', 100);
          table.text('description');
          table.integer('count');
          table.bigInteger('big_count');
          table.real('score');
          table.double('price');
          table.decimal('amount');
          table.boolean('active');
          table.date('birth_date');
          table.dateTime('created_at');
          table.timestamp('updated_at');
          table.time('start_time');
          table.json('metadata');
          table.blob('file_data');
        });

        expect(await Schema.hasTable('comprehensive_table'), isTrue);
        
        final columns = await Schema.getColumnListing('comprehensive_table');
        expect(columns.length, equals(15));
      });

      test('creates table with constraints and defaults', () async {
        await Schema.create('constrained_table', (table) {
          table.id();
          table.string('name').notNull();
          table.string('email').unique();
          table.integer('age').nullable().defaultValue(0);
          table.boolean('active').defaultValue(true);
          table.string('status').defaultValue('pending');
        });

        expect(await Schema.hasTable('constrained_table'), isTrue);

        // Test that we can insert data respecting constraints
        await Database.execute(
          'INSERT INTO constrained_table (name, email) VALUES (?, ?)',
          ['John Doe', 'john@example.com']
        );

        final result = await Database.query('SELECT * FROM constrained_table');
        expect(result.length, equals(1));
        expect(result.first['name'], equals('John Doe'));
        expect(result.first['age'], equals(0));
        expect(result.first['active'], equals(1)); // SQLite stores boolean as integer
        expect(result.first['status'], equals('pending'));
      });

      test('creates table with timestamps', () async {
        await Schema.create('timestamped_table', (table) {
          table.id();
          table.string('name');
          table.timestamps();
        });

        expect(await Schema.hasTable('timestamped_table'), isTrue);
        
        final columns = await Schema.getColumnListing('timestamped_table');
        final columnNames = columns.map((c) => c['name']).toList();
        expect(columnNames, contains('created_at'));
        expect(columnNames, contains('updated_at'));
      });

      test('creates table with soft deletes', () async {
        await Schema.create('soft_delete_table', (table) {
          table.id();
          table.string('name');
          table.softDeletes();
        });

        expect(await Schema.hasTable('soft_delete_table'), isTrue);
        
        final columns = await Schema.getColumnListing('soft_delete_table');
        final columnNames = columns.map((c) => c['name']).toList();
        expect(columnNames, contains('deleted_at'));
      });

      test('creates table with indexes', () async {
        await Schema.create('indexed_table', (table) {
          table.id();
          table.string('name');
          table.string('email');
          table.integer('age');
          
          table.index('name');
          table.unique(['email']);
          table.index(['name', 'age']);
        });

        expect(await Schema.hasTable('indexed_table'), isTrue);
        
        // Verify indexes were created (check sqlite_master)
        final indexes = await Database.query(
          "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='indexed_table'"
        );
        
        expect(indexes.length, greaterThan(0));
      });

      test('creates table with foreign keys', () async {
        // Create parent table first
        await Schema.create('users', (table) {
          table.id();
          table.string('name');
        });

        await Schema.create('posts', (table) {
          table.id();
          table.string('title');
          table.foreignId('user_id');
          
          table.foreign('user_id', 'users.id');
        });

        expect(await Schema.hasTable('posts'), isTrue);
        
        // Verify foreign key by inserting valid data
        await Database.execute('INSERT INTO users (name) VALUES (?)', ['John']);
        await Database.execute('INSERT INTO posts (title, user_id) VALUES (?, ?)', ['Test Post', 1]);
        
        final posts = await Database.query('SELECT * FROM posts');
        expect(posts.length, equals(1));
      });
    });

    group('Schema.table() - ALTER TABLE', () {
      test('adds columns to existing table', () async {
        // Create initial table
        await Schema.create('alterable_table', (table) {
          table.id();
          table.string('name');
        });

        // Add columns
        await Schema.table('alterable_table', (table) {
          table.integer('age');
          table.string('email');
        });

        final columns = await Schema.getColumnListing('alterable_table');
        final columnNames = columns.map((c) => c['name']).toList();
        
        expect(columnNames, contains('id'));
        expect(columnNames, contains('name'));
        expect(columnNames, contains('age'));
        expect(columnNames, contains('email'));
      });

      test('adds indexes to existing table', () async {
        await Schema.create('index_test_table', (table) {
          table.id();
          table.string('name');
          table.string('email');
        });

        await Schema.table('index_test_table', (table) {
          table.index('name');
          table.unique(['email']);
        });

        // Verify indexes were created
        final indexes = await Database.query(
          "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='index_test_table'"
        );
        
        expect(indexes.length, greaterThan(0));
      });
    });

    group('Schema utility methods', () {
      test('hasTable() checks table existence', () async {
        expect(await Schema.hasTable('nonexistent_table'), isFalse);
        
        await Schema.create('existing_table', (table) {
          table.id();
        });
        
        expect(await Schema.hasTable('existing_table'), isTrue);
      });

      test('hasColumn() checks column existence', () async {
        await Schema.create('column_test_table', (table) {
          table.id();
          table.string('name');
        });

        expect(await Schema.hasColumn('column_test_table', 'id'), isTrue);
        expect(await Schema.hasColumn('column_test_table', 'name'), isTrue);
        expect(await Schema.hasColumn('column_test_table', 'nonexistent'), isFalse);
      });

      test('drop() removes table', () async {
        await Schema.create('droppable_table', (table) {
          table.id();
        });

        expect(await Schema.hasTable('droppable_table'), isTrue);
        
        await Schema.drop('droppable_table');
        
        expect(await Schema.hasTable('droppable_table'), isFalse);
      });

      test('rename() renames table', () async {
        await Schema.create('old_table_name', (table) {
          table.id();
          table.string('name');
        });

        expect(await Schema.hasTable('old_table_name'), isTrue);
        
        await Schema.rename('old_table_name', 'new_table_name');
        
        expect(await Schema.hasTable('old_table_name'), isFalse);
        expect(await Schema.hasTable('new_table_name'), isTrue);
      });

      test('foreign key constraints can be toggled', () async {
        await Schema.enableForeignKeyConstraints();
        
        final result = await Database.query('PRAGMA foreign_keys');
        expect(result.first['foreign_keys'], equals(1));
        
        await Schema.disableForeignKeyConstraints();
        
        final result2 = await Database.query('PRAGMA foreign_keys');
        expect(result2.first['foreign_keys'], equals(0));
      });
    });

    group('Blueprint column definitions', () {
      test('generates correct SQL for various column types', () async {
        await Schema.create('sql_test_table', (table) {
          table.id();
          table.string('name', 50).notNull();
          table.integer('age').nullable().defaultValue(0);
          table.boolean('active').defaultValue(true);
          table.real('score').check('score >= 0 AND score <= 100');
        });

        expect(await Schema.hasTable('sql_test_table'), isTrue);
        
        // Test inserting data that validates constraints
        await Database.execute(
          'INSERT INTO sql_test_table (name, age, active, score) VALUES (?, ?, ?, ?)',
          ['Test User', 25, 1, 85.5]
        );

        final result = await Database.query('SELECT * FROM sql_test_table');
        expect(result.length, equals(1));
        expect(result.first['name'], equals('Test User'));
        expect(result.first['age'], equals(25));
        expect(result.first['score'], equals(85.5));
      });

      test('handles custom constraints', () async {
        await Schema.create('custom_constraint_table', (table) {
          table.id();
          table.string('email').unique().constraint('CHECK (email LIKE "%@%")');
          table.integer('age').check('age >= 0 AND age <= 150');
        });

        expect(await Schema.hasTable('custom_constraint_table'), isTrue);
        
        // Valid email should work
        await Database.execute(
          'INSERT INTO custom_constraint_table (email, age) VALUES (?, ?)',
          ['test@example.com', 25]
        );

        final result = await Database.query('SELECT * FROM custom_constraint_table');
        expect(result.length, equals(1));
      });
    });
  });
}
