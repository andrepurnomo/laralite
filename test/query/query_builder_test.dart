import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

// Test model for QueryBuilder testing
class TestUser extends Model<TestUser> {
  final _id = AutoIncrementField();
  final _name = StringField(required: true);
  final _email = EmailField();
  final _age = IntField();
  final _active = BoolField(defaultValue: true);
  final _createdAt = TimestampField(autoCreate: true);

  @override
  String get table => 'users';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('email', _email);
    registerField('age', _age);
    registerField('active', _active);
    registerField('created_at', _createdAt);
  }

  // Convenience getters/setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get name => _name.value;
  set name(String? value) => _name.value = value;

  String? get email => _email.value;
  set email(String? value) => _email.value = value;

  int? get age => _age.value;
  set age(int? value) => _age.value = value;

  bool? get active => _active.value;
  set active(bool? value) => _active.value = value;

  DateTime? get createdAt => _createdAt.value;
}

void main() {
  group('QueryBuilder Tests', () {
    setUp(() async {
      // Reset database state before each test
      Database.reset();
      await Database.initialize(databasePath: ':memory:');

      // Create test table
      await Database.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT,
          age INTEGER,
          active INTEGER DEFAULT 1,
          created_at TEXT
        )
      ''');

      // Insert test data
      await Database.execute('''
        INSERT INTO users (name, email, age, active, created_at) VALUES
        ('John Doe', 'john@example.com', 30, 1, '2023-12-01T10:00:00.000Z'),
        ('Jane Smith', 'jane@example.com', 25, 1, '2023-12-02T10:00:00.000Z'),
        ('Bob Wilson', 'bob@example.com', 35, 0, '2023-12-03T10:00:00.000Z'),
        ('Alice Brown', 'alice@example.com', 28, 1, '2023-12-04T10:00:00.000Z'),
        ('Charlie Green', null, 45, 1, '2023-12-05T10:00:00.000Z')
      ''');
    });

    tearDown(() async {
      await Database.close();
      await Future.delayed(Duration(milliseconds: 50));
    });

    group('Basic Query Building', () {
      test('should create QueryBuilder with model constructor', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        expect(query.table, equals('users'));
      });

      test('should build basic SELECT query', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users'));
      });

      test('should build SELECT with specific columns', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.select(['name', 'email']);
        final sql = query.toSql();
        expect(sql, equals('SELECT name, email FROM users'));
      });
    });

    group('WHERE Conditions', () {
      test('should add basic WHERE condition with two parameters', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('name', 'John Doe');
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE name = ?'));
        expect(query.getBindings(), equals(['John Doe']));
      });

      test('should add basic WHERE condition with operator', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('age', '>', 25);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE age > ?'));
        expect(query.getBindings(), equals([25]));
      });

      test('should chain multiple WHERE conditions', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('age', '>', 25).where('active', 1);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE age > ? AND active = ?'));
        expect(query.getBindings(), equals([25, 1]));
      });

      test('should add WHERE IN condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.whereIn('age', [25, 30, 35]);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE age IN (?, ?, ?)'));
        expect(query.getBindings(), equals([25, 30, 35]));
      });

      test('should add WHERE NOT IN condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.whereNotIn('age', [25, 30]);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE age NOT IN (?, ?)'));
        expect(query.getBindings(), equals([25, 30]));
      });

      test('should add WHERE NULL condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.whereNull('email');
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE email IS NULL'));
        expect(query.getBindings(), isEmpty);
      });

      test('should add WHERE NOT NULL condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.whereNotNull('email');
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE email IS NOT NULL'));
        expect(query.getBindings(), isEmpty);
      });

      test('should add WHERE BETWEEN condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.whereBetween('age', 25, 35);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE age BETWEEN ? AND ?'));
        expect(query.getBindings(), equals([25, 35]));
      });

      test('should combine different WHERE conditions', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query
            .where('active', 1)
            .whereNotNull('email')
            .whereBetween('age', 20, 40);
        final sql = query.toSql();
        expect(
          sql,
          equals(
            'SELECT * FROM users WHERE active = ? AND email IS NOT NULL AND age BETWEEN ? AND ?',
          ),
        );
        expect(query.getBindings(), equals([1, 20, 40]));
      });
    });

    group('ORDER BY Clauses', () {
      test('should add ORDER BY clause with default ASC', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.orderBy('name');
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users ORDER BY name ASC'));
      });

      test('should add ORDER BY clause with explicit direction', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.orderBy('age', 'DESC');
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users ORDER BY age DESC'));
      });

      test('should add ORDER BY ASC shorthand', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.orderByAsc('name');
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users ORDER BY name ASC'));
      });

      test('should add ORDER BY DESC shorthand', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.orderByDesc('age');
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users ORDER BY age DESC'));
      });

      test('should chain multiple ORDER BY clauses', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.orderByDesc('active').orderByAsc('name');
        final sql = query.toSql();
        expect(
          sql,
          equals('SELECT * FROM users ORDER BY active DESC, name ASC'),
        );
      });

      test('should handle mixed ASC/DESC ordering', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query
            .orderBy('active', 'DESC')
            .orderBy('age', 'ASC')
            .orderBy('name', 'DESC');
        final sql = query.toSql();
        expect(
          sql,
          equals(
            'SELECT * FROM users ORDER BY active DESC, age ASC, name DESC',
          ),
        );
      });
    });

    group('LIMIT and OFFSET', () {
      test('should add LIMIT clause', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.limit(10);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users LIMIT 10'));
      });

      test('should add OFFSET clause', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.offset(5);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users OFFSET 5'));
      });

      test('should combine LIMIT and OFFSET', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.limit(10).offset(5);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users LIMIT 10 OFFSET 5'));
      });

      test('should use take() as alias for limit()', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.take(5);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users LIMIT 5'));
      });

      test('should use skip() as alias for offset()', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.skip(3);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users OFFSET 3'));
      });

      test('should implement pagination with take() and skip()', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.skip(10).take(5);
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users LIMIT 5 OFFSET 10'));
      });
    });

    group('Complex Query Building', () {
      test('should build complex query with all clauses', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query
            .select(['name', 'email', 'age'])
            .where('active', 1)
            .whereNotNull('email')
            .orderByDesc('age')
            .limit(10)
            .offset(5);

        final sql = query.toSql();
        final expected =
            'SELECT name, email, age FROM users WHERE active = ? AND email IS NOT NULL ORDER BY age DESC LIMIT 10 OFFSET 5';
        expect(sql, equals(expected));
        expect(query.getBindings(), equals([1]));
      });

      test('should maintain query builder chain', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final result = query.where('active', 1).orderBy('name').limit(5);

        expect(result, same(query));
      });
    });

    group('Query Execution - get()', () {
      test('should execute query and return all results', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final users = await query.get();

        expect(users, hasLength(5));
        expect(users.every((u) => u.exists), isTrue);
      });

      test('should execute query with WHERE condition', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final users = await query.where('active', 1).get();

        expect(users, hasLength(4)); // Only active users
        expect(users.every((u) => u.active == true), isTrue);
      });

      test('should execute query with ORDER BY', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final users = await query.orderBy('age').get();

        expect(users, hasLength(5));
        expect(users[0].age, equals(25)); // Jane Smith (youngest)
        expect(users[4].age, equals(45)); // Charlie Green (oldest)
      });

      test('should execute query with LIMIT', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final users = await query.limit(3).get();

        expect(users, hasLength(3));
      });

      test('should execute query with complex conditions', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final users = await query
            .where('active', 1)
            .whereBetween('age', 25, 35)
            .orderBy('age')
            .get();

        expect(users, hasLength(3)); // Jane, John, Alice
        expect(users[0].name, equals('Jane Smith'));
        expect(users[1].name, equals('Alice Brown'));
        expect(users[2].name, equals('John Doe'));
      });
    });

    group('Query Execution - first()', () {
      test('should return first result', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final user = await query.orderBy('name').first();

        expect(user, isNotNull);
        expect(user!.name, equals('Alice Brown')); // First alphabetically
      });

      test('should return null when no results', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final user = await query.where('name', 'Non-existent').first();

        expect(user, isNull);
      });

      test('should limit to 1 result internally', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final user = await query.first();

        expect(user, isNotNull);
        // Should return only one result even though there are multiple records
      });

      test('should work with WHERE conditions', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final user = await query.where('active', 0).first();

        expect(user, isNotNull);
        expect(user!.name, equals('Bob Wilson'));
        expect(user.active, isFalse);
      });
    });

    group('Query Execution - count()', () {
      test('should return total count', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final count = await query.count();

        expect(count, equals(5));
      });

      test('should return count with WHERE condition', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final count = await query.where('active', 1).count();

        expect(count, equals(4)); // Only active users
      });

      test('should return count with complex conditions', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final count = await query
            .whereNotNull('email')
            .whereBetween('age', 25, 35)
            .count();

        expect(count, equals(4)); // Jane (25), Alice (28), John (30), Bob (35)
      });

      test('should return 0 when no matches', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final count = await query.where('name', 'Non-existent').count();

        expect(count, equals(0));
      });

      test('should preserve original select columns after count', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.select(['name', 'email']);

        await query.count();

        // Original select should be restored
        final sql = query.toSql();
        expect(sql, contains('name, email'));
      });
    });

    group('Query Execution - exists()', () {
      test('should return true when records exist', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final exists = await query.exists();

        expect(exists, isTrue);
      });

      test('should return false when no records exist', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final exists = await query.where('name', 'Non-existent').exists();

        expect(exists, isFalse);
      });

      test('should work with WHERE conditions', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final exists = await query.where('active', 0).exists();

        expect(exists, isTrue); // Bob Wilson is inactive
      });

      test('should work with complex conditions', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final exists = await query
            .whereNull('email')
            .where('age', '>', 40)
            .exists();

        expect(exists, isTrue); // Charlie Green has null email and age 45
      });
    });

    group('Advanced Features', () {
      test('should apply scope callback', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final result = query.scope((q) => q.where('active', 1).orderBy('name'));

        expect(result, same(query));
        final sql = query.toSql();
        expect(
          sql,
          equals('SELECT * FROM users WHERE active = ? ORDER BY name ASC'),
        );
      });

      test('should apply conditional logic when true', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final result = query.when(true, (q) => q.where('active', 1));

        expect(result, same(query));
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE active = ?'));
      });

      test('should skip conditional logic when false', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final result = query.when(false, (q) => q.where('active', 1));

        expect(result, same(query));
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users'));
      });

      test('should chain scope and when methods', () {
        final isAdmin = true;
        final query = QueryBuilder<TestUser>(() => TestUser());

        query
            .scope((q) => q.where('active', 1))
            .when(isAdmin, (q) => q.where('age', '>', 25))
            .orderBy('name');

        final sql = query.toSql();
        expect(
          sql,
          equals(
            'SELECT * FROM users WHERE active = ? AND age > ? ORDER BY name ASC',
          ),
        );
      });
    });

    group('SQL Injection Prevention', () {
      test('should use parameter binding for WHERE values', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('name', "'; DROP TABLE users; --");

        final sql = query.toSql();
        final params = query.getBindings();

        expect(sql, equals('SELECT * FROM users WHERE name = ?'));
        expect(params, equals(["'; DROP TABLE users; --"]));
      });

      test('should use parameter binding for WHERE IN values', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.whereIn('name', ["'; DROP TABLE users; --", 'normal_name']);

        final sql = query.toSql();
        final params = query.getBindings();

        expect(sql, equals('SELECT * FROM users WHERE name IN (?, ?)'));
        expect(params, equals(["'; DROP TABLE users; --", 'normal_name']));
      });

      test('should use parameter binding for BETWEEN values', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.whereBetween('age', "'; DROP TABLE users; --", 50);

        final sql = query.toSql();
        final params = query.getBindings();

        expect(sql, equals('SELECT * FROM users WHERE age BETWEEN ? AND ?'));
        expect(params, equals(["'; DROP TABLE users; --", 50]));
      });
    });

    group('OR Conditions Tests', () {
      test('should add OR WHERE condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('active', 1).orWhere('name', 'Admin');
        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE active = ? OR name = ?'));
        expect(query.getBindings(), equals([1, 'Admin']));
      });

      test('should add OR WHERE IN condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('active', 1).orWhereIn('age', [25, 30]);
        final sql = query.toSql();
        expect(
          sql,
          equals('SELECT * FROM users WHERE active = ? OR age IN (?, ?)'),
        );
        expect(query.getBindings(), equals([1, 25, 30]));
      });

      test('should add OR WHERE NOT IN condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('active', 1).orWhereNotIn('age', [25, 30]);
        final sql = query.toSql();
        expect(
          sql,
          equals('SELECT * FROM users WHERE active = ? OR age NOT IN (?, ?)'),
        );
        expect(query.getBindings(), equals([1, 25, 30]));
      });

      test('should add OR WHERE NULL condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('active', 1).orWhereNull('email');
        final sql = query.toSql();
        expect(
          sql,
          equals('SELECT * FROM users WHERE active = ? OR email IS NULL'),
        );
        expect(query.getBindings(), equals([1]));
      });

      test('should add OR WHERE NOT NULL condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('active', 1).orWhereNotNull('email');
        final sql = query.toSql();
        expect(
          sql,
          equals('SELECT * FROM users WHERE active = ? OR email IS NOT NULL'),
        );
        expect(query.getBindings(), equals([1]));
      });

      test('should add OR WHERE BETWEEN condition', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('active', 1).orWhereBetween('age', 25, 35);
        final sql = query.toSql();
        expect(
          sql,
          equals('SELECT * FROM users WHERE active = ? OR age BETWEEN ? AND ?'),
        );
        expect(query.getBindings(), equals([1, 25, 35]));
      });

      test('should chain multiple OR conditions', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final users = await query
            .where('active', 0)
            .orWhere('age', '>', 40)
            .orWhereNull('email')
            .get();

        expect(
          users,
          hasLength(2),
        ); // Bob Wilson (inactive) + Charlie Green (null email, age 45)
      });
    });

    group('Aggregation Methods Tests', () {
      test('should calculate sum of column', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final sum = await query.sum('age');

        expect(sum, equals(163.0)); // 30 + 25 + 35 + 28 + 45
      });

      test('should calculate average of column', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final avg = await query.avg('age');

        expect(avg, equals(32.6)); // 163 / 5
      });

      test('should find maximum value of column', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final max = await query.max('age');

        expect(max, equals(45)); // Charlie Green
      });

      test('should find minimum value of column', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final min = await query.min('age');

        expect(min, equals(25)); // Jane Smith
      });

      test('should handle aggregation with WHERE conditions', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final sum = await query.where('active', 1).sum('age');

        expect(
          sum,
          equals(128.0),
        ); // 30 + 25 + 28 + 45 (excluding Bob Wilson who is inactive)
      });

      test('should return null for empty result sets in aggregation', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final sum = await query.where('name', 'Non-existent').sum('age');

        expect(sum, isNull);
      });
    });

    group('Pagination Tests', () {
      test('should paginate results with default parameters', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final result = await query.paginate();

        expect(result.data, hasLength(5));
        expect(result.currentPage, equals(1));
        expect(result.perPage, equals(15));
        expect(result.total, equals(5));
        expect(result.lastPage, equals(1));
      });

      test('should paginate with custom page and perPage', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final result = await query.paginate(page: 2, perPage: 2);

        expect(result.data, hasLength(2));
        expect(result.currentPage, equals(2));
        expect(result.perPage, equals(2));
        expect(result.total, equals(5));
        expect(result.lastPage, equals(3));
      });

      test('should handle pagination metadata correctly', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final result = await query.paginate(page: 2, perPage: 2);

        expect(result.from, equals(3));
        expect(result.to, equals(4));
        expect(result.hasMorePages, isTrue);
        expect(result.hasPreviousPages, isTrue);
        expect(result.nextPage, equals(3));
        expect(result.previousPage, equals(1));
      });

      test('should handle last page correctly', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final result = await query.paginate(page: 3, perPage: 2);

        expect(result.data, hasLength(1));
        expect(result.hasMorePages, isFalse);
        expect(result.nextPage, isNull);
      });

      test('should combine pagination with WHERE conditions', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final result = await query
            .where('active', 1)
            .paginate(page: 1, perPage: 2);

        expect(result.data, hasLength(2));
        expect(result.total, equals(4)); // Only active users
      });
    });

    group('Soft Delete Tests', () {
      test('should include trashed records with withTrashed', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.withTrashed();

        // This test assumes the model supports soft deletes
        // The actual behavior depends on implementation
        expect(query, isA<QueryBuilder<TestUser>>());
      });

      test('should show only trashed records with onlyTrashed', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.onlyTrashed();

        expect(query, isA<QueryBuilder<TestUser>>());
      });

      test('should restore soft deleted records', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());

        try {
          final count = await query.where('name', 'Test User').restore();
          expect(count, isA<int>());
        } catch (e) {
          // Expected if model doesn't support soft deletes
          expect(e, isA<UnsupportedError>());
        }
      });

      test('should force delete records permanently', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final count = await query.where('name', 'Non-existent').forceDelete();

        expect(count, equals(0));
      });
    });

    group('Include and Eager Loading Tests', () {
      test('should set includes for eager loading', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.include(['posts', 'profile']);

        expect(query, isA<QueryBuilder<TestUser>>());
      });

      test('should use withRelations as alias for include', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.withRelations(['posts']);

        expect(query, isA<QueryBuilder<TestUser>>());
      });

      test('should handle single relationship include', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.include('posts');

        expect(query, isA<QueryBuilder<TestUser>>());
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty WHERE IN list', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.whereIn('age', []);

        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE age IN ()'));
        expect(query.getBindings(), isEmpty);
      });

      test('should handle null values in WHERE conditions', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.where('name', null);

        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users WHERE name = ?'));
        expect(query.getBindings(), equals([null]));
      });

      test('should handle multiple ORDER BY with same column', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.orderBy('name', 'ASC').orderBy('name', 'DESC');

        final sql = query.toSql();
        expect(sql, equals('SELECT * FROM users ORDER BY name ASC, name DESC'));
      });

      test('should handle zero and negative LIMIT/OFFSET', () {
        final query1 = QueryBuilder<TestUser>(() => TestUser());
        query1.limit(0);
        expect(query1.toSql(), equals('SELECT * FROM users LIMIT 0'));

        final query2 = QueryBuilder<TestUser>(() => TestUser());
        query2.offset(0);
        expect(query2.toSql(), equals('SELECT * FROM users OFFSET 0'));
      });

      test('should handle SELECT with empty column list', () {
        final query = QueryBuilder<TestUser>(() => TestUser());
        query.select([]);

        final sql = query.toSql();
        expect(
          sql,
          equals('SELECT  FROM users'),
        ); // May need handling in implementation
      });

      test('should handle complex mixed AND/OR conditions', () async {
        final query = QueryBuilder<TestUser>(() => TestUser());
        final users = await query
            .where('active', 1)
            .where('age', '>', 25)
            .orWhere('name', 'Bob Wilson')
            .orderBy('name')
            .get();

        expect(users, hasLength(4)); // Active users > 25 + Bob Wilson
      });
    });
  });
}
