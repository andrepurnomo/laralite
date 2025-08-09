// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_field, unused_element

part of 'generated_test_user.dart';

extension _$GeneratedTestUserFieldAccess on GeneratedTestUser {
  /// Get id field for registration
  Field get idFieldRef => _id;

  /// Get name field for registration
  Field get nameFieldRef => _name;

  /// Get email field for registration
  Field get emailFieldRef => _email;

  /// Get password field for registration
  Field get passwordFieldRef => _password;

  /// Get status field for registration
  Field get statusFieldRef => _status;

  /// Get roleId field for registration
  Field get roleIdFieldRef => _roleId;

  /// Get createdAt field for registration
  Field get createdAtFieldRef => _createdAt;

  /// Get updatedAt field for registration
  Field get updatedAtFieldRef => _updatedAt;

  /// Get deletedAt field for registration
  Field get deletedAtFieldRef => _deletedAt;
}

mixin _$GeneratedTestUserFields on Model<GeneratedTestUser> {
  /// id property getter
  int? get id => getValue<int>('id');

  /// id property setter
  set id(int? value) => setValue('id', value);

  /// name property getter
  String? get name => getValue<String>('name');

  /// name property setter
  set name(String? value) => setValue('name', value);

  /// email property getter
  dynamic get email => getValue<dynamic>('email');

  /// email property setter
  set email(dynamic value) => setValue('email', value);

  /// password property getter
  String? get password => getValue<String>('password');

  /// password property setter
  set password(String? value) => setValue('password', value);

  /// status property getter
  String? get status => getValue<String>('status');

  /// status property setter
  set status(String? value) => setValue('status', value);

  /// roleId property getter
  int? get roleId => getValue<int>('role_id');

  /// roleId property setter
  set roleId(int? value) => setValue('role_id', value);

  /// createdAt property getter
  DateTime? get createdAt => getValue<DateTime>('created_at');

  /// createdAt property setter
  set createdAt(DateTime? value) => setValue('created_at', value);

  /// updatedAt property getter
  DateTime? get updatedAt => getValue<DateTime>('updated_at');

  /// updatedAt property setter
  set updatedAt(DateTime? value) => setValue('updated_at', value);

  /// deletedAt property getter
  DateTime? get deletedAt => getValue<DateTime>('deleted_at');

  /// deletedAt property setter
  set deletedAt(DateTime? value) => setValue('deleted_at', value);

  @override
  void registerFields() {
    registerField('id', (this as GeneratedTestUser).idFieldRef);
    registerField('name', (this as GeneratedTestUser).nameFieldRef);
    registerField('email', (this as GeneratedTestUser).emailFieldRef);
    registerField('password', (this as GeneratedTestUser).passwordFieldRef);
    registerField('status', (this as GeneratedTestUser).statusFieldRef);
    registerField('role_id', (this as GeneratedTestUser).roleIdFieldRef);
    registerField('created_at', (this as GeneratedTestUser).createdAtFieldRef);
    registerField('updated_at', (this as GeneratedTestUser).updatedAtFieldRef);
    registerField('deleted_at', (this as GeneratedTestUser).deletedAtFieldRef);
  }

  /// Create new query builder for this model
  QueryBuilder<GeneratedTestUser> query() {
    return Model.query<GeneratedTestUser>(() => GeneratedTestUser());
  }

  /// Add WHERE condition using type-safe field reference
  QueryBuilder<GeneratedTestUser> where(
    String fieldRef,
    dynamic operator, [
    dynamic value,
  ]) {
    return query().where(fieldRef, operator, value);
  }

  /// Add WHERE IN condition using type-safe field reference
  QueryBuilder<GeneratedTestUser> whereIn(
    String fieldRef,
    List<dynamic> values,
  ) {
    return query().whereIn(fieldRef, values);
  }

  /// Add WHERE NOT IN condition using type-safe field reference
  QueryBuilder<GeneratedTestUser> whereNotIn(
    String fieldRef,
    List<dynamic> values,
  ) {
    return query().whereNotIn(fieldRef, values);
  }

  /// Add WHERE NULL condition using type-safe field reference
  QueryBuilder<GeneratedTestUser> whereNull(String fieldRef) {
    return query().whereNull(fieldRef);
  }

  /// Add WHERE NOT NULL condition using type-safe field reference
  QueryBuilder<GeneratedTestUser> whereNotNull(String fieldRef) {
    return query().whereNotNull(fieldRef);
  }

  /// Add WHERE BETWEEN condition using type-safe field reference
  QueryBuilder<GeneratedTestUser> whereBetween(
    String fieldRef,
    dynamic min,
    dynamic max,
  ) {
    return query().whereBetween(fieldRef, min, max);
  }

  /// Add ORDER BY clause using type-safe field reference
  QueryBuilder<GeneratedTestUser> orderBy(
    String fieldRef, [
    String direction = 'ASC',
  ]) {
    return query().orderBy(fieldRef, direction);
  }

  /// Add ORDER BY ASC using type-safe field reference
  QueryBuilder<GeneratedTestUser> orderByAsc(String fieldRef) {
    return query().orderByAsc(fieldRef);
  }

  /// Add ORDER BY DESC using type-safe field reference
  QueryBuilder<GeneratedTestUser> orderByDesc(String fieldRef) {
    return query().orderByDesc(fieldRef);
  }

  /// Set LIMIT
  QueryBuilder<GeneratedTestUser> limit(int count) {
    return query().limit(count);
  }

  /// Set OFFSET
  QueryBuilder<GeneratedTestUser> offset(int count) {
    return query().offset(count);
  }

  /// Take records (alias for limit)
  QueryBuilder<GeneratedTestUser> take(int count) {
    return query().take(count);
  }

  /// Skip records (alias for offset)
  QueryBuilder<GeneratedTestUser> skip(int count) {
    return query().skip(count);
  }

  /// Select specific columns using type-safe field references
  QueryBuilder<GeneratedTestUser> select(List<String> fieldRefs) {
    return query().select(fieldRefs);
  }

  /// Apply scope callback
  QueryBuilder<GeneratedTestUser> scope(
    QueryBuilder<GeneratedTestUser> Function(QueryBuilder<GeneratedTestUser>)
    callback,
  ) {
    return query().scope(callback);
  }

  /// Execute query and return all results
  Future<List<GeneratedTestUser>> get() {
    return query().get();
  }

  /// Execute query and return first result
  Future<GeneratedTestUser?> first() {
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
  Future<PaginationResult<GeneratedTestUser>> paginate({
    int page = 1,
    int perPage = 15,
  }) {
    return query().paginate(page: page, perPage: perPage);
  }

  /// Include relationships for eager loading
  QueryBuilder<GeneratedTestUser> include(dynamic relationships) {
    return query().include(relationships);
  }

  /// Load relationships eagerly (alias for include)
  QueryBuilder<GeneratedTestUser> withRelations(dynamic relationships) {
    return query().withRelations(relationships);
  }

  /// Apply conditional query logic
  QueryBuilder<GeneratedTestUser> when(
    bool condition,
    QueryBuilder<GeneratedTestUser> Function(QueryBuilder<GeneratedTestUser>)
    callback,
  ) {
    return query().when(condition, callback);
  }

  /// Add WHERE EXISTS condition with relationship
  QueryBuilder<GeneratedTestUser> whereHas<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereHas<TRelated>(relationshipName, callback);
  }

  /// Add WHERE NOT EXISTS condition with relationship
  QueryBuilder<GeneratedTestUser>
  whereDoesntHave<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereDoesntHave<TRelated>(relationshipName, callback);
  }

  /// Add WHERE condition for relationship count
  QueryBuilder<GeneratedTestUser>
  whereHasCount<TRelated extends Model<TRelated>>(
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
  QueryBuilder<GeneratedTestUser> withTrashed() {
    return query().withTrashed();
  }

  /// Only show soft deleted records
  QueryBuilder<GeneratedTestUser> onlyTrashed() {
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
  QueryBuilder<GeneratedTestUser> orWhere(
    String fieldRef,
    dynamic operator, [
    dynamic value,
  ]) {
    return query().orWhere(fieldRef, operator, value);
  }

  /// Add OR WHERE IN condition
  QueryBuilder<GeneratedTestUser> orWhereIn(
    String fieldRef,
    List<dynamic> values,
  ) {
    return query().orWhereIn(fieldRef, values);
  }

  /// Add OR WHERE NOT IN condition
  QueryBuilder<GeneratedTestUser> orWhereNotIn(
    String fieldRef,
    List<dynamic> values,
  ) {
    return query().orWhereNotIn(fieldRef, values);
  }

  /// Add OR WHERE NULL condition
  QueryBuilder<GeneratedTestUser> orWhereNull(String fieldRef) {
    return query().orWhereNull(fieldRef);
  }

  /// Add OR WHERE NOT NULL condition
  QueryBuilder<GeneratedTestUser> orWhereNotNull(String fieldRef) {
    return query().orWhereNotNull(fieldRef);
  }

  /// Add OR WHERE BETWEEN condition
  QueryBuilder<GeneratedTestUser> orWhereBetween(
    String fieldRef,
    dynamic min,
    dynamic max,
  ) {
    return query().orWhereBetween(fieldRef, min, max);
  }
}

/// Type-safe field references for GeneratedTestUser queries
/// Use GeneratedTestUserFields.name instead of 'name' string literals
abstract class GeneratedTestUserFields {
  static const id = 'id';
  static const name = 'name';
  static const email = 'email';
  static const password = 'password';
  static const status = 'status';
  static const roleId = 'role_id';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const deletedAt = 'deleted_at';
}
