// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_field, unused_element

part of 'post.dart';

extension _$PostFieldAccess on Post {
  /// Get id field for registration
  Field get idFieldRef => _id;
  /// Get title field for registration
  Field get titleFieldRef => _title;
  /// Get content field for registration
  Field get contentFieldRef => _content;
  /// Get userId field for registration
  Field get userIdFieldRef => _userId;
  /// Get publishedAt field for registration
  Field get publishedAtFieldRef => _publishedAt;
  /// Get createdAt field for registration
  Field get createdAtFieldRef => _createdAt;
  /// Get updatedAt field for registration
  Field get updatedAtFieldRef => _updatedAt;
}

mixin _$PostFields on Model<Post> {
  /// id property getter
  int? get id => getValue<int>('id');

  /// id property setter
  set id(int? value) => setValue('id', value);

  /// title property getter
  String? get title => getValue<String>('title');

  /// title property setter
  set title(String? value) => setValue('title', value);

  /// content property getter
  String? get content => getValue<String>('content');

  /// content property setter
  set content(String? value) => setValue('content', value);

  /// userId property getter
  int? get userId => getValue<int>('user_id');

  /// userId property setter
  set userId(int? value) => setValue('user_id', value);

  /// publishedAt property getter
  DateTime? get publishedAt => getValue<DateTime>('published_at');

  /// publishedAt property setter
  set publishedAt(DateTime? value) => setValue('published_at', value);

  /// createdAt property getter
  DateTime? get createdAt => getValue<DateTime>('created_at');

  /// createdAt property setter
  set createdAt(DateTime? value) => setValue('created_at', value);

  /// updatedAt property getter
  DateTime? get updatedAt => getValue<DateTime>('updated_at');

  /// updatedAt property setter
  set updatedAt(DateTime? value) => setValue('updated_at', value);

  @override
  void registerFields() {
    registerField('id', (this as Post).idFieldRef);
    registerField('title', (this as Post).titleFieldRef);
    registerField('content', (this as Post).contentFieldRef);
    registerField('user_id', (this as Post).userIdFieldRef);
    registerField('published_at', (this as Post).publishedAtFieldRef);
    registerField('created_at', (this as Post).createdAtFieldRef);
    registerField('updated_at', (this as Post).updatedAtFieldRef);
  }

  @override
  void initializeRelationships() {
    super.initializeRelationships();
    relationships.registerLazy('user', () => (this as Post).user());
    relationships.registerLazy('comments', () => (this as Post).comments());
  }

  /// Create new query builder for this model
  QueryBuilder<Post> query() {
    return Model.query<Post>(() => Post());
  }

  /// Add WHERE condition using type-safe field reference
  QueryBuilder<Post> where(String fieldRef, dynamic operator, [dynamic value]) {
    return query().where(fieldRef, operator, value);
  }

  /// Add WHERE IN condition using type-safe field reference
  QueryBuilder<Post> whereIn(String fieldRef, List<dynamic> values) {
    return query().whereIn(fieldRef, values);
  }

  /// Add WHERE NOT IN condition using type-safe field reference
  QueryBuilder<Post> whereNotIn(String fieldRef, List<dynamic> values) {
    return query().whereNotIn(fieldRef, values);
  }

  /// Add WHERE NULL condition using type-safe field reference
  QueryBuilder<Post> whereNull(String fieldRef) {
    return query().whereNull(fieldRef);
  }

  /// Add WHERE NOT NULL condition using type-safe field reference
  QueryBuilder<Post> whereNotNull(String fieldRef) {
    return query().whereNotNull(fieldRef);
  }

  /// Add WHERE BETWEEN condition using type-safe field reference
  QueryBuilder<Post> whereBetween(String fieldRef, dynamic min, dynamic max) {
    return query().whereBetween(fieldRef, min, max);
  }

  /// Add ORDER BY clause using type-safe field reference
  QueryBuilder<Post> orderBy(String fieldRef, [String direction = 'ASC']) {
    return query().orderBy(fieldRef, direction);
  }

  /// Add ORDER BY ASC using type-safe field reference
  QueryBuilder<Post> orderByAsc(String fieldRef) {
    return query().orderByAsc(fieldRef);
  }

  /// Add ORDER BY DESC using type-safe field reference
  QueryBuilder<Post> orderByDesc(String fieldRef) {
    return query().orderByDesc(fieldRef);
  }

  /// Set LIMIT
  QueryBuilder<Post> limit(int count) {
    return query().limit(count);
  }

  /// Set OFFSET
  QueryBuilder<Post> offset(int count) {
    return query().offset(count);
  }

  /// Take records (alias for limit)
  QueryBuilder<Post> take(int count) {
    return query().take(count);
  }

  /// Skip records (alias for offset)
  QueryBuilder<Post> skip(int count) {
    return query().skip(count);
  }

  /// Select specific columns using type-safe field references
  QueryBuilder<Post> select(List<String> fieldRefs) {
    return query().select(fieldRefs);
  }

  /// Apply scope callback
  QueryBuilder<Post> scope(QueryBuilder<Post> Function(QueryBuilder<Post>) callback) {
    return query().scope(callback);
  }

  /// Execute query and return all results
  Future<List<Post>> get() {
    return query().get();
  }

  /// Execute query and return first result
  Future<Post?> first() {
    return query().first();
  }

  /// Execute query and return count
  Future<int> count() {
    return query().count();
  }

  /// Check if any records exist
  Future<bool> existsQuery() {
    return query().exists();
  }

  /// Paginate results
  Future<PaginationResult<Post>> paginate({int page = 1, int perPage = 15}) {
    return query().paginate(page: page, perPage: perPage);
  }

  /// Include relationships for eager loading
  QueryBuilder<Post> include(dynamic relationships) {
    return query().include(relationships);
  }

  /// Load relationships eagerly (alias for include)
  QueryBuilder<Post> withRelations(dynamic relationships) {
    return query().withRelations(relationships);
  }

  /// Apply conditional query logic
  QueryBuilder<Post> when(bool condition, QueryBuilder<Post> Function(QueryBuilder<Post>) callback) {
    return query().when(condition, callback);
  }

  /// Add WHERE EXISTS condition with relationship
  QueryBuilder<Post> whereHas<TRelated extends Model<TRelated>>(String relationshipName, [QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback]) {
    return query().whereHas<TRelated>(relationshipName, callback);
  }

  /// Add WHERE NOT EXISTS condition with relationship
  QueryBuilder<Post> whereDoesntHave<TRelated extends Model<TRelated>>(String relationshipName, [QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback]) {
    return query().whereDoesntHave<TRelated>(relationshipName, callback);
  }

  /// Add WHERE condition for relationship count
  QueryBuilder<Post> whereHasCount<TRelated extends Model<TRelated>>(String relationshipName, String operator, int count, [QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback]) {
    return query().whereHasCount<TRelated>(relationshipName, operator, count, callback);
  }

  /// Include soft deleted records in query
  QueryBuilder<Post> withTrashed() {
    return query().withTrashed();
  }

  /// Only show soft deleted records
  QueryBuilder<Post> onlyTrashed() {
    return query().onlyTrashed();
  }

  /// Restore soft deleted records matching conditions
  Future<int> restoreWhere() {
    return query().restore();
  }

  /// Force delete records matching conditions
  Future<int> forceDeleteWhere() {
    return query().forceDelete();
  }

  /// Calculate sum of a column
  Future<double?> sum(String column) {
    return query().sum(column);
  }

  /// Calculate average of a column
  Future<double?> avg(String column) {
    return query().avg(column);
  }

  /// Find maximum value of a column
  Future<dynamic> max(String column) {
    return query().max(column);
  }

  /// Find minimum value of a column
  Future<dynamic> min(String column) {
    return query().min(column);
  }

  /// Add OR WHERE condition
  QueryBuilder<Post> orWhere(String fieldRef, dynamic operator, [dynamic value]) {
    return query().orWhere(fieldRef, operator, value);
  }

  /// Add OR WHERE IN condition
  QueryBuilder<Post> orWhereIn(String fieldRef, List<dynamic> values) {
    return query().orWhereIn(fieldRef, values);
  }

  /// Add OR WHERE NOT IN condition
  QueryBuilder<Post> orWhereNotIn(String fieldRef, List<dynamic> values) {
    return query().orWhereNotIn(fieldRef, values);
  }

  /// Add OR WHERE NULL condition
  QueryBuilder<Post> orWhereNull(String fieldRef) {
    return query().orWhereNull(fieldRef);
  }

  /// Add OR WHERE NOT NULL condition
  QueryBuilder<Post> orWhereNotNull(String fieldRef) {
    return query().orWhereNotNull(fieldRef);
  }

  /// Add OR WHERE BETWEEN condition
  QueryBuilder<Post> orWhereBetween(String fieldRef, dynamic min, dynamic max) {
    return query().orWhereBetween(fieldRef, min, max);
  }

}

/// Type-safe field references for Post queries
/// Use PostFields.name instead of 'name' string literals
abstract class PostFields {
  static const id = 'id';
  static const title = 'title';
  static const content = 'content';
  static const userId = 'user_id';
  static const publishedAt = 'published_at';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

