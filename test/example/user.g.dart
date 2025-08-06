// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_field, unused_element

part of 'user.dart';

extension _$UserFieldAccess on User {
  /// Get id field for registration
  Field get idFieldRef => _id;
  /// Get name field for registration
  Field get nameFieldRef => _name;
  /// Get email field for registration
  Field get emailFieldRef => _email;
  /// Get age field for registration
  Field get ageFieldRef => _age;
  /// Get active field for registration
  Field get activeFieldRef => _active;
  /// Get createdAt field for registration
  Field get createdAtFieldRef => _createdAt;
  /// Get updatedAt field for registration
  Field get updatedAtFieldRef => _updatedAt;
}

mixin _$UserFields on Model<User> {
  /// id property getter
  int? get id => getValue<int>('id');

  /// id property setter
  set id(int? value) => setValue('id', value);

  /// name property getter
  String? get name => getValue<String>('name');

  /// name property setter
  set name(String? value) => setValue('name', value);

  /// email property getter
  String? get email => getValue<String>('email');

  /// email property setter
  set email(String? value) => setValue('email', value);

  /// age property getter
  int? get age => getValue<int>('age');

  /// age property setter
  set age(int? value) => setValue('age', value);

  /// active property getter
  bool? get active => getValue<bool>('active');

  /// active property setter
  set active(bool? value) => setValue('active', value);

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
    registerField('id', (this as User).idFieldRef);
    registerField('name', (this as User).nameFieldRef);
    registerField('email', (this as User).emailFieldRef);
    registerField('age', (this as User).ageFieldRef);
    registerField('active', (this as User).activeFieldRef);
    registerField('created_at', (this as User).createdAtFieldRef);
    registerField('updated_at', (this as User).updatedAtFieldRef);
  }

  /// Create new query builder for this model
  QueryBuilder<User> query() {
    return Model.query<User>(() => User());
  }

  /// Add WHERE condition using type-safe field reference
  QueryBuilder<User> where(String fieldRef, dynamic operator, [dynamic value]) {
    return query().where(fieldRef, operator, value);
  }

  /// Add WHERE IN condition using type-safe field reference
  QueryBuilder<User> whereIn(String fieldRef, List<dynamic> values) {
    return query().whereIn(fieldRef, values);
  }

  /// Add WHERE NOT IN condition using type-safe field reference
  QueryBuilder<User> whereNotIn(String fieldRef, List<dynamic> values) {
    return query().whereNotIn(fieldRef, values);
  }

  /// Add WHERE NULL condition using type-safe field reference
  QueryBuilder<User> whereNull(String fieldRef) {
    return query().whereNull(fieldRef);
  }

  /// Add WHERE NOT NULL condition using type-safe field reference
  QueryBuilder<User> whereNotNull(String fieldRef) {
    return query().whereNotNull(fieldRef);
  }

  /// Add WHERE BETWEEN condition using type-safe field reference
  QueryBuilder<User> whereBetween(String fieldRef, dynamic min, dynamic max) {
    return query().whereBetween(fieldRef, min, max);
  }

  /// Add ORDER BY clause using type-safe field reference
  QueryBuilder<User> orderBy(String fieldRef, [String direction = 'ASC']) {
    return query().orderBy(fieldRef, direction);
  }

  /// Add ORDER BY ASC using type-safe field reference
  QueryBuilder<User> orderByAsc(String fieldRef) {
    return query().orderByAsc(fieldRef);
  }

  /// Add ORDER BY DESC using type-safe field reference
  QueryBuilder<User> orderByDesc(String fieldRef) {
    return query().orderByDesc(fieldRef);
  }

  /// Set LIMIT
  QueryBuilder<User> limit(int count) {
    return query().limit(count);
  }

  /// Set OFFSET
  QueryBuilder<User> offset(int count) {
    return query().offset(count);
  }

  /// Take records (alias for limit)
  QueryBuilder<User> take(int count) {
    return query().take(count);
  }

  /// Skip records (alias for offset)
  QueryBuilder<User> skip(int count) {
    return query().skip(count);
  }

  /// Select specific columns using type-safe field references
  QueryBuilder<User> select(List<String> fieldRefs) {
    return query().select(fieldRefs);
  }

  /// Apply scope callback
  QueryBuilder<User> scope(QueryBuilder<User> Function(QueryBuilder<User>) callback) {
    return query().scope(callback);
  }

  /// Execute query and return all results
  Future<List<User>> get() {
    return query().get();
  }

  /// Execute query and return first result
  Future<User?> first() {
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
  Future<PaginationResult<User>> paginate({int page = 1, int perPage = 15}) {
    return query().paginate(page: page, perPage: perPage);
  }

  /// Include relationships for eager loading
  QueryBuilder<User> include(dynamic relationships) {
    return query().include(relationships);
  }

  /// Load relationships eagerly (alias for include)
  QueryBuilder<User> withRelations(dynamic relationships) {
    return query().withRelations(relationships);
  }

  /// Apply conditional query logic
  QueryBuilder<User> when(bool condition, QueryBuilder<User> Function(QueryBuilder<User>) callback) {
    return query().when(condition, callback);
  }

  /// Add WHERE EXISTS condition with relationship
  QueryBuilder<User> whereHas<TRelated extends Model<TRelated>>(String relationshipName, [QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback]) {
    return query().whereHas<TRelated>(relationshipName, callback);
  }

  /// Add WHERE NOT EXISTS condition with relationship
  QueryBuilder<User> whereDoesntHave<TRelated extends Model<TRelated>>(String relationshipName, [QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback]) {
    return query().whereDoesntHave<TRelated>(relationshipName, callback);
  }

  /// Add WHERE condition for relationship count
  QueryBuilder<User> whereHasCount<TRelated extends Model<TRelated>>(String relationshipName, String operator, int count, [QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback]) {
    return query().whereHasCount<TRelated>(relationshipName, operator, count, callback);
  }

  /// Include soft deleted records in query
  QueryBuilder<User> withTrashed() {
    return query().withTrashed();
  }

  /// Only show soft deleted records
  QueryBuilder<User> onlyTrashed() {
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
  QueryBuilder<User> orWhere(String fieldRef, dynamic operator, [dynamic value]) {
    return query().orWhere(fieldRef, operator, value);
  }

  /// Add OR WHERE IN condition
  QueryBuilder<User> orWhereIn(String fieldRef, List<dynamic> values) {
    return query().orWhereIn(fieldRef, values);
  }

  /// Add OR WHERE NOT IN condition
  QueryBuilder<User> orWhereNotIn(String fieldRef, List<dynamic> values) {
    return query().orWhereNotIn(fieldRef, values);
  }

  /// Add OR WHERE NULL condition
  QueryBuilder<User> orWhereNull(String fieldRef) {
    return query().orWhereNull(fieldRef);
  }

  /// Add OR WHERE NOT NULL condition
  QueryBuilder<User> orWhereNotNull(String fieldRef) {
    return query().orWhereNotNull(fieldRef);
  }

  /// Add OR WHERE BETWEEN condition
  QueryBuilder<User> orWhereBetween(String fieldRef, dynamic min, dynamic max) {
    return query().orWhereBetween(fieldRef, min, max);
  }

}

/// Type-safe field references for User queries
/// Use UserFields.name instead of 'name' string literals
abstract class UserFields {
  static const id = 'id';
  static const name = 'name';
  static const email = 'email';
  static const age = 'age';
  static const active = 'active';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

