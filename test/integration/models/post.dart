import 'package:laralite/laralite.dart';
import 'user.dart';
import 'comment.dart';

part 'post.g.dart';

@laralite
class Post extends Model<Post> with _$PostFields, SoftDeletesMixin {
  @override
  String get table => 'posts';

  @override
  bool get timestamps => true;

  final _id = AutoIncrementField();
  final _title = StringField(required: true, maxLength: 255);
  final _content = TextField(nullable: true, maxLength: 10000);
  final _userId = ForeignKeyField(
    referencedTable: 'users',
    columnName: 'user_id',
    required: true,
  );
  final _publishedAt = DateTimeField(
    nullable: true,
    columnName: 'published_at',
  );
  final _createdAt = TimestampField(autoCreate: true, columnName: 'created_at');
  final _updatedAt = TimestampField(autoUpdate: true, columnName: 'updated_at');

  Post();

  // Relationships
  BelongsTo<User> user() =>
      belongsTo<User>(() => User(), foreignKey: 'user_id');
  HasMany<Comment> comments() =>
      hasMany<Comment>(() => Comment(), foreignKey: 'post_id');

  // Scopes
  @override
  void initializeScopes() {
    super.initializeScopes();
    registerLocalScope(
      'published',
      (query) => query.whereNotNull('published_at'),
    );
    registerLocalScope('draft', (query) => query.whereNull('published_at'));
    // Register global scope for soft deletes
    registerGlobalScope(SoftDeleteScope<Post>());
  }

  // Custom methods
  bool get isPublished => publishedAt != null;
  bool get isDraft => publishedAt == null;

  Future<void> publish() async {
    publishedAt = DateTime.now();
    await save();
  }
}
