import 'model.dart';
import '../database/database.dart';

/// Base class for all relationships
abstract class Relationship<T extends Model<T>, R> {
  /// The parent model instance
  final Model parent;

  /// The related model constructor
  final T Function() relatedConstructor;

  /// Foreign key field name
  final String foreignKey;

  /// Local key field name
  final String localKey;

  /// Whether this relationship has been loaded
  bool _isLoaded = false;

  /// Cached result
  R? _cachedResult;

  Relationship({
    required this.parent,
    required this.relatedConstructor,
    required this.foreignKey,
    required this.localKey,
  });

  /// Whether this relationship has been loaded
  bool get isLoaded => _isLoaded;

  /// Get the cached result
  R? get cachedResult => _cachedResult;

  /// Execute the relationship query
  Future<R> execute();

  /// Get the relationship result (with caching)
  Future<R> get() async {
    if (!_isLoaded) {
      _cachedResult = await execute();
      _isLoaded = true;
    }
    return _cachedResult as R;
  }

  /// Reset the cached result
  void reset() {
    _isLoaded = false;
    _cachedResult = null;
  }
}

/// Has One relationship (1:1)
class HasOne<T extends Model<T>> extends Relationship<T, T?> {
  HasOne({
    required super.parent,
    required super.relatedConstructor,
    required super.foreignKey,
    required super.localKey,
  });

  @override
  Future<T?> execute() async {
    final localValue = parent.getValue(localKey);
    if (localValue == null) return null;

    final relatedInstance = relatedConstructor();
    final rows = await Database.query(
      'SELECT * FROM ${relatedInstance.table} WHERE $foreignKey = ? LIMIT 1',
      [localValue],
    );

    if (rows.isNotEmpty) {
      relatedInstance.fromMap(rows.first);
      return relatedInstance;
    }

    return null;
  }
}

/// Has Many relationship (1:N)
class HasMany<T extends Model<T>> extends Relationship<T, List<T>> {
  HasMany({
    required super.parent,
    required super.relatedConstructor,
    required super.foreignKey,
    required super.localKey,
  });

  @override
  Future<List<T>> execute() async {
    final localValue = parent.getValue(localKey);
    if (localValue == null) return [];

    final relatedInstance = relatedConstructor();
    final rows = await Database.query(
      'SELECT * FROM ${relatedInstance.table} WHERE $foreignKey = ?',
      [localValue],
    );

    return rows.map((row) {
      final model = relatedConstructor();
      model.fromMap(row);
      return model;
    }).toList();
  }
}

/// Belongs To relationship (N:1)
class BelongsTo<T extends Model<T>> extends Relationship<T, T?> {
  BelongsTo({
    required super.parent,
    required super.relatedConstructor,
    required super.foreignKey,
    required super.localKey,
  });

  @override
  Future<T?> execute() async {
    final foreignValue = parent.getValue(foreignKey);
    if (foreignValue == null) return null;

    final relatedInstance = relatedConstructor();
    final rows = await Database.query(
      'SELECT * FROM ${relatedInstance.table} WHERE $localKey = ? LIMIT 1',
      [foreignValue],
    );

    if (rows.isNotEmpty) {
      relatedInstance.fromMap(rows.first);
      return relatedInstance;
    }

    return null;
  }
}

/// Belongs To Many relationship (N:M) - for future implementation
class BelongsToMany<T extends Model<T>> extends Relationship<T, List<T>> {
  /// Pivot table name
  final String pivotTable;

  /// Parent key in pivot table
  final String parentPivotKey;

  /// Related key in pivot table
  final String relatedPivotKey;

  BelongsToMany({
    required super.parent,
    required super.relatedConstructor,
    required super.foreignKey,
    required super.localKey,
    required this.pivotTable,
    required this.parentPivotKey,
    required this.relatedPivotKey,
  });

  @override
  Future<List<T>> execute() async {
    final localValue = parent.getValue(localKey);
    if (localValue == null) return [];

    final relatedInstance = relatedConstructor();
    final rows = await Database.query(
      '''
      SELECT ${relatedInstance.table}.* 
      FROM ${relatedInstance.table}
      INNER JOIN $pivotTable ON ${relatedInstance.table}.$foreignKey = $pivotTable.$relatedPivotKey
      WHERE $pivotTable.$parentPivotKey = ?
      ''',
      [localValue],
    );

    return rows.map((row) {
      final model = relatedConstructor();
      model.fromMap(row);
      return model;
    }).toList();
  }
}

/// Relationship registry for managing model relationships
class RelationshipRegistry {
  /// Map of relationship name to relationship instance
  final Map<String, Relationship> _relationships = {};

  /// Map of lazy relationship name to relationship factory
  final Map<String, Relationship Function()> _lazyRelationships = {};

  /// Register a relationship
  void register(String name, Relationship relationship) {
    _relationships[name] = relationship;
  }

  /// Register a relationship lazily (prevents circular constructor calls)
  void registerLazy(String name, Relationship Function() relationshipFactory) {
    _lazyRelationships[name] = relationshipFactory;
  }

  /// Get a relationship by name
  Relationship? get(String name) {
    // Check if already registered
    if (_relationships.containsKey(name)) {
      return _relationships[name];
    }

    // Check if lazy relationship exists and create it
    if (_lazyRelationships.containsKey(name)) {
      final relationship = _lazyRelationships[name]!();
      _relationships[name] = relationship; // Cache for future use
      return relationship;
    }

    return null;
  }

  /// Get HasOne relationship result directly
  Future<T?> getHasOne<T extends Model<T>>(String name) async {
    final relationship = get(name) as HasOne<T>?;
    if (relationship == null) {
      throw ArgumentError('HasOne relationship "$name" not found');
    }
    return await relationship.get();
  }

  /// Get HasMany relationship result directly
  Future<List<T>> getHasMany<T extends Model<T>>(String name) async {
    final relationship = get(name) as HasMany<T>?;
    if (relationship == null) {
      throw ArgumentError('HasMany relationship "$name" not found');
    }
    return await relationship.get();
  }

  /// Get BelongsTo relationship result directly
  Future<T?> getBelongsTo<T extends Model<T>>(String name) async {
    final relationship = get(name) as BelongsTo<T>?;
    if (relationship == null) {
      throw ArgumentError('BelongsTo relationship "$name" not found');
    }
    return await relationship.get();
  }

  /// Get BelongsToMany relationship result directly
  Future<List<T>> getBelongsToMany<T extends Model<T>>(String name) async {
    final relationship = get(name) as BelongsToMany<T>?;
    if (relationship == null) {
      throw ArgumentError('BelongsToMany relationship "$name" not found');
    }
    return await relationship.get();
  }

  // Short API aliases
  /// Get HasOne relationship (short alias)
  Future<T?> one<T extends Model<T>>(String name) => getHasOne<T>(name);

  /// Get HasMany relationship (short alias)
  Future<List<T>> many<T extends Model<T>>(String name) => getHasMany<T>(name);

  /// Get BelongsTo relationship (short alias)
  Future<T?> belongsTo<T extends Model<T>>(String name) =>
      getBelongsTo<T>(name);

  /// Get BelongsToMany relationship (short alias)
  Future<List<T>> belongsToMany<T extends Model<T>>(String name) =>
      getBelongsToMany<T>(name);

  /// Check if a relationship is registered
  bool has(String name) {
    return _relationships.containsKey(name) ||
        _lazyRelationships.containsKey(name);
  }

  /// Get all relationship names
  List<String> get names {
    final allNames = <String>{};
    allNames.addAll(_relationships.keys);
    allNames.addAll(_lazyRelationships.keys);
    return allNames.toList();
  }

  /// Reset all relationships (clear cache)
  void resetAll() {
    for (final relationship in _relationships.values) {
      relationship.reset();
    }
  }
}
