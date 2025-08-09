import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

// Simple test model for aggregates
class Sale extends Model<Sale> {
  final _id = AutoIncrementField();
  final _productName = StringField(required: true);
  final _amount = DoubleField();
  final _quantity = IntField();
  final _saleDate = DateField();
  final _categoryId = IntField();

  @override
  String get table => 'sales';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('product_name', _productName);
    registerField('amount', _amount);
    registerField('quantity', _quantity);
    registerField('sale_date', _saleDate);
    registerField('category_id', _categoryId);
  }

  // Getters and setters
  int? get id => getValue<int>('id');
  set id(int? value) => setValue<int>('id', value);

  String? get productName => getValue<String>('product_name');
  set productName(String? value) => setValue<String>('product_name', value);

  double? get amount => getValue<double>('amount');
  set amount(double? value) => setValue<double>('amount', value);

  int? get quantity => getValue<int>('quantity');
  set quantity(int? value) => setValue<int>('quantity', value);

  DateTime? get saleDate => getValue<DateTime>('sale_date');
  set saleDate(DateTime? value) => setValue<DateTime>('sale_date', value);

  int? get categoryId => getValue<int>('category_id');
  set categoryId(int? value) => setValue<int>('category_id', value);
}

void main() async {
  // Initialize database connection
  await Database.initialize(databasePath: ':memory:');

  group('Aggregate Functions Tests', () {
    setUp(() async {
      // Create tables
      await Database.execute('''
        CREATE TABLE sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_name TEXT NOT NULL,
          amount REAL,
          quantity INTEGER,
          sale_date TEXT,
          category_id INTEGER
        )
      ''');

      // Insert test data
      final sales = [
        Sale()
          ..productName = 'Laptop'
          ..amount = 999.99
          ..quantity = 1
          ..categoryId = 1,
        Sale()
          ..productName = 'Mouse'
          ..amount = 25.50
          ..quantity = 5
          ..categoryId = 1,
        Sale()
          ..productName = 'Keyboard'
          ..amount = 75.00
          ..quantity = 3
          ..categoryId = 1,
        Sale()
          ..productName = 'Monitor'
          ..amount = 299.99
          ..quantity = 2
          ..categoryId = 2,
        Sale()
          ..productName = 'Speaker'
          ..amount = 150.00
          ..quantity = 4
          ..categoryId = 2,
      ];

      for (final sale in sales) {
        await sale.save();
      }
    });

    tearDown(() async {
      await Database.execute('DROP TABLE IF EXISTS sales');
    });

    group('Count Aggregate Tests', () {
      test('should count all records', () async {
        final totalCount = await Model.query<Sale>(() => Sale()).count();
        expect(totalCount, equals(5));
      });

      test('should count with WHERE condition', () async {
        final category1Count = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 1).count();
        expect(category1Count, equals(3));
      });

      test('should count with multiple conditions', () async {
        final expensiveCategory1 = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 1).where('amount', '>', 50.0).count();
        expect(expensiveCategory1, equals(2));
      });

      test('should return 0 for no matches', () async {
        final noMatches = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 99).count();
        expect(noMatches, equals(0));
      });
    });

    group('Sum Aggregate Tests', () {
      test('should sum all amounts', () async {
        final totalAmount = await Model.query<Sale>(() => Sale()).sum('amount');
        expect(totalAmount, closeTo(1550.48, 0.01));
      });

      test('should sum with WHERE condition', () async {
        final category1Sum = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 1).sum('amount');
        expect(category1Sum, closeTo(1100.49, 0.01));
      });

      test('should sum quantities', () async {
        final totalQuantity = await Model.query<Sale>(
          () => Sale(),
        ).sum('quantity');
        expect(totalQuantity, equals(15));
      });

      test('should return null for no matches', () async {
        final noMatches = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 99).sum('amount');
        expect(noMatches, isNull);
      });
    });

    group('Average Aggregate Tests', () {
      test('should calculate average amount', () async {
        final avgAmount = await Model.query<Sale>(() => Sale()).avg('amount');
        expect(avgAmount, closeTo(310.096, 0.01));
      });

      test('should calculate average with WHERE condition', () async {
        final category2Avg = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 2).avg('amount');
        expect(category2Avg, closeTo(224.995, 0.01));
      });

      test('should calculate average quantity', () async {
        final avgQuantity = await Model.query<Sale>(
          () => Sale(),
        ).avg('quantity');
        expect(avgQuantity, equals(3.0));
      });

      test('should return null for no matches', () async {
        final noMatches = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 99).avg('amount');
        expect(noMatches, isNull);
      });
    });

    group('Min Aggregate Tests', () {
      test('should find minimum amount', () async {
        final minAmount = await Model.query<Sale>(() => Sale()).min('amount');
        expect(minAmount, equals(25.50));
      });

      test('should find minimum with WHERE condition', () async {
        final category1Min = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 1).min('amount');
        expect(category1Min, equals(25.50));
      });

      test('should find minimum quantity', () async {
        final minQuantity = await Model.query<Sale>(
          () => Sale(),
        ).min('quantity');
        expect(minQuantity, equals(1));
      });

      test('should return null for no matches', () async {
        final noMatches = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 99).min('amount');
        expect(noMatches, isNull);
      });
    });

    group('Max Aggregate Tests', () {
      test('should find maximum amount', () async {
        final maxAmount = await Model.query<Sale>(() => Sale()).max('amount');
        expect(maxAmount, equals(999.99));
      });

      test('should find maximum with WHERE condition', () async {
        final category2Max = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 2).max('amount');
        expect(category2Max, equals(299.99));
      });

      test('should find maximum quantity', () async {
        final maxQuantity = await Model.query<Sale>(
          () => Sale(),
        ).max('quantity');
        expect(maxQuantity, equals(5));
      });

      test('should return null for no matches', () async {
        final noMatches = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 99).max('amount');
        expect(noMatches, isNull);
      });
    });

    group('Complex Aggregate Queries', () {
      test('should combine aggregates with GROUP BY-like logic', () async {
        // Test category 1 aggregates
        final cat1Query = Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 1);
        final cat1Count = await cat1Query.count();
        final cat1Sum = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 1).sum('amount');
        final cat1Avg = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 1).avg('amount');

        expect(cat1Count, equals(3));
        expect(cat1Sum, closeTo(1100.49, 0.01));
        expect(cat1Avg, closeTo(366.83, 0.01));
      });

      test('should work with multiple WHERE conditions', () async {
        final complexQuery = Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 1).where('quantity', '>=', 3);

        final count = await complexQuery.count();
        final sum = await Model.query<Sale>(
          () => Sale(),
        ).where('category_id', 1).where('quantity', '>=', 3).sum('amount');

        expect(count, equals(2));
        // Keyboard (75.00, qty 3) + Mouse (25.50, qty 5) = 100.50
        expect(sum, closeTo(100.50, 0.01));
      });

      test('should work with ORDER BY and LIMIT', () async {
        // This tests that aggregates work even with other query clauses
        final topExpensiveCount = await Model.query<Sale>(
          () => Sale(),
        ).where('amount', '>', 100.0).orderByDesc('amount').limit(2).count();

        // Laptop (999.99), Monitor (299.99), Speaker (150.00) = 3 items > 100.0
        expect(topExpensiveCount, equals(3));
      });
    });

    group('Aggregate SQL Generation Tests', () {
      test('should generate correct COUNT SQL using toSql', () {
        final query = Model.query<Sale>(() => Sale()).where('category_id', 1);

        // Test that we can generate SQL - the exact format depends on implementation
        final sql = query.toSql();
        expect(sql, contains('SELECT'));
        expect(sql, contains('FROM sales'));
        expect(sql, contains('WHERE category_id = ?'));
      });

      test('should have proper parameter binding', () {
        final query = Model.query<Sale>(() => Sale()).where('category_id', 1);
        final bindings = query.getBindings();

        expect(bindings, contains(1));
      });
    });
  });
}
