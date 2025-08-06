# Laralite

[![Development Status](https://img.shields.io/badge/Status-Development-red?style=for-the-badge)](https://github.com/andrepurnomo/laralite)
[![Not Production Ready](https://img.shields.io/badge/Production-NOT%20READY-red?style=for-the-badge)](https://github.com/andrepurnomo/laralite)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)

A powerful and elegant ORM (Object-Relational Mapping) library for Flutter/Dart, inspired by Laravel's Eloquent ORM. Laralite brings the expressive syntax and powerful features of Laravel's database layer to the Dart ecosystem.

---

## ⚠️ **IMPORTANT DISCLAIMER**

> **🚧 THIS PACKAGE IS IN ACTIVE DEVELOPMENT**
> 
> **❌ NOT READY FOR PRODUCTION USE**
> 
> **⚠️ API WILL CHANGE WITHOUT NOTICE**

### Development Status:
- 🔄 **Breaking Changes Expected** - API is unstable and will change
- 🧪 **Experimental Features** - Many features are still being tested
- 📝 **Incomplete Documentation** - Docs are still being written
- 🐛 **Known Issues** - Bugs and limitations exist

### ✅ **Suitable For:**
- Learning and experimentation
- Proof of concepts
- Contributing to development
- Testing and feedback

### ❌ **NOT Suitable For:**
- Production applications
- Critical systems
- Stable applications
- Client projects

---

## Features

✨ **Eloquent-style Model Definition** - Define your models with clean, expressive syntax  
🏗️ **Schema Builder** - Laravel-style migrations and schema management  
🔍 **Query Builder** - Fluent, expressive query building  
🔗 **Relationships** - HasOne, HasMany, BelongsTo, BelongsToMany support  
📝 **Field Types** - Rich field type system with validation  
⚡ **Isolate Support** - Non-blocking database operations using Dart isolates  
🗑️ **Soft Deletes** - Built-in soft delete functionality  
⏰ **Timestamps** - Automatic created_at/updated_at management  
🎯 **Type Safety** - Full type safety with code generation  
🔧 **Code Generation** - Automatic property generation with build_runner  

## Installation

⚠️ **Warning**: This is a development package. Only install for testing and experimentation.

Add laralite to your `pubspec.yaml`:

```yaml
dependencies:
  laralite:
    git:
      url: https://github.com/andrepurnomo/laralite.git
      ref: main
  sqlite3: ^2.8.0
  
dev_dependencies:
  build_runner: ^2.6.0
```

> **Note**: Laralite is currently in development and not yet published to pub.dev. Use the GitHub repository directly. API stability is not guaranteed.

## Quick Start

### 1. Initialize the Database

```dart
import 'package:laralite/laralite.dart';

void main() async {
  // Initialize database connection
  await Laralite.initialize(databaseName: 'app.db');
  
  runApp(MyApp());
}
```

### 2. Define Your Models

```dart
// user.dart
import 'package:laralite/laralite.dart';

part 'user.g.dart';

@laralite
class User extends Model<User> with _$UserFields {
  @override
  String get table => 'users';
  
  @override
  bool get timestamps => true;
  
  // Define fields
  final _id = AutoIncrementField();
  final _name = StringField(required: true, maxLength: 255);
  final _email = EmailField(required: true, unique: true);
  final _age = IntField(min: 0, max: 120);
  final _isActive = BoolField(defaultValue: true);
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);
  
  // Constructor
  User();
  
  // Relationships
  HasMany<Post> posts() => hasMany<Post>(() => Post());
}
```

```dart
// post.dart
import 'package:laralite/laralite.dart';

part 'post.g.dart';

@laralite  
class Post extends Model<Post> with _$PostFields {
  @override
  String get table => 'posts';
  
  final _id = AutoIncrementField();
  final _title = StringField(required: true, maxLength: 255);
  final _content = TextField();
  final _userId = ForeignKeyField(referencedTable: 'users');
  final _publishedAt = DateTimeField();
  
  Post();
  
  // Relationships
  BelongsTo<User> user() => belongsTo<User>(() => User());
}
```

### 3. Run Code Generation

```bash
dart run build_runner build
```

### 4. Create Database Schema

```dart
// Create tables using schema builder
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
  table.dateTime('published_at').nullable();
  table.timestamps();
});
```

### 5. Use Your Models

```dart
// Create a new user
final user = User()
  ..name = 'John Doe'
  ..email = 'john@example.com'
  ..age = 30;

await user.save();

// Query users
final users = await User().query()
  .where('age', '>', 18)
  .orderBy('name')
  .get();

// Find user by ID (static method)
final user = await Model.find<User>(1, () => User());

// Find user with posts (eager loading)
final userWithPosts = await User().query()
  .include('posts')
  .where('id', 1)
  .first();

// Get all users
final allUsers = await User().query().get();

// Complex queries with relationships
final activeAdults = await User().query()
  .where('is_active', true)
  .where('age', '>=', 18)
  .whereHas('posts', (query) => query.whereNotNull('published_at'))
  .get();
```

## Field Types

Laralite provides a rich set of field types:

```dart
// Numeric fields
final _id = AutoIncrementField();
final _count = IntField(min: 0, max: 1000);
final _price = DoubleField(decimalPlaces: 2);
final _isActive = BoolField(defaultValue: false);

// Text fields  
final _name = StringField(maxLength: 255, required: true);
final _description = TextField();
final _email = EmailField(unique: true);
final _website = UrlField();
final _uuid = UuidField();

// Date/Time fields
final _createdAt = DateTimeField();
final _birthDate = DateField();
final _workTime = TimeField();
final _updatedAt = TimestampField(autoUpdate: true);

// Special fields
final _metadata = JsonField<Map<String, dynamic>>();
final _avatar = BlobField();
final _status = EnumField<Status>(enumValues: Status.values);
final _userId = ForeignKeyField(referencedTable: 'users');
```

## Relationships

Define relationships between your models:

```dart
// One-to-One
HasOne<Profile> profile() => hasOne<Profile>(() => Profile());

// One-to-Many
HasMany<Post> posts() => hasMany<Post>(() => Post());

// Belongs-To
BelongsTo<User> user() => belongsTo<User>(() => User());

// Many-to-Many
BelongsToMany<Role> roles() => belongsToMany<Role>(() => Role());
```

## Query Builder

Build complex queries with fluent syntax:

```dart
// Basic queries
final users = await User().query()
  .where('name', 'like', '%john%')
  .whereIn('status', ['active', 'pending'])
  .whereNotNull('email_verified_at')
  .orderBy('created_at', 'desc')
  .limit(10)
  .get();

// Complex WHERE conditions
final filteredUsers = await User().query()
  .where('age', '>', 18)
  .whereIn('status', ['active', 'verified'])
  .whereNotIn('role', ['banned', 'suspended'])
  .whereBetween('created_at', startDate, endDate)
  .whereNull('deleted_at')
  .get();

// OR conditions
final users = await User().query()
  .where('status', 'active')
  .orWhere('role', 'admin')
  .orWhereIn('id', [1, 2, 3])
  .orWhereBetween('age', 25, 35)
  .get();

// Relationship queries
final postsWithComments = await Post().query()
  .whereHas('comments', (query) => query.where('approved', true))
  .include(['user', 'comments'])
  .get();

// Aggregations
final totalUsers = await User().query().count();
final averageAge = await User().query().avg('age');
final oldestUser = await User().query().max('age');
final youngestUser = await User().query().min('age');
final totalAge = await User().query().sum('age');

// Advanced query features
final users = await User().query()
  .scope((query) => query.where('verified', true))
  .when(isAdmin, (query) => query.where('role', 'admin'))
  .orderByDesc('created_at')
  .get();
```

## Soft Deletes

Enable soft deletes on your models:

```dart
@laralite
class Post extends Model<Post> with _$PostFields, SoftDeletesMixin {
  // Your model definition...
}

// Soft delete a post
await post.delete(); // Sets deleted_at timestamp

// Query including soft deleted
final allPosts = await Post().query().withTrashed().get();

// Query only soft deleted
final deletedPosts = await Post().query().onlyTrashed().get();

// Restore soft deleted
await Post().query().where('id', 1).restore();

// Force delete (permanent)
await Post().query().where('id', 1).forceDelete();
```

## Validation

Built-in field validation:

```dart
final _email = EmailField(
  required: true,
  validationRules: [
    MinLengthRule(5),
    MaxLengthRule(255),
  ],
);

final _age = IntField(
  required: true,
  validationRules: [
    MinValueRule(0),
    MaxValueRule(120),
  ],
);

// Validate model
final user = User()..email = 'invalid-email';
final validation = user.validate();

if (!validation.isValid) {
  print('Validation errors: ${validation.errors}');
}
```

## Model Static Methods

Convenient static methods for common operations:

```dart
// Find by primary key
final user = await Model.find<User>(1, () => User());

// Find or throw exception
final user = await Model.findOrFail<User>(1, () => User());

// Find multiple records by IDs
final users = await Model.findMany<User>([1, 2, 3], () => User());

// Create multiple records
final users = await User.createMany(() => User(), [
  {'name': 'Alice', 'email': 'alice@example.com', 'age': 25},
  {'name': 'Bob', 'email': 'bob@example.com', 'age': 30},
]);
```

## Transactions

Execute multiple operations in transactions:

```dart
await Model.withTransaction(() async {
  final user = User()..name = 'John';
  await user.save();
  
  final post = Post()
    ..title = 'My First Post'
    ..userId = user.id;
  await post.save();
  
  // Both operations succeed or both fail
});

// Alternative syntax
await Laralite.withTransaction(() async {
  // Your transactional operations
});
```

## Pagination

Built-in pagination support:

```dart
final result = await User().query()
  .where('is_active', true)
  .paginate(page: 1, perPage: 20);

print('Total: ${result.total}');
print('Current page: ${result.currentPage}/${result.lastPage}');
print('Showing: ${result.from}-${result.to} of ${result.total}');
print('Has more: ${result.hasMorePages}');
print('Has previous: ${result.hasPreviousPages}');
print('Next page: ${result.nextPage}');
print('Previous page: ${result.previousPage}');

for (final user in result.data) {
  print(user.name);
}
```

## Architecture

Laralite is built with performance and reliability in mind:

- **Isolate-based Database Operations**: All database operations run in separate isolates to prevent blocking the main thread
- **Type-safe Field System**: Comprehensive field type system with validation and serialization
- **Efficient Query Building**: Smart query building with parameter binding and SQL injection prevention  
- **Relationship Eager Loading**: Efficient N+1 query prevention with eager loading support
- **Schema Management**: Laravel-style migrations and schema building

## Contributing

We welcome contributions! This project is in active development and we appreciate:

- 🐛 Bug reports and issue submissions
- 💡 Feature suggestions and feedback  
- 🔧 Code contributions and pull requests
- 📖 Documentation improvements

Please see our [Contributing Guide](CONTRIBUTING.md) for details.

**Note**: Since this is a development package, expect frequent changes and breaking updates.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Inspired By

Laralite is heavily inspired by [Laravel's Eloquent ORM](https://laravel.com/docs/eloquent). We aim to bring the same level of elegance and power to the Dart/Flutter ecosystem.
