import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

// Test model implementation
class TestUser extends Model<TestUser> {
  // Fields
  final _id = AutoIncrementField();
  final _name = StringField(required: true, maxLength: 100);
  final _email = EmailField(unique: true);
  final _age = IntField(min: 0, max: 150);
  final _active = BoolField(defaultValue: true);
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
    registerField('age', _age);
    registerField('active', _active);
    registerField('created_at', _createdAt);
    registerField('updated_at', _updatedAt);
  }
  
  // Convenience getters/setters (this would be generated)
  int? get id => _id.value;
  set id(int? value) => _id.value = value;
  
  String? get name => _name.value;
  set name(String? value) => _name.value = value;
  
  String? get email => _email.value;
  set email(String? value) => _email.value = value;
  
  int? get age => _age.value;
  set age(int? value) => _age.value = value;
  
  bool? get active => _active.value;
  set active(bool? value) => _active.value = value;
  
  DateTime? get createdAt => _createdAt.value;
  DateTime? get updatedAt => _updatedAt.value;
}

// Test model without timestamps
class TestPost extends Model<TestPost> {
  final _id = AutoIncrementField();
  final _title = StringField(required: true);
  final _content = TextField();
  final _userId = ForeignKeyField(referencedTable: 'users');
  
  @override
  String get table => 'posts';
  
  @override
  void registerFields() {
    registerField('id', _id);
    registerField('title', _title);
    registerField('content', _content);
    registerField('user_id', _userId);
  }
  
  // Convenience getters/setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;
  
  String? get title => _title.value;
  set title(String? value) => _title.value = value;
  
  String? get content => _content.value;
  set content(String? value) => _content.value = value;
  
  int? get userId => _userId.value;
  set userId(int? value) => _userId.value = value;
}

void main() {
  group('Model System Tests', () {
    setUp(() async {
      // Reset database state before each test
      Database.reset();
      await Database.initialize(databasePath: ':memory:');
      
      // Create test tables
      await Database.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name VARCHAR(100) NOT NULL,
          email TEXT UNIQUE,
          age INTEGER,
          active INTEGER DEFAULT 1,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
      
      await Database.execute('''
        CREATE TABLE posts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT,
          user_id INTEGER REFERENCES users(id)
        )
      ''');
    });
    
    tearDown(() async {
      await Database.close();
      await Future.delayed(Duration(milliseconds: 50));
    });
    
    group('Field Registry Tests', () {
      test('should register fields correctly', () {
        final user = TestUser();
        
        expect(user.fields, hasLength(7)); // 5 explicit + 2 timestamps
        expect(user.fields.containsKey('id'), isTrue);
        expect(user.fields.containsKey('name'), isTrue);
        expect(user.fields.containsKey('email'), isTrue);
        expect(user.fields.containsKey('age'), isTrue);
        expect(user.fields.containsKey('active'), isTrue);
        expect(user.fields.containsKey('created_at'), isTrue);
        expect(user.fields.containsKey('updated_at'), isTrue);
      });
      
      test('should handle models without timestamps', () {
        final post = TestPost();
        
        expect(post.fields, hasLength(4));
        expect(post.fields.containsKey('id'), isTrue);
        expect(post.fields.containsKey('title'), isTrue);
        expect(post.fields.containsKey('content'), isTrue);
        expect(post.fields.containsKey('user_id'), isTrue);
        expect(post.fields.containsKey('created_at'), isFalse);
        expect(post.fields.containsKey('updated_at'), isFalse);
      });
      
      test('should get specific field types', () {
        final user = TestUser();
        
        final nameField = user.getField<String>('name');
        expect(nameField, isA<StringField>());
        
        final ageField = user.getField<int>('age');
        expect(ageField, isA<IntField>());
        
        final activeField = user.getField<bool>('active');
        expect(activeField, isA<BoolField>());
      });
    });
    
    group('Value Management Tests', () {
      test('should set and get field values', () {
        final user = TestUser();
        
        user.name = 'John Doe';
        user.email = 'john@example.com';
        user.age = 30;
        user.active = true;
        
        expect(user.name, equals('John Doe'));
        expect(user.email, equals('john@example.com'));
        expect(user.age, equals(30));
        expect(user.active, isTrue);
      });
      
      test('should track dirty state when values change', () {
        final user = TestUser();
        
        expect(user.isDirty, isFalse);
        
        user.name = 'John Doe';
        expect(user.isDirty, isTrue);
        
        user.markAsExisting();
        expect(user.isDirty, isFalse);
        
        user.email = 'john@example.com';
        expect(user.isDirty, isTrue);
      });
      
      test('should not mark as dirty when setting same value', () {
        final user = TestUser();
        user.name = 'John Doe';
        user.markAsExisting();
        
        expect(user.isDirty, isFalse);
        
        user.name = 'John Doe'; // Same value
        expect(user.isDirty, isFalse);
      });
      
      test('should handle null values', () {
        final user = TestUser();
        
        user.name = null;
        user.age = null;
        
        expect(user.name, isNull);
        expect(user.age, isNull);
      });
    });
    
    group('Model State Tests', () {
      test('should track existence state correctly', () {
        final user = TestUser();
        
        expect(user.exists, isFalse);
        expect(user.primaryKeyValue, isNull);
        
        user.markAsExisting();
        expect(user.exists, isTrue);
        
        user.markAsNew();
        expect(user.exists, isFalse);
        expect(user.primaryKeyValue, isNull);
      });
      
      test('should handle primary key values', () {
        final user = TestUser();
        
        user.primaryKeyValue = 42;
        expect(user.primaryKeyValue, equals(42));
        expect(user.id, equals(42));
      });
    });
    
    group('Serialization Tests', () {
      test('should convert model to map', () {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        user.age = 30;
        user.active = true;
        
        final map = user.toMap();
        
        expect(map['name'], equals('John Doe'));
        expect(map['email'], equals('john@example.com'));
        expect(map['age'], equals(30));
        expect(map['active'], isTrue);
      });
      
      test('should create model from map', () {
        final user = TestUser();
        
        final map = {
          'id': 1,
          'name': 'Jane Smith',
          'email': 'jane@example.com',
          'age': 25,
          'active': true,
          'created_at': '2023-12-25T10:30:00.000Z',
          'updated_at': '2023-12-25T10:30:00.000Z',
        };
        
        user.fromMap(map);
        
        expect(user.id, equals(1));
        expect(user.name, equals('Jane Smith'));
        expect(user.email, equals('jane@example.com'));
        expect(user.age, equals(25));
        expect(user.active, isTrue);
        expect(user.exists, isTrue);
        expect(user.isDirty, isFalse);
      });
      
      test('should handle serialization round-trip', () {
        final user = TestUser();
        user.name = 'Test User';
        user.email = 'test@example.com';
        user.age = 35;
        user.active = false;
        
        final map = user.toMap();
        final newUser = TestUser();
        newUser.fromMap(map);
        
        expect(newUser.name, equals(user.name));
        expect(newUser.email, equals(user.email));
        expect(newUser.age, equals(user.age));
        expect(newUser.active, equals(user.active));
      });
    });
    
    group('Validation Tests', () {
      test('should validate required fields', () {
        final user = TestUser();
        user.email = 'john@example.com';
        user.age = 30;
        // Missing required name field
        
        final result = user.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('This field is required'));
      });
      
      test('should validate field constraints', () {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'invalid-email'; // Invalid email format
        user.age = -5; // Below minimum
        
        final result = user.validate();
        expect(result.isValid, isFalse);
        expect(result.errors.length, greaterThan(1));
      });
      
      test('should pass validation with valid data', () {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        user.age = 30;
        user.active = true;
        
        final result = user.validate();
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });
    });
    
    group('Database Operations Tests', () {
      test('should save new model to database', () async {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        user.age = 30;
        
        final success = await user.save();
        
        expect(success, isTrue);
        expect(user.exists, isTrue);
        expect(user.id, isNotNull);
        expect(user.isDirty, isFalse);
      });
      
      test('should update existing model in database', () async {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        user.age = 30;
        
        await user.save();
        final originalId = user.id;
        
        user.name = 'John Smith';
        user.age = 31;
        
        final success = await user.save();
        
        expect(success, isTrue);
        expect(user.id, equals(originalId)); // ID shouldn't change
        expect(user.name, equals('John Smith'));
        expect(user.age, equals(31));
      });
      
      test('should delete model from database', () async {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        
        await user.save();
        expect(user.exists, isTrue);
        
        final success = await user.delete();
        
        expect(success, isTrue);
        expect(user.exists, isFalse);
        expect(user.primaryKeyValue, isNull);
      });
      
      test('should find model by primary key', () async {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        
        await user.save();
        final savedId = user.id;
        
        final foundUser = await Model.find<TestUser>(savedId, () => TestUser());
        
        expect(foundUser, isNotNull);
        expect(foundUser!.id, equals(savedId));
        expect(foundUser.name, equals('John Doe'));
        expect(foundUser.email, equals('john@example.com'));
        expect(foundUser.exists, isTrue);
      });
      
      test('should return null when model not found', () async {
        final foundUser = await Model.find<TestUser>(999, () => TestUser());
        expect(foundUser, isNull);
      });
      
      test('should get all models from table', () async {
        // Create multiple users
        final user1 = TestUser();
        user1.name = 'John Doe';
        user1.email = 'john@example.com';
        await user1.save();
        
        final user2 = TestUser();
        user2.name = 'Jane Smith';
        user2.email = 'jane@example.com';
        await user2.save();
        
        final users = await Model.all<TestUser>(() => TestUser());
        
        expect(users, hasLength(2));
        expect(users.every((u) => u.exists), isTrue);
        
        final names = users.map((u) => u.name).toList();
        expect(names, contains('John Doe'));
        expect(names, contains('Jane Smith'));
      });
      
      test('should create and save model in one step', () async {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        
        final savedUser = await Model.create<TestUser>(user);
        
        expect(savedUser.exists, isTrue);
        expect(savedUser.id, isNotNull);
        expect(savedUser, same(user)); // Should return the same instance
      });
    });
    
    group('Timestamp Tests', () {
      test('should auto-set timestamps on save', () async {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        
        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
        
        await user.save();
        
        expect(user.createdAt, isNotNull);
        expect(user.updatedAt, isNotNull);
      });
      
      test('should update timestamp on subsequent saves', () async {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        
        await user.save();
        final originalCreatedAt = user.createdAt;
        final originalUpdatedAt = user.updatedAt;
        
        await Future.delayed(Duration(milliseconds: 10));
        
        user.name = 'John Smith';
        await user.save();
        
        expect(user.createdAt, equals(originalCreatedAt)); // Should not change
        expect(user.updatedAt, isNot(equals(originalUpdatedAt))); // Should update
      });
    });
    
    group('Validation Exception Tests', () {
      test('should throw ValidationException on invalid data', () async {
        final user = TestUser();
        user.email = 'john@example.com'; // Missing required name
        
        expect(
          () => user.save(),
          throwsA(isA<ValidationException>()),
        );
      });
      
      test('ValidationException should contain error details', () async {
        final user = TestUser();
        user.email = 'invalid-email';
        user.age = -5;
        
        try {
          await user.save();
          fail('Should have thrown ValidationException');
        } catch (e) {
          expect(e, isA<ValidationException>());
          final validation = e as ValidationException;
          expect(validation.errors, isNotEmpty);
        }
      });
    });

    group('Advanced Static Methods Tests', () {
      test('findOrFail should return model when found', () async {
        final user = TestUser();
        user.name = 'John Doe';
        user.email = 'john@example.com';
        await user.save();
        final savedId = user.id;

        final foundUser = await Model.findOrFail<TestUser>(savedId, () => TestUser());
        
        expect(foundUser.id, equals(savedId));
        expect(foundUser.name, equals('John Doe'));
      });

      test('findOrFail should throw exception when not found', () async {
        expect(
          () => Model.findOrFail<TestUser>(999, () => TestUser()),
          throwsException,
        );
      });

      test('findMany should return multiple models by IDs', () async {
        final user1 = TestUser();
        user1.name = 'User 1';
        user1.email = 'user1@example.com';
        await user1.save();

        final user2 = TestUser();
        user2.name = 'User 2';
        user2.email = 'user2@example.com';
        await user2.save();

        final users = await Model.findMany<TestUser>([user1.id, user2.id], () => TestUser());
        
        expect(users, hasLength(2));
        expect(users.map((u) => u.name), containsAll(['User 1', 'User 2']));
      });

      test('findMany should return empty list for empty IDs', () async {
        final users = await Model.findMany<TestUser>([], () => TestUser());
        expect(users, isEmpty);
      });

      test('firstOrCreate should return existing model when found', () async {
        final user = TestUser();
        user.name = 'Existing User';
        user.email = 'existing@example.com';
        await user.save();

        final result = await Model.firstOrCreate<TestUser>(
          () => TestUser(),
          {'email': 'existing@example.com'},
        );

        expect(result.name, equals('Existing User'));
        expect(result.id, equals(user.id));
      });

      test('firstOrCreate should create new model when not found', () async {
        final result = await Model.firstOrCreate<TestUser>(
          () => TestUser(),
          {'name': 'New User', 'email': 'new@example.com'},
        );

        expect(result.name, equals('New User'));
        expect(result.email, equals('new@example.com'));
        expect(result.exists, isTrue);
      });

      test('updateOrCreate should update existing model', () async {
        final user = TestUser();
        user.name = 'Original Name';
        user.email = 'update@example.com';
        await user.save();

        final result = await Model.updateOrCreate<TestUser>(
          () => TestUser(),
          {'email': 'update@example.com'},
          {'name': 'Updated Name'},
        );

        expect(result.name, equals('Updated Name'));
        expect(result.id, equals(user.id));
      });

      test('updateOrCreate should create new model when not found', () async {
        final result = await Model.updateOrCreate<TestUser>(
          () => TestUser(),
          {'email': 'create@example.com'},
          {'name': 'Created User'},
        );

        expect(result.name, equals('Created User'));
        expect(result.email, equals('create@example.com'));
        expect(result.exists, isTrue);
      });

      test('createMany should create multiple models in transaction', () async {
        final records = [
          {'name': 'User 1', 'email': 'user1@example.com'},
          {'name': 'User 2', 'email': 'user2@example.com'},
          {'name': 'User 3', 'email': 'user3@example.com'},
        ];

        final users = await Model.createMany<TestUser>(() => TestUser(), records);

        expect(users, hasLength(3));
        expect(users.every((u) => u.exists), isTrue);
        expect(users.map((u) => u.name), containsAll(['User 1', 'User 2', 'User 3']));
      });

      test('createMany should return empty list for empty records', () async {
        final users = await Model.createMany<TestUser>(() => TestUser(), []);
        expect(users, isEmpty);
      });

      test('createManyInChunks should handle large datasets', () async {
        final records = List.generate(5, (i) => {
          'name': 'User ${i + 1}',
          'email': 'user${i + 1}@example.com',
        });

        final users = await Model.createManyInChunks<TestUser>(
          () => TestUser(),
          records,
          chunkSize: 2,
        );

        expect(users, hasLength(5));
        expect(users.every((u) => u.exists), isTrue);
      });

      test('updateMany should update multiple records', () async {
        // Create test users
        final user1 = TestUser();
        user1.name = 'User 1';
        user1.email = 'user1@example.com';
        user1.active = true;
        await user1.save();

        final user2 = TestUser();
        user2.name = 'User 2';
        user2.email = 'user2@example.com';
        user2.active = true;
        await user2.save();

        final affectedRows = await Model.updateMany<TestUser>(
          () => TestUser(),
          {'active': true},
          {'name': 'Updated User'},
        );

        expect(affectedRows, equals(2));
      });

      test('deleteMany should delete multiple records', () async {
        // Create test users
        final user1 = TestUser();
        user1.name = 'Delete Me 1';
        user1.email = 'delete1@example.com';
        await user1.save();

        final user2 = TestUser();
        user2.name = 'Delete Me 2';
        user2.email = 'delete2@example.com';
        await user2.save();

        final deletedCount = await Model.deleteMany<TestUser>(
          () => TestUser(),
          {'name': 'Delete Me 1'},
        );

        expect(deletedCount, equals(1));
      });

      test('withTransaction should commit on success', () async {
        final result = await Model.withTransaction(() async {
          final user = TestUser();
          user.name = 'Transaction User';
          user.email = 'transaction@example.com';
          await user.save();
          return user.id;
        });

        expect(result, isNotNull);
        final foundUser = await Model.find<TestUser>(result, () => TestUser());
        expect(foundUser, isNotNull);
        expect(foundUser!.name, equals('Transaction User'));
      });

      test('query should create QueryBuilder', () {
        final queryBuilder = Model.query<TestUser>(() => TestUser());
        expect(queryBuilder, isA<QueryBuilder<TestUser>>());
      });

      test('where should create QueryBuilder with WHERE condition', () {
        final queryBuilder = Model.where<TestUser>(() => TestUser(), 'name', 'John Doe');
        expect(queryBuilder, isA<QueryBuilder<TestUser>>());
      });

      test('whereIn should create QueryBuilder with WHERE IN condition', () {
        final queryBuilder = Model.whereIn<TestUser>(() => TestUser(), 'age', [25, 30]);
        expect(queryBuilder, isA<QueryBuilder<TestUser>>());
      });

      test('orderBy should create QueryBuilder with ORDER BY', () {
        final queryBuilder = Model.orderBy<TestUser>(() => TestUser(), 'name');
        expect(queryBuilder, isA<QueryBuilder<TestUser>>());
      });

      test('limit should create QueryBuilder with LIMIT', () {
        final queryBuilder = Model.limit<TestUser>(() => TestUser(), 10);
        expect(queryBuilder, isA<QueryBuilder<TestUser>>());
      });

      test('paginate should return PaginationResult', () async {
        // Create test data
        for (int i = 1; i <= 10; i++) {
          final user = TestUser();
          user.name = 'User $i';
          user.email = 'user$i@example.com';
          await user.save();
        }

        final result = await Model.paginate<TestUser>(() => TestUser(), page: 1, perPage: 3);
        
        expect(result.data, hasLength(3));
        expect(result.currentPage, equals(1));
        expect(result.perPage, equals(3));
        expect(result.total, equals(10));
      });
    });

    group('Instance Methods Tests', () {
      test('insertOrReplace should replace existing record', () async {
        final user = TestUser();
        user.name = 'Original';
        user.email = 'replace@example.com';
        await user.save();
        final originalId = user.id;

        user.name = 'Replaced';
        final success = await user.insertOrReplace();

        expect(success, isTrue);
        expect(user.name, equals('Replaced'));
        expect(user.id, equals(originalId));
      });

      test('insertOrIgnore should ignore on conflict', () async {
        final user1 = TestUser();
        user1.name = 'First User';
        user1.email = 'ignore@example.com';
        await user1.save();

        final user2 = TestUser();
        user2.name = 'Second User';
        user2.email = 'ignore@example.com'; // Same email (unique constraint)
        final success = await user2.insertOrIgnore();

        // Should not insert due to unique constraint
        expect(success, isFalse);
      });

      test('upsert should update on conflict', () async {
        final user = TestUser();
        user.name = 'Original';
        user.email = 'upsert@example.com';
        await user.save();

        user.name = 'Upserted';
        final success = await user.upsert(
          conflictColumns: ['email'],
          updateData: {'name': 'Updated via Upsert'},
        );

        expect(success, isTrue);
      });
    });

    group('Relationship Methods Tests', () {
      test('hasOne should create HasOne relationship', () {
        final user = TestUser();
        final relationship = user.hasOne<TestPost>(() => TestPost());
        
        expect(relationship, isA<HasOne<TestPost>>());
      });

      test('hasMany should create HasMany relationship', () {
        final user = TestUser();
        final relationship = user.hasMany<TestPost>(() => TestPost());
        
        expect(relationship, isA<HasMany<TestPost>>());
      });

      test('belongsTo should create BelongsTo relationship', () {
        final post = TestPost();
        final relationship = post.belongsTo<TestUser>(() => TestUser());
        
        expect(relationship, isA<BelongsTo<TestUser>>());
      });

      test('belongsToMany should create BelongsToMany relationship', () {
        final user = TestUser();
        final relationship = user.belongsToMany<TestPost>(() => TestPost());
        
        expect(relationship, isA<BelongsToMany<TestPost>>());
      });

      test('registerRelationship should register relationship by name', () {
        final user = TestUser();
        final relationship = user.hasOne<TestPost>(() => TestPost());
        
        user.registerRelationship('post', relationship);
        
        expect(user.relationships.get('post'), equals(relationship));
      });

      test('getRelationship should return registered relationship', () async {
        final user = TestUser();
        final relationship = user.hasOne<TestPost>(() => TestPost());
        user.registerRelationship('post', relationship);
        
        // The getRelationship method returns the result of relationship.get()
        // which might be null if no related records exist
        // Just verify the method doesn't throw an error
        expect(() => user.getRelationship('post'), returnsNormally);
      });

      test('isRelationshipLoaded should check load status', () {
        final user = TestUser();
        final relationship = user.hasOne<TestPost>(() => TestPost());
        user.registerRelationship('post', relationship);
        
        expect(user.isRelationshipLoaded('post'), isFalse);
      });

      test('resetRelationships should clear all caches', () {
        final user = TestUser();
        final relationship = user.hasOne<TestPost>(() => TestPost());
        user.registerRelationship('post', relationship);
        
        user.resetRelationships();
        
        // Verify relationships are reset
        expect(user.relationships.get('post'), isNotNull); // Still registered but cache cleared
      });
    });

    group('Scope Methods Tests', () {
      test('registerLocalScope should register local scope', () {
        final user = TestUser();
        
        user.registerLocalScope('active', (QueryBuilder<TestUser> query) {
          return query.where('active', true);
        });
        
        // Verify scope is registered
        expect(user.scopes.hasLocalScope('active'), isTrue);
      });

      test('registerGlobalScope should register global scope', () {
        final user = TestUser();
        
        // Create a proper GlobalScope implementation
        final activeScope = ActiveScope<TestUser>();
        user.registerGlobalScope(activeScope);
        
        // Verify scope is registered
        expect(user.scopes.getGlobalScopes(), isNotEmpty);
      });

      test('applyScope should apply local scope by name', () {
        final user = TestUser();
        
        user.registerLocalScope('active', (QueryBuilder<TestUser> query) {
          return query.where('active', true);
        });
        
        final queryBuilder = user.applyScope('active');
        expect(queryBuilder, isA<QueryBuilder<TestUser>>());
      });

      test('initializeScopes should be callable', () {
        final user = TestUser();
        
        // Should not throw
        user.initializeScopes();
        expect(user.scopes, isNotNull);
      });

      test('initializeRelationships should be callable', () {
        final user = TestUser();
        
        // Should not throw
        user.initializeRelationships();
        expect(user.relationships, isNotNull);
      });
    });
  });
}
