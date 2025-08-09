import 'package:laralite/laralite.dart';

part 'user_example.g.dart';

@laralite
class User extends Model<User> with _$UserFields {
  @override
  String get table => 'users';

  // Field definitions
  final _id = AutoIncrementField();
  final _name = StringField(maxLength: 255);
  final _email = StringField(maxLength: 255);
  final _emailVerifiedAt = TimestampField();
  final _password = StringField(maxLength: 255);
  final _rememberToken = StringField(maxLength: 100);
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);

  // Relationships - these ARE auto-detected by code generation ✅
  HasMany<Post> posts() {
    return hasMany<Post>(() => Post());
  }

  HasOne<Profile> profile() {
    return hasOne<Profile>(() => Profile());
  }

  HasMany<Comment> comments() {
    return hasMany<Comment>(() => Comment());
  }

  BelongsToMany<Role> roles() {
    return belongsToMany<Role>(() => Role(), pivotTable: 'user_roles');
  }
}

@laralite
class Post extends Model<Post> with _$PostFields {
  @override
  String get table => 'posts';

  final _id = AutoIncrementField();
  final _userId = ForeignKeyField(referencedTable: 'users');
  final _title = StringField(maxLength: 255);
  final _content = TextField();
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);

  // Relationships
  BelongsTo<User> user() {
    return belongsTo<User>(() => User());
  }

  HasMany<Comment> comments() {
    return hasMany<Comment>(() => Comment());
  }
}

@laralite
class Profile extends Model<Profile> with _$ProfileFields {
  @override
  String get table => 'profiles';

  final _id = AutoIncrementField();
  final _userId = ForeignKeyField(referencedTable: 'users');
  final _bio = TextField();
  final _avatar = StringField();
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);

  // Relationships
  BelongsTo<User> user() {
    return belongsTo<User>(() => User());
  }
}

@laralite
class Comment extends Model<Comment> with _$CommentFields {
  @override
  String get table => 'comments';

  final _id = AutoIncrementField();
  final _userId = ForeignKeyField(referencedTable: 'users');
  final _postId = ForeignKeyField(referencedTable: 'posts');
  final _content = TextField();
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);

  // Relationships
  BelongsTo<User> user() {
    return belongsTo<User>(() => User());
  }

  BelongsTo<Post> post() {
    return belongsTo<Post>(() => Post());
  }
}

@laralite
class Role extends Model<Role> with _$RoleFields {
  @override
  String get table => 'roles';

  final _id = AutoIncrementField();
  final _name = StringField(maxLength: 255);
  final _description = TextField();
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);

  // Relationships
  BelongsToMany<User> users() {
    return belongsToMany<User>(() => User(), pivotTable: 'user_roles');
  }
}
