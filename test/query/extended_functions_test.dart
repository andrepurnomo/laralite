import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

// Simple test model for extended functions
class TestUser extends Model<TestUser> {
  final _id = AutoIncrementField();
  final _name = StringField(required: true);
  final _email = StringField();
  final _createdAt = DateTimeField();

  @override
  String get table => 'test_users';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('email', _email);
    registerField('created_at', _createdAt);
  }

  String? get name => getValue<String>('name');
  set name(String? value) => setValue<String>('name', value);
}

void main() async {
  await Database.initialize(databasePath: ':memory:');

  group('Extended Query Builder Functions', () {
    setUp(() async {
      // Create table manually for testing
      await Database.execute('''
        CREATE TABLE IF NOT EXISTS test_users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT,
          created_at TEXT
        )
      ''');
      
      await Database.execute('DELETE FROM test_users');
      
      // Insert test data manually
      await Database.execute('INSERT INTO test_users (name, email, created_at) VALUES (?, ?, ?)', 
        ['John', 'john@example.com', '2024-01-15 10:00:00']);
      await Database.execute('INSERT INTO test_users (name, email, created_at) VALUES (?, ?, ?)', 
        ['Jane', 'jane@example.com', '2024-01-16 15:30:00']);
    });

    tearDown(() async {
      await Database.execute('DROP TABLE IF EXISTS test_users');
    });

    group('Raw SQL Methods', () {
      test('selectRaw generates SQL correctly', () async {
        final query = Model.query<TestUser>(() => TestUser()).selectRaw('COUNT(*) as total').toSql();
        expect(query, contains('COUNT(*) as total'));
      });

      test('whereRaw generates SQL correctly', () async {
        final query = Model.query<TestUser>(() => TestUser()).whereRaw('name LIKE ?', ['%John%']).toSql();
        expect(query, contains('name LIKE ?'));
      });

      test('groupByRaw generates SQL correctly', () async {
        final query = Model.query<TestUser>(() => TestUser()).groupByRaw('name').toSql();
        expect(query, contains('GROUP BY name'));
      });
    });

    group('Date Functions', () {
      test('whereDateBetween generates SQL correctly', () async {
        final start = DateTime(2024, 1, 15);
        final end = DateTime(2024, 1, 16);
        
        final query = Model.query<TestUser>(() => TestUser()).whereDateBetween('created_at', start, end).toSql();
        expect(query, contains('DATE(created_at) BETWEEN ? AND ?'));
      });

      test('whereYear generates SQL correctly', () async {
        final query = Model.query<TestUser>(() => TestUser()).whereYear('created_at', 2024).toSql();
        expect(query, contains("strftime('%Y', created_at) = ?"));
      });
    });
  });
}
