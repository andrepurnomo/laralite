import 'package:laralite/laralite.dart';
import 'post.dart';
import 'comment.dart';

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
