# Test Utilities and Fixtures

This document describes the comprehensive test utilities created to improve test maintainability and reduce code duplication in the Laralite project.

## Directory Structure

```
test/
├── fixtures/
│   ├── test_models.dart          # Standardized test models
│   └── test_data.dart            # Predefined test data
├── helpers/
│   ├── database_helper.dart      # Database test utilities
│   └── model_factory.dart       # Model factory patterns
└── example/
    └── test_helpers_demo.dart    # Complete usage examples
```

## Core Components

### 1. Test Fixtures (`test/fixtures/`)

#### `test_models.dart` - Standardized Test Models

Provides consistent test models with proper relationships, validation, and Laralite features:

- **TestUser**: User model with timestamps, soft deletes, validation, and roles
- **TestPost**: Blog post with relationships, status management, and SEO fields
- **TestComment**: Comment system with hierarchical replies and approval workflow
- **TestCategory**: Hierarchical categories with parent/child relationships
- **TestProduct**: E-commerce product with inventory, pricing, and tags
- **TestOrder**: Order management with status tracking and address handling

**Features:**
- Timestamps and soft deletes mixins
- Comprehensive field validation
- Business logic methods (mutators/accessors)
- Proper foreign key relationships
- JSON field handling for complex data

#### `test_data.dart` - Predefined Test Data

Comprehensive test data sets for consistent testing:

```dart
// Valid test data
TestData.validUserData
TestData.validPostData
TestData.validCommentData

// Invalid test data for validation testing
TestData.invalidUserData
TestData.validationTestData

// Bulk data generators
TestData.generateBulkUserData(100)
TestData.generateBulkPostData(50, authorId)

// Factory methods
TestModelFactory.createUser(customData)
TestModelFactory.createPost(customData)
```

### 2. Test Helpers (`test/helpers/`)

#### `database_helper.dart` - Database Test Utilities

Complete database management for tests:

```dart
// Basic setup/teardown
await DatabaseHelper.initializeTestDatabase()
await DatabaseHelper.closeTestDatabase()

// Table management
await DatabaseHelper.createAllTestTables()
await DatabaseHelper.clearAllTestTables()

// Data seeding
final testData = await DatabaseHelper.seedTestData()

// Performance testing
final duration = await DatabaseHelper.measureExecutionTime(() async {
  // Your operation here
})

// Utility functions
final count = await DatabaseHelper.getTableRowCount('test_users')
final exists = await DatabaseHelper.tableExists('test_posts')
```

**Includes TestDataSeeds class:**
```dart
class TestDataSeeds {
  final List<TestUser> users;
  final List<TestCategory> categories;
  final List<TestPost> posts;
  // ... etc
  
  // Convenience getters
  TestUser get primaryUser => users.first;
  TestPost get publishedPost => posts.first;
}
```

#### `model_factory.dart` - Factory Patterns

Powerful builder pattern for creating test models:

```dart
// Basic usage
final user = await Factory.user()
    .withName('John Doe')
    .withEmail('john@example.com')
    .active()
    .create();

// Specialized builders
final admin = await Factory.user().admin().create();
final post = await Factory.post()
    .withAuthor(user.id!)
    .published()
    .popular()
    .create();

// Bulk creation
final users = await Factory.user().createMany(10);
final products = await Factory.product()
    .expensive()
    .inStock()
    .createMany(5);

// Complex scenarios
final blogScenario = await Factory.createBlogScenario();
final ecommerceScenario = await Factory.createEcommerceScenario();
```

### 3. Usage Examples

#### Basic Test Setup

```dart
group('My Feature Tests', () {
  late TestDataSeeds testData;
  
  setUp(() async {
    await DatabaseHelper.initializeTestDatabase();
    await DatabaseHelper.createAllTestTables();
    testData = await DatabaseHelper.seedTestData();
    ModelFactory.resetSequences();
  });

  tearDown(() async {
    await DatabaseHelper.closeTestDatabase();
  });

  test('should work with seeded data', () async {
    final user = testData.primaryUser;
    final post = testData.publishedPost;
    
    expect(user.id, isNotNull);
    expect(post.authorId, equals(user.id));
  });
});
```

#### Using Factory Pattern

```dart
test('should create user with factory', () async {
  final user = await Factory.user()
      .withName('Test User')
      .withEmail('test@example.com')
      .active()
      .create();

  expect(user.isActive, isTrue);
  expect(user.createdAt, isNotNull);
});
```

#### Complex Scenario Testing

```dart
test('should create blog scenario', () async {
  final scenario = await Factory.createBlogScenario();
  
  expect(scenario.categories, hasLength(2));
  expect(scenario.users, hasLength(2));
  expect(scenario.posts, hasLength(2));
  expect(scenario.comments, hasLength(2));
  
  // Test relationships
  expect(scenario.subCategory.parentId, equals(scenario.rootCategory.id));
  expect(scenario.publishedPost.authorId, equals(scenario.author.id));
});
```

#### Validation Testing with Test Data

```dart
test('should validate with test data', () {
  final user = TestValidationUser();
  user.initializeValidation();
  
  // Use predefined invalid data
  final invalidData = TestData.invalidUserData;
  user.name = invalidData['name']; // Too short
  user.email = invalidData['email']; // Invalid format
  
  final result = user.validateModel();
  expect(result.isValid, isFalse);
  expect(result.hasFieldError('name'), isTrue);
  expect(result.hasFieldError('email'), isTrue);
});
```

## Benefits

### 1. **Reduced Code Duplication**
- Shared test models eliminate repetitive model definitions
- Common setup/teardown patterns through helpers
- Reusable data sets across multiple test files

### 2. **Improved Test Maintainability**
- Changes to test data structure only need updates in one place
- Consistent field types and validation rules
- Centralized database management

### 3. **Enhanced Readability**
- Expressive factory methods make test intent clear
- Complex scenarios become simple one-liners
- Consistent naming and patterns across tests

### 4. **Better Test Coverage**
- Predefined edge cases and validation scenarios
- Performance testing utilities
- Relationship testing with proper foreign keys

### 5. **Flexible and Extensible**
- Builder pattern allows easy customization
- Scenario factories for common use cases
- Trait-based model creation (active/inactive, published/draft, etc.)

## Migration Guide

To migrate existing tests to use these helpers:

1. **Replace manual database setup:**
   ```dart
   // Before
   setUp(() async {
     Database.reset();
     await Database.initialize(databasePath: ':memory:');
     // Manual table creation...
   });
   
   // After
   setUp(() async {
     await DatabaseHelper.setupTestEnvironment();
   });
   ```

2. **Use factory instead of manual model creation:**
   ```dart
   // Before
   final user = TestUser();
   user.name = 'John Doe';
   user.email = 'john@example.com';
   user.status = 'active';
   await user.save();
   
   // After
   final user = await Factory.user()
       .withName('John Doe')
       .withEmail('john@example.com')
       .active()
       .create();
   ```

3. **Replace hardcoded test data:**
   ```dart
   // Before
   user.email = 'invalid-email'; // Hardcoded
   
   // After
   final invalidData = TestData.invalidUserData;
   user.email = invalidData['email']; // Predefined
   ```

## Performance Considerations

- **In-memory database** for fast test execution
- **Bulk insertion helpers** for large dataset testing
- **Execution time measurement** utilities
- **Transaction helpers** for rollback testing
- **Table clearing** instead of recreation for better performance

The test utilities provide a solid foundation for writing maintainable, readable, and comprehensive tests while significantly reducing code duplication across the test suite.
