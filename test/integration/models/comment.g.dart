// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_field, unused_element

part of 'comment.dart';

extension _$CommentFieldAccess on Comment {
  /// Get id field for registration
  Field get idFieldRef => _id;

  /// Get content field for registration
  Field get contentFieldRef => _content;

  /// Get userId field for registration
  Field get userIdFieldRef => _userId;

  /// Get postId field for registration
  Field get postIdFieldRef => _postId;

  /// Get approved field for registration
  Field get approvedFieldRef => _approved;

  /// Get createdAt field for registration
  Field get createdAtFieldRef => _createdAt;

  /// Get updatedAt field for registration
  Field get updatedAtFieldRef => _updatedAt;
}

mixin _$CommentFields on Model<Comment> {
  /// id property getter
  int? get id => getValue<int>('id');

  /// id property setter
  set id(int? value) => setValue('id', value);

  /// content property getter
  String? get content => getValue<String>('content');

  /// content property setter
  set content(String? value) => setValue('content', value);

  /// userId property getter
  int? get userId => getValue<int>('user_id');

  /// userId property setter
  set userId(int? value) => setValue('user_id', value);

  /// postId property getter
  int? get postId => getValue<int>('post_id');

  /// postId property setter
  set postId(int? value) => setValue('post_id', value);

  /// approved property getter
  bool? get approved => getValue<bool>('approved');

  /// approved property setter
  set approved(bool? value) => setValue('approved', value);

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
    registerField('id', (this as Comment).idFieldRef);
    registerField('content', (this as Comment).contentFieldRef);
    registerField('user_id', (this as Comment).userIdFieldRef);
    registerField('post_id', (this as Comment).postIdFieldRef);
    registerField('approved', (this as Comment).approvedFieldRef);
    registerField('created_at', (this as Comment).createdAtFieldRef);
    registerField('updated_at', (this as Comment).updatedAtFieldRef);
  }

  @override
  void initializeRelationships() {
    super.initializeRelationships();
    relationships.registerLazy('user', () => (this as Comment).user());
    relationships.registerLazy('post', () => (this as Comment).post());
  }

  /// Create new query builder for this model
  QueryBuilder<Comment> query() {
    return Model.query<Comment>(() => Comment());
  }

  /// Add WHERE condition using type-safe field reference
  QueryBuilder<Comment> where(
    String fieldRef,
    dynamic operator, [
    dynamic value,
  ]) {
    return query().where(fieldRef, operator, value);
  }

  /// Add WHERE IN condition using type-safe field reference
  QueryBuilder<Comment> whereIn(String fieldRef, List<dynamic> values) {
    return query().whereIn(fieldRef, values);
  }

  /// Add WHERE NOT IN condition using type-safe field reference
  QueryBuilder<Comment> whereNotIn(String fieldRef, List<dynamic> values) {
    return query().whereNotIn(fieldRef, values);
  }

  /// Add WHERE NULL condition using type-safe field reference
  QueryBuilder<Comment> whereNull(String fieldRef) {
    return query().whereNull(fieldRef);
  }

  /// Add WHERE NOT NULL condition using type-safe field reference
  QueryBuilder<Comment> whereNotNull(String fieldRef) {
    return query().whereNotNull(fieldRef);
  }

  /// Add WHERE BETWEEN condition using type-safe field reference
  QueryBuilder<Comment> whereBetween(
    String fieldRef,
    dynamic min,
    dynamic max,
  ) {
    return query().whereBetween(fieldRef, min, max);
  }

  /// Add ORDER BY clause using type-safe field reference
  QueryBuilder<Comment> orderBy(String fieldRef, [String direction = 'ASC']) {
    return query().orderBy(fieldRef, direction);
  }

  /// Add ORDER BY ASC using type-safe field reference
  QueryBuilder<Comment> orderByAsc(String fieldRef) {
    return query().orderByAsc(fieldRef);
  }

  /// Add ORDER BY DESC using type-safe field reference
  QueryBuilder<Comment> orderByDesc(String fieldRef) {
    return query().orderByDesc(fieldRef);
  }

  /// Set LIMIT
  QueryBuilder<Comment> limit(int count) {
    return query().limit(count);
  }

  /// Set OFFSET
  QueryBuilder<Comment> offset(int count) {
    return query().offset(count);
  }

  /// Take records (alias for limit)
  QueryBuilder<Comment> take(int count) {
    return query().take(count);
  }

  /// Skip records (alias for offset)
  QueryBuilder<Comment> skip(int count) {
    return query().skip(count);
  }

  /// Select specific columns using type-safe field references
  QueryBuilder<Comment> select(List<String> fieldRefs) {
    return query().select(fieldRefs);
  }

  /// Apply scope callback
  QueryBuilder<Comment> scope(
    QueryBuilder<Comment> Function(QueryBuilder<Comment>) callback,
  ) {
    return query().scope(callback);
  }

  /// Execute query and return all results
  Future<List<Comment>> get() {
    return query().get();
  }

  /// Execute query and return first result
  Future<Comment?> first() {
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
  Future<PaginationResult<Comment>> paginate({int page = 1, int perPage = 15}) {
    return query().paginate(page: page, perPage: perPage);
  }

  /// Include relationships for eager loading
  QueryBuilder<Comment> include(dynamic relationships) {
    return query().include(relationships);
  }

  /// Load relationships eagerly (alias for include)
  QueryBuilder<Comment> withRelations(dynamic relationships) {
    return query().withRelations(relationships);
  }

  /// Apply conditional query logic
  QueryBuilder<Comment> when(
    bool condition,
    QueryBuilder<Comment> Function(QueryBuilder<Comment>) callback,
  ) {
    return query().when(condition, callback);
  }

  /// Add WHERE EXISTS condition with relationship
  QueryBuilder<Comment> whereHas<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereHas<TRelated>(relationshipName, callback);
  }

  /// Add WHERE NOT EXISTS condition with relationship
  QueryBuilder<Comment> whereDoesntHave<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereDoesntHave<TRelated>(relationshipName, callback);
  }

  /// Add WHERE condition for relationship count
  QueryBuilder<Comment> whereHasCount<TRelated extends Model<TRelated>>(
    String relationshipName,
    String operator,
    int count, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereHasCount<TRelated>(
      relationshipName,
      operator,
      count,
      callback,
    );
  }

  /// Include soft deleted records in query
  QueryBuilder<Comment> withTrashed() {
    return query().withTrashed();
  }

  /// Only show soft deleted records
  QueryBuilder<Comment> onlyTrashed() {
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
  QueryBuilder<Comment> orWhere(
    String fieldRef,
    dynamic operator, [
    dynamic value,
  ]) {
    return query().orWhere(fieldRef, operator, value);
  }

  /// Add OR WHERE IN condition
  QueryBuilder<Comment> orWhereIn(String fieldRef, List<dynamic> values) {
    return query().orWhereIn(fieldRef, values);
  }

  /// Add OR WHERE NOT IN condition
  QueryBuilder<Comment> orWhereNotIn(String fieldRef, List<dynamic> values) {
    return query().orWhereNotIn(fieldRef, values);
  }

  /// Add OR WHERE NULL condition
  QueryBuilder<Comment> orWhereNull(String fieldRef) {
    return query().orWhereNull(fieldRef);
  }

  /// Add OR WHERE NOT NULL condition
  QueryBuilder<Comment> orWhereNotNull(String fieldRef) {
    return query().orWhereNotNull(fieldRef);
  }

  /// Add OR WHERE BETWEEN condition
  QueryBuilder<Comment> orWhereBetween(
    String fieldRef,
    dynamic min,
    dynamic max,
  ) {
    return query().orWhereBetween(fieldRef, min, max);
  }
}

/// Type-safe field references for Comment queries
/// Use CommentFields.name instead of 'name' string literals
abstract class CommentFields {
  static const id = 'id';
  static const content = 'content';
  static const userId = 'user_id';
  static const postId = 'post_id';
  static const approved = 'approved';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}
