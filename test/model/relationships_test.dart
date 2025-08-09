import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

// Test models for relationships
class User extends Model<User> {
  final _id = AutoIncrementField();
  final _name = StringField(required: true);
  final _email = StringField(unique: true);
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
    registerField('created_at', _createdAt);
    registerField('updated_at', _updatedAt);
  }

  // Getters and setters
  int? get id => getValue<int>('id');
  set id(int? value) => setValue<int>('id', value);

  String? get name => getValue<String>('name');
  set name(String? value) => setValue<String>('name', value);

  String? get email => getValue<String>('email');
  set email(String? value) => setValue<String>('email', value);

  DateTime? get createdAt => getValue<DateTime>('created_at');
  DateTime? get updatedAt => getValue<DateTime>('updated_at');

  // Relationships
  Future<List<Post>> posts() async => await hasMany<Post>(() => Post()).get();
  Future<Profile?> profile() async =>
      await hasOne<Profile>(() => Profile()).get();
}

class Post extends Model<Post> {
  final _id = AutoIncrementField();
  final _title = StringField(required: true);
  final _content = TextField();
  final _userId = IntField(required: true);
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);

  @override
  String get table => 'posts';

  @override
  bool get timestamps => true;

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('title', _title);
    registerField('content', _content);
    registerField('user_id', _userId);
    registerField('created_at', _createdAt);
    registerField('updated_at', _updatedAt);
  }

  // Getters and setters
  int? get id => getValue<int>('id');
  set id(int? value) => setValue<int>('id', value);

  String? get title => getValue<String>('title');
  set title(String? value) => setValue<String>('title', value);

  String? get content => getValue<String>('content');
  set content(String? value) => setValue<String>('content', value);

  int? get userId => getValue<int>('user_id');
  set userId(int? value) => setValue<int>('user_id', value);

  DateTime? get createdAt => getValue<DateTime>('created_at');
  DateTime? get updatedAt => getValue<DateTime>('updated_at');

  // Relationships
  Future<User?> user() async => await belongsTo<User>(() => User()).get();
  Future<List<Comment>> comments() async =>
      await hasMany<Comment>(() => Comment()).get();
}

class Profile extends Model<Profile> {
  final _id = AutoIncrementField();
  final _userId = IntField(required: true, unique: true);
  final _bio = TextField();
  final _website = StringField();
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);

  @override
  String get table => 'profiles';

  @override
  bool get timestamps => true;

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('user_id', _userId);
    registerField('bio', _bio);
    registerField('website', _website);
    registerField('created_at', _createdAt);
    registerField('updated_at', _updatedAt);
  }

  // Getters and setters
  int? get id => getValue<int>('id');
  set id(int? value) => setValue<int>('id', value);

  int? get userId => getValue<int>('user_id');
  set userId(int? value) => setValue<int>('user_id', value);

  String? get bio => getValue<String>('bio');
  set bio(String? value) => setValue<String>('bio', value);

  String? get website => getValue<String>('website');
  set website(String? value) => setValue<String>('website', value);

  DateTime? get createdAt => getValue<DateTime>('created_at');
  DateTime? get updatedAt => getValue<DateTime>('updated_at');

  // Relationships
  Future<User?> user() async => await belongsTo<User>(() => User()).get();
}

class Comment extends Model<Comment> {
  final _id = AutoIncrementField();
  final _postId = IntField(required: true);
  final _content = TextField(required: true);
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);

  @override
  String get table => 'comments';

  @override
  bool get timestamps => true;

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('post_id', _postId);
    registerField('content', _content);
    registerField('created_at', _createdAt);
    registerField('updated_at', _updatedAt);
  }

  // Getters and setters
  int? get id => getValue<int>('id');
  set id(int? value) => setValue<int>('id', value);

  int? get postId => getValue<int>('post_id');
  set postId(int? value) => setValue<int>('post_id', value);

  String? get content => getValue<String>('content');
  set content(String? value) => setValue<String>('content', value);

  DateTime? get createdAt => getValue<DateTime>('created_at');
  DateTime? get updatedAt => getValue<DateTime>('updated_at');

  // Relationships
  Future<Post?> post() async => await belongsTo<Post>(() => Post()).get();
}

void main() async {
  // Initialize database connection
  await Database.initialize(databasePath: ':memory:');

  group('Relationship Tests', () {
    setUp(() async {
      // Create tables
      await Database.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE,
          created_at TEXT,
          updated_at TEXT
        )
      ''');

      await Database.execute('''
        CREATE TABLE posts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT,
          user_id INTEGER NOT NULL,
          created_at TEXT,
          updated_at TEXT
        )
      ''');

      await Database.execute('''
        CREATE TABLE profiles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL UNIQUE,
          bio TEXT,
          website TEXT,
          created_at TEXT,
          updated_at TEXT
        )
      ''');

      await Database.execute('''
        CREATE TABLE comments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          post_id INTEGER NOT NULL,
          content TEXT NOT NULL,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    });

    tearDown(() async {
      await Database.execute('DROP TABLE IF EXISTS comments');
      await Database.execute('DROP TABLE IF EXISTS profiles');
      await Database.execute('DROP TABLE IF EXISTS posts');
      await Database.execute('DROP TABLE IF EXISTS users');
    });

    group('HasOne Relationship Tests', () {
      test('should define hasOne relationship correctly', () {
        final user = User();
        final relationship = user.hasOne<Profile>(() => Profile());

        expect(relationship, isA<HasOne<Profile>>());
        expect(relationship.parent, equals(user));
        expect(relationship.foreignKey, equals('user_id'));
        expect(relationship.localKey, equals('id'));
      });

      test('should retrieve hasOne related model', () async {
        // Create user
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        // Create profile
        final profile = Profile()
          ..userId = user.id
          ..bio = 'Software Developer'
          ..website = 'https://johndoe.com';
        await profile.save();

        // Test relationship
        final retrievedProfile = await user.profile();
        expect(retrievedProfile, isNotNull);
        expect(retrievedProfile!.userId, equals(user.id));
        expect(retrievedProfile.bio, equals('Software Developer'));
      });

      test('should return null when no related model exists', () async {
        final user = User()
          ..name = 'Jane Doe'
          ..email = 'jane@example.com';
        await user.save();

        final profile = await user.profile();
        expect(profile, isNull);
      });

      test('should cache hasOne relationship result', () async {
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        final profile = Profile()
          ..userId = user.id
          ..bio = 'Developer';
        await profile.save();

        final relationship = user.hasOne<Profile>(() => Profile());
        user.registerRelationship('profile', relationship);

        // First call - loads from database
        final profile1 = await relationship.get();
        expect(relationship.isLoaded, isTrue);

        // Second call - loads from cache
        final profile2 = await relationship.get();
        expect(profile1, equals(profile2));
      });
    });

    group('HasMany Relationship Tests', () {
      test('should define hasMany relationship correctly', () {
        final user = User();
        final relationship = user.hasMany<Post>(() => Post());

        expect(relationship, isA<HasMany<Post>>());
        expect(relationship.parent, equals(user));
        expect(relationship.foreignKey, equals('user_id'));
        expect(relationship.localKey, equals('id'));
      });

      test('should retrieve hasMany related models', () async {
        // Create user
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        // Create posts
        final post1 = Post()
          ..title = 'First Post'
          ..content = 'Content of first post'
          ..userId = user.id;
        await post1.save();

        final post2 = Post()
          ..title = 'Second Post'
          ..content = 'Content of second post'
          ..userId = user.id;
        await post2.save();

        // Test relationship
        final posts = await user.posts();
        expect(posts, hasLength(2));
        expect(
          posts.map((p) => p.title),
          containsAll(['First Post', 'Second Post']),
        );
        expect(posts.every((p) => p.userId == user.id), isTrue);
      });

      test('should return empty list when no related models exist', () async {
        final user = User()
          ..name = 'Jane Doe'
          ..email = 'jane@example.com';
        await user.save();

        final posts = await user.posts();
        expect(posts, isEmpty);
      });

      test('should cache hasMany relationship result', () async {
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        final post = Post()
          ..title = 'Test Post'
          ..userId = user.id;
        await post.save();

        final relationship = user.hasMany<Post>(() => Post());
        user.registerRelationship('posts', relationship);

        // First call - loads from database
        final posts1 = await relationship.get();
        expect(relationship.isLoaded, isTrue);

        // Second call - loads from cache
        final posts2 = await relationship.get();
        expect(posts1, equals(posts2));
      });
    });

    group('BelongsTo Relationship Tests', () {
      test('should define belongsTo relationship correctly', () {
        final post = Post();
        final relationship = post.belongsTo<User>(() => User());

        expect(relationship, isA<BelongsTo<User>>());
        expect(relationship.parent, equals(post));
        expect(relationship.foreignKey, equals('user_id'));
        expect(relationship.localKey, equals('id'));
      });

      test('should retrieve belongsTo related model', () async {
        // Create user
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        // Create post
        final post = Post()
          ..title = 'Test Post'
          ..content = 'Test content'
          ..userId = user.id;
        await post.save();

        // Test relationship
        final retrievedUser = await post.user();
        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.id, equals(user.id));
        expect(retrievedUser.name, equals('John Doe'));
      });

      test('should return null when no related model exists', () async {
        final post = Post()
          ..title = 'Orphan Post'
          ..content = 'No user'
          ..userId = 999; // Non-existent user
        await post.save();

        final user = await post.user();
        expect(user, isNull);
      });

      test('should cache belongsTo relationship result', () async {
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        final post = Post()
          ..title = 'Test Post'
          ..userId = user.id;
        await post.save();

        final relationship = post.belongsTo<User>(() => User());
        post.registerRelationship('user', relationship);

        // First call - loads from database
        final user1 = await relationship.get();
        expect(relationship.isLoaded, isTrue);

        // Second call - loads from cache
        final user2 = await relationship.get();
        expect(user1, equals(user2));
      });
    });

    group('Relationship Registry Tests', () {
      test('should register and retrieve relationships', () {
        final user = User();
        final postsRelationship = user.hasMany<Post>(() => Post());
        final profileRelationship = user.hasOne<Profile>(() => Profile());

        user.registerRelationship('posts', postsRelationship);
        user.registerRelationship('profile', profileRelationship);

        expect(user.relationships.has('posts'), isTrue);
        expect(user.relationships.has('profile'), isTrue);
        expect(user.relationships.has('nonexistent'), isFalse);

        expect(user.relationships.get('posts'), equals(postsRelationship));
        expect(user.relationships.get('profile'), equals(profileRelationship));
      });

      test('should use short API for type-safe relationship access', () async {
        // Create user
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        // Create posts
        final post1 = Post()
          ..title = 'First Post'
          ..content = 'Content 1'
          ..userId = user.id;
        await post1.save();

        final post2 = Post()
          ..title = 'Second Post'
          ..content = 'Content 2'
          ..userId = user.id;
        await post2.save();

        // Create profile
        final profile = Profile()
          ..userId = user.id
          ..bio = 'Software Developer';
        await profile.save();

        // Register relationships
        user.registerRelationship('posts', user.hasMany<Post>(() => Post()));
        user.registerRelationship(
          'profile',
          user.hasOne<Profile>(() => Profile()),
        );

        // Test short API - HasMany
        final List<Post> posts = await user.relationships.many<Post>('posts');
        expect(posts, hasLength(2));
        expect(
          posts.map((p) => p.title),
          containsAll(['First Post', 'Second Post']),
        );

        // Test short API - HasOne
        final Profile? retrievedProfile = await user.relationships.one<Profile>(
          'profile',
        );
        expect(retrievedProfile, isNotNull);
        expect(retrievedProfile!.bio, equals('Software Developer'));

        // Test BelongsTo with post
        post1.registerRelationship('user', post1.belongsTo<User>(() => User()));
        final User? retrievedUser = await post1.relationships.belongsTo<User>(
          'user',
        );
        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.name, equals('John Doe'));
      });

      test(
        'should throw error for non-existent relationships in short API',
        () async {
          final user = User();

          // Test that accessing non-existent relationships throws error
          expect(
            () => user.relationships.many<Post>('nonexistent'),
            throwsA(isA<ArgumentError>()),
          );

          expect(
            () => user.relationships.one<Profile>('nonexistent'),
            throwsA(isA<ArgumentError>()),
          );

          expect(
            () => user.relationships.belongsTo<User>('nonexistent'),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test('should handle null results correctly in short API', () async {
        // Create user without profile
        final user = User()
          ..name = 'Jane Doe'
          ..email = 'jane@example.com';
        await user.save();

        // Register profile relationship but don't create profile
        user.registerRelationship(
          'profile',
          user.hasOne<Profile>(() => Profile()),
        );

        // Test that null is returned for missing HasOne relationship
        final Profile? profile = await user.relationships.one<Profile>(
          'profile',
        );
        expect(profile, isNull);

        // Test that empty list is returned for missing HasMany relationship
        user.registerRelationship('posts', user.hasMany<Post>(() => Post()));
        final List<Post> posts = await user.relationships.many<Post>('posts');
        expect(posts, isEmpty);
      });

      test('should reset all relationships', () async {
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        final profile = Profile()
          ..userId = user.id
          ..bio = 'Developer';
        await profile.save();

        final relationship = user.hasOne<Profile>(() => Profile());
        user.registerRelationship('profile', relationship);

        // Load the relationship
        await relationship.get();
        expect(relationship.isLoaded, isTrue);

        // Reset all relationships
        user.resetRelationships();
        expect(relationship.isLoaded, isFalse);
      });

      test('should check if relationship is loaded', () async {
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        final relationship = user.hasMany<Post>(() => Post());
        user.registerRelationship('posts', relationship);

        expect(user.isRelationshipLoaded('posts'), isFalse);

        await user.getRelationship('posts');
        expect(user.isRelationshipLoaded('posts'), isTrue);
      });
    });

    group('Complex Relationship Tests', () {
      test('should handle nested relationships', () async {
        // Create user
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        // Create post
        final post = Post()
          ..title = 'Test Post'
          ..content = 'Test content'
          ..userId = user.id;
        await post.save();

        // Create comment
        final comment = Comment()
          ..postId = post.id
          ..content = 'Great post!';
        await comment.save();

        // Test nested relationships: user -> posts -> comments
        final posts = await user.posts();
        expect(posts, hasLength(1));

        final comments = await posts.first.comments();
        expect(comments, hasLength(1));
        expect(comments.first.content, equals('Great post!'));

        // Test reverse: comment -> post -> user
        final retrievedPost = await comment.post();
        expect(retrievedPost, isNotNull);
        expect(retrievedPost!.title, equals('Test Post'));

        final retrievedUser = await retrievedPost.user();
        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.name, equals('John Doe'));
      });

      test('should handle custom foreign keys', () async {
        final user = User()
          ..name = 'John Doe'
          ..email = 'john@example.com';
        await user.save();

        // Test custom foreign key naming
        final relationship = user.hasMany<Post>(
          () => Post(),
          foreignKey: 'user_id',
          localKey: 'id',
        );

        expect(relationship.foreignKey, equals('user_id'));
        expect(relationship.localKey, equals('id'));
      });
    });
  });
}
