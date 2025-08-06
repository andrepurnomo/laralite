import 'package:laralite/laralite.dart';

part 'user.g.dart';

@laralite
class User extends Model<User> with _$UserFields {
  // Field definitions - will auto-generate getters/setters
  final _id = AutoIncrementField();
  final _name = StringField(maxLength: 255, required: true);
  final _email = StringField(unique: true, required: true);
  final _age = IntField(min: 0, max: 150);
  final _active = BoolField(defaultValue: true);
  final _createdAt = TimestampField(autoCreate: true);
  final _updatedAt = TimestampField(autoUpdate: true);

  @override
  String get table => 'users';

  @override
  bool get timestamps => true;

  User() : super();
}
