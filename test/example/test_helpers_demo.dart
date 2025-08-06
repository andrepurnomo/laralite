import 'package:flutter_test/flutter_test.dart';
import '../helpers/database_helper.dart';
import '../helpers/model_factory.dart';
import '../fixtures/test_data.dart';
import '../fixtures/test_models.dart';

/// Demonstration of how to use the test helpers and fixtures.
/// This file shows various patterns for creating maintainable tests.

void main() {
  group('Test Helpers Demonstration', () {
    // Example 1: Using DatabaseTestMixin for automatic setup/teardown
    group('Database Test Mixin Example', () {
      // Use the mixin for automatic database setup
      late TestDataSeeds testData;
      
      setUp(() async {
        await DatabaseHelper.initializeTestDatabase();
        await DatabaseHelper.createAllTestTables();
        testData = await DatabaseHelper.seedTestData();
        ModelFactory.resetSequences();
      });

      tearDown(() async {
        await DatabaseHelper.closeTestDatabase();
      });

      test('should access seeded test data', () async {
        // Access pre-seeded data
        expect(testData.users, hasLength(3));
        expect(testData.posts, hasLength(2));
        expect(testData.comments, hasLength(2));
        
        // Use the convenience getters
        expect(testData.primaryUser.name, equals('John Doe'));
        expect(testData.publishedPost.isPublished, isTrue);
        expect(testData.draftPost.isDraft, isTrue);
      });
    });

    // Example 2: Using Factory pattern for flexible test data creation
    group('Factory Pattern Examples', () {
      setUp(() async {
        await DatabaseHelper.setupTestEnvironment();
        ModelFactory.resetSequences();
      });

      tearDown(() async {
        await DatabaseHelper.teardownTestEnvironment();
      });

      test('should create users with factory builder pattern', () async {
        // Basic user creation
        final user = await Factory.user()
            .withName('Test User')
            .withEmail('test@example.com')
            .active()
            .create();

        expect(user.id, isNotNull);
        expect(user.name, equals('Test User'));
        expect(user.isActive, isTrue);
        expect(user.createdAt, isNotNull);
      });

      test('should create specialized users', () async {
        // Create admin user
        final admin = await Factory.user()
            .withName('Admin User')
            .admin()
            .create();

        // Create inactive user
        final inactive = await Factory.user()
            .withName('Inactive User')
            .inactive()
            .create();

        // Create banned user
        final banned = await Factory.user()
            .withName('Banned User')
            .banned()
            .create();

        expect(admin.status, equals('active'));
        expect(admin.roleId, equals(1));
        expect(inactive.isInactive, isTrue);
        expect(banned.isBanned, isTrue);
      });

      test('should create posts with different statuses', () async {
        final author = await Factory.user().create();

        // Create published post
        final publishedPost = await Factory.post()
            .withTitle('Published Article')
            .withAuthor(author.id!)
            .published()
            .popular()
            .create();

        // Create draft post
        final draftPost = await Factory.post()
            .withTitle('Draft Article')
            .withAuthor(author.id!)
            .draft()
            .create();

        expect(publishedPost.isPublic, isTrue);
        expect(publishedPost.viewCount, greaterThan(100));
        expect(draftPost.isDraft, isTrue);
        expect(draftPost.viewCount, equals(0));
      });

      test('should create product variations', () async {
        // Create expensive product
        final expensiveProduct = await Factory.product()
            .withName('Premium Headphones')
            .expensive()
            .inStock()
            .addTag('premium')
            .addTag('electronics')
            .create();

        // Create low stock product
        final lowStockProduct = await Factory.product()
            .withName('USB Cable')
            .cheap()
            .lowStock()
            .create();

        // Create out of stock product
        final outOfStockProduct = await Factory.product()
            .withName('Limited Edition')
            .outOfStock()
            .inactive()
            .create();

        expect(expensiveProduct.price, greaterThan(500));
        expect(expensiveProduct.isInStock, isTrue);
        expect(expensiveProduct.tags, contains('premium'));

        expect(lowStockProduct.isLowStock, isTrue);
        expect(outOfStockProduct.isOutOfStock, isTrue);
        expect(outOfStockProduct.isActive, isFalse);
      });

      test('should create bulk data efficiently', () async {
        // Create multiple users
        final users = await Factory.user().createMany(10);
        expect(users, hasLength(10));

        // Verify unique emails
        final emails = users.map((u) => u.email).toSet();
        expect(emails, hasLength(10));

        // Create posts for each user
        final allPosts = <TestPost>[];
        for (final user in users) {
          final posts = await Factory.post()
              .withAuthor(user.id!)
              .createMany(3);
          allPosts.addAll(posts);
        }

        expect(allPosts, hasLength(30));
      });
    });

    // Example 3: Using complex scenarios
    group('Complex Scenario Examples', () {
      setUp(() async {
        await DatabaseHelper.setupTestEnvironment();
        ModelFactory.resetSequences();
      });

      tearDown(() async {
        await DatabaseHelper.teardownTestEnvironment();
      });

      test('should create complete blog scenario', () async {
        final blogScenario = await Factory.createBlogScenario();

        // Verify the structure
        expect(blogScenario.categories, hasLength(2));
        expect(blogScenario.users, hasLength(2));
        expect(blogScenario.posts, hasLength(2));
        expect(blogScenario.comments, hasLength(2));

        // Test convenience getters
        expect(blogScenario.rootCategory.isRootCategory, isTrue);
        expect(blogScenario.subCategory.isSubCategory, isTrue);
        expect(blogScenario.subCategory.parentId, equals(blogScenario.rootCategory.id));

        // Test post relationships
        expect(blogScenario.publishedPost.authorId, equals(blogScenario.author.id));
        expect(blogScenario.publishedPost.categoryId, equals(blogScenario.subCategory.id));

        // Test comment relationships
        expect(blogScenario.topComment.postId, equals(blogScenario.publishedPost.id));
        expect(blogScenario.replyComment.parentId, equals(blogScenario.topComment.id));
      });

      test('should create e-commerce scenario', () async {
        final ecommerceScenario = await Factory.createEcommerceScenario();

        expect(ecommerceScenario.customer.isActive, isTrue);
        expect(ecommerceScenario.products, hasLength(2));
        expect(ecommerceScenario.orders, hasLength(2));

        // Test product variations
        expect(ecommerceScenario.expensiveProduct.price, greaterThan(ecommerceScenario.cheapProduct.price ?? 0));
        expect(ecommerceScenario.expensiveProduct.isInStock, isTrue);
        expect(ecommerceScenario.cheapProduct.isLowStock, isTrue);

        // Test order statuses
        expect(ecommerceScenario.pendingOrder.isPending, isTrue);
        expect(ecommerceScenario.deliveredOrder.isDelivered, isTrue);
        expect(ecommerceScenario.deliveredOrder.deliveredAt, isNotNull);
      });

      test('should create user with content scenario', () async {
        final userWithContent = await Factory.createUserWithContent(
          postCount: 5,
          commentCount: 8,
        );

        expect(userWithContent.user.isActive, isTrue);
        expect(userWithContent.posts, hasLength(5));
        expect(userWithContent.comments, hasLength(8));

        // Verify all posts belong to the user
        for (final post in userWithContent.posts) {
          expect(post.authorId, equals(userWithContent.user.id));
        }

        // Verify all comments belong to the user
        for (final comment in userWithContent.comments) {
          expect(comment.authorId, equals(userWithContent.user.id));
        }
      });
    });

    // Example 4: Using test data fixtures
    group('Test Data Fixtures Examples', () {
      setUp(() async {
        await DatabaseHelper.setupTestEnvironment();
        ModelFactory.resetSequences();
      });

      tearDown(() async {
        await DatabaseHelper.teardownTestEnvironment();
      });

      test('should use predefined test data', () async {
        // Create user from test data
        final user = TestModelFactory.createUser(TestData.validUserData);
        await user.save();

        expect(user.name, equals('John Doe'));
        expect(user.email, equals('john.doe@example.com'));
        expect(user.isActive, isTrue);

        // Create post from test data
        final post = TestModelFactory.createPost(TestData.validPostData);
        post.authorId = user.id!;
        await post.save();

        expect(post.title, equals('Introduction to Flutter Development'));
        expect(post.isPublic, isTrue);
        expect(post.viewCount, equals(150));
      });

      test('should validate with invalid test data', () {
        // Test validation with invalid data
        final invalidUser = TestModelFactory.createUser(TestData.invalidUserData);
        final validationResult = invalidUser.validate();
        
        expect(validationResult.isValid, isFalse);
        expect(validationResult.errors, isNotEmpty);
      });

      test('should handle bulk data generation', () async {
        // Generate bulk test data
        final bulkUserData = TestData.generateBulkUserData(100);
        expect(bulkUserData, hasLength(100));

        // Verify unique emails
        final emails = bulkUserData.map((data) => data['email']).toSet();
        expect(emails, hasLength(100));

        // Create users from bulk data
        for (int i = 0; i < 10; i++) {
          final user = TestModelFactory.createUser(bulkUserData[i]);
          await user.save();
        }

        final savedUsers = await DatabaseHelper.getTableRowCount('test_users');
        expect(savedUsers, greaterThanOrEqualTo(10));
      });
    });

    // Example 5: Performance testing with helpers
    group('Performance Testing Examples', () {
      setUp(() async {
        await DatabaseHelper.setupTestEnvironment();
        ModelFactory.resetSequences();
      });

      tearDown(() async {
        await DatabaseHelper.teardownTestEnvironment();
      });

      test('should measure bulk insertion performance', () async {
        // Generate test data
        final bulkData = TestData.generateBulkUserData(100);

        // Measure execution time
        final duration = await DatabaseHelper.measureExecutionTime(() async {
          await DatabaseHelper.bulkInsertUsers(bulkData);
        });

        expect(duration, lessThan(Duration(seconds: 5)));

        // Verify all users were inserted
        final count = await DatabaseHelper.getTableRowCount('test_users');
        expect(count, greaterThanOrEqualTo(100));
      });

      test('should test with large dataset', () async {
        // Create a large number of test records
        const recordCount = 1000;
        
        final users = await Factory.user().createMany(recordCount);
        expect(users, hasLength(recordCount));

        // Test query performance on large dataset
        final startTime = DateTime.now();
        final userCount = await DatabaseHelper.getTableRowCount('test_users');
        final queryDuration = DateTime.now().difference(startTime);

        expect(userCount, greaterThanOrEqualTo(recordCount));
        expect(queryDuration, lessThan(Duration(seconds: 2)));
      });
    });
  });
}
