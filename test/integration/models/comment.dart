import 'package:laralite/laralite.dart';
import 'user.dart';
import 'post.dart';

part 'comment.g.dart';

@laralite
class Comment extends Model<Comment> with _$CommentFields {
  @override
  String get table => 'comments';

  @override
  bool get timestamps => true;

  final _id = AutoIncrementField();
  final _content = TextField(required: true, maxLength: 1000);
  final _userId = ForeignKeyField(
    referencedTable: 'users',
    columnName: 'user_id',
    required: true,
  );
  final _postId = ForeignKeyField(
    referencedTable: 'posts',
    columnName: 'post_id',
    required: true,
  );
  final _approved = BoolField(defaultValue: false);
  final _createdAt = TimestampField(autoCreate: true, columnName: 'created_at');
  final _updatedAt = TimestampField(autoUpdate: true, columnName: 'updated_at');

  Comment();

  // Relationships
  BelongsTo<User> user() =>
      belongsTo<User>(() => User(), foreignKey: 'user_id');
  BelongsTo<Post> post() =>
      belongsTo<Post>(() => Post(), foreignKey: 'post_id');

  // Scopes
  @override
  void initializeScopes() {
    super.initializeScopes();
    registerLocalScope('approved', (query) => query.where('approved', true));
    registerLocalScope('pending', (query) => query.where('approved', false));
  }

  // Custom methods
  bool get isApproved => approved == true;
  bool get isPending => approved == false;

  Future<void> approve() async {
    approved = true;
    await save();
  }

  Future<void> reject() async {
    approved = false;
    await save();
  }
}
