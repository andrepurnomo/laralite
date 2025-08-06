import 'package:laralite/laralite.dart';

part 'generated_test_user.g.dart';

/// Test user model using @laralite annotation for code generation
@laralite  
class GeneratedTestUser extends Model<GeneratedTestUser> with _$GeneratedTestUserFields {
  // Field definitions - will auto-generate getters/setters via generator
  final _id = AutoIncrementField();
  final _name = StringField(required: true, minLength: 2, maxLength: 100);
  final _email = EmailField(unique: true, required: true);
  final _password = StringField();
  final _status = StringField(defaultValue: 'active');
  final _roleId = IntField(nullable: true);
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);
  final _deletedAt = TimestampField(nullable: true);

  @override
  String get table => 'test_users_generated';

  @override
  bool get timestamps => true;

  GeneratedTestUser() : super();

  // Mutators
  void setPassword(String plainPassword) {
    password = 'hashed_$plainPassword';
  }

  // Accessors
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isBanned => status == 'banned';
}
