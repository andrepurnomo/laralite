import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';
import '../fixtures/test_models.dart';

/// Database test utilities for setting up, tearing down, and managing test databases.
/// Provides consistent database operations across all test files.

class DatabaseHelper {
  /// Initialize an in-memory database for testing
  static Future<void> initializeTestDatabase() async {
    Database.reset();
    await Database.initialize(databasePath: ':memory:');
  }

  /// Close and clean up the test database
  static Future<void> closeTestDatabase() async {
    await Database.close();
    await Future.delayed(Duration(milliseconds: 50));
  }

  /// Create all test tables required for the test models
  static Future<void> createAllTestTables() async {
    await createUsersTable();
    await createPostsTable();
    await createCommentsTable();
    await createCategoriesTable();
    await createProductsTable();
    await createOrdersTable();
  }

  /// Create the test_users table
  static Future<void> createUsersTable() async {
    await Database.execute('''
      CREATE TABLE test_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        password TEXT,
        status TEXT DEFAULT 'active',
        role_id INTEGER,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    ''');
  }

  /// Create the test_posts table
  static Future<void> createPostsTable() async {
    await Database.execute('''
      CREATE TABLE test_posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        slug TEXT UNIQUE,
        content TEXT,
        excerpt TEXT,
        status TEXT DEFAULT 'draft',
        author_id INTEGER NOT NULL,
        category_id INTEGER,
        view_count INTEGER DEFAULT 0,
        is_published BOOLEAN DEFAULT 0,
        published_at TEXT,
        meta_title TEXT,
        meta_description TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        FOREIGN KEY (author_id) REFERENCES test_users (id),
        FOREIGN KEY (category_id) REFERENCES test_categories (id)
      )
    ''');
  }

  /// Create the test_comments table
  static Future<void> createCommentsTable() async {
    await Database.execute('''
      CREATE TABLE test_comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        author_id INTEGER NOT NULL,
        post_id INTEGER NOT NULL,
        parent_id INTEGER,
        is_approved BOOLEAN DEFAULT 0,
        author_email TEXT,
        author_name TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        FOREIGN KEY (author_id) REFERENCES test_users (id),
        FOREIGN KEY (post_id) REFERENCES test_posts (id),
        FOREIGN KEY (parent_id) REFERENCES test_comments (id)
      )
    ''');
  }

  /// Create the test_categories table
  static Future<void> createCategoriesTable() async {
    await Database.execute('''
      CREATE TABLE test_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        slug TEXT UNIQUE,
        description TEXT,
        parent_id INTEGER,
        sort_order INTEGER DEFAULT 0,
        is_active BOOLEAN DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (parent_id) REFERENCES test_categories (id)
      )
    ''');
  }

  /// Create the test_products table
  static Future<void> createProductsTable() async {
    await Database.execute('''
      CREATE TABLE test_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sku TEXT UNIQUE,
        price REAL,
        cost_price REAL,
        weight REAL,
        stock_quantity INTEGER DEFAULT 0,
        min_stock_level INTEGER DEFAULT 5,
        is_active BOOLEAN DEFAULT 1,
        dimensions TEXT,
        tags TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  /// Create the test_orders table
  static Future<void> createOrdersTable() async {
    await Database.execute('''
      CREATE TABLE test_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT UNIQUE NOT NULL,
        customer_id INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        total_amount REAL,
        shipping_cost REAL DEFAULT 0.0,
        tax_amount REAL DEFAULT 0.0,
        discount_amount REAL DEFAULT 0.0,
        shipping_address TEXT,
        billing_address TEXT,
        notes TEXT,
        processed_at TEXT,
        shipped_at TEXT,
        delivered_at TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES test_users (id)
      )
    ''');
  }

  /// Drop all test tables
  static Future<void> dropAllTestTables() async {
    final tables = [
      'test_orders',
      'test_comments',
      'test_posts',
      'test_products',
      'test_categories',
      'test_users',
    ];

    for (final table in tables) {
      await Database.execute('DROP TABLE IF EXISTS $table');
    }
  }

  /// Clear all data from test tables (faster than recreating)
  static Future<void> clearAllTestTables() async {
    final tables = [
      'test_orders',
      'test_comments',
      'test_posts',
      'test_products',
      'test_categories',
      'test_users',
    ];

    // Disable foreign key constraints temporarily
    await Database.execute('PRAGMA foreign_keys = OFF');

    for (final table in tables) {
      await Database.execute('DELETE FROM $table');
      await Database.execute('DELETE FROM sqlite_sequence WHERE name = ?', [
        table,
      ]);
    }

    // Re-enable foreign key constraints
    await Database.execute('PRAGMA foreign_keys = ON');
  }

  /// Seed test data into the database
  static Future<TestDataSeeds> seedTestData() async {
    // Create users first (referenced by other models)
    final user1 = TestUser();
    user1.name = 'John Doe';
    user1.email = 'john.doe@example.com';
    user1.password = 'password123';
    user1.status = 'active';
    await user1.save();

    final user2 = TestUser();
    user2.name = 'Jane Smith';
    user2.email = 'jane.smith@example.com';
    user2.password = 'password456';
    user2.status = 'active';
    await user2.save();

    final user3 = TestUser();
    user3.name = 'Bob Wilson';
    user3.email = 'bob.wilson@example.com';
    user3.password = 'password789';
    user3.status = 'inactive';
    await user3.save();

    // Create categories
    final category1 = TestCategory();
    category1.name = 'Technology';
    category1.slug = 'technology';
    category1.description = 'Technology related articles';
    category1.isActive = true;
    await category1.save();

    final category2 = TestCategory();
    category2.name = 'Programming';
    category2.slug = 'programming';
    category2.description = 'Programming tutorials and guides';
    category2.parentId = category1.id;
    category2.isActive = true;
    await category2.save();

    // Create posts
    final post1 = TestPost();
    post1.title = 'Introduction to Flutter';
    post1.slug = 'introduction-to-flutter';
    post1.content = 'Flutter is a powerful UI framework...';
    post1.excerpt = 'Learn the basics of Flutter development';
    post1.status = 'published';
    post1.authorId = user1.id;
    post1.categoryId = category2.id;
    post1.isPublished = true;
    post1.viewCount = 100;
    await post1.save();

    final post2 = TestPost();
    post2.title = 'Advanced Dart Programming';
    post2.slug = 'advanced-dart-programming';
    post2.content = 'This article covers advanced Dart concepts...';
    post2.excerpt = 'Deep dive into Dart programming language';
    post2.status = 'draft';
    post2.authorId = user2.id;
    post2.categoryId = category2.id;
    post2.isPublished = false;
    post2.viewCount = 0;
    await post2.save();

    // Create comments
    final comment1 = TestComment();
    comment1.content = 'Great article! Very helpful.';
    comment1.authorId = user2.id!;
    comment1.postId = post1.id!;
    comment1.isApproved = true;
    comment1.authorEmail = user2.email;
    comment1.authorName = user2.name;
    await comment1.save();

    final comment2 = TestComment();
    comment2.content = 'Thanks for the feedback!';
    comment2.authorId = user1.id!;
    comment2.postId = post1.id!;
    comment2.parentId = comment1.id;
    comment2.isApproved = true;
    comment2.authorEmail = user1.email;
    comment2.authorName = user1.name;
    await comment2.save();

    // Create products
    final product1 = TestProduct();
    product1.name = 'Wireless Headphones';
    product1.sku = 'WH-001';
    product1.price = 99.99;
    product1.costPrice = 45.50;
    product1.stockQuantity = 25;
    product1.isActive = true;
    product1.tags = ['electronics', 'audio'];
    await product1.save();

    final product2 = TestProduct();
    product2.name = 'USB Cable';
    product2.sku = 'USB-001';
    product2.price = 15.99;
    product2.costPrice = 8.00;
    product2.stockQuantity = 3; // Low stock
    product2.isActive = true;
    product2.tags = ['accessories'];
    await product2.save();

    // Create order
    final order1 = TestOrder();
    order1.orderNumber = TestOrder.generateOrderNumber();
    order1.customerId = user1.id!;
    order1.status = 'pending';
    order1.totalAmount = 125.98;
    order1.shippingCost = 10.00;
    order1.taxAmount = 15.98;
    order1.shippingAddress = {
      'name': 'John Doe',
      'street': '123 Main St',
      'city': 'New York',
      'state': 'NY',
      'postal_code': '10001',
      'country': 'USA',
    };
    await order1.save();

    return TestDataSeeds(
      users: [user1, user2, user3],
      categories: [category1, category2],
      posts: [post1, post2],
      comments: [comment1, comment2],
      products: [product1, product2],
      orders: [order1],
    );
  }

  /// Execute a test within a transaction (rollback on completion)
  static Future<T> executeInTransaction<T>(
    Future<T> Function() testFunction,
  ) async {
    await Database.execute('BEGIN TRANSACTION');
    try {
      final result = await testFunction();
      await Database.execute('ROLLBACK');
      return result;
    } catch (e) {
      await Database.execute('ROLLBACK');
      rethrow;
    }
  }

  /// Get table row count for verification
  static Future<int> getTableRowCount(String tableName) async {
    final result = await Database.query(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return result.first['count'] as int;
  }

  /// Verify table exists
  static Future<bool> tableExists(String tableName) async {
    final result = await Database.query(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// Get table schema information
  static Future<List<Map<String, dynamic>>> getTableSchema(
    String tableName,
  ) async {
    return await Database.query('PRAGMA table_info($tableName)');
  }

  /// Check if foreign key constraints are enabled
  static Future<bool> areForeignKeysEnabled() async {
    final result = await Database.query('PRAGMA foreign_keys');
    return result.first['foreign_keys'] == 1;
  }

  /// Enable/disable foreign key constraints
  static Future<void> setForeignKeys(bool enabled) async {
    await Database.execute('PRAGMA foreign_keys = ${enabled ? 'ON' : 'OFF'}');
  }

  /// Get database file size (useful for performance testing)
  static Future<int> getDatabaseSize() async {
    final result = await Database.query('PRAGMA page_count');
    final pageCount = result.first['page_count'] as int;

    final pageSizeResult = await Database.query('PRAGMA page_size');
    final pageSize = pageSizeResult.first['page_size'] as int;

    return pageCount * pageSize;
  }

  /// Analyze database performance
  static Future<void> analyzeDatabase() async {
    await Database.execute('ANALYZE');
  }

  /// Vacuum database (reclaim space)
  static Future<void> vacuumDatabase() async {
    await Database.execute('VACUUM');
  }

  /// Helper for performance testing
  static Future<Duration> measureExecutionTime(
    Future<void> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Bulk insert helper for performance testing
  static Future<void> bulkInsertUsers(
    List<Map<String, dynamic>> usersData,
  ) async {
    await Database.execute('BEGIN TRANSACTION');
    try {
      for (final userData in usersData) {
        final user = TestUser();
        user.fromMap(userData);
        await user.save();
      }
      await Database.execute('COMMIT');
    } catch (e) {
      await Database.execute('ROLLBACK');
      rethrow;
    }
  }

  /// Complete test setup (initialize + create tables + seed data)
  static Future<TestDataSeeds> setupTestEnvironment() async {
    await initializeTestDatabase();
    await createAllTestTables();
    return await seedTestData();
  }

  /// Complete test teardown
  static Future<void> teardownTestEnvironment() async {
    await closeTestDatabase();
  }
}

/// Container for seeded test data references
class TestDataSeeds {
  final List<TestUser> users;
  final List<TestCategory> categories;
  final List<TestPost> posts;
  final List<TestComment> comments;
  final List<TestProduct> products;
  final List<TestOrder> orders;

  TestDataSeeds({
    required this.users,
    required this.categories,
    required this.posts,
    required this.comments,
    required this.products,
    required this.orders,
  });

  /// Get the first user (primary test user)
  TestUser get primaryUser => users.first;

  /// Get the second user (secondary test user)
  TestUser get secondaryUser => users[1];

  /// Get the first category (root category)
  TestCategory get primaryCategory => categories.first;

  /// Get the second category (sub category)
  TestCategory get subCategory => categories[1];

  /// Get the first post (published post)
  TestPost get publishedPost => posts.first;

  /// Get the second post (draft post)
  TestPost get draftPost => posts[1];

  /// Get the first comment (top-level comment)
  TestComment get topLevelComment => comments.first;

  /// Get the second comment (reply comment)
  TestComment get replyComment => comments[1];

  /// Get the first product (in-stock product)
  TestProduct get inStockProduct => products.first;

  /// Get the second product (low-stock product)
  TestProduct get lowStockProduct => products[1];

  /// Get the first order (pending order)
  TestOrder get pendingOrder => orders.first;
}

/// Test mixins for common setup/teardown patterns
mixin DatabaseTestMixin {
  /// Standard test setup
  void setUpDatabaseTest() {
    setUp(() async {
      await DatabaseHelper.initializeTestDatabase();
      await DatabaseHelper.createAllTestTables();
    });

    tearDown(() async {
      await DatabaseHelper.closeTestDatabase();
    });
  }

  /// Test setup with seeded data
  late TestDataSeeds testData;

  void setUpDatabaseTestWithData() {
    setUp(() async {
      testData = await DatabaseHelper.setupTestEnvironment();
    });

    tearDown(() async {
      await DatabaseHelper.teardownTestEnvironment();
    });
  }

  /// Test setup with clean database between tests
  void setUpCleanDatabaseTest() {
    setUp(() async {
      await DatabaseHelper.initializeTestDatabase();
      await DatabaseHelper.createAllTestTables();
    });

    tearDown(() async {
      await DatabaseHelper.clearAllTestTables();
    });

    tearDownAll(() async {
      await DatabaseHelper.closeTestDatabase();
    });
  }
}
