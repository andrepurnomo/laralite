# Laralite API Reference

A comprehensive reference for all available APIs in Laralite ORM.

## Laralite Class

### initialize()
```dart
static Future<void> initialize({
  String? databasePath,
  String databaseName = 'laralite.db',
  String? encryptionKey,
})
```

Initialize the Laralite ORM with database configuration.

**Parameters:**
- `databasePath` (optional): Custom path for database file. If not provided, uses current directory.
- `databaseName`: Name of the database file (default: 'laralite.db')
- `encryptionKey` (optional): SQLCipher encryption key for database encryption

**Examples:**
```dart
// Basic initialization
await Laralite.initialize(databaseName: 'myapp.db');

// With encryption
await Laralite.initialize(
  databaseName: 'secure.db',
  encryptionKey: 'my-secret-key',
);

// Custom path with encryption
await Laralite.initialize(
  databasePath: '/path/to/custom/location/app.db',
  encryptionKey: Platform.environment['DB_KEY'],
);
```

**Security Notes:**
- Never hardcode encryption keys in source code
- Use environment variables or secure storage for keys
- Encryption uses SQLCipher with automatic platform configuration
- Database operates normally without encryption if key not provided

## Model Class

### Static Methods

#### find()
```dart
static Future<TModel?> find<TModel extends Model<TModel>>(dynamic id, TModel Function() constructor)
```
Find a model by primary key. Returns null if not found.

#### findOrFail()
```dart
static Future<TModel> findOrFail<TModel extends Model<TModel>>(dynamic id, TModel Function() constructor)
```
Find a model by primary key or throw exception if not found.

#### findMany()
```dart
static Future<List<TModel>> findMany<TModel extends Model<TModel>>(List<dynamic> ids, TModel Function() constructor)
```
Find multiple models by their primary keys.

#### all()
```dart
static Future<List<TModel>> all<TModel extends Model<TModel>>(TModel Function() constructor)
```
Get all models from table (respects soft delete scopes).

#### create()
```dart
static Future<TModel> create<TModel extends Model<TModel>>(TModel model)
```
Create a new model and save it.

#### createMany()
```dart
static Future<List<TModel>> createMany<TModel extends Model<TModel>>(TModel Function() constructor, List<Map<String, dynamic>> records)
```
Create multiple model instances in bulk within a transaction.

#### withTransaction()
```dart
static Future<T> withTransaction<T>(Future<T> Function() callback)
```
Execute callback within a database transaction.

## QueryBuilder Class

### Basic Query Methods

#### select()
```dart
QueryBuilder<T> select(List<String> columns)
```
Specify which columns to select.

#### where()
```dart
QueryBuilder<T> where(String column, dynamic value)
QueryBuilder<T> where(String column, String operator, dynamic value)
```
Add WHERE condition to query. DateTime objects are automatically converted to ISO 8601 string format.

**Example:**
```dart
// Automatic DateTime conversion
final date = DateTime(2024, 1, 15);
query.where('created_at', '>', date);

// Also works with other types
query.where('name', 'John');
query.where('price', '>=', 100.0);
```

#### orWhere()
```dart
QueryBuilder<T> orWhere(String column, dynamic value)
QueryBuilder<T> orWhere(String column, String operator, dynamic value)
```
Add OR WHERE condition to query.

### Advanced WHERE Methods

#### whereIn()
```dart
QueryBuilder<T> whereIn(String column, List<dynamic> values)
```
Add WHERE IN condition. Supports automatic type conversion for all values in the list.

**Example:**
```dart
// Mixed types with automatic conversion
query.whereIn('status', [Status.active, Status.pending]);
query.whereIn('created_at', [date1, date2, date3]);
query.whereIn('is_enabled', [true, false]);
```

#### whereNotIn()
```dart
QueryBuilder<T> whereNotIn(String column, List<dynamic> values)
```
Add WHERE NOT IN condition. Supports automatic type conversion for all values in the list.

#### whereBetween()
```dart
QueryBuilder<T> whereBetween(String column, dynamic min, dynamic max)
```
Add WHERE BETWEEN condition. DateTime objects are automatically converted to ISO 8601 string format.

**Example:**
```dart
// Automatic DateTime conversion
final startDate = DateTime(2024, 1, 1);
final endDate = DateTime(2024, 1, 31);
query.whereBetween('created_at', startDate, endDate);

// Also works with other types
query.whereBetween('price', 100.0, 500.0);
```

#### whereNull()
```dart
QueryBuilder<T> whereNull(String column)
```
Add WHERE IS NULL condition.

#### whereNotNull()
```dart
QueryBuilder<T> whereNotNull(String column)
```
Add WHERE IS NOT NULL condition.

### OR Variants

#### orWhereIn()
```dart
QueryBuilder<T> orWhereIn(String column, List<dynamic> values)
```
Add OR WHERE IN condition.

#### orWhereNotIn()
```dart
QueryBuilder<T> orWhereNotIn(String column, List<dynamic> values)
```
Add OR WHERE NOT IN condition.

#### orWhereBetween()
```dart
QueryBuilder<T> orWhereBetween(String column, dynamic min, dynamic max)
```
Add OR WHERE BETWEEN condition.

#### orWhereNull()
```dart
QueryBuilder<T> orWhereNull(String column)
```
Add OR WHERE IS NULL condition.

#### orWhereNotNull()
```dart
QueryBuilder<T> orWhereNotNull(String column)
```
Add OR WHERE IS NOT NULL condition.

### Relationship Methods

#### whereHas()
```dart
QueryBuilder<T> whereHas(String relation, QueryBuilder Function(QueryBuilder) callback)
```
Add WHERE EXISTS condition for relationship.

#### whereDoesntHave()
```dart
QueryBuilder<T> whereDoesntHave(String relation)
```
Add WHERE NOT EXISTS condition for relationship.

#### orWhereHas()
```dart
QueryBuilder<T> orWhereHas(String relation, QueryBuilder Function(QueryBuilder) callback)
```
Add OR WHERE EXISTS condition for relationship.

### Ordering Methods

#### orderBy()
```dart
QueryBuilder<T> orderBy(String column, [String direction = 'ASC'])
```
Add ORDER BY clause.

#### orderByAsc()
```dart
QueryBuilder<T> orderByAsc(String column)
```
Add ORDER BY ASC clause.

#### orderByDesc()
```dart
QueryBuilder<T> orderByDesc(String column)
```
Add ORDER BY DESC clause.

### Limit and Offset

#### limit()
```dart
QueryBuilder<T> limit(int count)
```
Add LIMIT clause.

#### offset()
```dart
QueryBuilder<T> offset(int count)
```
Add OFFSET clause.

#### take()
```dart
QueryBuilder<T> take(int count)
```
Alias for limit().

#### skip()
```dart
QueryBuilder<T> skip(int count)
```
Alias for offset().

### Execution Methods

#### get()
```dart
Future<List<T>> get()
```
Execute query and return all results.

#### first()
```dart
Future<T?> first()
```
Execute query and return first result or null.

#### count()
```dart
Future<int> count()
```
Return count of matching records.

#### exists()
```dart
Future<bool> exists()
```
Check if any records match the query.

### Aggregation Methods

#### sum()
```dart
Future<double?> sum(String column)
```
Calculate sum of column values.

#### avg()
```dart
Future<double?> avg(String column)
```
Calculate average of column values.

#### max()
```dart
Future<dynamic> max(String column)
```
Find maximum value in column.

#### min()
```dart
Future<dynamic> min(String column)
```
Find minimum value in column.

### Pagination

#### paginate()
```dart
Future<PaginationResult<T>> paginate({int page = 1, int perPage = 15})
```
Paginate query results.

#### PaginationResult Properties
```dart
List<T> data              // Current page data
int currentPage           // Current page number
int perPage               // Items per page
int total                 // Total items
int lastPage              // Last page number
int from                  // First item number (required)
int to                    // Last item number (required)
bool hasMorePages         // Has next page
bool hasPreviousPages     // Has previous page
int? nextPage             // Next page number
int? previousPage         // Previous page number
bool isEmpty              // Whether result is empty
bool isNotEmpty           // Whether result is not empty
int count                 // Number of items in current page
```

### Soft Deletes

#### withTrashed()
```dart
QueryBuilder<T> withTrashed()
```
Include soft deleted records in query.

#### onlyTrashed()
```dart
QueryBuilder<T> onlyTrashed()
```
Only return soft deleted records.

#### restore()
```dart
Future<int> restore()
```
Restore soft deleted records matching query.

#### forceDelete()
```dart
Future<int> forceDelete()
```
Permanently delete records matching query.

### Eager Loading

#### include()
```dart
QueryBuilder<T> include(dynamic relationships)
```
Include relationships in query results. Accepts String or List<String>.

#### withRelations()
```dart
QueryBuilder<T> withRelations(dynamic relationships)
```
Alias for include() - loads relationships eagerly.

### Advanced Features

#### scope()
```dart
QueryBuilder<T> scope(QueryBuilder<T> Function(QueryBuilder<T>) callback)
```
Apply custom scope callback to query.

#### when()
```dart
QueryBuilder<T> when(bool condition, QueryBuilder<T> Function(QueryBuilder<T>) callback)
```
Conditionally apply query modifications based on boolean condition.

## Field Types

All field types support common parameters: `required`, `defaultValue`, `unique`, `nullable`, `columnName`, `validationRules`.

### Numeric Fields
- `AutoIncrementField()` - Auto-incrementing primary key (INTEGER PRIMARY KEY AUTOINCREMENT)
- `IntField({int? min, int? max})` - Integer field with optional min/max validation
- `DoubleField({double? min, double? max, int? decimalPlaces})` - Double precision field
- `BoolField()` - Boolean field (stored as INTEGER 0/1 in SQLite)

### Text Fields
- `StringField({int? maxLength, int? minLength, RegExp? pattern})` - Variable length string
- `TextField({int? maxLength})` - Large text field (TEXT column type)
- `EmailField({int? maxLength})` - String field with built-in email validation
- `UrlField({int? maxLength})` - String field with built-in URL validation
- `UuidField()` - String field with UUID validation (36 chars, unique by default)
- `BlobField({int? maxSize})` - Binary large object storage

### Date/Time Fields
- `DateTimeField({bool dateOnly, bool timeOnly})` - Full date and time (stored as ISO 8601 TEXT)
- `DateField()` - Date only (extends DateTimeField with dateOnly: true)
- `TimeField()` - Time only (extends DateTimeField with timeOnly: true)  
- `TimestampField({bool autoCreate, bool autoUpdate})` - Auto-managed timestamps

### Special Fields
- `JsonField<T>({String Function(T)? customSerializer, T Function(String)? customDeserializer})` - JSON serialization for complex types
- `EnumField<T extends Enum>({required List<T> enumValues})` - Enum type with validation
- `ForeignKeyField({required String referencedTable, String referencedColumn, ForeignKeyAction onUpdate, ForeignKeyAction onDelete})` - Foreign key with referential integrity

## Validation

### ValidationResult
```dart
class ValidationResult {
  bool isValid
  List<String> errors
}
```

### Built-in Validation Rules
- `RequiredRule<T>()` - Required field validation
- `MinLengthRule(int length)` - Minimum string length
- `MaxLengthRule(int length)` - Maximum string length
- `MinValueRule<T extends num>(T value)` - Minimum numeric value
- `MaxValueRule<T extends num>(T value)` - Maximum numeric value
- `CustomRule<T>(bool Function(T?) validator, {required String customMessage})` - Custom validation function

## Relationships

### HasOne
```dart
HasOne<T> hasOne<T>(T Function() constructor, {String? foreignKey, String? localKey})
```

### HasMany
```dart
HasMany<T> hasMany<T>(T Function() constructor, {String? foreignKey, String? localKey})
```

### BelongsTo
```dart
BelongsTo<T> belongsTo<T>(T Function() constructor, {String? foreignKey, String? ownerKey})
```

### BelongsToMany
```dart
BelongsToMany<T> belongsToMany<T>(T Function() constructor, {String? pivotTable, String? foreignKey, String? localKey, String? parentPivotKey, String? relatedPivotKey})
```

## Schema Builder

### Table Creation
```dart
Schema.create(String tableName, void Function(Blueprint) callback)
```

### Blueprint Methods
- `id()` - Primary key column
- `string(String name)` - VARCHAR column
- `text(String name)` - TEXT column
- `integer(String name)` - INTEGER column
- `boolean(String name)` - BOOLEAN column
- `dateTime(String name)` - DATETIME column
- `timestamps()` - created_at and updated_at columns
- `foreignId(String name)` - Foreign key column
- `unique()` - Add unique constraint
- `nullable()` - Make column nullable
- `defaultValue(dynamic value)` - Set default value

## Transaction Management

### Database Transactions
```dart
Future<T> Laralite.withTransaction<T>(Future<T> Function() callback)
```

### Model Transactions
```dart
Future<T> Model.withTransaction<T>(Future<T> Function() callback)
```

## Global Methods

### Database Connection
```dart
static Future<void> initialize({String? databasePath, String databaseName = 'laralite.db'})
static Future<void> close()
static void reset()
```

### Raw Queries
```dart
static Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? parameters])
static Future<int> execute(String sql, [List<dynamic>? parameters])
```

### Transaction Methods
```dart
static Future<void> transaction(List<String> statements)
static Future<T> withTransaction<T>(Future<T> Function() callback)
```

### Utility Methods
```dart
static Future<bool> tableExists(String tableName)
static Future<List<Map<String, dynamic>>> getTableInfo(String tableName)
static String? get databasePath
static bool get isInitialized
```
