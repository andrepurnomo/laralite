import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';
import '../helpers/database_helper.dart';
import '../helpers/model_factory.dart';
import '../fixtures/test_models.dart';

// Test model with only soft deletes
class SoftDeletedPost extends Model<SoftDeletedPost>
    with SoftDeletesMixin<SoftDeletedPost> {
  final _id = AutoIncrementField();
  final _title = StringField(required: true);
  final _content = TextField();
  final _authorId = IntField();

  @override
  String get table => 'soft_deleted_posts';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('title', _title);
    registerField('content', _content);
    registerField('author_id', _authorId);
    super.registerFields(); // This will add deleted_at field
  }

  // Convenience getters/setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get title => _title.value;
  set title(String? value) => _title.value = value;

  String? get content => _content.value;
  set content(String? value) => _content.value = value;

  int? get authorId => _authorId.value;
  set authorId(int? value) => _authorId.value = value;

  DateTime? get deletedAt => getValue<DateTime?>(deletedAtColumn)?.toLocal();
}

// Test model with only timestamps
class TimestampedArticle extends Model<TimestampedArticle>
    with TimestampsMixin<TimestampedArticle> {
  final _id = AutoIncrementField();
  final _title = StringField(required: true);
  final _slug = StringField(unique: true);

  @override
  String get table => 'timestamped_articles';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('title', _title);
    registerField('slug', _slug);
    super.registerFields(); // This will add timestamp fields
  }

  // Convenience getters/setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get title => _title.value;
  set title(String? value) => _title.value = value;

  String? get slug => _slug.value;
  set slug(String? value) => _slug.value = value;
}

// Test model with both timestamps and soft deletes
class FullFeatureUser extends Model<FullFeatureUser>
    with TimestampsAndSoftDeletesMixin<FullFeatureUser> {
  final _id = AutoIncrementField();
  final _name = StringField(required: true);
  final _email = EmailField(unique: true);
  final _status = StringField(defaultValue: 'active');

  @override
  String get table => 'full_feature_users';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('email', _email);
    registerField('status', _status);
    super.registerFields(); // This will add timestamp and soft delete fields
  }

  // Convenience getters/setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get name => _name.value;
  set name(String? value) => _name.value = value;

  String? get email => _email.value;
  set email(String? value) => _email.value = value;

  String? get status => _status.value;
  set status(String? value) => _status.value = value;
}

void main() {
  group('Soft Deletes and Timestamps Tests', () {
    late TestDataSeeds testData;

    setUp(() async {
      // Use DatabaseHelper for setup
      await DatabaseHelper.initializeTestDatabase();

      // Create legacy test tables for backward compatibility
      await Database.execute('''
        CREATE TABLE soft_deleted_posts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT,
          author_id INTEGER,
          deleted_at TEXT
        )
      ''');

      await Database.execute('''
        CREATE TABLE timestamped_articles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          slug TEXT UNIQUE,
          created_at TEXT,
          updated_at TEXT
        )
      ''');

      await Database.execute('''
        CREATE TABLE full_feature_users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE,
          status TEXT DEFAULT 'active',
          created_at TEXT,
          updated_at TEXT,
          deleted_at TEXT
        )
      ''');

      // Create new test tables and seed data
      await DatabaseHelper.createAllTestTables();
      testData = await DatabaseHelper.seedTestData();

      // Reset factory sequences for consistent test data
      ModelFactory.resetSequences();
    });

    tearDown(() async {
      await DatabaseHelper.closeTestDatabase();
    });

    group('SoftDeletesMixin Tests', () {
      test('should register deleted_at field automatically', () {
        final post = SoftDeletedPost();

        expect(post.fields.containsKey('deleted_at'), isTrue);
        expect(post.fields['deleted_at'], isA<TimestampField>());
        expect(post.softDeletes, isTrue);
      });

      test('should not be trashed by default', () {
        final post = SoftDeletedPost();

        expect(post.isTrashed, isFalse);
        expect(post.isNotTrashed, isTrue);
        expect(post.deletedAt, isNull);
      });

      test('should soft delete when delete() is called', () async {
        final post = SoftDeletedPost();
        post.title = 'Test Post';
        post.content = 'Test content';

        await post.save();
        expect(post.exists, isTrue);
        expect(post.isTrashed, isFalse);

        final deleteResult = await post.delete();

        expect(deleteResult, isTrue);
        expect(post.isTrashed, isTrue);
        expect(post.deletedAt, isNotNull);
        expect(post.exists, isTrue); // Still exists in DB, just soft deleted
      });

      test('should not delete already trashed model', () async {
        final post = SoftDeletedPost();
        post.title = 'Test Post';
        await post.save();

        // First delete
        await post.delete();
        expect(post.isTrashed, isTrue);

        // Second delete should return false
        final secondDelete = await post.delete();
        expect(secondDelete, isFalse);
      });

      test('should restore soft deleted model', () async {
        final post = SoftDeletedPost();
        post.title = 'Test Post';
        await post.save();

        // Soft delete
        await post.delete();
        expect(post.isTrashed, isTrue);

        // Restore
        final restoreResult = await post.restore();

        expect(restoreResult, isTrue);
        expect(post.isTrashed, isFalse);
        expect(post.deletedAt, isNull);
        expect(post.exists, isTrue);
      });

      test('should not restore non-trashed model', () async {
        final post = SoftDeletedPost();
        post.title = 'Test Post';
        await post.save();

        expect(post.isTrashed, isFalse);

        final restoreResult = await post.restore();
        expect(restoreResult, isFalse);
      });

      test('should force delete permanently', () async {
        final post = SoftDeletedPost();
        post.title = 'Test Post';
        await post.save();

        final forceDeleteResult = await post.forceDelete();

        expect(forceDeleteResult, isTrue);
        expect(post.exists, isFalse);
        expect(post.id, isNull);

        // Verify it's actually gone from database
        final found = await Model.find<SoftDeletedPost>(
          1,
          () => SoftDeletedPost(),
        );
        expect(found, isNull);
      });

      test('should force delete even if already soft deleted', () async {
        final post = SoftDeletedPost();
        post.title = 'Test Post';
        await post.save();

        // Soft delete first
        await post.delete();
        expect(post.isTrashed, isTrue);

        // Force delete
        final forceDeleteResult = await post.forceDelete();

        expect(forceDeleteResult, isTrue);
        expect(post.exists, isFalse);
      });
    });

    group('TimestampsMixin Tests', () {
      test('should register timestamp fields automatically', () {
        final article = TimestampedArticle();

        expect(article.fields.containsKey('created_at'), isTrue);
        expect(article.fields.containsKey('updated_at'), isTrue);
        expect(article.timestamps, isTrue);
      });

      test('should auto-set timestamps on save', () async {
        final article = TimestampedArticle();
        article.title = 'Test Article';
        article.slug = 'test-article';

        expect(article.createdAt, isNull);
        expect(article.updatedAt, isNull);

        await article.save();

        expect(article.createdAt, isNotNull);
        expect(article.updatedAt, isNotNull);
        expect(
          article.createdAt!.isAfter(
            DateTime.now().subtract(Duration(seconds: 5)),
          ),
          isTrue,
        );
        expect(
          article.updatedAt!.isAfter(
            DateTime.now().subtract(Duration(seconds: 5)),
          ),
          isTrue,
        );
      });

      test('should update timestamp on subsequent saves', () async {
        final article = TimestampedArticle();
        article.title = 'Test Article';
        article.slug = 'test-article';

        await article.save();
        final originalCreatedAt = article.createdAt;
        final originalUpdatedAt = article.updatedAt;

        await Future.delayed(Duration(milliseconds: 10));

        article.title = 'Updated Article';
        await article.save();

        expect(
          article.createdAt,
          equals(originalCreatedAt),
        ); // Should not change
        expect(
          article.updatedAt!.isAfter(originalUpdatedAt!),
          isTrue,
        ); // Should update
      });

      test('should handle manual timestamp setting', () async {
        final article = TimestampedArticle();
        final customTime = DateTime(2023, 12, 25, 10, 30);

        article.createdAt = customTime;
        article.updatedAt = customTime;

        expect(article.createdAt, equals(customTime));
        expect(article.updatedAt, equals(customTime));
      });

      test('should touch timestamp manually', () async {
        final article = TimestampedArticle();
        article.title = 'Test Article';
        await article.save();

        final originalUpdatedAt = article.updatedAt;
        await Future.delayed(Duration(milliseconds: 10));

        article.touch();
        expect(article.updatedAt!.isAfter(originalUpdatedAt!), isTrue);
      });

      test('should touch and save', () async {
        final article = TimestampedArticle();
        article.title = 'Test Article';
        await article.save();

        final originalUpdatedAt = article.updatedAt;
        await Future.delayed(Duration(milliseconds: 10));

        final touchResult = await article.touchAndSave();

        expect(touchResult, isTrue);
        expect(article.updatedAt!.isAfter(originalUpdatedAt!), isTrue);
      });
    });

    group('TimestampsAndSoftDeletesMixin Tests', () {
      test('should register all required fields', () {
        final user = FullFeatureUser();

        expect(user.fields.containsKey('created_at'), isTrue);
        expect(user.fields.containsKey('updated_at'), isTrue);
        expect(user.fields.containsKey('deleted_at'), isTrue);
        expect(user.timestamps, isTrue);
        expect(user.softDeletes, isTrue);
      });

      test('should handle timestamps and soft delete together', () async {
        final user = FullFeatureUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';

        await user.save();

        expect(user.createdAt, isNotNull);
        expect(user.updatedAt, isNotNull);
        expect(user.deletedAt, isNull);
        expect(user.isTrashed, isFalse);
      });

      test('should update timestamp when soft deleting', () async {
        final user = FullFeatureUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';

        await user.save();
        final originalUpdatedAt = user.updatedAt;

        await Future.delayed(Duration(milliseconds: 10));
        await user.delete();

        expect(user.isTrashed, isTrue);
        expect(user.deletedAt, isNotNull);
        expect(user.updatedAt!.isAfter(originalUpdatedAt!), isTrue);
      });

      test('should update timestamp when restoring', () async {
        final user = FullFeatureUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';

        await user.save();
        await user.delete();

        final deleteUpdatedAt = user.updatedAt;
        await Future.delayed(Duration(milliseconds: 10));

        await user.restore();

        expect(user.isTrashed, isFalse);
        expect(user.deletedAt, isNull);
        expect(user.updatedAt!.isAfter(deleteUpdatedAt!), isTrue);
      });

      test('should handle all three timestamps correctly', () async {
        final user = FullFeatureUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';

        // Create
        await user.save();
        final createdAt = user.createdAt;
        final firstUpdatedAt = user.updatedAt;

        expect(createdAt, isNotNull);
        expect(firstUpdatedAt, isNotNull);
        expect(user.deletedAt, isNull);

        await Future.delayed(Duration(milliseconds: 10));

        // Update
        user.name = 'Jane Doe';
        await user.save();
        final secondUpdatedAt = user.updatedAt;

        expect(user.createdAt, equals(createdAt)); // Should not change
        expect(secondUpdatedAt!.isAfter(firstUpdatedAt!), isTrue);
        expect(user.deletedAt, isNull);

        await Future.delayed(Duration(milliseconds: 10));

        // Soft Delete
        await user.delete();
        final thirdUpdatedAt = user.updatedAt;

        expect(user.createdAt, equals(createdAt)); // Should not change
        expect(thirdUpdatedAt!.isAfter(secondUpdatedAt), isTrue);
        expect(user.deletedAt, isNotNull);
        expect(user.isTrashed, isTrue);

        await Future.delayed(Duration(milliseconds: 10));

        // Restore
        await user.restore();
        final fourthUpdatedAt = user.updatedAt;

        expect(user.createdAt, equals(createdAt)); // Should not change
        expect(fourthUpdatedAt!.isAfter(thirdUpdatedAt), isTrue);
        expect(user.deletedAt, isNull);
        expect(user.isTrashed, isFalse);
      });
    });

    group('Bulk Operations Tests', () {
      test('should restore many soft deleted models', () async {
        // Create multiple users
        final user1 = FullFeatureUser();
        user1.name = 'User 1';
        user1.email = 'user1@example.com';
        await user1.save();

        final user2 = FullFeatureUser();
        user2.name = 'User 2';
        user2.email = 'user2@example.com';
        await user2.save();

        final user3 = FullFeatureUser();
        user3.name = 'User 3';
        user3.email = 'user3@example.com';
        await user3.save();

        // Soft delete all
        await user1.delete();
        await user2.delete();
        await user3.delete();

        // Restore all
        final restoredCount =
            await SoftDeletesMixin.restoreMany<FullFeatureUser>(
              () => FullFeatureUser(),
            );

        expect(restoredCount, equals(3));

        // Verify all are restored in database
        final allUsers = await Model.all<FullFeatureUser>(
          () => FullFeatureUser(),
        );
        expect(allUsers, hasLength(3));
        expect(allUsers.every((u) => u.isNotTrashed), isTrue);
      });

      test('should restore many with conditions', () async {
        // Create users with different status
        final user1 = FullFeatureUser();
        user1.name = 'Active User';
        user1.email = 'active@example.com';
        user1.status = 'active';
        await user1.save();

        final user2 = FullFeatureUser();
        user2.name = 'Inactive User';
        user2.email = 'inactive@example.com';
        user2.status = 'inactive';
        await user2.save();

        // Soft delete both
        await user1.delete();
        await user2.delete();

        // Restore only active users
        final restoredCount =
            await SoftDeletesMixin.restoreMany<FullFeatureUser>(
              () => FullFeatureUser(),
              where: {'status': 'active'},
            );

        expect(restoredCount, equals(1));

        // Verify only active user is restored
        final activeUser = await Model.find<FullFeatureUser>(
          user1.id!,
          () => FullFeatureUser(),
        );
        final inactiveUser = await Model.find<FullFeatureUser>(
          user2.id!,
          () => FullFeatureUser(),
        );

        expect(activeUser?.isNotTrashed, isTrue);
        expect(inactiveUser?.isTrashed, isTrue);
      });

      test('should force delete many models', () async {
        // Create multiple users
        final user1 = FullFeatureUser();
        user1.name = 'User 1';
        user1.email = 'user1@example.com';
        await user1.save();

        final user2 = FullFeatureUser();
        user2.name = 'User 2';
        user2.email = 'user2@example.com';
        await user2.save();

        // Force delete all
        final deletedCount =
            await SoftDeletesMixin.forceDeleteMany<FullFeatureUser>(
              () => FullFeatureUser(),
            );

        expect(deletedCount, equals(2));

        // Verify all are gone from database
        final allUsers = await Model.all<FullFeatureUser>(
          () => FullFeatureUser(),
        );
        expect(allUsers, isEmpty);
      });

      test('should force delete many with conditions', () async {
        // Create users with different status
        final user1 = FullFeatureUser();
        user1.name = 'Active User';
        user1.email = 'active@example.com';
        user1.status = 'active';
        await user1.save();

        final user2 = FullFeatureUser();
        user2.name = 'Inactive User';
        user2.email = 'inactive@example.com';
        user2.status = 'inactive';
        await user2.save();

        // Force delete only inactive users
        final deletedCount =
            await SoftDeletesMixin.forceDeleteMany<FullFeatureUser>(
              () => FullFeatureUser(),
              where: {'status': 'inactive'},
            );

        expect(deletedCount, equals(1));

        // Verify only inactive user is deleted
        final activeUser = await Model.find<FullFeatureUser>(
          user1.id!,
          () => FullFeatureUser(),
        );
        final inactiveUser = await Model.find<FullFeatureUser>(
          user2.id!,
          () => FullFeatureUser(),
        );

        expect(activeUser, isNotNull);
        expect(inactiveUser, isNull);
      });
    });

    group('Query Scope Tests', () {
      test('should exclude soft deleted models by default', () async {
        // Create and soft delete a user
        final user = FullFeatureUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        await user.save();
        await user.delete();

        // Model.all() should now automatically exclude soft deleted records
        final allUsers = await Model.all<FullFeatureUser>(
          () => FullFeatureUser(),
        );
        expect(
          allUsers,
          hasLength(0),
        ); // Should be empty since user was soft deleted

        // Verify the user still exists with withTrashed
        final withTrashedUsers =
            await SoftDeletesMixin.withTrashed<FullFeatureUser>(
              () => FullFeatureUser(),
            ).get();
        expect(withTrashedUsers, hasLength(1));
        expect(withTrashedUsers.first.isTrashed, isTrue);

        // Additional verification - check the deleted_at field is set
        expect(withTrashedUsers.first.deletedAt, isNotNull);
        expect(
          withTrashedUsers.first.deletedAt!.isBefore(
            DateTime.now().add(Duration(seconds: 1)),
          ),
          isTrue,
        );
        expect(
          withTrashedUsers.first.deletedAt!.isAfter(
            DateTime.now().subtract(Duration(seconds: 10)),
          ),
          isTrue,
        );
      });

      test('should include only active models with all()', () async {
        // Create users - one normal, one soft deleted
        final user1 = FullFeatureUser();
        user1.name = 'Active User';
        user1.email = 'active@example.com';
        await user1.save();

        final user2 = FullFeatureUser();
        user2.name = 'Deleted User';
        user2.email = 'deleted@example.com';
        await user2.save();
        await user2.delete();

        // all() should only return active models
        final allUsers = await Model.all<FullFeatureUser>(
          () => FullFeatureUser(),
        );
        expect(allUsers, hasLength(1));
        expect(allUsers.first.name, equals('Active User'));
        expect(allUsers.first.isTrashed, isFalse);
      });

      test('should include trashed models with withTrashed scope', () async {
        // Create users - one normal, one soft deleted
        final user1 = FullFeatureUser();
        user1.name = 'Active User';
        user1.email = 'active@example.com';
        await user1.save();

        final user2 = FullFeatureUser();
        user2.name = 'Deleted User';
        user2.email = 'deleted@example.com';
        await user2.save();
        await user2.delete();

        // Query with trashed
        final query = SoftDeletesMixin.withTrashed<FullFeatureUser>(
          () => FullFeatureUser(),
        );
        final allUsers = await query.get();

        expect(allUsers, hasLength(2));

        final names = allUsers.map((u) => u.name).toList();
        expect(names, contains('Active User'));
        expect(names, contains('Deleted User'));
      });

      test(
        'should only include trashed models with onlyTrashed scope',
        () async {
          // Create users - one normal, one soft deleted
          final user1 = FullFeatureUser();
          user1.name = 'Active User';
          user1.email = 'active@example.com';
          await user1.save();

          final user2 = FullFeatureUser();
          user2.name = 'Deleted User';
          user2.email = 'deleted@example.com';
          await user2.save();
          await user2.delete();

          // Query only trashed
          final query = SoftDeletesMixin.onlyTrashed<FullFeatureUser>(
            () => FullFeatureUser(),
          );
          final trashedUsers = await query.get();

          expect(trashedUsers, hasLength(1));
          expect(trashedUsers.first.name, equals('Deleted User'));
          expect(trashedUsers.first.isTrashed, isTrue);
        },
      );
    });

    group('Edge Cases and Error Handling Tests', () {
      test(
        'should handle model without soft deletes for bulk operations',
        () async {
          final restoredCount =
              await SoftDeletesMixin.restoreMany<TimestampedArticle>(
                () => TimestampedArticle(),
              );

          expect(restoredCount, equals(0));
        },
      );

      test('should handle UTC time conversion correctly', () async {
        final user = FullFeatureUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';

        await user.save();

        // Timestamps should be stored as UTC but returned as local time
        expect(user.createdAt, isNotNull);
        expect(user.updatedAt, isNotNull);

        // Verify they're reasonable times (within last few seconds)
        final now = DateTime.now();
        expect(user.createdAt!.isBefore(now.add(Duration(seconds: 5))), isTrue);
        expect(
          user.createdAt!.isAfter(now.subtract(Duration(seconds: 10))),
          isTrue,
        );
      });

      test('should handle null timestamp values', () {
        final user = FullFeatureUser();

        user.createdAt = null;
        user.updatedAt = null;
        user.deletedAt = null;

        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
        expect(user.deletedAt, isNull);
        expect(user.isTrashed, isFalse);
      });

      test('should properly serialize timestamps in toMap', () async {
        final user = FullFeatureUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';

        await user.save();
        await user.delete();

        final map = user.toMap();

        expect(map['created_at'], isNotNull);
        expect(map['updated_at'], isNotNull);
        expect(map['deleted_at'], isNotNull);

        // Should be ISO 8601 strings
        expect(
          map['created_at'],
          matches(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'),
        );
        expect(
          map['updated_at'],
          matches(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'),
        );
        expect(
          map['deleted_at'],
          matches(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'),
        );
      });

      test('should properly deserialize timestamps from map', () {
        final user = FullFeatureUser();

        final map = {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'status': 'active',
          'created_at': '2023-12-25T10:30:00.000Z',
          'updated_at': '2023-12-25T11:30:00.000Z',
          'deleted_at': '2023-12-25T12:30:00.000Z',
        };

        user.fromMap(map);

        expect(user.createdAt, isNotNull);
        expect(user.updatedAt, isNotNull);
        expect(user.deletedAt, isNotNull);
        expect(user.isTrashed, isTrue);

        // Should be parsed correctly (times are converted to local timezone)
        // Just verify the timestamps are in correct order (created < updated < deleted)
        expect(user.createdAt!.isBefore(user.updatedAt!), isTrue);
        expect(user.updatedAt!.isBefore(user.deletedAt!), isTrue);
      });
    });

    group('Test Helper Demonstrations', () {
      test(
        'should use Factory for creating test users with soft deletes',
        () async {
          // Create users using the factory pattern
          final activeUser = await Factory.user()
              .withName('Active User')
              .withEmail('active@example.com')
              .active()
              .create();

          final inactiveUser = await Factory.user()
              .withName('Inactive User')
              .withEmail('inactive@example.com')
              .inactive()
              .create();

          expect(activeUser.isActive, isTrue);
          expect(inactiveUser.isActive, isFalse);
          expect(activeUser.exists, isTrue); // Check if save succeeded
          expect(inactiveUser.exists, isTrue); // Check if save succeeded
          expect(activeUser.createdAt, isNotNull);
          expect(inactiveUser.createdAt, isNotNull);

          // Test soft deletion
          await activeUser.delete();
          expect(activeUser.isTrashed, isTrue);

          // Verify the user can be restored
          await activeUser.restore();
          expect(activeUser.isTrashed, isFalse);
        },
      );

      test('should use seeded test data for relationships', () async {
        // Use the seeded test data
        final user = testData.primaryUser;
        final post = testData.publishedPost;

        expect(user.id, isNotNull);
        expect(post.authorId, equals(user.id));

        // Test soft deleting user should work
        await user.delete();
        expect(user.isTrashed, isTrue);

        // Post should still exist but author is soft deleted
        final foundPost = await Model.find<TestPost>(
          post.id!,
          () => TestPost(),
        );
        expect(foundPost, isNotNull);
        expect(foundPost!.authorId, equals(user.id));
      });

      test('should create bulk test data using Factory', () async {
        // Create multiple users efficiently
        final users = await Factory.user().createMany(5);
        expect(users, hasLength(5));

        // Verify all users have unique emails
        final emails = users.map((u) => u.email).toSet();
        expect(emails, hasLength(5));

        // Soft delete some users
        await users[0].delete();
        await users[2].delete();
        await users[4].delete();

        // Count trashed vs active
        final trashedCount = users.where((u) => u.isTrashed).length;
        final activeCount = users.where((u) => !u.isTrashed).length;

        expect(trashedCount, equals(3));
        expect(activeCount, equals(2));
      });

      test('should demonstrate complex scenario creation', () async {
        // Create a complete blog scenario
        final blogScenario = await Factory.createBlogScenario();

        expect(blogScenario.categories, hasLength(2));
        expect(blogScenario.users, hasLength(2));
        expect(blogScenario.posts, hasLength(2));
        expect(blogScenario.comments, hasLength(2));

        // Test relationships
        expect(
          blogScenario.subCategory.parentId,
          equals(blogScenario.rootCategory.id),
        );
        expect(
          blogScenario.publishedPost.authorId,
          equals(blogScenario.author.id),
        );
        expect(
          blogScenario.replyComment.parentId,
          equals(blogScenario.topComment.id),
        );

        // Test soft deletion of author
        await blogScenario.author.delete();
        expect(blogScenario.author.isTrashed, isTrue);

        // Posts should still exist
        final posts = await Model.all<TestPost>(() => TestPost());
        expect(
          posts.where((p) => p.authorId == blogScenario.author.id),
          hasLength(
            2,
          ), // createBlogScenario creates 2 posts (published + draft)
        );
      });
    });

    group('Integration with Regular Model Operations', () {
      test('should work with validation system', () async {
        final user = FullFeatureUser();
        user.email = 'invalid-email'; // Invalid email, missing required name

        // Should fail validation
        final result = user.validate();
        expect(result.isValid, isFalse);

        // Should throw ValidationException on save
        expect(() => user.save(), throwsA(isA<ValidationException>()));
      });

      test('should work with field constraints', () async {
        final user = FullFeatureUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';

        await user.save();

        // Try to create another user with same email (unique constraint)
        final user2 = FullFeatureUser();
        user2.name = 'Jane Doe';
        user2.email = 'john@example.com'; // Duplicate email

        // Should fail due to unique constraint
        expect(() => user2.save(), throwsException);
      });

      test('should maintain referential integrity with relationships', () async {
        // This would need actual relationship implementation
        // For now, test basic foreign key behavior
        final post = SoftDeletedPost();
        post.title = 'Test Post';
        post.authorId = 999; // Non-existent author

        // Should save successfully (foreign key constraints depend on DB setup)
        final saved = await post.save();
        expect(saved, isTrue);

        // Soft delete should work
        await post.delete();
        expect(post.isTrashed, isTrue);
      });

      test('should handle concurrent soft delete operations', () async {
        final user = FullFeatureUser();
        user.name = 'Concurrent User';
        user.email = 'concurrent@example.com';
        await user.save();

        // Simulate concurrent operations
        final futures = List.generate(5, (index) async {
          try {
            return await user.delete();
          } catch (e) {
            return false;
          }
        });

        final results = await Future.wait(futures);

        // Only the first delete should succeed
        final successCount = results.where((r) => r == true).length;
        expect(successCount, equals(1));
        expect(user.isTrashed, isTrue);
      });

      test('should handle model state consistency during operations', () async {
        final user = FullFeatureUser();
        user.name = 'State Test User';
        user.email = 'state@example.com';
        await user.save();

        final originalId = user.id;
        final originalCreatedAt = user.createdAt;

        // Delete and verify state
        await user.delete();
        expect(user.id, equals(originalId)); // ID should remain
        expect(
          user.createdAt,
          equals(originalCreatedAt),
        ); // Created timestamp should remain
        expect(user.exists, isTrue); // Should still exist (soft deleted)
        expect(user.isTrashed, isTrue);

        // Restore and verify state
        await user.restore();
        expect(user.id, equals(originalId)); // ID should remain
        expect(
          user.createdAt,
          equals(originalCreatedAt),
        ); // Created timestamp should remain
        expect(user.exists, isTrue);
        expect(user.isTrashed, isFalse);
        expect(user.deletedAt, isNull);

        // Force delete and verify state
        await user.forceDelete();
        expect(user.id, isNull); // ID should be cleared
        expect(user.exists, isFalse); // Should no longer exist
      });
    });

    group('Advanced Soft Delete Scenarios', () {
      test('should handle cascading soft deletes', () async {
        // Create parent-child relationship (simulated with foreign key)
        final parent = SoftDeletedPost();
        parent.title = 'Parent Post';
        await parent.save();

        final child = SoftDeletedPost();
        child.title = 'Child Post';
        child.authorId = parent.id; // Simulate relationship
        await child.save();

        // Soft delete parent
        await parent.delete();
        expect(parent.isTrashed, isTrue);

        // Child should still exist (manual cascade would be needed)
        final foundChild = await Model.find<SoftDeletedPost>(
          child.id!,
          () => SoftDeletedPost(),
        );
        expect(foundChild, isNotNull);
        expect(foundChild!.isTrashed, isFalse);
      });

      test('should handle bulk operations with mixed states', () async {
        // Create mixed state models
        final users = <FullFeatureUser>[];

        for (int i = 0; i < 5; i++) {
          final user = FullFeatureUser();
          user.name = 'User $i';
          user.email = 'user$i@example.com';
          await user.save();
          users.add(user);
        }

        // Soft delete some
        await users[1].delete();
        await users[3].delete();

        // Force delete one
        await users[4].forceDelete();

        // Restore many should only affect soft deleted ones
        final restoredCount =
            await SoftDeletesMixin.restoreMany<FullFeatureUser>(
              () => FullFeatureUser(),
            );

        expect(restoredCount, equals(2)); // Only users[1] and users[3]

        // Verify states
        final allUsers = await Model.all<FullFeatureUser>(
          () => FullFeatureUser(),
        );
        expect(allUsers, hasLength(4)); // One was force deleted
        expect(
          allUsers.where((u) => u.isTrashed).length,
          equals(0),
        ); // All should be restored
      });

      test('should handle timestamp precision correctly', () async {
        final user = FullFeatureUser();
        user.name = 'Precision Test';
        user.email = 'precision@example.com';

        final beforeSave = DateTime.now();
        await user.save();
        final afterSave = DateTime.now();

        // Timestamps should be within reasonable bounds
        expect(
          user.createdAt!.isAfter(beforeSave.subtract(Duration(seconds: 1))),
          isTrue,
        );
        expect(
          user.createdAt!.isBefore(afterSave.add(Duration(seconds: 1))),
          isTrue,
        );
        expect(
          user.updatedAt!.isAfter(beforeSave.subtract(Duration(seconds: 1))),
          isTrue,
        );
        expect(
          user.updatedAt!.isBefore(afterSave.add(Duration(seconds: 1))),
          isTrue,
        );

        // Delete with precision
        final beforeDelete = DateTime.now();
        await user.delete();
        final afterDelete = DateTime.now();

        expect(
          user.deletedAt!.isAfter(beforeDelete.subtract(Duration(seconds: 1))),
          isTrue,
        );
        expect(
          user.deletedAt!.isBefore(afterDelete.add(Duration(seconds: 1))),
          isTrue,
        );
      });

      test('should handle mixin inheritance correctly', () {
        // Test that mixins are properly applied
        final softDeleteOnly = SoftDeletedPost();
        final timestampsOnly = TimestampedArticle();
        final bothMixins = FullFeatureUser();

        // Verify soft delete capability
        expect(softDeleteOnly.softDeletes, isTrue);
        expect(bothMixins.softDeletes, isTrue);

        // Verify timestamp capability
        expect(timestampsOnly.timestamps, isTrue);
        expect(bothMixins.timestamps, isTrue);

        // Verify field registration for soft delete only model
        expect(softDeleteOnly.fields.containsKey('deleted_at'), isTrue);
        expect(softDeleteOnly.fields.containsKey('created_at'), isFalse);
        expect(softDeleteOnly.fields.containsKey('updated_at'), isFalse);

        // Verify field registration for timestamps only model
        expect(timestampsOnly.fields.containsKey('deleted_at'), isFalse);
        expect(timestampsOnly.fields.containsKey('created_at'), isTrue);
        expect(timestampsOnly.fields.containsKey('updated_at'), isTrue);

        // Verify field registration for both mixins model
        expect(bothMixins.fields.containsKey('deleted_at'), isTrue);
        expect(bothMixins.fields.containsKey('created_at'), isTrue);
        expect(bothMixins.fields.containsKey('updated_at'), isTrue);

        // Verify proper method availability by checking capabilities
        expect(softDeleteOnly.softDeletes, isTrue);
        expect(timestampsOnly.timestamps, isTrue);
        expect(bothMixins.softDeletes, isTrue);
        expect(bothMixins.timestamps, isTrue);
      });

      test('should handle database transaction rollbacks', () async {
        final user = FullFeatureUser();
        user.name = 'Transaction Test';
        user.email = 'transaction@example.com';
        await user.save();

        expect(user.exists, isTrue);
        expect(user.isTrashed, isFalse);

        // Simulate a transaction that might fail
        try {
          // In a real implementation, this would be wrapped in a transaction
          await user.delete();

          // Simulate an error that would cause rollback
          // throw Exception('Simulated transaction error');
        } catch (e) {
          // In case of rollback, state should be consistent
          // This is more relevant when actual transactions are implemented
        }

        // For now, just verify the delete worked
        expect(user.isTrashed, isTrue);
      });
    });
  });
}
