import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_database.dart';
import 'models/user.dart';
import 'models/post.dart';
import 'models/comment.dart';

/// Comprehensive integration test following BEST_PRACTICES.md
void main() {
  group('🧪 Laralite Integration Test Suite', () {
    // Setup and teardown for each test
    setUp(() async {
      await TestDatabase.setup();
    });

    tearDown(() async {
      await TestDatabase.tearDown();
    });

    group('🗄️ Database Setup & Schema', () {
      test('should initialize database successfully', () async {
        expect(TestDatabase.tableExists('users'), completion(true));
        expect(TestDatabase.tableExists('posts'), completion(true));
        expect(TestDatabase.tableExists('comments'), completion(true));

        print('✅ Database tables created successfully');
      });

      test('should have correct table schema', () async {
        final userSchema = await TestDatabase.getTableInfo('users');
        final postSchema = await TestDatabase.getTableInfo('posts');

        // Verify users table columns
        final userColumns = userSchema.map((col) => col['name']).toList();
        expect(userColumns, contains('id'));
        expect(userColumns, contains('name'));
        expect(userColumns, contains('email'));
        expect(userColumns, contains('age'));
        expect(userColumns, contains('is_active'));
        expect(userColumns, contains('created_at'));
        expect(userColumns, contains('updated_at'));

        // Verify posts table columns
        final postColumns = postSchema.map((col) => col['name']).toList();
        expect(postColumns, contains('id'));
        expect(postColumns, contains('title'));
        expect(postColumns, contains('content'));
        expect(postColumns, contains('user_id'));
        expect(postColumns, contains('published_at'));
        expect(postColumns, contains('deleted_at')); // Soft deletes

        print('✅ Table schemas are correct');
      });
    });

    group('👤 User Model Tests', () {
      test('should create user with all fields', () async {
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com'
          ..age = 30
          ..isActive = true;

        await user.save();

        expect(user.exists, true);
        expect(user.id, isNotNull);
        expect(user.name, 'John Doe');
        expect(user.email, 'john@example.com');
        expect(user.age, 30);
        expect(user.isActive, true);
        expect(user.createdAt, isNotNull);
        expect(user.updatedAt, isNotNull);

        print('✅ User created with all fields');
      });

      test('should validate required fields', () async {
        final user = User(); // Missing required fields

        final validation = user.validate();

        expect(validation.isValid, false);
        expect(validation.errors.length, greaterThan(0));

        print('✅ User validation works correctly');
      });

      test('should validate email format', () async {
        final user = User()
          ..name = 'John'
          ..email = 'invalid-email'
          ..age = 25;

        final validation = user.validate();

        expect(validation.isValid, false);
        expect(validation.errors.any((error) => error.contains('email')), true);

        print('✅ Email validation works correctly');
      });

      test('should validate age constraints', () async {
        final youngUser = User()
          ..name = 'Too Young'
          ..email = 'young@example.com'
          ..age = 5; // Below minimum age of 13

        final validation = youngUser.validate();

        expect(validation.isValid, false);

        print('✅ Age validation works correctly');
      });

      test('should find user by email', () async {
        // Create test user
        final user = User()
          ..name = 'John Doe'
          ..email = 'findme@example.com'
          ..age = 25;
        await user.save();

        // Find by email
        final foundUser = await User()
            .query()
            .where('email', 'findme@example.com')
            .first();

        expect(foundUser, isNotNull);
        expect(foundUser!.name, 'John Doe');
        expect(foundUser.email, 'findme@example.com');

        print('✅ User found by email successfully');
      });

      test('should test custom methods', () async {
        final adultUser = User()
          ..name = 'Adult User'
          ..email = 'adult@example.com'
          ..age = 25;

        final minorUser = User()
          ..name = 'Minor User'
          ..email = 'minor@example.com'
          ..age = 16;

        expect(adultUser.isAdult, true);
        expect(minorUser.isAdult, false);
        expect(adultUser.displayName, 'Adult User');

        print('✅ Custom methods work correctly');
      });
    });

    group('📝 Post Model Tests', () {
      test('should create post with relationships', () async {
        // Create user first
        final user = User()
          ..name = 'Author'
          ..email = 'author@example.com'
          ..age = 30;
        await user.save();

        // Create post
        final post = Post()
          ..title = 'Test Post'
          ..content = 'This is test content'
          ..userId = user.id!;
        await post.save();

        expect(post.exists, true);
        expect(post.id, isNotNull);
        expect(post.title, 'Test Post');
        expect(post.userId!, user.id);
        expect(post.isDraft, true); // publishedAt is null

        print('✅ Post created with relationships');
      });

      test('should publish post', () async {
        final user = User()
          ..name = 'Author'
          ..email = 'author@example.com';
        await user.save();

        final post = Post()
          ..title = 'Draft Post'
          ..content = 'Draft content'
          ..userId = user.id!;
        await post.save();

        expect(post.isDraft, true);

        // Publish the post
        await post.publish();

        expect(post.isPublished, true);
        expect(post.publishedAt, isNotNull);

        print('✅ Post publishing works correctly');
      });

      test('should validate post title length', () async {
        final post = Post()
          ..title =
              'Hi' // Too short (minimum 5 characters)
          ..content = 'Content';

        final validation = post.validate();

        expect(validation.isValid, false);

        print('✅ Post title validation works');
      });
    });

    group('💬 Comment Model Tests', () {
      test('should create comment with relationships', () async {
        // Setup user and post
        final user = User()
          ..name = 'Commenter'
          ..email = 'commenter@example.com';
        await user.save();

        final author = User()
          ..name = 'Author'
          ..email = 'author@example.com';
        await author.save();

        final post = Post()
          ..title = 'Post to Comment'
          ..content = 'Post content'
          ..userId = author.id!;
        await post.save();

        // Create comment
        final comment = Comment()
          ..content = 'Great post!'
          ..userId = user.id!
          ..postId = post.id!
          ..approved = false;
        await comment.save();

        expect(comment.exists, true);
        expect(comment.content, 'Great post!');
        expect(comment.isPending, true);
        expect(comment.isApproved, false);

        print('✅ Comment created with relationships');
      });

      test('should approve and reject comments', () async {
        final user = User()
          ..name = 'User'
          ..email = 'user@example.com';
        await user.save();

        final author = User()
          ..name = 'Author'
          ..email = 'author@example.com';
        await author.save();

        final post = Post()
          ..title = 'Post'
          ..content = 'Content'
          ..userId = author.id!;
        await post.save();

        final comment = Comment()
          ..content = 'Test comment'
          ..userId = user.id!
          ..postId = post.id!;
        await comment.save();

        // Test approval
        await comment.approve();
        expect(comment.isApproved, true);

        // Test rejection
        await comment.reject();
        expect(comment.isPending, true);

        print('✅ Comment approval/rejection works');
      });
    });

    group('🔗 Relationship Tests', () {
      test('should load user posts relationship', () async {
        await TestDatabase.seed();

        final user = await User()
            .query()
            .where('email', 'john@example.com')
            .first();

        expect(user, isNotNull);

        // Load posts relationship
        final posts = await user!.posts().get();

        expect(posts.length, greaterThan(0));
        expect(posts.every((post) => post.userId! == user.id), true);

        print('✅ User posts relationship works');
      });

      test('should load post user relationship', () async {
        await TestDatabase.seed();

        final post = await Post().query().where('title', 'First Post').first();

        expect(post, isNotNull);

        // Load user relationship
        final user = await post!.user().get();

        expect(user, isNotNull);
        expect(user!.id, post.userId!);

        print('✅ Post user relationship works');
      });

      test('should load post comments relationship', () async {
        await TestDatabase.seed();

        final post = await Post().query().where('title', 'First Post').first();

        expect(post, isNotNull);

        // Load comments relationship
        final comments = await post!.comments().get();

        expect(comments.length, greaterThan(0));
        expect(comments.every((comment) => comment.postId == post.id!), true);

        print('✅ Post comments relationship works');
      });
    });

    group('🔍 Query Builder Tests', () {
      test('should perform complex queries', () async {
        await TestDatabase.seed();

        // Test WHERE conditions
        final activeUsers = await User().query().where('is_active', true).get();

        expect(activeUsers.isNotEmpty, true);
        expect(activeUsers.every((user) => user.isActive == true), true);

        // Test WHERE with age
        final adults = await User().query().where('age', '>=', 18).get();

        expect(adults.isNotEmpty, true);
        expect(adults.every((user) => user.age! >= 18), true);

        // Test multiple conditions
        final activeAdults = await User()
            .query()
            .where('is_active', true)
            .where('age', '>=', 18)
            .get();

        expect(activeAdults.isNotEmpty, true);

        print('✅ Complex queries work correctly');
      });

      test('should perform aggregation queries', () async {
        await TestDatabase.seed();

        // Count users
        final userCount = await User().query().count();
        expect(userCount, greaterThan(0));

        // Average age
        final avgAge = await User().query().avg('age');
        expect(avgAge, isNotNull);

        // Max age
        final maxAge = await User().query().max('age');
        expect(maxAge, isNotNull);

        print('✅ Aggregation queries work correctly');
      });

      test('should order and limit results', () async {
        await TestDatabase.seed();

        final users = await User()
            .query()
            .orderBy('name', 'ASC')
            .limit(2)
            .get();

        expect(users.length, lessThanOrEqualTo(2));

        // Check ordering
        if (users.length > 1) {
          expect(users[0].name!.compareTo(users[1].name!) <= 0, true);
        }

        print('✅ Ordering and limiting work correctly');
      });
    });

    group('🗑️ Soft Deletes Tests', () {
      test('should soft delete posts', () async {
        final user = User()
          ..name = 'User'
          ..email = 'user@example.com';
        await user.save();

        final post = Post()
          ..title = 'Post to Delete'
          ..content = 'Content'
          ..userId = user.id!;
        await post.save();

        // Soft delete
        await post.delete();

        // Should not appear in normal queries
        final foundPost = await Post().query().where('id', post.id!).first();

        expect(foundPost, isNull);

        // Should appear with withTrashed
        final trashedPost = await Post()
            .query()
            .withTrashed()
            .where('id', post.id!)
            .first();

        expect(trashedPost, isNotNull);

        print('✅ Soft deletes work correctly');
      });
    });

    group('✅ Validation Tests', () {
      test('should validate all field types', () async {
        // Test string validation
        final user = User()
          ..name =
              'A' // Too short
          ..email = 'invalid-email'
          ..age = 150; // Too high

        final validation = user.validate();
        expect(validation.isValid, false);

        // Test valid user
        final validUser = User()
          ..name = 'Valid User'
          ..email = 'valid@example.com'
          ..age = 25;

        final validValidation = validUser.validate();
        expect(validValidation.isValid, true);

        print('✅ Field validation works correctly');
      });
    });

    group('📊 Performance Tests', () {
      test('should handle bulk operations', () async {
        final stopwatch = Stopwatch()..start();

        // Create multiple users
        for (int i = 0; i < 50; i++) {
          final user = User()
            ..name = 'User $i'
            ..email = 'user$i@example.com'
            ..age = 20 + (i % 50);
          await user.save();
        }

        stopwatch.stop();
        print('⏱️ Created 50 users in ${stopwatch.elapsedMilliseconds}ms');

        // Query performance
        stopwatch.reset();
        stopwatch.start();

        final users = await User().query().get();

        stopwatch.stop();
        print(
          '⏱️ Queried ${users.length} users in ${stopwatch.elapsedMilliseconds}ms',
        );

        expect(users.length, 50);

        print('✅ Bulk operations performance acceptable');
      });
    });
  });
}
