# Laralite Best Practices Guide

This guide provides step-by-step best practices for using Laralite ORM in your Flutter/Dart projects.

## 📋 Table of Contents

1. [Project Setup](#1-project-setup)
2. [Project Structure](#2-project-structure)
3. [Database Initialization](#3-database-initialization)
4. [Model Definition](#4-model-definition)
5. [Schema Management](#5-schema-management)
6. [Code Generation](#6-code-generation)
7. [Basic CRUD Operations](#7-basic-crud-operations)
8. [Advanced Query Building](#8-advanced-query-building)
9. [Relationships](#9-relationships)
10. [Validation](#10-validation)
11. [Testing](#11-testing)
12. [Production Considerations](#12-production-considerations)

---

## 1. Project Setup

### Step 1: Add Dependencies

Add Laralite and required dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  laralite:
    git:
      url: https://github.com/andrepurnomo/laralite.git
      ref: main
  sqlite3: ^2.8.0
  path: ^1.9.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.6.0
```

> **Note**: Laralite is currently in development and not yet published to pub.dev. We're using the GitHub repository directly.

### Step 2: Install Dependencies

```bash
flutter pub get
```

---

## 2. Project Structure

Organize your project with this recommended structure:

```
lib/
├── models/
│   ├── user.dart
│   ├── post.dart
│   └── comment.dart
├── database/
│   ├── migrations/
│   │   ├── 001_create_users_table.dart
│   │   ├── 002_create_posts_table.dart
│   │   └── 003_create_comments_table.dart
│   └── database_manager.dart
├── services/
│   ├── user_service.dart
│   └── post_service.dart
└── main.dart
```

---

## 3. Database Initialization

### Step 1: Create Database Manager

Create `lib/database/database_manager.dart`:

```dart
import 'package:laralite/laralite.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class DatabaseManager {
  static bool _initialized = false;

  /// Initialize database with proper path handling
  static Future<void> initialize({String? customPath}) async {
    if (_initialized) return;

    String dbPath;
    if (customPath != null) {
      dbPath = customPath;
    } else {
      // For production apps, use application documents directory
      final documentsDirectory = Directory.current; // Replace with proper path in real app
      final dbDirectory = Directory(path.join(documentsDirectory.path, 'database'));
      if (!await dbDirectory.exists()) {
        await dbDirectory.create(recursive: true);
      }
      dbPath = path.join(dbDirectory.path, 'app.db');
    }

    await Laralite.initialize(databasePath: dbPath);
    _initialized = true;
  }

  /// Run all migrations
  static Future<void> runMigrations() async {
    await _createUsersTable();
    await _createPostsTable();
    await _createCommentsTable();
  }

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

  static Future<void> _createPostsTable() async {
    await Schema.create('posts', (table) {
      table.id();
      table.string('title');
      table.text('content').nullable();
      table.foreignId('user_id').references('id').on('users');
      table.dateTime('published_at').nullable();
      table.timestamps();
    });
  }

  static Future<void> _createCommentsTable() async {
    await Schema.create('comments', (table) {
      table.id();
      table.text('content');
      table.foreignId('user_id').references('id').on('users');
      table.foreignId('post_id').references('id').on('posts');
      table.boolean('approved').defaultValue(false);
      table.timestamps();
    });
  }
}
```

### Step 2: Initialize in Main

Update your `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'database/database_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseManager.initialize();

  // Run migrations (only run once or when schema changes)
  await DatabaseManager.runMigrations();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laralite Demo',
      home: HomeScreen(),
    );
  }
}
```

---

## 4. Model Definition

### Step 1: Define Base Models

Create `lib/models/user.dart`:

```dart
import 'package:laralite/laralite.dart';

part 'user.g.dart';

@laralite
class User extends Model<User> with _$UserFields {
  @override
  String get table => 'users';

  @override
  bool get timestamps => true;

  // Define fields with proper validation
  final _id = AutoIncrementField();
  final _name = StringField(
    required: true,
    maxLength: 255,
    validationRules: [MinLengthRule(2)],
  );
  final _email = EmailField(
    required: true,
    unique: true,
    maxLength: 255,
  );
  final _age = IntField(
    min: 13,
    max: 120,
    nullable: true,
  );
  final _isActive = BoolField(
    defaultValue: true,
    columnName: 'is_active',
  );
  final _createdAt = TimestampField(
    autoCreate: true,
    columnName: 'created_at',
  );
  final _updatedAt = TimestampField(
    autoUpdate: true,
    columnName: 'updated_at',
  );

  User();

  // Relationships
  HasMany<Post> posts() => hasMany<Post>(() => Post());
  HasMany<Comment> comments() => hasMany<Comment>(() => Comment());

  // Scopes
  @override
  void initializeScopes() {
    super.initializeScopes();
    registerLocalScope('active', (query) => query.where('is_active', true));
    registerLocalScope('adults', (query) => query.where('age', '>=', 18));
  }

  // Custom methods
  bool get isAdult => age != null && age! >= 18;
  String get displayName => name ?? 'Anonymous';
}
```

### Step 2: Define Related Models

Create `lib/models/post.dart`:

```dart
import 'package:laralite/laralite.dart';

part 'post.g.dart';

@laralite
class Post extends Model<Post> with _$PostFields, SoftDeletesMixin {
  @override
  String get table => 'posts';

  @override
  bool get timestamps => true;

  final _id = AutoIncrementField();
  final _title = StringField(
    required: true,
    maxLength: 255,
    validationRules: [MinLengthRule(5)],
  );
  final _content = TextField(
    nullable: true,
    maxLength: 10000,
  );
  final _userId = ForeignKeyField(
    referencedTable: 'users',
    columnName: 'user_id',
    required: true,
  );
  final _publishedAt = DateTimeField(
    nullable: true,
    columnName: 'published_at',
  );
  final _createdAt = TimestampField(autoCreate: true, columnName: 'created_at');
  final _updatedAt = TimestampField(autoUpdate: true, columnName: 'updated_at');

  Post();

  // Relationships
  BelongsTo<User> user() => belongsTo<User>(() => User(), foreignKey: 'user_id');
  HasMany<Comment> comments() => hasMany<Comment>(() => Comment(), foreignKey: 'post_id');

  // Scopes
  @override
  void initializeScopes() {
    super.initializeScopes();
    registerLocalScope('published', (query) => query.whereNotNull('published_at'));
    registerLocalScope('draft', (query) => query.whereNull('published_at'));
  }

  // Custom methods
  bool get isPublished => publishedAt != null;
  bool get isDraft => publishedAt == null;

  Future<void> publish() async {
    publishedAt = DateTime.now();
    await save();
  }
}
```

---

## 5. Schema Management

### Best Practices for Migrations

1. **Version Control**: Always version your migrations with sequential numbers
2. **Descriptive Names**: Use clear, descriptive migration names
3. **Rollback Support**: Consider rollback scenarios when designing schema changes

Example migration pattern:

```dart
// 001_create_users_table.dart
class CreateUsersTable {
  static Future<void> up() async {
    await Schema.create('users', (table) {
      table.id();
      table.string('name');
      table.string('email').unique();
      table.timestamps();
    });
  }

  static Future<void> down() async {
    await Schema.drop('users');
  }
}

// 002_add_age_to_users.dart
class AddAgeToUsers {
  static Future<void> up() async {
    await Schema.table('users', (table) {
      table.integer('age').nullable();
    });
  }

  static Future<void> down() async {
    await Schema.table('users', (table) {
      table.dropColumn('age');
    });
  }
}
```

---

## 6. Code Generation

### Step 1: Run Build Runner

Generate the necessary code:

```bash
dart run build_runner build
```

### Step 2: Watch for Changes (Development)

For continuous development:

```bash
dart run build_runner watch
```

### Step 3: Clean Generated Files (if needed)

```bash
dart run build_runner clean
```

**⚠️ Important**: Always run code generation after:

- Adding new models
- Modifying field definitions
- Adding relationships
- Changing annotations

---

## 7. Basic CRUD Operations

### Create Operations

```dart
// Create new user
final user = User()
  ..name = 'John Doe'
  ..email = 'john@example.com'
  ..age = 30;

await user.save();

// Bulk create
final users = await User.createMany(() => User(), [
  {'name': 'Alice', 'email': 'alice@example.com', 'age': 25},
  {'name': 'Bob', 'email': 'bob@example.com', 'age': 35},
]);
```

### Read Operations

```dart
// Find by ID (static method)
final user = await Model.find<User>(1, () => User());

// Find or throw exception
final user = await Model.findOrFail<User>(1, () => User());

// Get all users
final allUsers = await User().query().get();

// Query with conditions
final activeUsers = await User().query()
  .where('is_active', true)
  .where('age', '>=', 18)
  .orderBy('name')
  .get();

// First result or null
final user = await User().query()
  .where('email', 'john@example.com')
  .first();

// Advanced queries with OR conditions
final users = await User().query()
  .where('status', 'active')
  .orWhere('role', 'admin')
  .orWhereIn('department', ['IT', 'Engineering'])
  .get();
```

### Update Operations

```dart
// Update single model
final user = await Model.find<User>(1, () => User());
if (user != null) {
  user.name = 'Updated Name';
  await user.save();
}

// Update using query
await User().query()
  .where('status', 'inactive')
  .update({'is_active': false});

// Bulk create
final users = await User.createMany(() => User(), [
  {'name': 'Alice', 'email': 'alice@example.com', 'age': 25},
  {'name': 'Bob', 'email': 'bob@example.com', 'age': 30},
]);
```

### Delete Operations

```dart
// Soft delete (if SoftDeletesMixin is used)
final post = await Model.find<Post>(1, () => Post());
await post?.delete();

// Force delete (permanent)
await post?.forceDelete();

// Query soft deleted records
final trashedPosts = await Post().query()
  .onlyTrashed()
  .get();

// Include soft deleted in results
final allPosts = await Post().query()
  .withTrashed()
  .get();

// Restore soft deleted records
await Post().query()
  .where('title', 'Draft Post')
  .restore();

// Bulk force delete
await Post().query()
  .where('created_at', '<', DateTime.now().subtract(Duration(days: 30)))
  .forceDelete();
```

---

## 8. Advanced Query Building

### Complex Queries

```dart
// Multiple conditions with OR
final users = await User().query()
  .where('name', 'like', '%john%')
  .orWhere('email', 'like', '%john%')
  .where('is_active', true)
  .get();

// Complex WHERE conditions
final filteredUsers = await User().query()
  .where('age', '>', 18)
  .whereIn('status', ['active', 'verified'])
  .whereNotIn('role', ['banned', 'suspended'])
  .whereBetween('created_at', startDate, endDate)
  .whereNull('deleted_at')
  .whereNotNull('email_verified_at')
  .get();

// OR conditions variants
final users = await User().query()
  .where('status', 'active')
  .orWhere('role', 'admin')
  .orWhereIn('department', ['IT', 'Engineering'])
  .orWhereNotIn('status', ['banned', 'suspended'])
  .orWhereBetween('age', 25, 35)
  .orWhereNull('deleted_at')
  .orWhereNotNull('last_login_at')
  .get();

// Subqueries and EXISTS
final usersWithPosts = await User().query()
  .whereHas('posts', (query) =>
    query.whereNotNull('published_at')
         .where('created_at', '>', DateTime.now().subtract(Duration(days: 30)))
  )
  .get();

// Advanced query features
final users = await User().query()
  .scope((query) => query.where('verified', true))
  .when(isAdmin, (query) => query.where('role', 'admin'))
  .orderByDesc('created_at')
  .get();

// Aggregations
final stats = {
  'total_users': await User().query().count(),
  'average_age': await User().query().avg('age'),
  'oldest_user_age': await User().query().max('age'),
  'youngest_user_age': await User().query().min('age'),
  'total_age': await User().query().sum('age'),
  'active_users': await User().query().where('is_active', true).count(),
};
```

### Pagination

```dart
final result = await User().query()
  .where('is_active', true)
  .orderBy('created_at', 'desc')
  .paginate(page: 1, perPage: 20);

print('Total: ${result.total}');
print('Current page: ${result.currentPage}/${result.lastPage}');
print('Showing: ${result.from}-${result.to} of ${result.total}');
print('Has more: ${result.hasMorePages}');
print('Has previous: ${result.hasPreviousPages}');
print('Next page: ${result.nextPage}');
print('Previous page: ${result.previousPage}');

for (final user in result.data) {
  print('User: ${user.name}');
}
```

---

## 9. Relationships

### Eager Loading

```dart
// Load single relationship
final usersWithPosts = await User().query()
  .include('posts')
  .get();

// Load multiple relationships
final usersWithData = await User().query()
  .include(['posts', 'comments'])
  .get();

// Nested eager loading
final usersWithPostsAndComments = await User().query()
  .include(['posts.comments', 'posts.user'])
  .get();
```

### Lazy Loading

```dart
final user = await Model.find<User>(1, () => User());
if (user != null) {
  // Load relationship when needed
  final posts = await user.posts().get();
  final comments = await user.comments().get();
}
```

### Relationship Queries

```dart
// Query through relationships
final user = await Model.find<User>(1, () => User());
if (user != null) {
  final publishedPosts = await user.posts()
    .whereNotNull('published_at')
    .orderBy('published_at', 'desc')
    .get();
  
  // Complex relationship queries
  final recentPosts = await user.posts()
    .where('created_at', '>', DateTime.now().subtract(Duration(days: 30)))
    .whereIn('status', ['published', 'featured'])
    .orderByDesc('published_at')
    .limit(10)
    .get();
}
```

---

## 10. Validation

### Field-Level Validation

```dart
// Define validation rules in model
final _email = EmailField(
  required: true,
  validationRules: [
    MinLengthRule(5),
    MaxLengthRule(255),
    // Custom validation
    CustomValidationRule((value) =>
      value?.contains('@company.com') ?? false,
      'Email must be from company domain'
    ),
  ],
);
```

### Model Validation

```dart
// Validate before saving
final user = User()
  ..name = 'John'
  ..email = 'invalid-email'
  ..age = -5;

final validation = user.validate();
if (!validation.isValid) {
  print('Validation errors:');
  for (final error in validation.errors) {
    print('- $error');
  }
  return;
}

await user.save();
```

### Custom Validation

```dart
class User extends Model<User> with _$UserFields {
  // ... field definitions ...

  @override
  ValidationResult validate() {
    final result = super.validate();
    final errors = List<String>.from(result.errors);

    // Custom business logic validation
    if (age != null && age! < 13) {
      errors.add('Users must be at least 13 years old');
    }

    if (email != null && !email!.endsWith('@company.com')) {
      errors.add('Only company emails are allowed');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
```

---

## 11. Testing

### Setup Test Database

Create `test/helpers/test_database.dart`:

```dart
import 'package:laralite/laralite.dart';

class TestDatabase {
  static Future<void> setup() async {
    await Laralite.initialize(databasePath: ':memory:');
    await _runMigrations();
  }

  static Future<void> tearDown() async {
    await Laralite.close();
    Laralite.reset();
  }

  static Future<void> _runMigrations() async {
    // Create test tables
    await Schema.create('users', (table) {
      table.id();
      table.string('name');
      table.string('email').unique();
      table.integer('age').nullable();
      table.boolean('is_active').defaultValue(true);
      table.timestamps();
    });

    await Schema.create('posts', (table) {
      table.id();
      table.string('title');
      table.text('content').nullable();
      table.foreignId('user_id').references('id').on('users');
      table.timestamps();
    });
  }

  static Future<void> seed() async {
    // Create test data
    final user = User()
      ..name = 'Test User'
      ..email = 'test@example.com'
      ..age = 25;
    await user.save();

    final post = Post()
      ..title = 'Test Post'
      ..content = 'Test content'
      ..userId = user.id;
    await post.save();
  }
}
```

### Model Tests

Create `test/models/user_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_database.dart';
import '../../lib/models/user.dart';

void main() {
  group('User Model', () {
    setUp(() async {
      await TestDatabase.setup();
    });

    tearDown(() async {
      await TestDatabase.tearDown();
    });

    test('should create user successfully', () async {
      final user = User()
        ..name = 'John Doe'
        ..email = 'john@example.com'
        ..age = 30;

      await user.save();

      expect(user.exists, true);
      expect(user.id, isNotNull);
      expect(user.name, 'John Doe');
    });

    test('should validate required fields', () async {
      final user = User(); // Missing required fields

      final validation = user.validate();

      expect(validation.isValid, false);
      expect(validation.errors, contains('Name is required'));
      expect(validation.errors, contains('Email is required'));
    });

    test('should find user by email', () async {
      await TestDatabase.seed();

      final user = await User().query()
        .where('email', 'test@example.com')
        .first();

      expect(user, isNotNull);
      expect(user!.name, 'Test User');
    });

    test('should test complex queries', () async {
      await TestDatabase.seed();

      final users = await User().query()
        .where('is_active', true)
        .whereIn('age', [25, 30, 35])
        .whereNotNull('email')
        .orderByDesc('created_at')
        .limit(10)
        .get();

      expect(users.length, greaterThan(0));
    });
  });
}
```

---

## 12. Production Considerations

### Performance Optimization

1. **Use Indexes**: Add indexes to frequently queried columns
2. **Eager Loading**: Use `include()` to prevent N+1 queries
3. **Pagination**: Always paginate large result sets
4. **Connection Pooling**: Laralite handles this automatically via isolates

### Error Handling

```dart
try {
  final user = await User().find(1);
  await user?.save();
} on ValidationException catch (e) {
  // Handle validation errors
  print('Validation failed: ${e.errors.join(', ')}');
} catch (e) {
  // Handle other database errors
  print('Database error: $e');
}
```

### Logging and Monitoring

```dart
class DatabaseLogger {
  static void logQuery(String sql, List<dynamic>? params) {
    if (kDebugMode) {
      print('[SQL] $sql');
      if (params != null) print('[PARAMS] $params');
    }
  }
}
```

### Migration Management

1. **Version Control**: Store migrations in version control
2. **Environment Specific**: Use different databases for dev/staging/prod
3. **Backup Strategy**: Always backup before running migrations in production
4. **Rollback Plan**: Have rollback procedures ready

### Security

1. **Parameterized Queries**: Laralite handles this automatically
2. **Input Validation**: Always validate user input before database operations
3. **Access Control**: Implement proper authentication and authorization
4. **Sensitive Data**: Encrypt sensitive fields when necessary

---

## 📚 Additional Resources

- [Laralite Documentation](README.md)
- [Laravel Eloquent Documentation](https://laravel.com/docs/eloquent) (for reference)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Dart Build Runner](https://pub.dev/packages/build_runner)

---

## 13. Automatic Parameter Type Conversion

Laralite automatically converts Dart types to SQLite-compatible formats:

```dart
// DateTime objects (converted to UTC ISO 8601 strings)
query.where('created_at', '>', DateTime.now());
query.whereBetween('updated_at', startDate, endDate);

// Boolean values (converted to INTEGER 0/1)
query.where('is_active', true);  // becomes: WHERE is_active = 1

// Enums (converted to string names)
enum Status { active, inactive }
query.where('status', Status.active);  // becomes: WHERE status = 'active'

// Duration objects (converted to milliseconds)
query.where('timeout', Duration(minutes: 5));  // becomes: WHERE timeout = 300000

// Complex types (converted to JSON strings)
query.where('metadata', {'key': 'value'});  // becomes JSON string
query.whereIn('tags', ['tag1', 'tag2']);    // becomes JSON array

// All supported WHERE methods with automatic conversion:
query.where('column', value)
query.whereBetween('column', min, max)  
query.whereIn('column', [value1, value2])
query.whereNotIn('column', [value1, value2])
```

**Supported Type Conversions:**
- `DateTime` → UTC ISO 8601 string
- `bool` → INTEGER (0/1)
- `Enum` → string name
- `Duration` → milliseconds (INTEGER)
- `Uri` → string representation
- `BigInt` → string (prevents overflow)
- `List/Iterable` → JSON string
- `Map` → JSON string  
- `String`, `int`, `double`, `num` → unchanged (native SQLite types)

---

**💡 Tip**: Follow this guide step by step for the best Laralite development experience. Each step builds on the previous one, so don't skip ahead!
