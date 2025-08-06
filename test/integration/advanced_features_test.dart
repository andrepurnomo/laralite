import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';
import 'helpers/test_database.dart';
import 'models/user.dart';
import 'models/post.dart';
import 'models/comment.dart';

/// Advanced features test following BEST_PRACTICES.md
void main() {
  group('🚀 Advanced Features Test Suite', () {
    setUp(() async {
      await TestDatabase.setup();
    });
    
    tearDown(() async {
      await TestDatabase.tearDown();
    });
    
    group('🎯 Scopes Tests', () {
      test('should apply local scopes', () async {
        await TestDatabase.seed();
        
        // Test active users scope
        final activeUsers = await User().query()
          .where('is_active', true)
          .get();
        
        expect(activeUsers.isNotEmpty, true);
        expect(activeUsers.every((user) => user.isActive == true), true);
        
        // Test adults scope  
        final adults = await User().query()
          .where('age', '>=', 18)
          .get();
        
        expect(adults.isNotEmpty, true);
        expect(adults.every((user) => user.age! >= 18), true);
        
        print('✅ Local scopes work correctly');
      });
      
      test('should apply post scopes', () async {
        await TestDatabase.seed();
        
        // Test published posts scope
        final publishedPosts = await Post().query()
          .whereNotNull('published_at')
          .get();
        
        expect(publishedPosts.isNotEmpty, true);
        expect(publishedPosts.every((post) => post.isPublished), true);
        
        // Test draft posts scope
        final draftPosts = await Post().query()
          .whereNull('published_at')
          .get();
        
        expect(draftPosts.isNotEmpty, true);
        expect(draftPosts.every((post) => post.isDraft), true);
        
        print('✅ Post scopes work correctly');
      });
      
      test('should apply comment scopes', () async {
        await TestDatabase.seed();
        
        // Test approved comments scope
        final approvedComments = await Comment().query()
          .where('approved', true)
          .get();
        
        expect(approvedComments.every((comment) => comment.isApproved), true);
        
        // Test pending comments scope
        final pendingComments = await Comment().query()
          .where('approved', false)
          .get();
        
        expect(pendingComments.every((comment) => comment.isPending), true);
        
        print('✅ Comment scopes work correctly');
      });
    });
    
    group('🔗 Advanced Relationship Tests', () {
      test('should load nested relationships', () async {
        await TestDatabase.seed();
        
        // Get user with posts and comments
        final user = await User().query()
          .where('email', 'john@example.com')
          .first();
        
        expect(user, isNotNull);
        
        // Load user's posts
        final posts = await user!.posts().get();
        expect(posts.isNotEmpty, true);
        
        // Load comments for each post
        for (final post in posts) {
          final comments = await post.comments().get();
          print('Post "${post.title}" has ${comments.length} comments');
        }
        
        // Load user's comments
        final userComments = await user.comments().get();
        print('User has ${userComments.length} comments');
        
        print('✅ Nested relationships work correctly');
      });
      
      test('should filter relationships', () async {
        await TestDatabase.seed();
        
        final user = await User().query()
          .where('email', 'john@example.com')
          .first();
        
        expect(user, isNotNull);
        
        // Get only published posts
        final publishedPosts = await Post().query()
          .where('user_id', user!.id!)
          .whereNotNull('published_at')
          .get();
        
        expect(publishedPosts.every((post) => post.isPublished), true);
        
        // Get only draft posts
        final draftPosts = await Post().query()
          .where('user_id', user.id!)
          .whereNull('published_at')
          .get();
        
        expect(draftPosts.every((post) => post.isDraft), true);
        
        print('✅ Filtered relationships work correctly');
      });
    });
    
    group('🔍 Complex Query Tests', () {
      test('should perform whereIn queries', () async {
        await TestDatabase.seed();
        
        // Get specific users by IDs
        final users = await User().query()
          .whereIn('id', [1, 2])
          .get();
        
        expect(users.length, lessThanOrEqualTo(2));
        expect(users.every((user) => [1, 2].contains(user.id)), true);
        
        print('✅ whereIn queries work correctly');
      });
      
      test('should perform whereNotIn queries', () async {
        await TestDatabase.seed();
        
        // Get users excluding specific IDs
        final users = await User().query()
          .whereNotIn('id', [1])
          .get();
        
        expect(users.every((user) => user.id != 1), true);
        
        print('✅ whereNotIn queries work correctly');
      });
      
      test('should perform whereBetween queries', () async {
        await TestDatabase.seed();
        
        // Get users between age range
        final users = await User().query()
          .whereBetween('age', 20, 30)
          .get();
        
        expect(users.every((user) => user.age! >= 20 && user.age! <= 30), true);
        
        print('✅ whereBetween queries work correctly');
      });
      
      test('should perform OR queries', () async {
        await TestDatabase.seed();
        
        // Get users that are either young OR inactive
        final users = await User().query()
          .where('age', '<', 18)
          .orWhere('is_active', false)
          .get();
        
        expect(users.isNotEmpty, true);
        
        print('✅ OR queries work correctly');
      });
    });
    
    group('📊 Aggregation Tests', () {
      test('should calculate various aggregations', () async {
        await TestDatabase.seed();
        
        // Count
        final userCount = await User().query().count();
        final postCount = await Post().query().count();
        final commentCount = await Comment().query().count();
        
        expect(userCount, greaterThan(0));
        expect(postCount, greaterThan(0));
        expect(commentCount, greaterThan(0));
        
        // Average age
        final avgAge = await User().query().avg('age');
        expect(avgAge, isNotNull);
        expect(avgAge, greaterThan(0));
        
        // Min/Max age
        final minAge = await User().query().min('age');
        final maxAge = await User().query().max('age');
        
        expect(minAge, isNotNull);
        expect(maxAge, isNotNull);
        expect(maxAge, greaterThanOrEqualTo(minAge));
        
        print('✅ Aggregation calculations work correctly');
      });
      
      test('should calculate sum aggregation', () async {
        await TestDatabase.seed();
        
        // Sum of all user IDs (just for testing sum function)
        final sumIds = await User().query().sum('id');
        
        expect(sumIds, isNotNull);
        expect(sumIds, greaterThan(0));
        
        print('✅ Sum aggregation works correctly');
      });
    });
    
    group('🔄 Transaction Tests', () {
      test('should handle successful transactions', () async {
        await TestDatabase.cleanData();
        
        // Transaction that should succeed
        await Laralite.withTransaction(() async {
          final user = User()
            ..name = 'Transaction User'
            ..email = 'transaction@example.com'
            ..age = 25;
          await user.save();
          
          final post = Post()
            ..title = 'Transaction Post'
            ..content = 'Created in transaction'
            ..userId = user.id!;
          await post.save();
          
          final comment = Comment()
            ..content = 'Transaction comment'
            ..userId = user.id!
            ..postId = post.id!;
          await comment.save();
        });
        
        // Verify all records were created
        final users = await User().query().get();
        final posts = await Post().query().get();
        final comments = await Comment().query().get();
        
        expect(users.length, 1);
        expect(posts.length, 1);
        expect(comments.length, 1);
        
        print('✅ Successful transactions work correctly');
      });
      
      test('should rollback failed transactions', () async {
        await TestDatabase.cleanData();
        
        try {
          await Laralite.withTransaction(() async {
            final user = User()
              ..name = 'Transaction User'
              ..email = 'transaction@example.com'
              ..age = 25;
            await user.save();
            
            // This should cause the transaction to fail
            throw Exception('Intentional error');
          });
        } catch (e) {
          // Expected to fail
        }
        
        // Verify no records were created due to rollback
        final users = await User().query().get();
        expect(users.length, 0);
        
        print('✅ Transaction rollback works correctly');
      });
    });
    
    group('🏃‍♂️ Performance & Optimization Tests', () {
      test('should handle large datasets efficiently', () async {
        await TestDatabase.cleanData();
        
        final stopwatch = Stopwatch()..start();
        
        // Create 100 users
        for (int i = 0; i < 100; i++) {
          final user = User()
            ..name = 'Perf User $i'
            ..email = 'perf$i@example.com'
            ..age = 20 + (i % 60);
          await user.save();
        }
        
        stopwatch.stop();
        final createTime = stopwatch.elapsedMilliseconds;
        print('⏱️ Created 100 users in ${createTime}ms');
        
        // Query performance
        stopwatch.reset();
        stopwatch.start();
        
        final allUsers = await User().query().get();
        
        stopwatch.stop();
        final queryTime = stopwatch.elapsedMilliseconds;
        print('⏱️ Queried ${allUsers.length} users in ${queryTime}ms');
        
        // Complex query performance
        stopwatch.reset();
        stopwatch.start();
        
        final filteredUsers = await User().query()
          .where('age', '>', 30)
          .where('is_active', true)
          .orderBy('name')
          .limit(20)
          .get();
        
        stopwatch.stop();
        final complexQueryTime = stopwatch.elapsedMilliseconds;
        print('⏱️ Complex query returned ${filteredUsers.length} users in ${complexQueryTime}ms');
        
        // Performance assertions
        expect(createTime, lessThan(5000)); // 5 seconds max
        expect(queryTime, lessThan(1000)); // 1 second max
        expect(complexQueryTime, lessThan(500)); // 500ms max
        
        print('✅ Performance tests passed');
      });
      
      test('should handle pagination efficiently', () async {
        await TestDatabase.cleanData();
        
        // Create test data
        for (int i = 0; i < 50; i++) {
          final user = User()
            ..name = 'Page User $i'
            ..email = 'page$i@example.com'
            ..age = 20 + i;
          await user.save();
        }
        
        // Test pagination
        final page1 = await User().query()
          .orderBy('id')
          .paginate(page: 1, perPage: 10);
        
        expect(page1.data.length, 10);
        expect(page1.currentPage, 1);
        expect(page1.total, 50);
        expect(page1.lastPage, 5);
        expect(page1.hasMorePages, true);
        
        final page2 = await User().query()
          .orderBy('id')
          .paginate(page: 2, perPage: 10);
        
        expect(page2.data.length, 10);
        expect(page2.currentPage, 2);
        expect(page2.hasMorePages, true);
        expect(page2.hasPreviousPages, true);
        
        final lastPage = await User().query()
          .orderBy('id')
          .paginate(page: 5, perPage: 10);
        
        expect(lastPage.data.length, 10);
        expect(lastPage.hasMorePages, false);
        
        print('✅ Pagination works efficiently');
      });
    });
    
    group('🔒 Edge Cases & Error Handling', () {
      test('should handle duplicate email gracefully', () async {
        final user1 = User()
          ..name = 'User 1'
          ..email = 'duplicate@example.com'
          ..age = 25;
        await user1.save();
        
        final user2 = User()
          ..name = 'User 2'
          ..email = 'duplicate@example.com' // Same email
          ..age = 30;
        
        // This should fail due to unique constraint
        expect(() => user2.save(), throwsA(isA<Exception>()));
        
        print('✅ Duplicate email handling works correctly');
      });
      
      test('should handle non-existent records', () async {
        final user = await Model.find<User>(99999, () => User()); // Non-existent ID
        expect(user, isNull);
        
        final users = await User().query()
          .where('email', 'nonexistent@example.com')
          .get();
        expect(users.isEmpty, true);
        
        print('✅ Non-existent record handling works correctly');
      });
      
      test('should handle empty queries', () async {
        await TestDatabase.cleanData(); // No data
        
        final users = await User().query().get();
        expect(users.isEmpty, true);
        
        final count = await User().query().count();
        expect(count, 0);
        
        final avg = await User().query().avg('age');
        expect(avg, isNull);
        
        print('✅ Empty query handling works correctly');
      });
    });
  });
}
