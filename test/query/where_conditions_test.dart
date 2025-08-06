import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

// Test model for WHERE condition testing
class TestProduct extends Model<TestProduct> {
  final _id = AutoIncrementField();
  final _name = StringField(required: true);
  final _category = StringField();
  final _price = DoubleField();
  final _stock = IntField();
  final _active = BoolField(defaultValue: true);
  final _description = StringField();
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField();

  @override
  String get table => 'products';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('category', _category);
    registerField('price', _price);
    registerField('stock', _stock);
    registerField('active', _active);
    registerField('description', _description);
    registerField('created_at', _createdAt);
    registerField('updated_at', _updatedAt);
  }

  // Convenience getters/setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get name => _name.value;
  set name(String? value) => _name.value = value;

  String? get category => _category.value;
  set category(String? value) => _category.value = value;

  double? get price => _price.value;
  set price(double? value) => _price.value = value;

  int? get stock => _stock.value;
  set stock(int? value) => _stock.value = value;

  bool? get active => _active.value;
  set active(bool? value) => _active.value = value;

  String? get description => _description.value;
  set description(String? value) => _description.value = value;
}

void main() {
  group('WHERE Conditions Tests', () {
    setUp(() async {
      // Reset database state before each test
      Database.reset();
      await Database.initialize(databasePath: ':memory:');

      // Create test table
      await Database.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          category TEXT,
          price REAL,
          stock INTEGER,
          active INTEGER DEFAULT 1,
          description TEXT,
          created_at TEXT,
          updated_at TEXT
        )
      ''');

      // Insert comprehensive test data
      await Database.execute('''
        INSERT INTO products (name, category, price, stock, active, description, created_at, updated_at) VALUES
        ('Laptop Pro', 'Electronics', 1299.99, 10, 1, 'High-end laptop', '2023-12-01T10:00:00.000Z', '2023-12-01T10:00:00.000Z'),
        ('Gaming Mouse', 'Electronics', 79.99, 25, 1, 'Wireless gaming mouse', '2023-12-02T10:00:00.000Z', '2023-12-02T10:00:00.000Z'),
        ('Office Chair', 'Furniture', 199.99, 5, 1, 'Ergonomic office chair', '2023-12-03T10:00:00.000Z', '2023-12-03T10:00:00.000Z'),
        ('Desk Lamp', 'Furniture', 49.99, 0, 0, 'LED desk lamp', '2023-12-04T10:00:00.000Z', '2023-12-04T10:00:00.000Z'),
        ('Notebook', 'Stationery', 12.99, 100, 1, null, '2023-12-05T10:00:00.000Z', null),
        ('Smartphone', 'Electronics', 899.99, 15, 1, 'Latest model smartphone', '2023-12-06T10:00:00.000Z', '2023-12-06T10:00:00.000Z'),
        ('Bookshelf', 'Furniture', 149.99, 3, 1, 'Wooden bookshelf', '2023-12-07T10:00:00.000Z', '2023-12-07T10:00:00.000Z'),
        ('Pen Set', 'Stationery', 24.99, 50, 1, 'Premium pen set', '2023-12-08T10:00:00.000Z', '2023-12-08T10:00:00.000Z'),
        ('Monitor', 'Electronics', 299.99, 8, 1, '27-inch monitor', '2023-12-09T10:00:00.000Z', '2023-12-09T10:00:00.000Z'),
        ('Table', null, 99.99, 2, 0, 'Simple wooden table', '2023-12-10T10:00:00.000Z', '2023-12-10T10:00:00.000Z')
      ''');
    });

    tearDown(() async {
      await Database.close();
      await Future.delayed(Duration(milliseconds: 50));
    });

    group('BasicWhereCondition Tests', () {
      test('should create BasicWhereCondition with equals operator', () {
        final condition = BasicWhereCondition('name', '=', 'Laptop Pro');
        expect(condition.toSql(), equals('name = ?'));
        expect(condition.getParameters(), equals(['Laptop Pro']));
      });

      test('should handle different comparison operators', () {
        final operators = [
          '=',
          '!=',
          '<>',
          '>',
          '>=',
          '<',
          '<=',
          'LIKE',
          'NOT LIKE',
        ];

        for (final op in operators) {
          final condition = BasicWhereCondition('price', op, 100.0);
          expect(condition.toSql(), equals('price $op ?'));
          expect(condition.getParameters(), equals([100.0]));
        }
      });

      test('should handle various data types in BasicWhereCondition', () {
        // String value
        final stringCondition = BasicWhereCondition(
          'name',
          '=',
          'Test Product',
        );
        expect(stringCondition.getParameters(), equals(['Test Product']));

        // Integer value
        final intCondition = BasicWhereCondition('stock', '>', 10);
        expect(intCondition.getParameters(), equals([10]));

        // Double value
        final doubleCondition = BasicWhereCondition('price', '<=', 99.99);
        expect(doubleCondition.getParameters(), equals([99.99]));

        // Boolean value
        final boolCondition = BasicWhereCondition('active', '=', true);
        expect(boolCondition.getParameters(), equals([true]));

        // Null value
        final nullCondition = BasicWhereCondition('description', '=', null);
        expect(nullCondition.getParameters(), equals([null]));
      });

      test('should handle LIKE patterns with wildcards', () {
        final condition = BasicWhereCondition('name', 'LIKE', '%Laptop%');
        expect(condition.toSql(), equals('name LIKE ?'));
        expect(condition.getParameters(), equals(['%Laptop%']));
      });

      test('should handle case-sensitive operations', () {
        final condition1 = BasicWhereCondition('name', '=', 'laptop pro');
        final condition2 = BasicWhereCondition('name', '=', 'Laptop Pro');

        expect(condition1.toSql(), equals(condition2.toSql()));
        expect(condition1.getParameters(), equals(['laptop pro']));
        expect(condition2.getParameters(), equals(['Laptop Pro']));
      });
    });

    group('WhereInCondition Tests', () {
      test('should create WhereInCondition with multiple values', () {
        final condition = WhereInCondition('category', [
          'Electronics',
          'Furniture',
        ]);
        expect(condition.toSql(), equals('category IN (?, ?)'));
        expect(condition.getParameters(), equals(['Electronics', 'Furniture']));
      });

      test('should handle single value in WhereInCondition', () {
        final condition = WhereInCondition('category', ['Electronics']);
        expect(condition.toSql(), equals('category IN (?)'));
        expect(condition.getParameters(), equals(['Electronics']));
      });

      test('should handle empty list in WhereInCondition', () {
        final condition = WhereInCondition('category', []);
        expect(condition.toSql(), equals('category IN ()'));
        expect(condition.getParameters(), isEmpty);
      });

      test('should handle mixed data types in WhereInCondition', () {
        final condition = WhereInCondition('mixed_column', [
          1,
          'text',
          99.99,
          true,
          null,
        ]);
        expect(condition.toSql(), equals('mixed_column IN (?, ?, ?, ?, ?)'));
        expect(
          condition.getParameters(),
          equals([1, 'text', 99.99, true, null]),
        );
      });

      test('should handle large value lists in WhereInCondition', () {
        final largeList = List.generate(100, (i) => 'value_$i');
        final condition = WhereInCondition('test_column', largeList);
        final expectedPlaceholders = List.generate(100, (_) => '?').join(', ');
        expect(
          condition.toSql(),
          equals('test_column IN ($expectedPlaceholders)'),
        );
        expect(condition.getParameters(), equals(largeList));
      });
    });

    group('WhereNotInCondition Tests', () {
      test('should create WhereNotInCondition with multiple values', () {
        final condition = WhereNotInCondition('category', [
          'Electronics',
          'Furniture',
        ]);
        expect(condition.toSql(), equals('category NOT IN (?, ?)'));
        expect(condition.getParameters(), equals(['Electronics', 'Furniture']));
      });

      test('should handle single value in WhereNotInCondition', () {
        final condition = WhereNotInCondition('stock', [0]);
        expect(condition.toSql(), equals('stock NOT IN (?)'));
        expect(condition.getParameters(), equals([0]));
      });

      test('should handle empty list in WhereNotInCondition', () {
        final condition = WhereNotInCondition('category', []);
        expect(condition.toSql(), equals('category NOT IN ()'));
        expect(condition.getParameters(), isEmpty);
      });

      test('should handle numeric ranges in WhereNotInCondition', () {
        final condition = WhereNotInCondition('stock', [0, 1, 2, 3, 4, 5]);
        expect(condition.toSql(), equals('stock NOT IN (?, ?, ?, ?, ?, ?)'));
        expect(condition.getParameters(), equals([0, 1, 2, 3, 4, 5]));
      });
    });

    group('WhereNullCondition Tests', () {
      test('should create WhereNullCondition for IS NULL', () {
        final condition = WhereNullCondition('description', true);
        expect(condition.toSql(), equals('description IS NULL'));
        expect(condition.getParameters(), isEmpty);
      });

      test('should create WhereNullCondition for IS NOT NULL', () {
        final condition = WhereNullCondition('description', false);
        expect(condition.toSql(), equals('description IS NOT NULL'));
        expect(condition.getParameters(), isEmpty);
      });

      test('should not have parameters for null conditions', () {
        final nullCondition = WhereNullCondition('column1', true);
        final notNullCondition = WhereNullCondition('column2', false);

        expect(nullCondition.getParameters(), isEmpty);
        expect(notNullCondition.getParameters(), isEmpty);
      });
    });

    group('WhereBetweenCondition Tests', () {
      test('should create WhereBetweenCondition with numeric values', () {
        final condition = WhereBetweenCondition('price', 100.0, 200.0);
        expect(condition.toSql(), equals('price BETWEEN ? AND ?'));
        expect(condition.getParameters(), equals([100.0, 200.0]));
      });

      test('should handle integer ranges in WhereBetweenCondition', () {
        final condition = WhereBetweenCondition('stock', 10, 50);
        expect(condition.toSql(), equals('stock BETWEEN ? AND ?'));
        expect(condition.getParameters(), equals([10, 50]));
      });

      test('should handle string ranges in WhereBetweenCondition', () {
        final condition = WhereBetweenCondition('name', 'A', 'M');
        expect(condition.toSql(), equals('name BETWEEN ? AND ?'));
        expect(condition.getParameters(), equals(['A', 'M']));
      });

      test('should handle date ranges in WhereBetweenCondition', () {
        final startDate = '2023-12-01T00:00:00.000Z';
        final endDate = '2023-12-31T23:59:59.999Z';
        final condition = WhereBetweenCondition(
          'created_at',
          startDate,
          endDate,
        );
        expect(condition.toSql(), equals('created_at BETWEEN ? AND ?'));
        expect(condition.getParameters(), equals([startDate, endDate]));
      });

      test('should handle equal min and max values', () {
        final condition = WhereBetweenCondition('price', 99.99, 99.99);
        expect(condition.toSql(), equals('price BETWEEN ? AND ?'));
        expect(condition.getParameters(), equals([99.99, 99.99]));
      });

      test('should handle null values in BETWEEN', () {
        final condition = WhereBetweenCondition('price', null, 100.0);
        expect(condition.toSql(), equals('price BETWEEN ? AND ?'));
        expect(condition.getParameters(), equals([null, 100.0]));
      });
    });

    group('Complex WHERE Combinations', () {
      test(
        'should execute query with multiple basic WHERE conditions',
        () async {
          final query = QueryBuilder<TestProduct>(() => TestProduct());
          final products = await query
              .where('active', 1)
              .where('stock', '>', 0)
              .where('category', 'Electronics')
              .get();

          expect(
            products,
            hasLength(4),
          ); // Laptop Pro, Gaming Mouse, Smartphone, Monitor
          expect(products.every((p) => p.active == true), isTrue);
          expect(products.every((p) => p.stock! > 0), isTrue);
          expect(products.every((p) => p.category == 'Electronics'), isTrue);
        },
      );

      test('should execute query with WHERE IN and basic WHERE', () async {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        final products = await query
            .whereIn('category', ['Electronics', 'Furniture'])
            .where('active', 1)
            .where('stock', '>', 5)
            .get();

        expect(
          products,
          hasLength(4),
        ); // Laptop Pro, Gaming Mouse, Smartphone, Monitor
        expect(
          products.every(
            (p) => ['Electronics', 'Furniture'].contains(p.category),
          ),
          isTrue,
        );
        expect(products.every((p) => p.active == true), isTrue);
        expect(products.every((p) => p.stock! > 5), isTrue);
      });

      test('should execute query with WHERE NOT IN conditions', () async {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        final products = await query
            .whereNotIn('category', ['Electronics'])
            .where('active', 1)
            .get();

        expect(
          products,
          hasLength(4),
        ); // Office Chair, Notebook, Bookshelf, Pen Set
        expect(products.every((p) => p.category != 'Electronics'), isTrue);
        expect(products.every((p) => p.active == true), isTrue);
      });

      test('should execute query with NULL and NOT NULL conditions', () async {
        final query1 = QueryBuilder<TestProduct>(() => TestProduct());
        final productsWithNullDescription = await query1
            .whereNull('description')
            .get();
        expect(productsWithNullDescription, hasLength(1)); // Notebook

        final query2 = QueryBuilder<TestProduct>(() => TestProduct());
        final productsWithDescription = await query2
            .whereNotNull('description')
            .get();
        expect(productsWithDescription, hasLength(9)); // All except Notebook
      });

      test('should execute query with BETWEEN conditions', () async {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        final products = await query
            .whereBetween('price', 50.0, 300.0)
            .where('active', 1)
            .get();

        expect(
          products,
          hasLength(4),
        ); // Gaming Mouse, Office Chair, Bookshelf, Monitor (Pen Set is 24.99, below 50.0)
        expect(
          products.every((p) => p.price! >= 50.0 && p.price! <= 300.0),
          isTrue,
        );
        expect(products.every((p) => p.active == true), isTrue);
      });

      test('should combine all WHERE condition types', () async {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        final products = await query
            .whereIn('category', ['Electronics', 'Furniture', 'Stationery'])
            .whereNotIn('stock', [0])
            .whereNotNull('description')
            .whereBetween('price', 20.0, 500.0)
            .where('active', 1)
            .get();

        expect(
          products,
          hasLength(5),
        ); // Gaming Mouse, Office Chair, Bookshelf, Pen Set, Monitor
        expect(products.every((p) => p.active == true), isTrue);
        expect(products.every((p) => p.stock! > 0), isTrue);
        expect(products.every((p) => p.description != null), isTrue);
        expect(
          products.every((p) => p.price! >= 20.0 && p.price! <= 500.0),
          isTrue,
        );
      });
    });

    group('Dynamic WHERE Condition Building', () {
      test('should build conditions based on runtime parameters', () {
        String? searchCategory;
        double? minPrice;
        double? maxPrice;
        bool? includeInactive;

        final query = QueryBuilder<TestProduct>(() => TestProduct());

        // Simulate dynamic building
        searchCategory = 'Electronics';
        minPrice = 100.0;
        maxPrice = 1000.0;
        includeInactive = false;

        query.where('category', searchCategory);
        query.where('price', '>=', minPrice);
        query.where('price', '<=', maxPrice);
        if (includeInactive == false) {
          query.where('active', 1);
        }

        final sql = query.toSql();
        expect(
          sql,
          equals(
            'SELECT * FROM products WHERE category = ? AND price >= ? AND price <= ? AND active = ?',
          ),
        );
        expect(query.getBindings(), equals(['Electronics', 100.0, 1000.0, 1]));
      });

      test('should use conditional WHERE with when() method', () {
        final hasCategory = true;
        final hasMinPrice = false;
        final query = QueryBuilder<TestProduct>(() => TestProduct());

        query
            .when(hasCategory, (q) => q.where('category', 'Electronics'))
            .when(hasMinPrice, (q) => q.where('price', '>=', 100.0))
            .where('active', 1);

        final sql = query.toSql();
        expect(
          sql,
          equals('SELECT * FROM products WHERE category = ? AND active = ?'),
        );
        expect(query.getBindings(), equals(['Electronics', 1]));
      });

      test(
        'should build search functionality with multiple conditions',
        () async {
          // Simulate search parameters
          final searchTerm = 'chair';
          final categories = ['Furniture', 'Electronics'];
          final minPrice = 50.0;
          final maxStock = 20;

          final query = QueryBuilder<TestProduct>(() => TestProduct());
          final products = await query
              .where('name', 'LIKE', '%$searchTerm%')
              .whereIn('category', categories)
              .where('price', '>=', minPrice)
              .where('stock', '<=', maxStock)
              .where('active', 1)
              .get();

          expect(products, hasLength(1)); // Office Chair
          expect(products.first.name!.toLowerCase(), contains('chair'));
          expect(categories.contains(products.first.category), isTrue);
          expect(products.first.price! >= minPrice, isTrue);
          expect(products.first.stock! <= maxStock, isTrue);
        },
      );
    });

    group('WHERE with QueryBuilder Methods', () {
      test('should combine WHERE with ORDER BY and LIMIT', () async {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        final products = await query
            .where('active', 1)
            .whereNotNull('description')
            .orderBy('price', 'DESC')
            .limit(3)
            .get();

        expect(products, hasLength(3));
        expect(products.every((p) => p.active == true), isTrue);
        expect(products.every((p) => p.description != null), isTrue);
        // Should be ordered by price descending
        expect(products[0].price! >= products[1].price!, isTrue);
        expect(products[1].price! >= products[2].price!, isTrue);
      });

      test('should use WHERE with SELECT specific columns', () async {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        query
            .select(['name', 'price', 'category'])
            .where('category', 'Electronics')
            .where('active', 1);

        final sql = query.toSql();
        expect(
          sql,
          equals(
            'SELECT name, price, category FROM products WHERE category = ? AND active = ?',
          ),
        );
        expect(query.getBindings(), equals(['Electronics', 1]));
      });

      test('should use WHERE with count() method', () async {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        final count = await query.where('active', 1).whereIn('category', [
          'Electronics',
          'Furniture',
        ]).count();

        expect(count, equals(6)); // 4 Electronics + 2 Furniture (active)
      });

      test('should use WHERE with exists() method', () async {
        final query1 = QueryBuilder<TestProduct>(() => TestProduct());
        final hasExpensiveProducts = await query1
            .where('price', '>', 1000.0)
            .where('active', 1)
            .exists();

        expect(hasExpensiveProducts, isTrue); // Laptop Pro

        final query2 = QueryBuilder<TestProduct>(() => TestProduct());
        final hasVeryExpensiveProducts = await query2
            .where('price', '>', 2000.0)
            .exists();

        expect(hasVeryExpensiveProducts, isFalse);
      });

      test('should use WHERE with first() method', () async {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        final product = await query
            .where('category', 'Electronics')
            .where('active', 1)
            .orderBy('price', 'ASC')
            .first();

        expect(product, isNotNull);
        expect(product!.category, equals('Electronics'));
        expect(product.active, isTrue);
        expect(
          product.name,
          equals('Gaming Mouse'),
        ); // Cheapest active electronics
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle special characters in WHERE conditions', () {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        query.where('name', "O'Reilly's \"Book\"");

        final sql = query.toSql();
        final params = query.getBindings();

        expect(sql, equals('SELECT * FROM products WHERE name = ?'));
        expect(params, equals(["O'Reilly's \"Book\""]));
      });

      test('should handle SQL injection attempts in WHERE conditions', () {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        query.where('name', "'; DROP TABLE products; --").whereIn('category', [
          "'; DROP TABLE products; --",
          'Electronics',
        ]);

        final sql = query.toSql();
        final params = query.getBindings();

        expect(
          sql,
          equals(
            'SELECT * FROM products WHERE name = ? AND category IN (?, ?)',
          ),
        );
        expect(
          params,
          equals([
            "'; DROP TABLE products; --",
            "'; DROP TABLE products; --",
            'Electronics',
          ]),
        );
      });

      test('should handle very long WHERE condition chains', () {
        final query = QueryBuilder<TestProduct>(() => TestProduct());

        // Add 20 WHERE conditions
        for (int i = 0; i < 20; i++) {
          query.where('test_column_$i', '=', 'value_$i');
        }

        final sql = query.toSql();
        final params = query.getBindings();

        expect(sql, contains('WHERE'));
        expect(sql.split(' AND '), hasLength(20));
        expect(params, hasLength(20));
        expect(params.every((p) => p.toString().startsWith('value_')), isTrue);
      });

      test('should handle empty and whitespace values in WHERE conditions', () {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        query
            .where('name', '')
            .where('description', '   ')
            .where('category', '\t\n\r');

        final sql = query.toSql();
        final params = query.getBindings();

        expect(
          sql,
          equals(
            'SELECT * FROM products WHERE name = ? AND description = ? AND category = ?',
          ),
        );
        expect(params, equals(['', '   ', '\t\n\r']));
      });

      test('should handle numeric edge cases in WHERE conditions', () {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        query
            .where('price', double.infinity)
            .where('stock', double.nan)
            .where('id', double.negativeInfinity);

        final sql = query.toSql();
        final params = query.getBindings();

        expect(
          sql,
          equals(
            'SELECT * FROM products WHERE price = ? AND stock = ? AND id = ?',
          ),
        );
        expect(params[0], equals(double.infinity));
        expect(params[1].isNaN, isTrue);
        expect(params[2], equals(double.negativeInfinity));
      });

      test('should handle WHERE conditions with very large lists', () {
        final largeList = List.generate(1000, (i) => 'item_$i');
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        query.whereIn('large_column', largeList);

        final sql = query.toSql();
        final params = query.getBindings();

        expect(
          sql.split('?'),
          hasLength(1001),
        ); // 1000 placeholders + 1 for split
        expect(params, hasLength(1000));
        expect(params.last, equals('item_999'));
      });
    });

    group('Performance and Optimization', () {
      test('should generate efficient SQL for combined conditions', () {
        final query = QueryBuilder<TestProduct>(() => TestProduct());
        query
            .where('active', 1)
            .whereIn('category', ['Electronics', 'Furniture'])
            .whereBetween('price', 50.0, 500.0)
            .whereNotNull('description');

        final sql = query.toSql();
        final params = query.getBindings();

        // Verify SQL structure
        expect(
          sql,
          equals(
            'SELECT * FROM products WHERE active = ? AND category IN (?, ?) AND price BETWEEN ? AND ? AND description IS NOT NULL',
          ),
        );
        expect(params, equals([1, 'Electronics', 'Furniture', 50.0, 500.0]));

        // Verify parameters are properly bound
        expect(params, hasLength(5));
      });

      test('should handle parameter binding efficiently', () {
        final startTime = DateTime.now();

        final query = QueryBuilder<TestProduct>(() => TestProduct());
        for (int i = 0; i < 100; i++) {
          query.where('column_$i', '=', 'value_$i');
        }

        final sql = query.toSql();
        final params = query.getBindings();

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        expect(duration.inMilliseconds, lessThan(100)); // Should be fast
        expect(params, hasLength(100));
        expect(sql.split(' AND '), hasLength(100));
      });
    });
  });
}
