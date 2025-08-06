import 'package:laralite/laralite.dart';

/// Example migration showing relationships and foreign keys
class CreatePostsTable extends Migration {
  @override
  Future<void> up() async {
    await Schema.create('posts', (table) {
      // Primary key
      table.id();
      
      // Post content
      table.string('title').notNull();
      table.string('slug').unique().notNull();
      table.text('content').nullable();
      table.text('excerpt').nullable();
      
      // Publishing
      table.string('status', 20).defaultValue('draft');
      table.boolean('is_published').defaultValue(false);
      table.dateTime('published_at').nullable();
      
      // Relationships
      table.foreignId('author_id').notNull();
      table.foreignId('category_id').nullable();
      
      // Meta information
      table.integer('view_count').defaultValue(0);
      table.json('meta_data').nullable();
      table.string('featured_image').nullable();
      
      // SEO
      table.string('meta_title').nullable();
      table.text('meta_description').nullable();
      table.json('tags').nullable();
      
      // Timestamps
      table.timestamps();
      table.softDeletes();
      
      // Foreign key constraints
      table.foreign('author_id', 'users.id');
      // Note: categories table not created in this example, so skip foreign key
      // table.foreign('category_id', 'categories.id');
      
      // Indexes
      table.index('slug');
      table.index('status');
      table.index('published_at');
      table.index(['author_id', 'status']);
      table.index(['category_id', 'is_published']);
    });
  }

  @override
  Future<void> down() async {
    await Schema.drop('posts');
  }
}
