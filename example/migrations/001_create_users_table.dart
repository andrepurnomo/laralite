import 'package:laralite/laralite.dart';

/// Example migration demonstrating the Laralite Schema Builder
///
/// To run this migration:
/// ```dart
/// final migration = CreateUsersTable();
/// await MigrationRunner.runMigration(migration);
/// ```
class CreateUsersTable extends Migration {
  @override
  Future<void> up() async {
    await Schema.create('users', (table) {
      // Primary key
      table.id();

      // Basic user fields
      table.string('name', 255).notNull();
      table.string('email').unique().notNull();
      table.string('password').notNull();

      // Optional fields
      table.string('phone', 20).nullable();
      table.date('birth_date').nullable();
      table.integer('age').nullable().check('age >= 0 AND age <= 150');

      // Status and role
      table.string('status', 20).defaultValue('active');
      table.string('role', 50).defaultValue('user');

      // Profile information
      table.text('bio').nullable();
      table.json('preferences').nullable();

      // Timestamps
      table.timestamps();

      // Soft deletes
      table.softDeletes();

      // Indexes
      table.index('email');
      table.index(['status', 'role']);
      table.unique(['email']);
    });
  }

  @override
  Future<void> down() async {
    await Schema.drop('users');
  }
}
