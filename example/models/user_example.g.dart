// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_field, unused_element

part of 'user_example.dart';

extension _$UserFieldAccess on User {
  /// Get id field for registration
  Field get idFieldRef => _id;

  /// Get name field for registration
  Field get nameFieldRef => _name;

  /// Get email field for registration
  Field get emailFieldRef => _email;

  /// Get emailVerifiedAt field for registration
  Field get emailVerifiedAtFieldRef => _emailVerifiedAt;

  /// Get password field for registration
  Field get passwordFieldRef => _password;

  /// Get rememberToken field for registration
  Field get rememberTokenFieldRef => _rememberToken;

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

  /// emailVerifiedAt property getter
  DateTime? get emailVerifiedAt => getValue<DateTime>('email_verified_at');

  /// emailVerifiedAt property setter
  set emailVerifiedAt(DateTime? value) => setValue('email_verified_at', value);

  /// password property getter
  String? get password => getValue<String>('password');

  /// password property setter
  set password(String? value) => setValue('password', value);

  /// rememberToken property getter
  String? get rememberToken => getValue<String>('remember_token');

  /// rememberToken property setter
  set rememberToken(String? value) => setValue('remember_token', value);

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
    registerField('email_verified_at', (this as User).emailVerifiedAtFieldRef);
    registerField('password', (this as User).passwordFieldRef);
    registerField('remember_token', (this as User).rememberTokenFieldRef);
    registerField('created_at', (this as User).createdAtFieldRef);
    registerField('updated_at', (this as User).updatedAtFieldRef);
  }

  @override
  void initializeRelationships() {
    super.initializeRelationships();
    relationships.registerLazy('posts', () => (this as User).posts());
    relationships.registerLazy('profile', () => (this as User).profile());
    relationships.registerLazy('comments', () => (this as User).comments());
    relationships.registerLazy('roles', () => (this as User).roles());
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
  QueryBuilder<User> scope(
    QueryBuilder<User> Function(QueryBuilder<User>) callback,
  ) {
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
  QueryBuilder<User> when(
    bool condition,
    QueryBuilder<User> Function(QueryBuilder<User>) callback,
  ) {
    return query().when(condition, callback);
  }

  /// Add WHERE EXISTS condition with relationship
  QueryBuilder<User> whereHas<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereHas<TRelated>(relationshipName, callback);
  }

  /// Add WHERE NOT EXISTS condition with relationship
  QueryBuilder<User> whereDoesntHave<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereDoesntHave<TRelated>(relationshipName, callback);
  }

  /// Add WHERE condition for relationship count
  QueryBuilder<User> whereHasCount<TRelated extends Model<TRelated>>(
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
  QueryBuilder<User> orWhere(
    String fieldRef,
    dynamic operator, [
    dynamic value,
  ]) {
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
  static const emailVerifiedAt = 'email_verified_at';
  static const password = 'password';
  static const rememberToken = 'remember_token';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

extension _$PostFieldAccess on Post {
  /// Get id field for registration
  Field get idFieldRef => _id;

  /// Get userId field for registration
  Field get userIdFieldRef => _userId;

  /// Get title field for registration
  Field get titleFieldRef => _title;

  /// Get content field for registration
  Field get contentFieldRef => _content;

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

  /// userId property getter
  int? get userId => getValue<int>('user_id');

  /// userId property setter
  set userId(int? value) => setValue('user_id', value);

  /// title property getter
  String? get title => getValue<String>('title');

  /// title property setter
  set title(String? value) => setValue('title', value);

  /// content property getter
  String? get content => getValue<String>('content');

  /// content property setter
  set content(String? value) => setValue('content', value);

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
    registerField('user_id', (this as Post).userIdFieldRef);
    registerField('title', (this as Post).titleFieldRef);
    registerField('content', (this as Post).contentFieldRef);
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
  QueryBuilder<Post> scope(
    QueryBuilder<Post> Function(QueryBuilder<Post>) callback,
  ) {
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
  QueryBuilder<Post> when(
    bool condition,
    QueryBuilder<Post> Function(QueryBuilder<Post>) callback,
  ) {
    return query().when(condition, callback);
  }

  /// Add WHERE EXISTS condition with relationship
  QueryBuilder<Post> whereHas<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereHas<TRelated>(relationshipName, callback);
  }

  /// Add WHERE NOT EXISTS condition with relationship
  QueryBuilder<Post> whereDoesntHave<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereDoesntHave<TRelated>(relationshipName, callback);
  }

  /// Add WHERE condition for relationship count
  QueryBuilder<Post> whereHasCount<TRelated extends Model<TRelated>>(
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
  QueryBuilder<Post> orWhere(
    String fieldRef,
    dynamic operator, [
    dynamic value,
  ]) {
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
  static const userId = 'user_id';
  static const title = 'title';
  static const content = 'content';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

extension _$ProfileFieldAccess on Profile {
  /// Get id field for registration
  Field get idFieldRef => _id;

  /// Get userId field for registration
  Field get userIdFieldRef => _userId;

  /// Get bio field for registration
  Field get bioFieldRef => _bio;

  /// Get avatar field for registration
  Field get avatarFieldRef => _avatar;

  /// Get createdAt field for registration
  Field get createdAtFieldRef => _createdAt;

  /// Get updatedAt field for registration
  Field get updatedAtFieldRef => _updatedAt;
}

mixin _$ProfileFields on Model<Profile> {
  /// id property getter
  int? get id => getValue<int>('id');

  /// id property setter
  set id(int? value) => setValue('id', value);

  /// userId property getter
  int? get userId => getValue<int>('user_id');

  /// userId property setter
  set userId(int? value) => setValue('user_id', value);

  /// bio property getter
  String? get bio => getValue<String>('bio');

  /// bio property setter
  set bio(String? value) => setValue('bio', value);

  /// avatar property getter
  String? get avatar => getValue<String>('avatar');

  /// avatar property setter
  set avatar(String? value) => setValue('avatar', value);

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
    registerField('id', (this as Profile).idFieldRef);
    registerField('user_id', (this as Profile).userIdFieldRef);
    registerField('bio', (this as Profile).bioFieldRef);
    registerField('avatar', (this as Profile).avatarFieldRef);
    registerField('created_at', (this as Profile).createdAtFieldRef);
    registerField('updated_at', (this as Profile).updatedAtFieldRef);
  }

  @override
  void initializeRelationships() {
    super.initializeRelationships();
    relationships.registerLazy('user', () => (this as Profile).user());
  }

  /// Create new query builder for this model
  QueryBuilder<Profile> query() {
    return Model.query<Profile>(() => Profile());
  }

  /// Add WHERE condition using type-safe field reference
  QueryBuilder<Profile> where(
    String fieldRef,
    dynamic operator, [
    dynamic value,
  ]) {
    return query().where(fieldRef, operator, value);
  }

  /// Add WHERE IN condition using type-safe field reference
  QueryBuilder<Profile> whereIn(String fieldRef, List<dynamic> values) {
    return query().whereIn(fieldRef, values);
  }

  /// Add WHERE NOT IN condition using type-safe field reference
  QueryBuilder<Profile> whereNotIn(String fieldRef, List<dynamic> values) {
    return query().whereNotIn(fieldRef, values);
  }

  /// Add WHERE NULL condition using type-safe field reference
  QueryBuilder<Profile> whereNull(String fieldRef) {
    return query().whereNull(fieldRef);
  }

  /// Add WHERE NOT NULL condition using type-safe field reference
  QueryBuilder<Profile> whereNotNull(String fieldRef) {
    return query().whereNotNull(fieldRef);
  }

  /// Add WHERE BETWEEN condition using type-safe field reference
  QueryBuilder<Profile> whereBetween(
    String fieldRef,
    dynamic min,
    dynamic max,
  ) {
    return query().whereBetween(fieldRef, min, max);
  }

  /// Add ORDER BY clause using type-safe field reference
  QueryBuilder<Profile> orderBy(String fieldRef, [String direction = 'ASC']) {
    return query().orderBy(fieldRef, direction);
  }

  /// Add ORDER BY ASC using type-safe field reference
  QueryBuilder<Profile> orderByAsc(String fieldRef) {
    return query().orderByAsc(fieldRef);
  }

  /// Add ORDER BY DESC using type-safe field reference
  QueryBuilder<Profile> orderByDesc(String fieldRef) {
    return query().orderByDesc(fieldRef);
  }

  /// Set LIMIT
  QueryBuilder<Profile> limit(int count) {
    return query().limit(count);
  }

  /// Set OFFSET
  QueryBuilder<Profile> offset(int count) {
    return query().offset(count);
  }

  /// Take records (alias for limit)
  QueryBuilder<Profile> take(int count) {
    return query().take(count);
  }

  /// Skip records (alias for offset)
  QueryBuilder<Profile> skip(int count) {
    return query().skip(count);
  }

  /// Select specific columns using type-safe field references
  QueryBuilder<Profile> select(List<String> fieldRefs) {
    return query().select(fieldRefs);
  }

  /// Apply scope callback
  QueryBuilder<Profile> scope(
    QueryBuilder<Profile> Function(QueryBuilder<Profile>) callback,
  ) {
    return query().scope(callback);
  }

  /// Execute query and return all results
  Future<List<Profile>> get() {
    return query().get();
  }

  /// Execute query and return first result
  Future<Profile?> first() {
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
  Future<PaginationResult<Profile>> paginate({int page = 1, int perPage = 15}) {
    return query().paginate(page: page, perPage: perPage);
  }

  /// Include relationships for eager loading
  QueryBuilder<Profile> include(dynamic relationships) {
    return query().include(relationships);
  }

  /// Load relationships eagerly (alias for include)
  QueryBuilder<Profile> withRelations(dynamic relationships) {
    return query().withRelations(relationships);
  }

  /// Apply conditional query logic
  QueryBuilder<Profile> when(
    bool condition,
    QueryBuilder<Profile> Function(QueryBuilder<Profile>) callback,
  ) {
    return query().when(condition, callback);
  }

  /// Add WHERE EXISTS condition with relationship
  QueryBuilder<Profile> whereHas<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereHas<TRelated>(relationshipName, callback);
  }

  /// Add WHERE NOT EXISTS condition with relationship
  QueryBuilder<Profile> whereDoesntHave<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereDoesntHave<TRelated>(relationshipName, callback);
  }

  /// Add WHERE condition for relationship count
  QueryBuilder<Profile> whereHasCount<TRelated extends Model<TRelated>>(
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
  QueryBuilder<Profile> withTrashed() {
    return query().withTrashed();
  }

  /// Only show soft deleted records
  QueryBuilder<Profile> onlyTrashed() {
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
  QueryBuilder<Profile> orWhere(
    String fieldRef,
    dynamic operator, [
    dynamic value,
  ]) {
    return query().orWhere(fieldRef, operator, value);
  }

  /// Add OR WHERE IN condition
  QueryBuilder<Profile> orWhereIn(String fieldRef, List<dynamic> values) {
    return query().orWhereIn(fieldRef, values);
  }

  /// Add OR WHERE NOT IN condition
  QueryBuilder<Profile> orWhereNotIn(String fieldRef, List<dynamic> values) {
    return query().orWhereNotIn(fieldRef, values);
  }

  /// Add OR WHERE NULL condition
  QueryBuilder<Profile> orWhereNull(String fieldRef) {
    return query().orWhereNull(fieldRef);
  }

  /// Add OR WHERE NOT NULL condition
  QueryBuilder<Profile> orWhereNotNull(String fieldRef) {
    return query().orWhereNotNull(fieldRef);
  }

  /// Add OR WHERE BETWEEN condition
  QueryBuilder<Profile> orWhereBetween(
    String fieldRef,
    dynamic min,
    dynamic max,
  ) {
    return query().orWhereBetween(fieldRef, min, max);
  }
}

/// Type-safe field references for Profile queries
/// Use ProfileFields.name instead of 'name' string literals
abstract class ProfileFields {
  static const id = 'id';
  static const userId = 'user_id';
  static const bio = 'bio';
  static const avatar = 'avatar';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

extension _$CommentFieldAccess on Comment {
  /// Get id field for registration
  Field get idFieldRef => _id;

  /// Get userId field for registration
  Field get userIdFieldRef => _userId;

  /// Get postId field for registration
  Field get postIdFieldRef => _postId;

  /// Get content field for registration
  Field get contentFieldRef => _content;

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

  /// userId property getter
  int? get userId => getValue<int>('user_id');

  /// userId property setter
  set userId(int? value) => setValue('user_id', value);

  /// postId property getter
  int? get postId => getValue<int>('post_id');

  /// postId property setter
  set postId(int? value) => setValue('post_id', value);

  /// content property getter
  String? get content => getValue<String>('content');

  /// content property setter
  set content(String? value) => setValue('content', value);

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
    registerField('user_id', (this as Comment).userIdFieldRef);
    registerField('post_id', (this as Comment).postIdFieldRef);
    registerField('content', (this as Comment).contentFieldRef);
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
  static const userId = 'user_id';
  static const postId = 'post_id';
  static const content = 'content';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

extension _$RoleFieldAccess on Role {
  /// Get id field for registration
  Field get idFieldRef => _id;

  /// Get name field for registration
  Field get nameFieldRef => _name;

  /// Get description field for registration
  Field get descriptionFieldRef => _description;

  /// Get createdAt field for registration
  Field get createdAtFieldRef => _createdAt;

  /// Get updatedAt field for registration
  Field get updatedAtFieldRef => _updatedAt;
}

mixin _$RoleFields on Model<Role> {
  /// id property getter
  int? get id => getValue<int>('id');

  /// id property setter
  set id(int? value) => setValue('id', value);

  /// name property getter
  String? get name => getValue<String>('name');

  /// name property setter
  set name(String? value) => setValue('name', value);

  /// description property getter
  String? get description => getValue<String>('description');

  /// description property setter
  set description(String? value) => setValue('description', value);

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
    registerField('id', (this as Role).idFieldRef);
    registerField('name', (this as Role).nameFieldRef);
    registerField('description', (this as Role).descriptionFieldRef);
    registerField('created_at', (this as Role).createdAtFieldRef);
    registerField('updated_at', (this as Role).updatedAtFieldRef);
  }

  @override
  void initializeRelationships() {
    super.initializeRelationships();
    relationships.registerLazy('users', () => (this as Role).users());
  }

  /// Create new query builder for this model
  QueryBuilder<Role> query() {
    return Model.query<Role>(() => Role());
  }

  /// Add WHERE condition using type-safe field reference
  QueryBuilder<Role> where(String fieldRef, dynamic operator, [dynamic value]) {
    return query().where(fieldRef, operator, value);
  }

  /// Add WHERE IN condition using type-safe field reference
  QueryBuilder<Role> whereIn(String fieldRef, List<dynamic> values) {
    return query().whereIn(fieldRef, values);
  }

  /// Add WHERE NOT IN condition using type-safe field reference
  QueryBuilder<Role> whereNotIn(String fieldRef, List<dynamic> values) {
    return query().whereNotIn(fieldRef, values);
  }

  /// Add WHERE NULL condition using type-safe field reference
  QueryBuilder<Role> whereNull(String fieldRef) {
    return query().whereNull(fieldRef);
  }

  /// Add WHERE NOT NULL condition using type-safe field reference
  QueryBuilder<Role> whereNotNull(String fieldRef) {
    return query().whereNotNull(fieldRef);
  }

  /// Add WHERE BETWEEN condition using type-safe field reference
  QueryBuilder<Role> whereBetween(String fieldRef, dynamic min, dynamic max) {
    return query().whereBetween(fieldRef, min, max);
  }

  /// Add ORDER BY clause using type-safe field reference
  QueryBuilder<Role> orderBy(String fieldRef, [String direction = 'ASC']) {
    return query().orderBy(fieldRef, direction);
  }

  /// Add ORDER BY ASC using type-safe field reference
  QueryBuilder<Role> orderByAsc(String fieldRef) {
    return query().orderByAsc(fieldRef);
  }

  /// Add ORDER BY DESC using type-safe field reference
  QueryBuilder<Role> orderByDesc(String fieldRef) {
    return query().orderByDesc(fieldRef);
  }

  /// Set LIMIT
  QueryBuilder<Role> limit(int count) {
    return query().limit(count);
  }

  /// Set OFFSET
  QueryBuilder<Role> offset(int count) {
    return query().offset(count);
  }

  /// Take records (alias for limit)
  QueryBuilder<Role> take(int count) {
    return query().take(count);
  }

  /// Skip records (alias for offset)
  QueryBuilder<Role> skip(int count) {
    return query().skip(count);
  }

  /// Select specific columns using type-safe field references
  QueryBuilder<Role> select(List<String> fieldRefs) {
    return query().select(fieldRefs);
  }

  /// Apply scope callback
  QueryBuilder<Role> scope(
    QueryBuilder<Role> Function(QueryBuilder<Role>) callback,
  ) {
    return query().scope(callback);
  }

  /// Execute query and return all results
  Future<List<Role>> get() {
    return query().get();
  }

  /// Execute query and return first result
  Future<Role?> first() {
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
  Future<PaginationResult<Role>> paginate({int page = 1, int perPage = 15}) {
    return query().paginate(page: page, perPage: perPage);
  }

  /// Include relationships for eager loading
  QueryBuilder<Role> include(dynamic relationships) {
    return query().include(relationships);
  }

  /// Load relationships eagerly (alias for include)
  QueryBuilder<Role> withRelations(dynamic relationships) {
    return query().withRelations(relationships);
  }

  /// Apply conditional query logic
  QueryBuilder<Role> when(
    bool condition,
    QueryBuilder<Role> Function(QueryBuilder<Role>) callback,
  ) {
    return query().when(condition, callback);
  }

  /// Add WHERE EXISTS condition with relationship
  QueryBuilder<Role> whereHas<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereHas<TRelated>(relationshipName, callback);
  }

  /// Add WHERE NOT EXISTS condition with relationship
  QueryBuilder<Role> whereDoesntHave<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    return query().whereDoesntHave<TRelated>(relationshipName, callback);
  }

  /// Add WHERE condition for relationship count
  QueryBuilder<Role> whereHasCount<TRelated extends Model<TRelated>>(
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
  QueryBuilder<Role> withTrashed() {
    return query().withTrashed();
  }

  /// Only show soft deleted records
  QueryBuilder<Role> onlyTrashed() {
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
  QueryBuilder<Role> orWhere(
    String fieldRef,
    dynamic operator, [
    dynamic value,
  ]) {
    return query().orWhere(fieldRef, operator, value);
  }

  /// Add OR WHERE IN condition
  QueryBuilder<Role> orWhereIn(String fieldRef, List<dynamic> values) {
    return query().orWhereIn(fieldRef, values);
  }

  /// Add OR WHERE NOT IN condition
  QueryBuilder<Role> orWhereNotIn(String fieldRef, List<dynamic> values) {
    return query().orWhereNotIn(fieldRef, values);
  }

  /// Add OR WHERE NULL condition
  QueryBuilder<Role> orWhereNull(String fieldRef) {
    return query().orWhereNull(fieldRef);
  }

  /// Add OR WHERE NOT NULL condition
  QueryBuilder<Role> orWhereNotNull(String fieldRef) {
    return query().orWhereNotNull(fieldRef);
  }

  /// Add OR WHERE BETWEEN condition
  QueryBuilder<Role> orWhereBetween(String fieldRef, dynamic min, dynamic max) {
    return query().orWhereBetween(fieldRef, min, max);
  }
}

/// Type-safe field references for Role queries
/// Use RoleFields.name instead of 'name' string literals
abstract class RoleFields {
  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}
