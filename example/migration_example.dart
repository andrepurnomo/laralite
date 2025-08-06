import 'package:laralite/laralite.dart';
import 'migrations/001_create_users_table.dart';
import 'migrations/002_create_posts_table.dart';
import 'migrations/003_add_social_fields_to_users.dart';

/// Example showing how to use the Migration system
void main() async {
  // Initialize database (in memory for example)
  await Database.initialize(databasePath: ':memory:');
  
  // Enable foreign key constraints
  await Schema.enableForeignKeyConstraints();
  
  print('=== Laralite Migration System Example ===\n');
  
  // Example 1: Running individual migrations
  print('1. Running individual migrations:');
  await MigrationRunner.runMigration(CreateUsersTable());
  await MigrationRunner.runMigration(CreatePostsTable());
  await MigrationRunner.runMigration(AddSocialFieldsToUsers());
  
  // Check migration status
  print('\nMigration status:');
  final status = await MigrationRunner.getStatus();
  for (final migration in status) {
    print('  ✓ ${migration['migration']} (batch ${migration['batch']})');
  }
  
  // Example 2: Using Migration Registry
  print('\n2. Using Migration Registry:');
  
  // Reset for fresh start - drop all tables created
  await Schema.drop('posts'); // Drop posts first (has foreign keys)
  await Schema.drop('users');
  await MigrationRunner.reset();
  
  // Register migrations
  MigrationRegistry.register(CreateUsersTable());
  MigrationRegistry.register(CreatePostsTable());
  MigrationRegistry.register(AddSocialFieldsToUsers());
  
  print('Registered migrations: ${MigrationRegistry.all.length}');
  
  // Run all pending migrations
  final pending = await MigrationRegistry.getPending();
  print('Pending migrations: ${pending.length}');
  
  await MigrationRegistry.runAll();
  print('All migrations completed!');
  
  // Example 3: Testing the created tables
  print('\n3. Testing created tables:');
  
  // Insert a test user
  await Database.execute('''
    INSERT INTO users (name, email, password, status, role, age) 
    VALUES (?, ?, ?, ?, ?, ?)
  ''', ['John Doe', 'john@example.com', 'hashed_password', 'active', 'admin', 30]);
  
  // Insert a test post (set category_id to NULL since we don't have categories table)
  await Database.execute('''
    INSERT INTO posts (title, slug, content, status, author_id, category_id, is_published) 
    VALUES (?, ?, ?, ?, ?, ?, ?)
  ''', [
    'Welcome to Laralite',
    'welcome-to-laralite',
    'This is our first post using the new migration system!',
    'published',
    1,
    null, // No category
    true
  ]);
  
  // Query the data
  final users = await Database.query('SELECT * FROM users');
  final posts = await Database.query('''
    SELECT p.*, u.name as author_name 
    FROM posts p 
    JOIN users u ON p.author_id = u.id
  ''');
  
  print('Users: ${users.length}');
  print('Posts: ${posts.length}');
  print('Post: "${posts.first['title']}" by ${posts.first['author_name']}');
  
  // Example 4: Schema introspection
  print('\n4. Schema introspection:');
  
  final tables = ['users', 'posts'];
  for (final table in tables) {
    print('\n$table table structure:');
    final columns = await Schema.getColumnListing(table);
    for (final column in columns) {
      print('  - ${column['name']}: ${column['type']} (nullable: ${column['notnull'] == 0})');
    }
  }
  
  // Example 5: Rollback demonstration
  print('\n5. Rollback demonstration:');
  
  print('Attempting to rollback last migration...');
  try {
    await MigrationRunner.rollbackMigration(AddSocialFieldsToUsers());
    
    // Check if social fields are gone
    final hasTwitterField = await Schema.hasColumn('users', 'twitter_handle');
    print('Twitter handle field exists: $hasTwitterField');
  } catch (e) {
    print('Rollback failed as expected: ${e.toString()}');
    print('Note: SQLite has limited ALTER TABLE support for dropping columns');
  }
  
  print('\n=== Example completed successfully! ===');
  
  // Cleanup
  await Database.close();
}
