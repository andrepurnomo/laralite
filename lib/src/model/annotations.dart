/// Annotation to mark a class for laralite code generation
///
/// Classes marked with this annotation will have property getters/setters
/// and field references automatically generated.
class Laralite {
  /// Table name override (optional)
  final String? tableName;

  /// Whether to generate timestamps (created_at, updated_at)
  final bool timestamps;

  /// Whether to generate soft delete support (deleted_at)
  final bool softDeletes;

  const Laralite({
    this.tableName,
    this.timestamps = false,
    this.softDeletes = false,
  });
}

/// Shorthand for @Laralite()
const laralite = Laralite();

/// Annotation for field configuration
class FieldConfig {
  /// Column name override
  final String? columnName;

  /// Whether this field should be included in toMap() output
  final bool serializable;

  /// Whether this field should be mass assignable
  final bool fillable;

  /// Whether this field should be hidden from toMap() output
  final bool hidden;

  const FieldConfig({
    this.columnName,
    this.serializable = true,
    this.fillable = true,
    this.hidden = false,
  });
}

/// Annotation to mark a field as the primary key

class PrimaryKey {
  /// Whether this is an auto-incrementing primary key
  final bool autoIncrement;

  const PrimaryKey({this.autoIncrement = true});
}

/// Annotation to mark a field as a foreign key

class ForeignKey {
  /// The referenced table name
  final String table;

  /// The referenced column name (defaults to 'id')
  final String column;

  const ForeignKey({required this.table, this.column = 'id'});
}

/// Annotation to configure field validation

class Validate {
  /// Validation rules as string expressions
  final List<String> rules;

  const Validate(this.rules);
}

/// Annotation to mark a field as a computed property

class Computed {
  /// Whether to include this computed field in serialization
  final bool serializable;

  const Computed({this.serializable = true});
}

/// Annotation for relationship configuration

class Relationship {
  /// Type of relationship (hasOne, hasMany, belongsTo, etc.)
  final RelationshipType type;

  /// Related model class name
  final String? relatedModel;

  /// Foreign key field name
  final String? foreignKey;

  /// Local key field name
  final String? localKey;

  const Relationship({
    required this.type,
    this.relatedModel,
    this.foreignKey,
    this.localKey,
  });
}

/// Types of relationships
enum RelationshipType {
  hasOne,
  hasMany,
  belongsTo,
  belongsToMany,
  hasManyThrough,
}

/// Annotation for query scopes

class Scope {
  /// Scope name (defaults to method name)
  final String? name;

  const Scope({this.name});
}

/// Annotation for mutators (setters that transform values)

class Mutator {
  /// Field name this mutator applies to
  final String field;

  const Mutator({required this.field});
}

/// Annotation for accessors (getters that transform values)

class Accessor {
  /// Field name this accessor applies to
  final String field;

  const Accessor({required this.field});
}
