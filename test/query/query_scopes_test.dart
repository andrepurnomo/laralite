import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

// Simple test model for scopes
class User extends Model<User> {
  final _id = AutoIncrementField();
  final _name = StringField(required: true);
  final _email = StringField(unique: true);
  final _active = BoolField(defaultValue: true);
  final _age = IntField();
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);
  
  @override
  String get table => 'users';
  
  @override
  bool get timestamps => true;
  
  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('email', _email);
    registerField('active', _active);
    registerField('age', _age);
    registerField('created_at', _createdAt);
    registerField('updated_at', _updatedAt);
  }
  
  @override
  void initializeScopes() {
    // Register local scopes
    registerLocalScope('active', (query) => query.where('active', true));
    registerLocalScope('inactive', (query) => query.where('active', false));
    registerLocalScope('adults', (query) => query.where('age', '>=', 18));
    registerLocalScope('recent', (query) => query.orderByDesc('created_at'));
  }
  
  // Getters and setters
  int? get id => getValue<int>('id');
  set id(int? value) => setValue<int>('id', value);
  
  String? get name => getValue<String>('name');
  set name(String? value) => setValue<String>('name', value);
  
  String? get email => getValue<String>('email');
  set email(String? value) => setValue<String>('email', value);
  
  bool? get isActive => getValue<bool>('active');
  set isActive(bool? value) => setValue<bool>('active', value);
  
  int? get age => getValue<int>('age');
  set age(int? value) => setValue<int>('age', value);
  
  DateTime? get createdAt => getValue<DateTime>('created_at');
  DateTime? get updatedAt => getValue<DateTime>('updated_at');
}

void main() async {
  // Initialize database connection
  await Database.initialize(databasePath: ':memory:');
  
  group('Query Scopes Tests', () {
    setUp(() async {
      // Create tables
      await Database.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE,
          active INTEGER DEFAULT 1,
          age INTEGER,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    });
    
    tearDown(() async {
      await Database.execute('DROP TABLE IF EXISTS users');
    });
    
    group('Query Builder Tests', () {
      test('should create basic query builder', () {
        final query = Model.query<User>(() => User());
        expect(query, isA<QueryBuilder<User>>());
        expect(query.table, equals('users'));
      });
      
      test('should support WHERE conditions', () async {
        // Create test users
        final user1 = User()..name = 'John'..email = 'john@test.com'..isActive = true..age = 25;
        final user2 = User()..name = 'Jane'..email = 'jane@test.com'..isActive = false..age = 30;
        await user1.save();
        await user2.save();
        
        // Test WHERE condition
        final activeUsers = await Model.where<User>(() => User(), 'active', true).get();
        expect(activeUsers, hasLength(1));
        expect(activeUsers.first.name, equals('John'));
      });
      
      test('should support WHERE IN conditions', () async {
        // Create test users
        final user1 = User()..name = 'John'..email = 'john@test.com'..age = 25;
        final user2 = User()..name = 'Jane'..email = 'jane@test.com'..age = 30;
        final user3 = User()..name = 'Bob'..email = 'bob@test.com'..age = 35;
        await user1.save();
        await user2.save();
        await user3.save();
        
        // Test WHERE IN condition
        final youngUsers = await Model.whereIn<User>(() => User(), 'age', [25, 30]).get();
        expect(youngUsers, hasLength(2));
        expect(youngUsers.map((u) => u.name), containsAll(['John', 'Jane']));
      });
      
      test('should support ORDER BY clauses', () async {
        // Create test users
        final user1 = User()..name = 'John'..email = 'john@test.com'..age = 30;
        final user2 = User()..name = 'Jane'..email = 'jane@test.com'..age = 25;
        final user3 = User()..name = 'Bob'..email = 'bob@test.com'..age = 35;
        await user1.save();
        await user2.save();
        await user3.save();
        
        // Test ORDER BY ASC
        final usersByAge = await Model.orderBy<User>(() => User(), 'age', 'ASC').get();
        expect(usersByAge.map((u) => u.age), equals([25, 30, 35]));
        
        // Test ORDER BY DESC
        final usersByAgeDesc = await Model.orderBy<User>(() => User(), 'age', 'DESC').get();
        expect(usersByAgeDesc.map((u) => u.age), equals([35, 30, 25]));
      });
      
      test('should support LIMIT', () async {
        // Create test users
        for (int i = 1; i <= 5; i++) {
          final user = User()..name = 'User$i'..email = 'user$i@test.com'..age = 20 + i;
          await user.save();
        }
        
        // Test LIMIT
        final limitedUsers = await Model.limit<User>(() => User(), 3).get();
        expect(limitedUsers, hasLength(3));
      });
      
      test('should support complex queries', () async {
        // Create test users
        for (int i = 1; i <= 5; i++) {
          final user = User()..name = 'User$i'..email = 'user$i@test.com'..age = 20 + i;
          await user.save();
        }
        
        // Test complex query with multiple clauses
        final complexQuery = await Model.query<User>(() => User())
            .where('age', '>', 22)
            .orderBy('age')
            .limit(2)
            .get();
        expect(complexQuery, hasLength(2));
        expect(complexQuery.first.age, equals(23));
      });
    });
    
    group('Local Scopes Tests', () {
      test('should register and check local scopes', () {
        final user = User();
        expect(user.scopes.hasLocalScope('active'), isTrue);
        expect(user.scopes.hasLocalScope('adults'), isTrue);
        expect(user.scopes.hasLocalScope('nonexistent'), isFalse);
      });
      
      test('should apply scopes using Model.scope', () async {
        // Create test users
        final user1 = User()..name = 'John'..email = 'john@test.com'..isActive = true;
        final user2 = User()..name = 'Jane'..email = 'jane@test.com'..isActive = false;
        await user1.save();
        await user2.save();
        
        // Test active scope
        final activeUsers = await Model.scope<User>(() => User(), 'active').get();
        expect(activeUsers, hasLength(1));
        expect(activeUsers.first.name, equals('John'));
      });
      
      test('should apply adults scope correctly', () async {
        // Create test users
        final user1 = User()..name = 'John'..email = 'john@test.com'..age = 25;
        final user2 = User()..name = 'Jane'..email = 'jane@test.com'..age = 16;
        final user3 = User()..name = 'Bob'..email = 'bob@test.com'..age = 30;
        await user1.save();
        await user2.save();
        await user3.save();
        
        // Test adults scope
        final adults = await Model.scope<User>(() => User(), 'adults').get();
        expect(adults, hasLength(2));
        expect(adults.map((u) => u.name), containsAll(['John', 'Bob']));
      });
      
      test('should chain scopes with query builder methods', () async {
        // Create test users
        final user1 = User()..name = 'John'..email = 'john@test.com'..isActive = true..age = 25;
        final user2 = User()..name = 'Jane'..email = 'jane@test.com'..isActive = true..age = 16;
        final user3 = User()..name = 'Bob'..email = 'bob@test.com'..isActive = false..age = 30;
        await user1.save();
        await user2.save();
        await user3.save();
        
        // Test chaining scopes with additional conditions
        final activeAdults = await Model.scope<User>(() => User(), 'active')
            .where('age', '>=', 18)
            .get();
        expect(activeAdults, hasLength(1));
        expect(activeAdults.first.name, equals('John'));
      });
    });
    
    group('Query Builder Methods Tests', () {
      test('should support first() method', () async {
        // Create test users
        final user1 = User()..name = 'John'..email = 'john@test.com'..age = 25;
        final user2 = User()..name = 'Jane'..email = 'jane@test.com'..age = 30;
        await user1.save();
        await user2.save();
        
        // Test first() method
        final firstUser = await Model.query<User>(() => User()).orderBy('age').first();
        expect(firstUser, isNotNull);
        expect(firstUser!.name, equals('John'));
      });
      
      test('should support count() method', () async {
        // Create test users
        for (int i = 1; i <= 5; i++) {
          final user = User()..name = 'User$i'..email = 'user$i@test.com'..age = 20 + i;
          await user.save();
        }
        
        // Test count() method
        final totalCount = await Model.query<User>(() => User()).count();
        expect(totalCount, equals(5));
        
        // Test count with conditions
        final adultCount = await Model.query<User>(() => User()).where('age', '>=', 23).count();
        expect(adultCount, equals(3));
      });
      
      test('should support exists() method', () async {
        // Initially no users
        final hasUsers = await Model.query<User>(() => User()).exists();
        expect(hasUsers, isFalse);
        
        // Create a user
        final user = User()..name = 'John'..email = 'john@test.com';
        await user.save();
        
        // Now should exist
        final hasUsersNow = await Model.query<User>(() => User()).exists();
        expect(hasUsersNow, isTrue);
        
        // Test exists with conditions
        final hasOldUsers = await Model.query<User>(() => User()).where('age', '>', 50).exists();
        expect(hasOldUsers, isFalse);
      });
      
      test('should support when() conditional method', () async {
        // Create test users
        final user1 = User()..name = 'John'..email = 'john@test.com'..age = 25;
        final user2 = User()..name = 'Jane'..email = 'jane@test.com'..age = 16;
        await user1.save();
        await user2.save();
        
        // Test conditional scoping
        bool filterByAge = true;
        final users = await Model.query<User>(() => User())
            .when(filterByAge, (query) => query.where('age', '>=', 18))
            .get();
        
        expect(users, hasLength(1));
        expect(users.first.name, equals('John'));
        
        // Test when condition is false
        filterByAge = false;
        final allUsers = await Model.query<User>(() => User())
            .when(filterByAge, (query) => query.where('age', '>=', 18))
            .get();
        
        expect(allUsers, hasLength(2));
      });
    });
    
    group('Helper Scope Functions Tests', () {
      test('should use helper scope functions', () async {
        // Create test users
        final user1 = User()..name = 'John'..email = 'john@test.com'..age = 25;
        final user2 = User()..name = 'Jane'..email = 'jane@test.com'..age = 30;
        await user1.save();
        await user2.save();
        
        // Test using where scope helper
        final youngScope = whereScope<User>('age', 25);
        final queryBuilder = Model.query<User>(() => User());
        final youngUsers = await youngScope(queryBuilder).get();
        expect(youngUsers, hasLength(1));
        expect(youngUsers.first.name, equals('John'));
      });
      
      test('should use search scope helper', () async {
        // Create test users
        final user1 = User()..name = 'John Doe'..email = 'john@test.com';
        final user2 = User()..name = 'Jane Smith'..email = 'jane@test.com';
        await user1.save();
        await user2.save();
        
        // Test search scope
        final searchScopeFunction = searchScope<User>('name', 'John');
        final queryBuilder = Model.query<User>(() => User());
        final searchResults = await searchScopeFunction(queryBuilder).get();
        expect(searchResults, hasLength(1));
        expect(searchResults.first.name, equals('John Doe'));
      });
      
      test('should use dateRangeScope helper', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(Duration(days: 1)).toIso8601String();
        final tomorrow = now.add(Duration(days: 1)).toIso8601String();
        
        final dateScope = dateRangeScope<User>('created_at', DateTime.parse(yesterday), DateTime.parse(tomorrow));
        final queryBuilder = Model.query<User>(() => User());
        final query = dateScope(queryBuilder);
        
        // Test SQL generation for date range scope
        expect(query.toSql(), contains('WHERE created_at >= ?'));
        expect(query.toSql(), contains('AND created_at <= ?'));
      });
      
      test('should use limitScope helper', () async {
        for (int i = 1; i <= 5; i++) {
          final user = User()..name = 'User$i'..email = 'user$i@test.com';
          await user.save();
        }
        
        final limitScopeFunction = limitScope<User>(3);
        final queryBuilder = Model.query<User>(() => User());
        final limitedUsers = await limitScopeFunction(queryBuilder).get();
        expect(limitedUsers, hasLength(3));
      });
      
      test('should use recentScope helper', () async {
        for (int i = 1; i <= 3; i++) {
          final user = User()..name = 'User$i'..email = 'user$i@test.com';
          await user.save();
          await Future.delayed(Duration(milliseconds: 10));
        }
        
        final recentScopeFunction = recentScope<User>('created_at', Duration(days: 1));
        final queryBuilder = Model.query<User>(() => User());
        final query = recentScopeFunction(queryBuilder);
        
        // Test SQL generation for recent scope
        expect(query.toSql(), contains('ORDER BY created_at DESC'));
        expect(query.toSql(), contains('WHERE created_at >= ?'));
      });
    });
    
    group('Global Scopes Tests', () {
      test('should apply ActiveScope globally', () {
        final scope = ActiveScope<User>();
        final query = Model.query<User>(() => User());
        final scopedQuery = scope.apply(query);
        
        expect(scopedQuery.toSql(), contains('WHERE active = ?'));
        expect(scopedQuery.getBindings(), contains(true));
      });
      
      test('should apply SoftDeleteScope globally', () {
        final scope = SoftDeleteScope<User>();
        final query = Model.query<User>(() => User());
        final scopedQuery = scope.apply(query);
        
        expect(scopedQuery.toSql(), contains('WHERE deleted_at IS NULL'));
      });
      
      test('should apply PublishedScope globally', () {
        final scope = PublishedScope<User>();
        final query = Model.query<User>(() => User());
        final scopedQuery = scope.apply(query);
        
        expect(scopedQuery.toSql(), contains('WHERE published = ?'));
        expect(scopedQuery.getBindings(), contains(true));
      });
      
      test('should apply RecentScope ordering', () {
        final scope = RecentScope<User>();
        final query = Model.query<User>(() => User());
        final scopedQuery = scope.apply(query);
        
        expect(scopedQuery.toSql(), contains('ORDER BY created_at DESC'));
      });
      
      test('should apply PopularScope ordering', () {
        final scope = PopularScope<User>();
        final query = Model.query<User>(() => User());
        final scopedQuery = scope.apply(query);
        
        expect(scopedQuery.toSql(), contains('ORDER BY view_count DESC'));
      });
      
      test('should register and apply global scopes through registry', () {
        final user = User();
        final registry = user.scopes;
        final activeScope = ActiveScope<User>();
        
        registry.registerGlobal(activeScope);
        expect(registry.getGlobalScopes(), contains(activeScope));
        
        final query = Model.query<User>(() => User());
        final scopedQuery = registry.applyGlobalScopes(query);
        expect(scopedQuery.toSql(), contains('WHERE active = ?'));
      });
    });
  });
}
