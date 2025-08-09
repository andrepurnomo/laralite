import 'package:laralite/laralite.dart';

/// Example migration demonstrating table alteration
class AddSocialFieldsToUsers extends Migration {
  @override
  Future<void> up() async {
    await Schema.table('users', (table) {
      // Social media fields
      table.string('twitter_handle', 50).nullable();
      table.string('github_username', 100).nullable();
      table.string('linkedin_profile').nullable();
      table.string('website_url').nullable();

      // Location information
      table.string('country', 100).nullable();
      table.string('city', 100).nullable();
      table.string('timezone', 50).nullable();

      // Additional profile fields
      table.string('avatar_url').nullable();
      table.boolean('is_verified').defaultValue(false);
      table.dateTime('last_login_at').nullable();

      // Indexes for social fields
      table.index('twitter_handle');
      table.index('github_username');
      table.index('country');
      table.index('is_verified');
    });
  }

  @override
  Future<void> down() async {
    // SQLite doesn't support dropping columns easily
    // In a real scenario, you might need to recreate the table
    // or use a more complex migration strategy
    throw UnimplementedError(
      'SQLite does not support dropping columns. '
      'Consider creating a new migration that recreates the table.',
    );
  }
}
