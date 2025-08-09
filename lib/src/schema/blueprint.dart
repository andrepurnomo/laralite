/// Blueprint for defining table structure in a fluent way.
/// Supports SQLite-specific column types and constraints.
class Blueprint {
  final String tableName;
  final bool isCreating;
  final List<ColumnDefinition> _columns = [];
  final List<String> _indexes = [];
  final List<String> _foreignKeys = [];
  final List<String> additionalStatements = [];

  Blueprint(this.tableName, {required this.isCreating});

  /// Add an auto-incrementing primary key column
  ColumnDefinition id([String name = 'id']) {
    return _addColumn(name, 'INTEGER')
      ..primaryKey()
      ..autoIncrement();
  }

  /// Add a string column
  ColumnDefinition string(String name, [int? length]) {
    final column = _addColumn(name, 'TEXT');
    if (length != null) {
      column._constraints.add('CHECK (LENGTH($name) <= $length)');
    }
    return column;
  }

  /// Add a text column (unlimited length)
  ColumnDefinition text(String name) {
    return _addColumn(name, 'TEXT');
  }

  /// Add an integer column
  ColumnDefinition integer(String name) {
    return _addColumn(name, 'INTEGER');
  }

  /// Add a big integer column
  ColumnDefinition bigInteger(String name) {
    return _addColumn(name, 'INTEGER');
  }

  /// Add a real/float column
  ColumnDefinition real(String name) {
    return _addColumn(name, 'REAL');
  }

  /// Add a double column
  ColumnDefinition double(String name) {
    return _addColumn(name, 'REAL');
  }

  /// Add a decimal column (stored as TEXT in SQLite)
  ColumnDefinition decimal(String name, [int precision = 8, int scale = 2]) {
    return _addColumn(name, 'TEXT');
  }

  /// Add a boolean column
  ColumnDefinition boolean(String name) {
    return _addColumn(name, 'BOOLEAN');
  }

  /// Add a date column (stored as TEXT in ISO format)
  ColumnDefinition date(String name) {
    return _addColumn(name, 'TEXT');
  }

  /// Add a datetime column (stored as TEXT in ISO format)
  ColumnDefinition dateTime(String name) {
    return _addColumn(name, 'TEXT');
  }

  /// Add a timestamp column (stored as TEXT in ISO format)
  ColumnDefinition timestamp(String name) {
    return _addColumn(name, 'TEXT');
  }

  /// Add a time column (stored as TEXT)
  ColumnDefinition time(String name) {
    return _addColumn(name, 'TEXT');
  }

  /// Add a JSON column (stored as TEXT)
  ColumnDefinition json(String name) {
    return _addColumn(name, 'TEXT');
  }

  /// Add a BLOB column for binary data
  ColumnDefinition blob(String name) {
    return _addColumn(name, 'BLOB');
  }

  /// Add standard created_at and updated_at timestamp columns
  void timestamps([bool nullable = true]) {
    final createdAt = timestamp('created_at');
    final updatedAt = timestamp('updated_at');

    if (!nullable) {
      createdAt.notNull();
      updatedAt.notNull();
    } else {
      createdAt.nullable();
      updatedAt.nullable();
    }
  }

  /// Add deleted_at timestamp column for soft deletes
  ColumnDefinition softDeletes([String name = 'deleted_at']) {
    return timestamp(name).nullable();
  }

  /// Add a foreign key column
  ColumnDefinition foreignId(String name) {
    return integer(name);
  }

  /// Create an index
  void index(dynamic columns, [String? name]) {
    final columnList = columns is List ? columns : [columns];
    final indexName = name ?? '${tableName}_${columnList.join('_')}_index';
    final columnNames = columnList.join(', ');

    _indexes.add('CREATE INDEX $indexName ON $tableName ($columnNames)');
  }

  /// Create a unique index
  void unique(dynamic columns, [String? name]) {
    final columnList = columns is List ? columns : [columns];
    final indexName = name ?? '${tableName}_${columnList.join('_')}_unique';
    final columnNames = columnList.join(', ');

    _indexes.add('CREATE UNIQUE INDEX $indexName ON $tableName ($columnNames)');
  }

  /// Add a foreign key constraint
  void foreign(String column, String references, [String? on]) {
    final referencedTable = on ?? references.replaceAll('_id', '');
    final referencedColumn = references.contains('.')
        ? references.split('.')[1]
        : 'id';

    if (references.contains('.')) {
      final parts = references.split('.');
      _foreignKeys.add(
        'FOREIGN KEY ($column) REFERENCES ${parts[0]} (${parts[1]})',
      );
    } else {
      _foreignKeys.add(
        'FOREIGN KEY ($column) REFERENCES $referencedTable ($referencedColumn)',
      );
    }
  }

  /// Add a raw column definition
  ColumnDefinition addColumn(String type, String name) {
    return _addColumn(name, type);
  }

  ColumnDefinition _addColumn(String name, String type) {
    final column = ColumnDefinition(name, type);
    _columns.add(column);
    return column;
  }

  /// Generate CREATE TABLE SQL
  String toSql() {
    if (!isCreating) {
      throw StateError('toSql() can only be called for table creation');
    }

    final columnDefs = _columns.map((col) => col.toSql()).toList();

    // Add foreign key constraints
    columnDefs.addAll(_foreignKeys);

    final sql =
        '''
CREATE TABLE $tableName (
  ${columnDefs.join(',\n  ')}
)''';

    // Add indexes to additional statements
    additionalStatements.addAll(_indexes);

    return sql;
  }

  /// Generate CREATE TABLE IF NOT EXISTS SQL
  String toSqlIfNotExists() {
    if (!isCreating) {
      throw StateError(
        'toSqlIfNotExists() can only be called for table creation',
      );
    }

    final columnDefs = _columns.map((col) => col.toSql()).toList();

    // Add foreign key constraints
    columnDefs.addAll(_foreignKeys);

    final sql =
        '''
CREATE TABLE IF NOT EXISTS $tableName (
  ${columnDefs.join(',\n  ')}
)''';

    // Add indexes to additional statements
    additionalStatements.addAll(_indexes);

    return sql;
  }

  /// Generate ALTER TABLE statements for SQLite
  List<String> toAlterStatements() {
    final statements = <String>[];

    // SQLite has limited ALTER TABLE support
    // We can only add columns, not modify existing ones
    for (final column in _columns) {
      statements.add('ALTER TABLE $tableName ADD COLUMN ${column.toSql()}');
    }

    // Add indexes
    statements.addAll(_indexes);

    return statements;
  }
}

/// Represents a column definition with fluent methods for adding constraints
class ColumnDefinition {
  final String name;
  final String type;
  final List<String> _constraints = [];
  bool _isPrimary = false;
  bool _isAutoIncrement = false;
  bool _isNullable = true;
  String? _defaultValue;

  ColumnDefinition(this.name, this.type);

  /// Make column nullable
  ColumnDefinition nullable() {
    _isNullable = true;
    return this;
  }

  /// Make column not null
  ColumnDefinition notNull() {
    _isNullable = false;
    return this;
  }

  /// Set default value
  ColumnDefinition defaultValue(dynamic value) {
    if (value is String) {
      _defaultValue = "'$value'";
    } else if (value is bool) {
      _defaultValue = value ? '1' : '0';
    } else {
      _defaultValue = value.toString();
    }
    return this;
  }

  /// Make column primary key
  ColumnDefinition primaryKey() {
    _isPrimary = true;
    _isNullable = false;
    return this;
  }

  /// Make column auto increment (requires primary key)
  ColumnDefinition autoIncrement() {
    _isAutoIncrement = true;
    _isPrimary = true;
    _isNullable = false;
    return this;
  }

  /// Add unique constraint
  ColumnDefinition unique() {
    _constraints.add('UNIQUE');
    return this;
  }

  /// Add custom constraint
  ColumnDefinition constraint(String constraint) {
    _constraints.add(constraint);
    return this;
  }

  /// Add check constraint
  ColumnDefinition check(String condition) {
    _constraints.add('CHECK ($condition)');
    return this;
  }

  /// Generate column SQL
  String toSql() {
    final parts = <String>[name, type];

    if (_isPrimary) {
      parts.add('PRIMARY KEY');
    }

    if (_isAutoIncrement) {
      parts.add('AUTOINCREMENT');
    }

    if (!_isNullable && !_isPrimary) {
      parts.add('NOT NULL');
    }

    if (_defaultValue != null) {
      parts.add('DEFAULT $_defaultValue');
    }

    parts.addAll(_constraints);

    return parts.join(' ');
  }
}
