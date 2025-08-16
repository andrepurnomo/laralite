import 'dart:convert';
import '../model/model.dart';
import '../model/soft_deletes.dart';
import '../database/database.dart';

/// Helper function to process query parameters with automatic type conversion to SQLite-compatible types
dynamic processQueryParameter(dynamic value) {
  // Handle null
  if (value == null) return null;

  // DateTime -> ISO 8601 string (UTC)
  if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }

  // Boolean -> INTEGER (0 or 1)
  if (value is bool) {
    return value ? 1 : 0;
  }

  // Enum -> string representation
  if (value is Enum) {
    return value.name;
  }

  // Duration -> milliseconds as INTEGER
  if (value is Duration) {
    return value.inMilliseconds;
  }

  // Uri -> string representation
  if (value is Uri) {
    return value.toString();
  }

  // BigInt -> string (to avoid SQLite INTEGER overflow)
  if (value is BigInt) {
    return value.toString();
  }

  // List/Iterable -> JSON string (for proper serialization)
  if (value is List || value is Iterable) {
    try {
      return jsonEncode(value.toList());
    } catch (e) {
      return value.toString();
    }
  }

  // Map -> JSON string (for proper serialization)
  if (value is Map) {
    try {
      return jsonEncode(value);
    } catch (e) {
      return value.toString();
    }
  }

  // Already SQLite-compatible types: String, int, double, num
  if (value is String || value is int || value is double || value is num) {
    return value;
  }

  // Fallback: convert to string
  return value.toString();
}

/// Query builder for constructing and executing database queries
class QueryBuilder<T extends Model<T>> {
  /// The model constructor function
  final T Function() _modelConstructor;

  /// The model instance for table information
  final T _modelInstance;

  /// WHERE clause conditions
  final List<WhereCondition> _whereConditions = [];

  /// Boolean logic for WHERE clauses (AND/OR)
  final List<String> _whereBooleans = [];

  /// ORDER BY clauses
  final List<OrderClause> _orderClauses = [];

  /// LIMIT value
  int? _limit;

  /// OFFSET value
  int? _offset;

  /// SELECT columns (defaults to all columns)
  List<String>? _selectColumns;

  /// Relationships to eager load
  final List<String> _includes = [];

  /// Raw SQL bindings for selectRaw, whereRaw etc.
  final List<dynamic> _rawBindings = [];

  /// GROUP BY columns (including raw expressions)
  List<String>? _groupByColumns;

  /// Constructor
  QueryBuilder(this._modelConstructor) : _modelInstance = _modelConstructor();

  /// Get the table name
  String get table => _modelInstance.table;

  /// Add a WHERE condition
  QueryBuilder<T> where(String column, dynamic operator, [dynamic value]) {
    if (value == null) {
      // If only two arguments, treat operator as value with '=' operator
      _whereConditions.add(BasicWhereCondition(column, '=', operator));
    } else {
      _whereConditions.add(
        BasicWhereCondition(column, operator.toString(), value),
      );
    }
    _whereBooleans.add('AND');
    return this;
  }

  /// Add an OR WHERE condition
  QueryBuilder<T> orWhere(String column, dynamic operator, [dynamic value]) {
    if (value == null) {
      // If only two arguments, treat operator as value with '=' operator
      _whereConditions.add(BasicWhereCondition(column, '=', operator));
    } else {
      _whereConditions.add(
        BasicWhereCondition(column, operator.toString(), value),
      );
    }
    _whereBooleans.add('OR');
    return this;
  }

  /// Add a WHERE IN condition
  QueryBuilder<T> whereIn(String column, List<dynamic> values) {
    _whereConditions.add(WhereInCondition(column, values));
    _whereBooleans.add('AND');
    return this;
  }

  /// Add a WHERE NOT IN condition
  QueryBuilder<T> whereNotIn(String column, List<dynamic> values) {
    _whereConditions.add(WhereNotInCondition(column, values));
    _whereBooleans.add('AND');
    return this;
  }

  /// Add a WHERE NULL condition
  QueryBuilder<T> whereNull(String column) {
    _whereConditions.add(WhereNullCondition(column, true));
    _whereBooleans.add('AND');
    return this;
  }

  /// Add a WHERE NOT NULL condition
  QueryBuilder<T> whereNotNull(String column) {
    _whereConditions.add(WhereNullCondition(column, false));
    _whereBooleans.add('AND');
    return this;
  }

  /// Add a WHERE BETWEEN condition
  QueryBuilder<T> whereBetween(String column, dynamic min, dynamic max) {
    _whereConditions.add(WhereBetweenCondition(column, min, max));
    _whereBooleans.add('AND');
    return this;
  }

  /// Add an OR WHERE IN condition
  QueryBuilder<T> orWhereIn(String column, List<dynamic> values) {
    _whereConditions.add(WhereInCondition(column, values));
    _whereBooleans.add('OR');
    return this;
  }

  /// Add an OR WHERE NOT IN condition
  QueryBuilder<T> orWhereNotIn(String column, List<dynamic> values) {
    _whereConditions.add(WhereNotInCondition(column, values));
    _whereBooleans.add('OR');
    return this;
  }

  /// Add an OR WHERE NULL condition
  QueryBuilder<T> orWhereNull(String column) {
    _whereConditions.add(WhereNullCondition(column, true));
    _whereBooleans.add('OR');
    return this;
  }

  /// Add an OR WHERE NOT NULL condition
  QueryBuilder<T> orWhereNotNull(String column) {
    _whereConditions.add(WhereNullCondition(column, false));
    _whereBooleans.add('OR');
    return this;
  }

  /// Add an OR WHERE BETWEEN condition
  QueryBuilder<T> orWhereBetween(String column, dynamic min, dynamic max) {
    _whereConditions.add(WhereBetweenCondition(column, min, max));
    _whereBooleans.add('OR');
    return this;
  }

  /// Add WHERE EXISTS condition with relationship
  QueryBuilder<T> whereHas<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    final relationship = _modelInstance.relationships.get(relationshipName);
    if (relationship == null) {
      throw ArgumentError('Relationship "$relationshipName" not found');
    }

    final existsCondition = WhereExistsCondition<TRelated>(
      relationshipName,
      relationship,
      callback,
      exists: true,
    );

    _whereConditions.add(existsCondition);
    _whereBooleans.add('AND');
    return this;
  }

  /// Add WHERE NOT EXISTS condition with relationship
  QueryBuilder<T> whereDoesntHave<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    final relationship = _modelInstance.relationships.get(relationshipName);
    if (relationship == null) {
      throw ArgumentError('Relationship "$relationshipName" not found');
    }

    final existsCondition = WhereExistsCondition<TRelated>(
      relationshipName,
      relationship,
      callback,
      exists: false,
    );

    _whereConditions.add(existsCondition);
    _whereBooleans.add('AND');
    return this;
  }

  /// Add OR WHERE EXISTS condition with relationship
  QueryBuilder<T> orWhereHas<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    final relationship = _modelInstance.relationships.get(relationshipName);
    if (relationship == null) {
      throw ArgumentError('Relationship "$relationshipName" not found');
    }

    final existsCondition = WhereExistsCondition<TRelated>(
      relationshipName,
      relationship,
      callback,
      exists: true,
    );

    _whereConditions.add(existsCondition);
    _whereBooleans.add('OR');
    return this;
  }

  /// Add OR WHERE NOT EXISTS condition with relationship
  QueryBuilder<T> orWhereDoesntHave<TRelated extends Model<TRelated>>(
    String relationshipName, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    final relationship = _modelInstance.relationships.get(relationshipName);
    if (relationship == null) {
      throw ArgumentError('Relationship "$relationshipName" not found');
    }

    final existsCondition = WhereExistsCondition<TRelated>(
      relationshipName,
      relationship,
      callback,
      exists: false,
    );

    _whereConditions.add(existsCondition);
    _whereBooleans.add('OR');
    return this;
  }

  /// Add WHERE condition for relationship count
  QueryBuilder<T> whereHasCount<TRelated extends Model<TRelated>>(
    String relationshipName,
    String operator,
    int count, [
    QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback,
  ]) {
    final relationship = _modelInstance.relationships.get(relationshipName);
    if (relationship == null) {
      throw ArgumentError('Relationship "$relationshipName" not found');
    }

    final countCondition = WhereRelationshipCountCondition<TRelated>(
      relationshipName,
      relationship,
      operator,
      count,
      callback,
    );

    _whereConditions.add(countCondition);
    _whereBooleans.add('AND');
    return this;
  }

  /// Include soft deleted records in query
  QueryBuilder<T> withTrashed() {
    // Remove any existing soft delete scopes by setting a flag
    _includesTrashed = true;

    // Remove any existing null conditions for deleted_at column
    final modelInstance = _modelConstructor();
    if (modelInstance is SoftDeletesMixin) {
      final deletedAtColumn =
          (modelInstance as SoftDeletesMixin).deletedAtColumn;
      _whereConditions.removeWhere(
        (condition) =>
            condition is WhereNullCondition &&
            condition.column == deletedAtColumn &&
            condition.isNull == true,
      );
    }

    return this;
  }

  /// Only show soft deleted records
  QueryBuilder<T> onlyTrashed() {
    // Add condition to only show trashed records
    _onlyTrashed = true;
    return this;
  }

  /// Restore soft deleted records matching query conditions
  Future<int> restore() async {
    final instance = _modelConstructor();

    // Check if model supports soft deletes
    final softDeleteColumn = _getSoftDeleteColumn();
    if (softDeleteColumn == null) {
      throw UnsupportedError('Model does not support soft deletes');
    }

    // Build the WHERE clause for existing conditions
    String whereClause = '';
    List<dynamic> parameters = [];

    if (_whereConditions.isNotEmpty) {
      whereClause =
          'WHERE ${_buildWhereClause()} AND $softDeleteColumn IS NOT NULL';
      parameters = _getParameters();
    } else {
      whereClause = 'WHERE $softDeleteColumn IS NOT NULL';
    }

    final sql =
        'UPDATE ${instance.table} SET $softDeleteColumn = NULL $whereClause';

    return await Database.execute(sql, parameters);
  }

  /// Force delete records matching query conditions (permanent delete)
  Future<int> forceDelete() async {
    final instance = _modelConstructor();

    // Build the WHERE clause for existing conditions
    String whereClause = '';
    List<dynamic> parameters = [];

    if (_whereConditions.isNotEmpty) {
      whereClause = 'WHERE ${_buildWhereClause()}';
      parameters = _getParameters();
    }

    final sql = 'DELETE FROM ${instance.table} $whereClause';

    return await Database.execute(sql, parameters);
  }

  /// Get soft delete column name if model supports soft deletes
  String? _getSoftDeleteColumn() {
    final instance = _modelConstructor();

    // Check if model has SoftDeletesMixin
    if (instance.toString().contains('SoftDeletes')) {
      return 'deleted_at'; // Default soft delete column
    }

    return null;
  }

  // Private flags for soft delete handling
  bool _includesTrashed = false;
  bool _onlyTrashed = false;

  /// Get whether query includes trashed records
  bool get includesTrashed => _includesTrashed;

  /// Add an ORDER BY clause
  QueryBuilder<T> orderBy(String column, [String direction = 'ASC']) {
    _orderClauses.add(OrderClause(column, direction.toUpperCase()));
    return this;
  }

  /// Add ORDER BY ASC
  QueryBuilder<T> orderByAsc(String column) {
    return orderBy(column, 'ASC');
  }

  /// Add ORDER BY DESC
  QueryBuilder<T> orderByDesc(String column) {
    return orderBy(column, 'DESC');
  }

  /// Set LIMIT
  QueryBuilder<T> limit(int count) {
    _limit = count;
    return this;
  }

  /// Set OFFSET
  QueryBuilder<T> offset(int count) {
    _offset = count;
    return this;
  }

  /// Take only a specific number of records (alias for limit)
  QueryBuilder<T> take(int count) {
    return limit(count);
  }

  /// Skip a specific number of records (alias for offset)
  QueryBuilder<T> skip(int count) {
    return offset(count);
  }

  /// Select specific columns
  QueryBuilder<T> select(List<String> columns) {
    _selectColumns = columns;
    return this;
  }

  /// Build the SQL query
  String _buildQuery() {
    final selectClause = _selectColumns?.join(', ') ?? '*';
    var query = 'SELECT $selectClause FROM $table';

    // Build WHERE conditions including soft delete handling
    final whereConditions = <String>[];
    final allParameters = <dynamic>[];

    // Add existing WHERE conditions
    if (_whereConditions.isNotEmpty) {
      whereConditions.add(_buildWhereClause());
      allParameters.addAll(_getParameters());
    }

    // Add soft delete conditions if applicable
    final softDeleteClause = _buildSoftDeleteClause();
    if (softDeleteClause.isNotEmpty) {
      whereConditions.add(softDeleteClause);
    }

    if (whereConditions.isNotEmpty) {
      query += ' WHERE ${whereConditions.join(' AND ')}';
    }

    // Add GROUP BY
    if (_groupByColumns != null && _groupByColumns!.isNotEmpty) {
      final groupByClause = _groupByColumns!.join(', ');
      query += ' GROUP BY $groupByClause';
    }

    // Add ORDER BY
    if (_orderClauses.isNotEmpty) {
      final orderClause = _orderClauses.map((c) => c.toSql()).join(', ');
      query += ' ORDER BY $orderClause';
    }

    // Add LIMIT
    if (_limit != null) {
      query += ' LIMIT $_limit';
    }

    // Add OFFSET
    if (_offset != null) {
      query += ' OFFSET $_offset';
    }

    return query;
  }

  /// Build soft delete clause based on flags
  String _buildSoftDeleteClause() {
    final softDeleteColumn = _getSoftDeleteColumn();
    if (softDeleteColumn == null) {
      return ''; // Model doesn't support soft deletes
    }

    if (_onlyTrashed) {
      return '$softDeleteColumn IS NOT NULL';
    } else if (_includesTrashed) {
      return ''; // Include all records
    } else {
      return '$softDeleteColumn IS NULL'; // Default: exclude soft deleted
    }
  }

  /// Build WHERE clause with AND/OR logic
  String _buildWhereClause() {
    if (_whereConditions.isEmpty) return '';

    final parts = <String>[];
    for (int i = 0; i < _whereConditions.length; i++) {
      final condition = _whereConditions[i];
      if (i == 0) {
        parts.add(condition.toSql());
      } else {
        final boolean = i < _whereBooleans.length ? _whereBooleans[i] : 'AND';
        parts.add('$boolean ${condition.toSql()}');
      }
    }
    return parts.join(' ');
  }

  /// Get query parameters
  List<dynamic> _getParameters() {
    final parameters = <dynamic>[];

    // Add raw bindings from selectRaw() calls first
    parameters.addAll(_rawBindings);

    // Add parameters from WHERE conditions
    for (final condition in _whereConditions) {
      parameters.addAll(condition.getParameters());
    }

    return parameters;
  }

  /// Execute query and return all results
  Future<List<T>> get() async {
    final query = _buildQuery();
    final parameters = _getParameters();
    final rows = await Database.query(query, parameters);

    final models = rows.map((row) {
      final model = _modelConstructor();
      model.fromMap(row);
      return model;
    }).toList();

    // Load eager loaded relationships
    if (_includes.isNotEmpty && models.isNotEmpty) {
      await _loadEagerRelationships(models);
    }

    return models;
  }

  /// Execute query and return first result
  Future<T?> first() async {
    final results = await limit(1).get();
    return results.isNotEmpty ? results.first : null;
  }

  /// Execute query and return count
  Future<int> count() async {
    final originalSelect = _selectColumns;
    _selectColumns = ['COUNT(*) as count'];

    final query = _buildQuery();
    final parameters = _getParameters();
    final rows = await Database.query(query, parameters);

    _selectColumns = originalSelect; // Restore original select

    return rows.isNotEmpty ? rows.first['count'] as int : 0;
  }

  /// Check if any records exist
  Future<bool> exists() async {
    final count = await this.count();
    return count > 0;
  }

  /// Calculate sum of a column
  Future<double?> sum(String column) async {
    final originalSelect = _selectColumns;
    _selectColumns = ['SUM($column) as sum'];

    final query = _buildQuery();
    final parameters = _getParameters();
    final rows = await Database.query(query, parameters);

    _selectColumns = originalSelect; // Restore original select

    final result = rows.isNotEmpty ? rows.first['sum'] : null;
    return result != null ? (result as num).toDouble() : null;
  }

  /// Calculate average of a column
  Future<double?> avg(String column) async {
    final originalSelect = _selectColumns;
    _selectColumns = ['AVG($column) as avg'];

    final query = _buildQuery();
    final parameters = _getParameters();
    final rows = await Database.query(query, parameters);

    _selectColumns = originalSelect; // Restore original select

    final result = rows.isNotEmpty ? rows.first['avg'] : null;
    return result != null ? (result as num).toDouble() : null;
  }

  /// Find maximum value of a column
  Future<dynamic> max(String column) async {
    final originalSelect = _selectColumns;
    _selectColumns = ['MAX($column) as max'];

    final query = _buildQuery();
    final parameters = _getParameters();
    final rows = await Database.query(query, parameters);

    _selectColumns = originalSelect; // Restore original select

    return rows.isNotEmpty ? rows.first['max'] : null;
  }

  /// Find minimum value of a column
  Future<dynamic> min(String column) async {
    final originalSelect = _selectColumns;
    _selectColumns = ['MIN($column) as min'];

    final query = _buildQuery();
    final parameters = _getParameters();
    final rows = await Database.query(query, parameters);

    _selectColumns = originalSelect; // Restore original select

    return rows.isNotEmpty ? rows.first['min'] : null;
  }

  // =============================================================================
  // NULL-SAFE AGGREGATE FUNCTIONS
  // =============================================================================

  /// Calculate sum with default value (equivalent to IFNULL(SUM(column), defaultValue))
  Future<double> sumWithDefault(
    String column, [
    double defaultValue = 0.0,
  ]) async {
    final result = await sum(column);
    return result ?? defaultValue;
  }

  /// Calculate average with default value (equivalent to IFNULL(AVG(column), defaultValue))
  Future<double> avgWithDefault(
    String column, [
    double defaultValue = 0.0,
  ]) async {
    final result = await avg(column);
    return result ?? defaultValue;
  }

  /// Count with default value (equivalent to IFNULL(COUNT(*), defaultValue))
  Future<int> countWithDefault([int defaultValue = 0]) async {
    final result = await count();
    return result;
  }

  /// Find max with default value (equivalent to IFNULL(MAX(column), defaultValue))
  Future<T2> maxWithDefault<T2>(String column, T2 defaultValue) async {
    final result = await max(column);
    return result ?? defaultValue;
  }

  /// Find min with default value (equivalent to IFNULL(MIN(column), defaultValue))
  Future<T2> minWithDefault<T2>(String column, T2 defaultValue) async {
    final result = await min(column);
    return result ?? defaultValue;
  }

  // =============================================================================
  // DATE FUNCTIONS
  // =============================================================================

  /// Filter by date part of datetime column (equivalent to DATE(column) = date)
  QueryBuilder<T> whereDate(String column, String operator, DateTime date) {
    final dateString = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    return whereRaw('DATE($column) $operator ?', [dateString]);
  }

  /// Filter by date range (equivalent to DATE(column) BETWEEN start AND end)
  QueryBuilder<T> whereDateBetween(
    String column,
    DateTime start,
    DateTime end,
  ) {
    final startString = start.toIso8601String().substring(0, 10);
    final endString = end.toIso8601String().substring(0, 10);
    return whereRaw('DATE($column) BETWEEN ? AND ?', [startString, endString]);
  }

  /// Filter by year (equivalent to strftime('%Y', column) = year)
  QueryBuilder<T> whereYear(String column, int year) {
    return whereRaw("strftime('%Y', $column) = ?", [year.toString()]);
  }

  /// Filter by month (equivalent to strftime('%m', column) = month)
  QueryBuilder<T> whereMonth(String column, int month) {
    final monthString = month.toString().padLeft(2, '0');
    return whereRaw("strftime('%m', $column) = ?", [monthString]);
  }

  /// Filter by day (equivalent to strftime('%d', column) = day)
  QueryBuilder<T> whereDay(String column, int day) {
    final dayString = day.toString().padLeft(2, '0');
    return whereRaw("strftime('%d', $column) = ?", [dayString]);
  }

  /// Group by date part (equivalent to GROUP BY DATE(column))
  QueryBuilder<T> groupByDate(String column) {
    return groupByRaw('DATE($column)');
  }

  /// Group by year (equivalent to GROUP BY strftime('%Y', column))
  QueryBuilder<T> groupByYear(String column) {
    return groupByRaw("strftime('%Y', $column)");
  }

  /// Group by month (equivalent to GROUP BY strftime('%Y-%m', column))
  QueryBuilder<T> groupByMonth(String column) {
    return groupByRaw("strftime('%Y-%m', $column)");
  }

  /// Select date part in results (equivalent to DATE(column) as alias)
  QueryBuilder<T> selectDate(String column, [String? alias]) {
    final aliasName = alias ?? '${column}_date';
    return selectRaw('DATE($column) as $aliasName');
  }

  /// Select year part in results
  QueryBuilder<T> selectYear(String column, [String? alias]) {
    final aliasName = alias ?? '${column}_year';
    return selectRaw("strftime('%Y', $column) as $aliasName");
  }

  /// Select month part in results
  QueryBuilder<T> selectMonth(String column, [String? alias]) {
    final aliasName = alias ?? '${column}_month';
    return selectRaw("strftime('%Y-%m', $column) as $aliasName");
  }

  // =============================================================================
  // RAW SQL SUPPORT METHODS
  // =============================================================================

  /// Add raw SQL to SELECT clause
  QueryBuilder<T> selectRaw(String expression, [List<dynamic>? bindings]) {
    _selectColumns ??= [];
    _selectColumns!.add(expression);

    // Store bindings for later use in query building
    if (bindings != null) {
      _rawBindings.addAll(bindings);
    }

    return this;
  }

  /// Add raw SQL WHERE condition
  QueryBuilder<T> whereRaw(String expression, [List<dynamic>? bindings]) {
    final condition = WhereRawCondition(expression, bindings ?? []);
    _whereConditions.add(condition);
    _whereBooleans.add('AND');
    return this;
  }

  /// Add raw SQL OR WHERE condition
  QueryBuilder<T> orWhereRaw(String expression, [List<dynamic>? bindings]) {
    final condition = WhereRawCondition(expression, bindings ?? []);
    _whereConditions.add(condition);
    _whereBooleans.add('OR');
    return this;
  }

  /// Add raw SQL to GROUP BY clause
  QueryBuilder<T> groupByRaw(String expression) {
    _groupByColumns ??= [];
    _groupByColumns!.add(expression);
    return this;
  }

  /// Add raw SQL to ORDER BY clause
  QueryBuilder<T> orderByRaw(String expression) {
    _orderClauses.add(OrderClause(expression, '', isRaw: true));
    return this;
  }

  /// Apply a scope (callback function)
  QueryBuilder<T> scope(QueryBuilder<T> Function(QueryBuilder<T>) callback) {
    return callback(this);
  }

  /// Apply conditional logic
  QueryBuilder<T> when(
    bool condition,
    QueryBuilder<T> Function(QueryBuilder<T>) callback,
  ) {
    if (condition) {
      return callback(this);
    }
    return this;
  }

  /// Add relationship(s) to eager load
  QueryBuilder<T> include(dynamic relationships) {
    if (relationships is String) {
      _includes.add(relationships);
    } else if (relationships is List<String>) {
      _includes.addAll(relationships);
    } else {
      throw ArgumentError('Relationships must be String or List<String>');
    }
    return this;
  }

  /// Alias for include() - loads relationships eagerly
  QueryBuilder<T> withRelations(dynamic relationships) {
    return include(relationships);
  }

  /// Paginate results
  Future<PaginationResult<T>> paginate({int page = 1, int perPage = 15}) async {
    if (page < 1) page = 1;
    if (perPage < 1) perPage = 15;

    // Get total count
    final totalQuery = QueryBuilder<T>(_modelConstructor);
    totalQuery._whereConditions.addAll(_whereConditions);
    final total = await totalQuery.count();

    // Calculate pagination values
    final lastPage = (total / perPage).ceil();
    final offset = (page - 1) * perPage;

    // Get paginated results
    final results = await this.offset(offset).limit(perPage).get();

    return PaginationResult<T>(
      data: results,
      currentPage: page,
      perPage: perPage,
      total: total,
      lastPage: lastPage,
      from: total > 0 ? offset + 1 : 0,
      to: total > 0 ? offset + results.length : 0,
    );
  }

  /// Get the SQL query string (for testing purposes)
  String toSql() => _buildQuery();

  /// Get query parameters (for testing purposes)
  List<dynamic> getBindings() => _getParameters();

  /// Load eager relationships for a list of models
  Future<void> _loadEagerRelationships(List<T> models) async {
    for (final relationshipName in _includes) {
      await _loadRelationship(models, relationshipName);
    }
  }

  /// Load a specific relationship for models using dynamic relationship registry
  Future<void> _loadRelationship(
    List<T> models,
    String relationshipName,
  ) async {
    if (models.isEmpty) return;

    // Get relationship from the first model's registry
    final firstModel = models.first;
    final relationship = firstModel.relationships.get(relationshipName);

    if (relationship == null) {
      print(
        'Warning: Unknown relationship "$relationshipName" for eager loading on ${firstModel.runtimeType}',
      );
      return;
    }

    // Load relationship data for all models at once (N+1 prevention)
    await _loadRelationshipBulk(models, relationshipName, relationship);
  }

  /// Load relationship data in bulk to prevent N+1 queries
  Future<void> _loadRelationshipBulk(
    List<T> models,
    String relationshipName,
    dynamic relationship,
  ) async {
    // Get primary key values from all models
    final primaryKeys = models
        .map((model) => model.getValue(model.primaryKey))
        .where((id) => id != null)
        .toList();

    if (primaryKeys.isEmpty) return;

    // Determine relationship type and load accordingly
    final relationshipTypeName = relationship.runtimeType.toString();

    if (relationshipTypeName.contains('HasOne')) {
      await _loadHasOneRelationshipBulk(models, relationshipName, relationship);
    } else if (relationshipTypeName.contains('HasMany')) {
      await _loadHasManyRelationshipBulk(
        models,
        relationshipName,
        relationship,
      );
    } else if (relationshipTypeName.contains('BelongsTo')) {
      await _loadBelongsToRelationshipBulk(
        models,
        relationshipName,
        relationship,
      );
    } else if (relationshipTypeName.contains('BelongsToMany')) {
      await _loadBelongsToManyRelationshipBulk(
        models,
        relationshipName,
        relationship,
      );
    } else {
      print(
        'Warning: Unsupported relationship type "$relationshipTypeName" for eager loading',
      );
    }
  }

  /// Load hasOne relationship in bulk
  Future<void> _loadHasOneRelationshipBulk(
    List<T> models,
    String relationshipName,
    dynamic relationship,
  ) async {
    final primaryKeys = models
        .map((model) => model.getValue(model.primaryKey))
        .where((id) => id != null)
        .toList();

    if (primaryKeys.isEmpty) return;

    final relatedInstance = relationship.relatedConstructor();
    final rows = await Database.query(
      'SELECT * FROM ${relatedInstance.table} WHERE ${relationship.foreignKey} IN (${primaryKeys.map((_) => '?').join(', ')})',
      primaryKeys,
    );

    // Group related records by foreign key value
    final relatedByForeignKey = <dynamic, Map<String, dynamic>>{};
    for (final row in rows) {
      final foreignKeyValue = row[relationship.foreignKey];
      relatedByForeignKey[foreignKeyValue] = row;
    }

    // Assign related records to models
    for (final model in models) {
      final primaryKeyValue = model.getValue(model.primaryKey);
      final relatedData = relatedByForeignKey[primaryKeyValue];

      if (relatedData != null) {
        final relatedModel = relationship.relatedConstructor();
        relatedModel.fromMap(relatedData);
        model.setValue('_eager_$relationshipName', relatedModel);
      }
    }
  }

  /// Load hasMany relationship in bulk
  Future<void> _loadHasManyRelationshipBulk(
    List<T> models,
    String relationshipName,
    dynamic relationship,
  ) async {
    final primaryKeys = models
        .map((model) => model.getValue(model.primaryKey))
        .where((id) => id != null)
        .toList();

    if (primaryKeys.isEmpty) return;

    final relatedInstance = relationship.relatedConstructor();
    final rows = await Database.query(
      'SELECT * FROM ${relatedInstance.table} WHERE ${relationship.foreignKey} IN (${primaryKeys.map((_) => '?').join(', ')})',
      primaryKeys,
    );

    // Group related records by foreign key value
    final relatedByForeignKey = <dynamic, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final foreignKeyValue = row[relationship.foreignKey];
      relatedByForeignKey.putIfAbsent(foreignKeyValue, () => []).add(row);
    }

    // Assign related records to models
    for (final model in models) {
      final primaryKeyValue = model.getValue(model.primaryKey);
      final relatedDataList = relatedByForeignKey[primaryKeyValue] ?? [];

      final relatedModels = relatedDataList.map((data) {
        final relatedModel = relationship.relatedConstructor();
        relatedModel.fromMap(data);
        return relatedModel;
      }).toList();

      model.setValue('_eager_$relationshipName', relatedModels);
    }
  }

  /// Load belongsTo relationship in bulk
  Future<void> _loadBelongsToRelationshipBulk(
    List<T> models,
    String relationshipName,
    dynamic relationship,
  ) async {
    final foreignKeys = models
        .map((model) => model.getValue(relationship.foreignKey))
        .where((id) => id != null)
        .toSet()
        .toList();

    if (foreignKeys.isEmpty) return;

    final relatedInstance = relationship.relatedConstructor();
    final rows = await Database.query(
      'SELECT * FROM ${relatedInstance.table} WHERE ${relationship.localKey} IN (${foreignKeys.map((_) => '?').join(', ')})',
      foreignKeys,
    );

    // Group related records by primary key value
    final relatedByPrimaryKey = <dynamic, Map<String, dynamic>>{};
    for (final row in rows) {
      final primaryKeyValue = row[relationship.localKey];
      relatedByPrimaryKey[primaryKeyValue] = row;
    }

    // Assign related records to models
    for (final model in models) {
      final foreignKeyValue = model.getValue(relationship.foreignKey);
      final relatedData = relatedByPrimaryKey[foreignKeyValue];

      if (relatedData != null) {
        final relatedModel = relationship.relatedConstructor();
        relatedModel.fromMap(relatedData);
        model.setValue('_eager_$relationshipName', relatedModel);
      }
    }
  }

  /// Load belongsToMany relationship in bulk
  Future<void> _loadBelongsToManyRelationshipBulk(
    List<T> models,
    String relationshipName,
    dynamic relationship,
  ) async {
    final primaryKeys = models
        .map((model) => model.getValue(model.primaryKey))
        .where((id) => id != null)
        .toList();

    if (primaryKeys.isEmpty) return;

    final relatedInstance = relationship.relatedConstructor();
    final rows = await Database.query('''
      SELECT ${relatedInstance.table}.*, ${relationship.pivotTable}.${relationship.parentPivotKey}
      FROM ${relatedInstance.table}
      INNER JOIN ${relationship.pivotTable} ON ${relatedInstance.table}.${relationship.foreignKey} = ${relationship.pivotTable}.${relationship.relatedPivotKey}
      WHERE ${relationship.pivotTable}.${relationship.parentPivotKey} IN (${primaryKeys.map((_) => '?').join(', ')})
      ''', primaryKeys);

    // Group related records by parent key
    final relatedByParentKey = <dynamic, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final parentKeyValue = row[relationship.parentPivotKey];
      relatedByParentKey.putIfAbsent(parentKeyValue, () => []).add(row);
    }

    // Assign related records to models
    for (final model in models) {
      final primaryKeyValue = model.getValue(model.primaryKey);
      final relatedDataList = relatedByParentKey[primaryKeyValue] ?? [];

      final relatedModels = relatedDataList.map((data) {
        final relatedModel = relationship.relatedConstructor();
        // Remove pivot column before mapping
        final cleanData = Map<String, dynamic>.from(data);
        cleanData.remove(relationship.parentPivotKey);
        relatedModel.fromMap(cleanData);
        return relatedModel;
      }).toList();

      model.setValue('_eager_$relationshipName', relatedModels);
    }
  }
}

/// Represents a WHERE condition
abstract class WhereCondition {
  String toSql();
  List<dynamic> getParameters();
}

/// Basic WHERE condition (column operator value)
class BasicWhereCondition extends WhereCondition {
  final String column;
  final String operator;
  final dynamic value;

  BasicWhereCondition(this.column, this.operator, this.value);

  @override
  String toSql() {
    return '$column $operator ?';
  }

  @override
  List<dynamic> getParameters() {
    return [processQueryParameter(value)];
  }
}

/// WHERE IN condition
class WhereInCondition extends WhereCondition {
  final String column;
  final List<dynamic> values;

  WhereInCondition(this.column, this.values);

  @override
  String toSql() {
    final placeholders = values.map((_) => '?').join(', ');
    return '$column IN ($placeholders)';
  }

  @override
  List<dynamic> getParameters() {
    return values.map(processQueryParameter).toList();
  }
}

/// WHERE NOT IN condition
class WhereNotInCondition extends WhereCondition {
  final String column;
  final List<dynamic> values;

  WhereNotInCondition(this.column, this.values);

  @override
  String toSql() {
    final placeholders = values.map((_) => '?').join(', ');
    return '$column NOT IN ($placeholders)';
  }

  @override
  List<dynamic> getParameters() {
    return values.map(processQueryParameter).toList();
  }
}

/// WHERE NULL/NOT NULL condition
class WhereNullCondition extends WhereCondition {
  final String column;
  final bool isNull;

  WhereNullCondition(this.column, this.isNull);

  @override
  String toSql() {
    return isNull ? '$column IS NULL' : '$column IS NOT NULL';
  }

  @override
  List<dynamic> getParameters() {
    return [];
  }
}

/// WHERE BETWEEN condition
class WhereBetweenCondition extends WhereCondition {
  final String column;
  final dynamic min;
  final dynamic max;

  WhereBetweenCondition(this.column, this.min, this.max);

  @override
  String toSql() {
    return '$column BETWEEN ? AND ?';
  }

  @override
  List<dynamic> getParameters() {
    return [processQueryParameter(min), processQueryParameter(max)];
  }
}

/// WHERE RAW SQL condition
class WhereRawCondition extends WhereCondition {
  final String expression;
  final List<dynamic> bindings;

  WhereRawCondition(this.expression, this.bindings);

  @override
  String toSql() {
    return expression;
  }

  @override
  List<dynamic> getParameters() {
    return bindings.map(processQueryParameter).toList();
  }
}

/// ORDER BY clause
class OrderClause {
  final String column;
  final String direction;
  final bool isRaw;

  OrderClause(this.column, this.direction, {this.isRaw = false});

  String toSql() {
    return isRaw ? column : '$column $direction';
  }
}

/// WHERE EXISTS condition for relationships
class WhereExistsCondition<TRelated extends Model<TRelated>>
    extends WhereCondition {
  final String relationshipName;
  final dynamic relationship;
  final QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback;
  final bool exists;

  WhereExistsCondition(
    this.relationshipName,
    this.relationship,
    this.callback, {
    required this.exists,
  });

  @override
  String toSql() {
    final relatedInstance = relationship.relatedConstructor();
    final relatedTable = relatedInstance.table;
    final parentTable = relationship.parent.table;

    // Build the EXISTS subquery based on relationship type
    String subquery;
    final relationshipTypeName = relationship.runtimeType.toString();

    if (relationshipTypeName.contains('HasOne') ||
        relationshipTypeName.contains('HasMany')) {
      // Parent has related records
      subquery =
          '''
        SELECT 1 FROM $relatedTable 
        WHERE $relatedTable.${relationship.foreignKey} = $parentTable.${relationship.localKey}
      ''';
    } else if (relationshipTypeName.contains('BelongsTo')) {
      // Parent belongs to related record
      subquery =
          '''
        SELECT 1 FROM $relatedTable 
        WHERE $relatedTable.${relationship.localKey} = $parentTable.${relationship.foreignKey}
      ''';
    } else if (relationshipTypeName.contains('BelongsToMany')) {
      // Many-to-many relationship
      final pivotTable = relationship.pivotTable;
      subquery =
          '''
        SELECT 1 FROM $relatedTable 
        INNER JOIN $pivotTable ON $relatedTable.${relationship.foreignKey} = $pivotTable.${relationship.relatedPivotKey}
        WHERE $pivotTable.${relationship.parentPivotKey} = $parentTable.${relationship.localKey}
      ''';
    } else {
      throw UnsupportedError('Unsupported relationship type for EXISTS query');
    }

    // Add callback conditions if provided
    if (callback != null) {
      final tempQueryBuilder = QueryBuilder<TRelated>(
        relationship.relatedConstructor,
      );
      final modifiedQueryBuilder = callback!(tempQueryBuilder);

      if (modifiedQueryBuilder._whereConditions.isNotEmpty) {
        final additionalWhere = modifiedQueryBuilder._buildWhereClause();
        subquery += ' AND ($additionalWhere)';
      }
    }

    return exists ? 'EXISTS ($subquery)' : 'NOT EXISTS ($subquery)';
  }

  @override
  List<dynamic> getParameters() {
    final parameters = <dynamic>[];

    // Add parameters from callback conditions if provided
    if (callback != null) {
      final tempQueryBuilder = QueryBuilder<TRelated>(
        relationship.relatedConstructor,
      );
      final modifiedQueryBuilder = callback!(tempQueryBuilder);
      parameters.addAll(modifiedQueryBuilder._getParameters());
    }

    return parameters;
  }
}

/// WHERE condition for relationship count
class WhereRelationshipCountCondition<TRelated extends Model<TRelated>>
    extends WhereCondition {
  final String relationshipName;
  final dynamic relationship;
  final String operator;
  final int count;
  final QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback;

  WhereRelationshipCountCondition(
    this.relationshipName,
    this.relationship,
    this.operator,
    this.count,
    this.callback,
  );

  @override
  String toSql() {
    final relatedInstance = relationship.relatedConstructor();
    final relatedTable = relatedInstance.table;
    final parentTable = relationship.parent.table;

    // Build the COUNT subquery based on relationship type
    String subquery;
    final relationshipTypeName = relationship.runtimeType.toString();

    if (relationshipTypeName.contains('HasOne') ||
        relationshipTypeName.contains('HasMany')) {
      // Parent has related records
      subquery =
          '''
        SELECT COUNT(*) FROM $relatedTable 
        WHERE $relatedTable.${relationship.foreignKey} = $parentTable.${relationship.localKey}
      ''';
    } else if (relationshipTypeName.contains('BelongsTo')) {
      // Parent belongs to related record (count should be 0 or 1)
      subquery =
          '''
        SELECT COUNT(*) FROM $relatedTable 
        WHERE $relatedTable.${relationship.localKey} = $parentTable.${relationship.foreignKey}
      ''';
    } else if (relationshipTypeName.contains('BelongsToMany')) {
      // Many-to-many relationship
      final pivotTable = relationship.pivotTable;
      subquery =
          '''
        SELECT COUNT(*) FROM $relatedTable 
        INNER JOIN $pivotTable ON $relatedTable.${relationship.foreignKey} = $pivotTable.${relationship.relatedPivotKey}
        WHERE $pivotTable.${relationship.parentPivotKey} = $parentTable.${relationship.localKey}
      ''';
    } else {
      throw UnsupportedError('Unsupported relationship type for COUNT query');
    }

    // Add callback conditions if provided
    if (callback != null) {
      final tempQueryBuilder = QueryBuilder<TRelated>(
        relationship.relatedConstructor,
      );
      final modifiedQueryBuilder = callback!(tempQueryBuilder);

      if (modifiedQueryBuilder._whereConditions.isNotEmpty) {
        final additionalWhere = modifiedQueryBuilder._buildWhereClause();
        subquery += ' AND ($additionalWhere)';
      }
    }

    return '($subquery) $operator ?';
  }

  @override
  List<dynamic> getParameters() {
    final parameters = <dynamic>[];

    // Add parameters from callback conditions if provided
    if (callback != null) {
      final tempQueryBuilder = QueryBuilder<TRelated>(
        relationship.relatedConstructor,
      );
      final modifiedQueryBuilder = callback!(tempQueryBuilder);
      parameters.addAll(modifiedQueryBuilder._getParameters());
    }

    // Add the count parameter
    parameters.add(count);

    return parameters;
  }
}

/// Pagination result containing data and pagination metadata
class PaginationResult<T> {
  /// The paginated data
  final List<T> data;

  /// Current page number
  final int currentPage;

  /// Number of items per page
  final int perPage;

  /// Total number of items
  final int total;

  /// Last page number
  final int lastPage;

  /// Starting item number for current page
  final int from;

  /// Ending item number for current page
  final int to;

  const PaginationResult({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  /// Whether there are more pages after current page
  bool get hasMorePages => currentPage < lastPage;

  /// Whether there are pages before current page
  bool get hasPreviousPages => currentPage > 1;

  /// Get next page number (null if no next page)
  int? get nextPage => hasMorePages ? currentPage + 1 : null;

  /// Get previous page number (null if no previous page)
  int? get previousPage => hasPreviousPages ? currentPage - 1 : null;

  /// Whether the pagination result is empty
  bool get isEmpty => data.isEmpty;

  /// Whether the pagination result is not empty
  bool get isNotEmpty => data.isNotEmpty;

  /// Number of items in current page
  int get count => data.length;
}
