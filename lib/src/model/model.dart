import '../fields/field.dart';
import '../fields/datetime_fields.dart';
import '../fields/numeric_fields.dart';
import '../database/database.dart';
import 'relationships.dart';
import '../query/query_builder.dart';
import '../query/scopes.dart';
import 'soft_deletes.dart';

/// Base class for all ORM models in laralite
///
/// Provides field registry, serialization, and basic CRUD operations
abstract class Model<T extends Model<T>> {
  /// Registry of all fields in this model
  final Map<String, Field> _fields = {};

  /// Registry of all relationships in this model
  final RelationshipRegistry _relationships = RelationshipRegistry();

  /// Registry of query scopes for this model
  final ScopeRegistry<T> _scopes = ScopeRegistry<T>();

  /// Whether this model exists in the database (has been saved)
  bool _exists = false;

  /// Whether this model has been modified since last save
  bool _isDirty = false;

  /// Primary key value
  dynamic _primaryKeyValue;

  /// Table name for this model (must be implemented by subclasses)
  String get table;

  /// Primary key field name (defaults to 'id')
  String get primaryKey => 'id';

  /// Whether to automatically manage timestamps
  bool get timestamps => false;

  /// Created at field name
  String get createdAtColumn => 'created_at';

  /// Updated at field name
  String get updatedAtColumn => 'updated_at';

  /// Constructor
  Model() {
    registerFields();
    _initializeTimestamps();
    initializeScopes();
    initializeRelationships();
  }

  /// Register all fields (to be implemented by subclasses or code generator)
  void registerFields() {
    // This will be implemented by subclasses manually or via code generation
    // For now, we provide a default implementation that does nothing
    // Subclasses should call registerField() for each field
  }

  /// Register a field with the model
  void registerField(String columnName, Field field) {
    _fields[columnName] = field;
  }

  /// Initialize timestamp fields if timestamps are enabled
  void _initializeTimestamps() {
    if (timestamps) {
      // Add timestamp fields if they don't exist
      if (!_fields.containsKey(createdAtColumn)) {
        _fields[createdAtColumn] = TimestampField(autoCreate: true);
      }
      if (!_fields.containsKey(updatedAtColumn)) {
        _fields[updatedAtColumn] = TimestampField(autoUpdate: true);
      }
    }
  }

  /// Get a field by its column name
  Field<TField>? getField<TField>(String columnName) {
    return _fields[columnName] as Field<TField>?;
  }

  /// Get all registered fields
  Map<String, Field> get fields => Map.unmodifiable(_fields);

  /// Get the relationship registry
  RelationshipRegistry get relationships => _relationships;

  /// Get the scope registry
  ScopeRegistry<T> get scopes => _scopes;

  /// Get the value of a field
  TValue? getValue<TValue>(String columnName) {
    final field = _fields[columnName];
    return field?.value as TValue?;
  }

  /// Set the value of a field
  void setValue<TValue>(String columnName, TValue? value) {
    final field = _fields[columnName];
    if (field != null) {
      final oldValue = field.value;
      field.value = value;

      // Mark model as dirty if value changed
      if (oldValue != value) {
        _isDirty = true;
      }
    }
  }

  /// Get the primary key value
  dynamic get primaryKeyValue => _primaryKeyValue;

  /// Set the primary key value
  set primaryKeyValue(dynamic value) {
    _primaryKeyValue = value;
    setValue(primaryKey, value);
  }

  /// Whether this model exists in the database
  bool get exists => _exists;

  /// Whether this model has been modified
  bool get isDirty => _isDirty || _fields.values.any((field) => field.isDirty);

  /// Mark this model as existing in the database
  void markAsExisting() {
    _exists = true;
    _isDirty = false;
    for (final field in _fields.values) {
      field.markClean();
      field.markLoaded();
    }
  }

  /// Mark this model as new (not yet saved)
  void markAsNew() {
    _exists = false;
    _primaryKeyValue = null;
    setValue(primaryKey, null);
  }

  /// Convert model to Map for database storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    for (final entry in _fields.entries) {
      final columnName = entry.key;
      final field = entry.value;

      // Include nullable fields even when value is null
      if (field.value != null || field.nullable) {
        // Use field's serialization method
        final serializedValue = field.serializeValue(field.value);

        // Parse the serialized value back to proper type for Map
        if (serializedValue == 'NULL' || field.value == null) {
          map[columnName] = null;
        } else if (serializedValue.startsWith("'") &&
            serializedValue.endsWith("'")) {
          // Remove quotes from string values
          map[columnName] = serializedValue.substring(
            1,
            serializedValue.length - 1,
          );
        } else {
          // Parse numeric and boolean values
          if (serializedValue == '1' || serializedValue == '0') {
            map[columnName] = serializedValue == '1';
          } else {
            final intValue = int.tryParse(serializedValue);
            if (intValue != null) {
              map[columnName] = intValue;
            } else {
              final doubleValue = double.tryParse(serializedValue);
              if (doubleValue != null) {
                map[columnName] = doubleValue;
              } else {
                map[columnName] = serializedValue;
              }
            }
          }
        }
      }
    }

    return map;
  }

  /// Create model from Map (database row)
  void fromMap(Map<String, dynamic> map) {
    for (final entry in map.entries) {
      final columnName = entry.key;
      final value = entry.value;
      final field = _fields[columnName];

      if (field != null) {
        // Use field's deserialization method
        field.value = field.deserializeValue(value);
        field.markClean();
        field.markLoaded();
      }

      // Set primary key value
      if (columnName == primaryKey) {
        _primaryKeyValue = value;
      }
    }

    markAsExisting();
  }

  /// Touch timestamp fields if auto-update is enabled
  void _touchTimestamps() {
    if (timestamps) {
      final updatedAtField = _fields[updatedAtColumn];
      if (updatedAtField is TimestampField) {
        updatedAtField.touchIfAutoUpdate();
      }

      // Touch created_at only for new records
      if (!_exists) {
        final createdAtField = _fields[createdAtColumn];
        if (createdAtField is TimestampField) {
          createdAtField.touchIfAutoCreate();
        }
      }
    }
  }

  /// Validate all fields in this model
  ValidationResult validate() {
    final errors = <String, List<String>>{};

    for (final entry in _fields.entries) {
      final columnName = entry.key;
      final field = entry.value;
      final result = field.validate();

      if (!result.isValid) {
        errors[columnName] = result.errors;
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors.values.expand((e) => e).toList(),
    );
  }

  /// Save the model to database
  Future<bool> save() async {
    // Touch timestamps
    _touchTimestamps();

    // Validate model
    final validation = validate();
    if (!validation.isValid) {
      throw ValidationException(validation.errors);
    }

    final map = toMap();

    if (_exists && _primaryKeyValue != null) {
      // Update existing record
      final affectedRows = await Database.execute(
        'UPDATE $table SET ${_buildUpdateClause(map)} WHERE $primaryKey = ?',
        [..._buildUpdateValues(map), _primaryKeyValue],
      );

      if (affectedRows > 0) {
        markAsExisting();
        return true;
      }
      return false;
    } else {
      // Insert new record
      final result = await Database.execute(
        'INSERT INTO $table (${_buildInsertColumns(map)}) VALUES (${_buildInsertPlaceholders(map)})',
        _buildInsertValues(map),
      );

      if (result > 0) {
        // Only set last_insert_rowid when primary key is auto-increment integer and wasn't provided
        final pkField = _fields[primaryKey];
        if (_primaryKeyValue == null && pkField is AutoIncrementField) {
          final rows = await Database.query('SELECT last_insert_rowid() as id');
          if (rows.isNotEmpty) {
            primaryKeyValue = rows.first['id'];
          }
        }

        markAsExisting();
        return true;
      }
      return false;
    }
  }

  /// Delete the model from database
  Future<bool> delete() async {
    if (!_exists || _primaryKeyValue == null) {
      return false;
    }

    final affectedRows = await Database.execute(
      'DELETE FROM $table WHERE $primaryKey = ?',
      [_primaryKeyValue],
    );

    if (affectedRows > 0) {
      markAsNew();
      return true;
    }
    return false;
  }

  /// Find a model by primary key
  static Future<TModel?> find<TModel extends Model<TModel>>(
    dynamic id,
    TModel Function() constructor,
  ) async {
    final instance = constructor();

    final rows = await Database.query(
      'SELECT * FROM ${instance.table} WHERE ${instance.primaryKey} = ?',
      [id],
    );

    if (rows.isNotEmpty) {
      instance.fromMap(rows.first);
      return instance;
    }

    return null;
  }

  /// Get all models from table
  static Future<List<TModel>> all<TModel extends Model<TModel>>(
    TModel Function() constructor,
  ) async {
    final instance = constructor();

    // Check if model uses soft deletes and apply soft delete scope
    if (instance is SoftDeletesMixin) {
      final mixin = instance as SoftDeletesMixin;
      // Apply soft delete scope manually by filtering out deleted_at IS NOT NULL
      final queryBuilder = QueryBuilder<TModel>(constructor);
      queryBuilder.whereNull(mixin.deletedAtColumn);
      return await queryBuilder.get();
    }

    // For models without soft deletes, use direct query
    final rows = await Database.query('SELECT * FROM ${instance.table}');

    return rows.map((row) {
      final model = constructor();
      model.fromMap(row);
      return model;
    }).toList();
  }

  /// Create a new model and save it
  static Future<TModel> create<TModel extends Model<TModel>>(
    TModel model,
  ) async {
    final success = await model.save();
    if (!success) {
      throw Exception('Failed to create model');
    }
    return model;
  }

  /// Create a new query builder for this model
  static QueryBuilder<TModel> query<TModel extends Model<TModel>>(
    TModel Function() constructor,
  ) {
    final queryBuilder = QueryBuilder<TModel>(constructor);
    final instance = constructor();

    // Apply global scopes
    return instance._scopes.applyGlobalScopes(queryBuilder);
  }

  /// Create a query builder and apply a WHERE condition
  static QueryBuilder<TModel> where<TModel extends Model<TModel>>(
    TModel Function() constructor,
    String column,
    dynamic operator, [
    dynamic value,
  ]) {
    return query<TModel>(constructor).where(column, operator, value);
  }

  /// Create a query builder and apply a WHERE IN condition
  static QueryBuilder<TModel> whereIn<TModel extends Model<TModel>>(
    TModel Function() constructor,
    String column,
    List<dynamic> values,
  ) {
    return query<TModel>(constructor).whereIn(column, values);
  }

  /// Create a query builder and apply an ORDER BY clause
  static QueryBuilder<TModel> orderBy<TModel extends Model<TModel>>(
    TModel Function() constructor,
    String column, [
    String direction = 'ASC',
  ]) {
    return query<TModel>(constructor).orderBy(column, direction);
  }

  /// Create a query builder with a LIMIT
  static QueryBuilder<TModel> limit<TModel extends Model<TModel>>(
    TModel Function() constructor,
    int count,
  ) {
    return query<TModel>(constructor).limit(count);
  }

  /// Apply a local scope to a query
  static QueryBuilder<TModel> scope<TModel extends Model<TModel>>(
    TModel Function() constructor,
    String scopeName,
  ) {
    final queryBuilder = query<TModel>(constructor);
    final instance = constructor();
    return instance._scopes.applyLocalScope(queryBuilder, scopeName);
  }

  /// Execute a function within a transaction context
  ///
  /// Automatically commits on success and rolls back on error.
  /// Returns the result of the callback function.
  static Future<T> withTransaction<T>(Future<T> Function() callback) async {
    return await Database.withTransaction(callback);
  }

  /// Paginate models
  static Future<PaginationResult<TModel>> paginate<
    TModel extends Model<TModel>
  >(TModel Function() constructor, {int page = 1, int perPage = 15}) async {
    return await query<TModel>(
      constructor,
    ).paginate(page: page, perPage: perPage);
  }

  /// Find a model by primary key or throw exception
  static Future<TModel> findOrFail<TModel extends Model<TModel>>(
    dynamic id,
    TModel Function() constructor,
  ) async {
    final model = await find<TModel>(id, constructor);
    if (model == null) {
      throw Exception('Model not found with id: $id');
    }
    return model;
  }

  /// Find many models by primary keys
  static Future<List<TModel>> findMany<TModel extends Model<TModel>>(
    List<dynamic> ids,
    TModel Function() constructor,
  ) async {
    if (ids.isEmpty) return [];
    return await whereIn<TModel>(
      constructor,
      constructor().primaryKey,
      ids,
    ).get();
  }

  /// Find first model matching conditions or create new one
  static Future<TModel> firstOrCreate<TModel extends Model<TModel>>(
    TModel Function() constructor,
    Map<String, dynamic> attributes, [
    Map<String, dynamic>? values,
  ]) async {
    // Build query for finding existing
    var queryBuilder = query<TModel>(constructor);
    for (final entry in attributes.entries) {
      queryBuilder = queryBuilder.where(entry.key, entry.value);
    }

    final existing = await queryBuilder.first();
    if (existing != null) {
      return existing;
    }

    // Create new model with combined attributes and values
    final model = constructor();
    final combinedData = {...attributes, ...?values};
    model.fromMap(combinedData);
    await model.save();
    return model;
  }

  /// Update existing model or create new one
  static Future<TModel> updateOrCreate<TModel extends Model<TModel>>(
    TModel Function() constructor,
    Map<String, dynamic> attributes,
    Map<String, dynamic> values,
  ) async {
    // Build query for finding existing
    var queryBuilder = query<TModel>(constructor);
    for (final entry in attributes.entries) {
      queryBuilder = queryBuilder.where(entry.key, entry.value);
    }

    final existing = await queryBuilder.first();
    if (existing != null) {
      // Update existing
      for (final entry in values.entries) {
        existing.setValue(entry.key, entry.value);
      }
      await existing.save();
      return existing;
    }

    // Create new model
    final model = constructor();
    final combinedData = {...attributes, ...values};
    model.fromMap(combinedData);
    await model.save();
    return model;
  }

  /// Create multiple models in a single transaction
  static Future<List<TModel>> createMany<TModel extends Model<TModel>>(
    TModel Function() constructor,
    List<Map<String, dynamic>> records,
  ) async {
    if (records.isEmpty) return [];

    return await withTransaction(() async {
      final models = <TModel>[];
      for (final record in records) {
        final model = constructor();
        model.fromMap(record);
        await model.save();
        models.add(model);
      }
      return models;
    });
  }

  /// Create multiple models in chunks to avoid memory issues
  static Future<List<TModel>> createManyInChunks<TModel extends Model<TModel>>(
    TModel Function() constructor,
    List<Map<String, dynamic>> records, {
    int chunkSize = 100,
  }) async {
    if (records.isEmpty) return [];

    final results = <TModel>[];

    for (int i = 0; i < records.length; i += chunkSize) {
      final end = (i + chunkSize < records.length)
          ? i + chunkSize
          : records.length;
      final chunk = records.sublist(i, end);

      final chunkResults = await createMany<TModel>(constructor, chunk);
      results.addAll(chunkResults);
    }

    return results;
  }

  /// Update multiple models in a single transaction
  static Future<int> updateMany<TModel extends Model<TModel>>(
    TModel Function() constructor,
    Map<String, dynamic> conditions,
    Map<String, dynamic> updates,
  ) async {
    if (conditions.isEmpty || updates.isEmpty) return 0;

    return await withTransaction(() async {
      final instance = constructor();

      // Build WHERE clause
      final whereClause = conditions.keys
          .map((key) => '$key = ?')
          .join(' AND ');
      final whereValues = conditions.values.toList();

      // Build SET clause
      final setClause = updates.keys.map((key) => '$key = ?').join(', ');
      final setValues = updates.values.toList();

      final sql = 'UPDATE ${instance.table} SET $setClause WHERE $whereClause';
      final parameters = [...setValues, ...whereValues];

      return await Database.execute(sql, parameters);
    });
  }

  /// Insert or update multiple records using UPSERT
  static Future<List<TModel>> upsertMany<TModel extends Model<TModel>>(
    TModel Function() constructor,
    List<Map<String, dynamic>> records,
    List<String> conflictColumns,
  ) async {
    if (records.isEmpty) return [];

    return await withTransaction(() async {
      final models = <TModel>[];

      for (final record in records) {
        final model = constructor();
        model.fromMap(record);

        // Check if record exists based on conflict columns
        var queryBuilder = query<TModel>(constructor);
        for (final column in conflictColumns) {
          if (record.containsKey(column)) {
            queryBuilder = queryBuilder.where(column, record[column]);
          }
        }

        final existing = await queryBuilder.first();
        if (existing != null) {
          // Update existing
          for (final entry in record.entries) {
            existing.setValue(entry.key, entry.value);
          }
          await existing.save();
          models.add(existing);
        } else {
          // Create new
          await model.save();
          models.add(model);
        }
      }

      return models;
    });
  }

  /// Delete multiple models by conditions
  static Future<int> deleteMany<TModel extends Model<TModel>>(
    TModel Function() constructor,
    Map<String, dynamic> conditions,
  ) async {
    if (conditions.isEmpty) return 0;

    final instance = constructor();

    // Build WHERE clause
    final whereClause = conditions.keys.map((key) => '$key = ?').join(' AND ');
    final whereValues = conditions.values.toList();

    final sql = 'DELETE FROM ${instance.table} WHERE $whereClause';

    return await Database.execute(sql, whereValues);
  }

  /// Insert or replace record (SQLite REPLACE)
  Future<bool> insertOrReplace() async {
    // Touch timestamps
    _touchTimestamps();

    // Validate model
    final validation = validate();
    if (!validation.isValid) {
      throw ValidationException(validation.errors);
    }

    final map = toMap();

    final result = await Database.execute(
      'REPLACE INTO $table (${_buildInsertColumns(map)}) VALUES (${_buildInsertPlaceholders(map)})',
      _buildInsertValues(map),
    );

    if (result > 0) {
      // Get the last inserted ID for auto-increment primary keys
      final rows = await Database.query('SELECT last_insert_rowid() as id');
      if (rows.isNotEmpty) {
        primaryKeyValue = rows.first['id'];
      }

      markAsExisting();
      return true;
    }
    return false;
  }

  /// Insert or ignore record (SQLite INSERT OR IGNORE)
  Future<bool> insertOrIgnore() async {
    // Touch timestamps for new records
    if (!_exists) {
      _touchTimestamps();
    }

    // Validate model
    final validation = validate();
    if (!validation.isValid) {
      throw ValidationException(validation.errors);
    }

    final map = toMap();

    final result = await Database.execute(
      'INSERT OR IGNORE INTO $table (${_buildInsertColumns(map)}) VALUES (${_buildInsertPlaceholders(map)})',
      _buildInsertValues(map),
    );

    if (result > 0) {
      // Get the last inserted ID for auto-increment primary keys
      final rows = await Database.query('SELECT last_insert_rowid() as id');
      if (rows.isNotEmpty && rows.first['id'] != 0) {
        primaryKeyValue = rows.first['id'];
        markAsExisting();
        return true;
      }
    }
    return false;
  }

  /// Upsert using ON CONFLICT (modern SQLite syntax)
  Future<bool> upsert({
    required List<String> conflictColumns,
    Map<String, dynamic>? updateData,
  }) async {
    // Touch timestamps
    _touchTimestamps();

    // Validate model
    final validation = validate();
    if (!validation.isValid) {
      throw ValidationException(validation.errors);
    }

    final map = toMap();
    final conflictClause = conflictColumns.join(', ');

    // Use provided updateData or exclude conflict columns from update
    final updateMap =
        updateData ??
        Map.fromEntries(
          map.entries.where((entry) => !conflictColumns.contains(entry.key)),
        );

    final updateClause = updateMap.keys
        .map((key) => '$key = excluded.$key')
        .join(', ');

    final sql =
        '''
      INSERT INTO $table (${_buildInsertColumns(map)}) 
      VALUES (${_buildInsertPlaceholders(map)})
      ON CONFLICT ($conflictClause) DO UPDATE SET $updateClause
    ''';

    final result = await Database.execute(sql, _buildInsertValues(map));

    if (result > 0) {
      // Get the inserted/updated row
      var queryBuilder = Model.query<T>(() => this as T);
      for (final column in conflictColumns) {
        if (map.containsKey(column)) {
          queryBuilder = queryBuilder.where(column, map[column]);
        }
      }

      final updated = await queryBuilder.first();
      if (updated != null) {
        // Update this model with the result
        fromMap(updated.toMap());
      }

      markAsExisting();
      return true;
    }
    return false;
  }

  /// Insert multiple records with OR REPLACE
  static Future<List<TModel>> insertOrReplaceMany<TModel extends Model<TModel>>(
    TModel Function() constructor,
    List<Map<String, dynamic>> records,
  ) async {
    if (records.isEmpty) return [];

    return await withTransaction(() async {
      final models = <TModel>[];
      for (final record in records) {
        final model = constructor();
        model.fromMap(record);
        await model.insertOrReplace();
        models.add(model);
      }
      return models;
    });
  }

  /// Insert multiple records with OR IGNORE
  static Future<List<TModel>> insertOrIgnoreMany<TModel extends Model<TModel>>(
    TModel Function() constructor,
    List<Map<String, dynamic>> records,
  ) async {
    if (records.isEmpty) return [];

    final models = <TModel>[];
    for (final record in records) {
      final model = constructor();
      model.fromMap(record);
      final success = await model.insertOrIgnore();
      if (success) {
        models.add(model);
      }
    }
    return models;
  }

  // Helper methods for SQL generation
  String _buildUpdateClause(Map<String, dynamic> map) {
    return map.keys
        .where((key) => key != primaryKey)
        .map((key) => '$key = ?')
        .join(', ');
  }

  List<dynamic> _buildUpdateValues(Map<String, dynamic> map) {
    return map.entries
        .where((entry) => entry.key != primaryKey)
        .map((entry) => entry.value)
        .toList();
  }

  String _buildInsertColumns(Map<String, dynamic> map) {
    return map.keys
        .where((key) => key != primaryKey || map[key] != null)
        .join(', ');
  }

  String _buildInsertPlaceholders(Map<String, dynamic> map) {
    return map.keys
        .where((key) => key != primaryKey || map[key] != null)
        .map((_) => '?')
        .join(', ');
  }

  List<dynamic> _buildInsertValues(Map<String, dynamic> map) {
    return map.entries
        .where((entry) => entry.key != primaryKey || entry.value != null)
        .map((entry) => entry.value)
        .toList();
  }

  /// Define a hasOne relationship
  HasOne<TRelated> hasOne<TRelated extends Model<TRelated>>(
    TRelated Function() relatedConstructor, {
    String? foreignKey,
    String? localKey,
  }) {
    return HasOne<TRelated>(
      parent: this,
      relatedConstructor: relatedConstructor,
      foreignKey:
          foreignKey ??
          '${table.substring(0, table.length - 1)}_id', // e.g., user_id from users
      localKey: localKey ?? primaryKey,
    );
  }

  /// Define a hasMany relationship
  HasMany<TRelated> hasMany<TRelated extends Model<TRelated>>(
    TRelated Function() relatedConstructor, {
    String? foreignKey,
    String? localKey,
  }) {
    return HasMany<TRelated>(
      parent: this,
      relatedConstructor: relatedConstructor,
      foreignKey:
          foreignKey ??
          '${table.substring(0, table.length - 1)}_id', // e.g., user_id from users
      localKey: localKey ?? primaryKey,
    );
  }

  /// Define a belongsTo relationship
  BelongsTo<TRelated> belongsTo<TRelated extends Model<TRelated>>(
    TRelated Function() relatedConstructor, {
    String? foreignKey,
    String? localKey,
  }) {
    final related = relatedConstructor();
    return BelongsTo<TRelated>(
      parent: this,
      relatedConstructor: relatedConstructor,
      foreignKey:
          foreignKey ??
          '${related.table.substring(0, related.table.length - 1)}_id', // e.g., user_id for users
      localKey: localKey ?? related.primaryKey,
    );
  }

  /// Define a belongsToMany relationship
  BelongsToMany<TRelated> belongsToMany<TRelated extends Model<TRelated>>(
    TRelated Function() relatedConstructor, {
    String? pivotTable,
    String? foreignKey,
    String? localKey,
    String? parentPivotKey,
    String? relatedPivotKey,
  }) {
    final related = relatedConstructor();
    final parentSingular = table.substring(0, table.length - 1);
    final relatedSingular = related.table.substring(
      0,
      related.table.length - 1,
    );

    // Default pivot table name: alphabetically ordered singular table names
    final defaultPivotTable = [parentSingular, relatedSingular]..sort();

    return BelongsToMany<TRelated>(
      parent: this,
      relatedConstructor: relatedConstructor,
      foreignKey: foreignKey ?? related.primaryKey,
      localKey: localKey ?? primaryKey,
      pivotTable: pivotTable ?? defaultPivotTable.join('_'),
      parentPivotKey: parentPivotKey ?? '${parentSingular}_id',
      relatedPivotKey: relatedPivotKey ?? '${relatedSingular}_id',
    );
  }

  /// Register a relationship with a name
  void registerRelationship(String name, Relationship relationship) {
    _relationships.register(name, relationship);
  }

  /// Get a relationship by name
  Future<dynamic> getRelationship(String name) async {
    final relationship = _relationships.get(name);
    if (relationship != null) {
      return await relationship.get();
    }
    return null;
  }

  /// Check if a relationship is loaded
  bool isRelationshipLoaded(String name) {
    final relationship = _relationships.get(name);
    return relationship?.isLoaded ?? false;
  }

  /// Reset all relationship caches
  void resetRelationships() {
    _relationships.resetAll();
  }

  /// Register a local scope
  void registerLocalScope(String name, LocalScope<T> scope) {
    _scopes.registerLocal(name, scope);
  }

  /// Register a global scope
  void registerGlobalScope(GlobalScope<T> scope) {
    _scopes.registerGlobal(scope);
  }

  /// Apply a local scope by name
  QueryBuilder<T> applyScope(String scopeName) {
    final queryBuilder = QueryBuilder<T>(() => this as T);
    return _scopes.applyLocalScope(queryBuilder, scopeName);
  }

  /// Initialize scopes (to be overridden by subclasses)
  void initializeScopes() {
    // Subclasses can override this to register their scopes
  }

  /// Initialize relationships (to be overridden by subclasses or code generation)
  void initializeRelationships() {
    // Subclasses can override this to register their relationships
    // Code generation will override this method to auto-register relationships
  }

  @override
  String toString() {
    return '$T(primaryKey: $_primaryKeyValue, exists: $_exists, dirty: $isDirty)';
  }
}

/// Exception thrown when model validation fails
class ValidationException implements Exception {
  final List<String> errors;

  const ValidationException(this.errors);

  @override
  String toString() => 'ValidationException: ${errors.join(', ')}';
}
