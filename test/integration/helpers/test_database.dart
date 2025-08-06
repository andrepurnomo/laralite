import 'package:laralite/laralite.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

/// Test database helper for integration tests
class TestDatabase {
  static bool _initialized = false;
  
  /// Setup in-memory database for testing
  static Future<void> setup() async {
    if (_initialized) return;
    
    await Laralite.initialize(databasePath: ':memory:');
    await _runMigrations();
    _initialized = true;
    
    print('✅ Test database initialized');
  }
  
  /// Teardown database after tests
  static Future<void> tearDown() async {
    if (!_initialized) return;
    
    await Laralite.close();
    Laralite.reset();
    _initialized = false;
    
    print('✅ Test database closed');
  }
  
  /// Run all test migrations
  static Future<void> _runMigrations() async {
    print('🔄 Running test migrations...');
    
    await _createUsersTable();
    await _createPostsTable(); 
    await _createCommentsTable();
    
    print('✅ Test migrations completed');
  }
  
  /// Create users table
  static Future<void> _createUsersTable() async {
    await Schema.create('users', (table) {
      table.id();
      table.string('name');
      table.string('email').unique();
      table.integer('age').nullable();
      table.boolean('is_active').defaultValue(true);
      table.timestamps();
    });
  }
  
  /// Create posts table
  static Future<void> _createPostsTable() async {
    await Schema.create('posts', (table) {
      table.id();
      table.string('title');
      table.text('content').nullable();
      table.foreignId('user_id');
      table.dateTime('published_at').nullable();
      table.timestamps();
      table.dateTime('deleted_at').nullable(); // For soft deletes
    });
  }
  
  /// Create comments table
  static Future<void> _createCommentsTable() async {
    await Schema.create('comments', (table) {
      table.id();
      table.text('content');
      table.foreignId('user_id');
      table.foreignId('post_id');
      table.boolean('approved').defaultValue(false);
      table.timestamps();
    });
  }
  
  /// Seed test data
  static Future<void> seed() async {
    print('🌱 Seeding test data...');
    
    // Create test users
    final user1 = User()
      ..name = 'John Doe'
      ..email = 'john@example.com'
      ..age = 30
      ..isActive = true;
    await user1.save();
    
    final user2 = User()
      ..name = 'Jane Smith'
      ..email = 'jane@example.com'
      ..age = 25
      ..isActive = true;
    await user2.save();
    
    final user3 = User()
      ..name = 'Bob Wilson'
      ..email = 'bob@example.com'
      ..age = 16 // Minor
      ..isActive = false;
    await user3.save();
    
    // Create test posts
    final post1 = Post()
      ..title = 'First Post'
      ..content = 'This is the content of the first post'
      ..userId = user1.id
      ..publishedAt = DateTime.now().subtract(Duration(days: 5));
    await post1.save();
    
    final post2 = Post()
      ..title = 'Second Post'
      ..content = 'This is the content of the second post'
      ..userId = user2.id
      ..publishedAt = DateTime.now().subtract(Duration(days: 2));
    await post2.save();
    
    final post3 = Post()
      ..title = 'Draft Post'
      ..content = 'This is a draft post'
      ..userId = user1.id;
      // publishedAt is null (draft)
    await post3.save();
    
    // Create test comments
    final comment1 = Comment()
      ..content = 'Great post!'
      ..userId = user2.id
      ..postId = post1.id
      ..approved = true;
    await comment1.save();
    
    final comment2 = Comment()
      ..content = 'Nice work'
      ..userId = user3.id
      ..postId = post1.id
      ..approved = false; // Pending approval
    await comment2.save();
    
    final comment3 = Comment()
      ..content = 'Very informative'
      ..userId = user1.id
      ..postId = post2.id
      ..approved = true;
    await comment3.save();
    
    print('✅ Test data seeded');
  }
  
  /// Clean all data (but keep schema)
  static Future<void> cleanData() async {
    await Laralite.execute('DELETE FROM comments');
    await Laralite.execute('DELETE FROM posts');
    await Laralite.execute('DELETE FROM users');
    
    // Reset auto-increment counters
    await Laralite.execute('DELETE FROM sqlite_sequence');
    
    print('🧹 Test data cleaned');
  }
  
  /// Get database statistics
  static Future<Map<String, int>> getStats() async {
    final userCount = await Laralite.query('SELECT COUNT(*) as count FROM users');
    final postCount = await Laralite.query('SELECT COUNT(*) as count FROM posts');
    final commentCount = await Laralite.query('SELECT COUNT(*) as count FROM comments');
    
    return {
      'users': userCount.first['count'] as int,
      'posts': postCount.first['count'] as int,
      'comments': commentCount.first['count'] as int,
    };
  }
  
  /// Verify table exists
  static Future<bool> tableExists(String tableName) async {
    return await Laralite.tableExists(tableName);
  }
  
  /// Get table schema
  static Future<List<Map<String, dynamic>>> getTableInfo(String tableName) async {
    return await Laralite.getTableInfo(tableName);
  }
}
