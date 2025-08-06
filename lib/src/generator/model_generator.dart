import 'dart:async';
import 'package:build/build.dart';

/// Code generator for @laralite annotation
/// Generates field accessors, registration code, and field references
class LaraliteGenerator implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    '.dart': ['.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final outputId = inputId.changeExtension('.g.dart');

    final contents = await buildStep.readAsString(inputId);

    // Check if file has @laralite annotation
    if (!contents.contains('@laralite')) {
      return;
    }

    final generatedCode = _generateCode(contents, inputId);

    if (generatedCode.isNotEmpty) {
      await buildStep.writeAsString(outputId, generatedCode);
    }
  }

  String _generateCode(String sourceCode, dynamic inputId) {
    final buffer = StringBuffer();

    // Extract all classes with @laralite annotation
    final classes = _extractClasses(sourceCode);

    if (classes.isEmpty) return '';

    // Generate header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln('// ignore_for_file: unused_field, unused_element');
    buffer.writeln();
    final sourceFileName = inputId.path.split('/').last;
    buffer.writeln('part of \'$sourceFileName\';');
    buffer.writeln();

    // Generate code for each class
    for (final classData in classes) {
      _generateClassCode(buffer, classData);
    }

    return buffer.toString();
  }

  /// Extract all classes with @laralite annotation from source code
  List<Map<String, dynamic>> _extractClasses(String sourceCode) {
    final classes = <Map<String, dynamic>>[];

    // Find all @laralite classes
    final classPattern = RegExp(
      r'@laralite.*?class\s+(\w+)\s+extends\s+Model<\w+>.*?\{',
      multiLine: true,
      dotAll: true,
    );
    final classMatches = classPattern.allMatches(sourceCode);

    for (final classMatch in classMatches) {
      final className = classMatch.group(1)!;
      final classStart = classMatch.end - 1; // Start at the opening brace

      // Find the end of this class by counting braces
      final classEnd = _findClassEnd(sourceCode, classStart);
      final classBody = sourceCode.substring(
        classStart + 1,
        classEnd,
      ); // Skip opening brace

      // Extract fields for this class
      final fields = _extractFields(classBody);

      // Extract relationships for this class
      final relationships = _extractRelationships(classBody);

      if (fields.isNotEmpty) {
        classes.add({
          'name': className,
          'fields': fields,
          'relationships': relationships,
        });
      }
    }

    return classes;
  }

  /// Find the end of a class definition by counting braces
  int _findClassEnd(String sourceCode, int startPos) {
    int braceCount = 0;
    bool inClass = false;

    for (int i = startPos; i < sourceCode.length; i++) {
      final char = sourceCode[i];

      if (char == '{') {
        braceCount++;
        inClass = true;
      } else if (char == '}') {
        braceCount--;
        if (inClass && braceCount == 0) {
          return i;
        }
      }
    }

    return sourceCode.length;
  }

  /// Extract field definitions from class body
  List<Map<String, String>> _extractFields(String classBody) {
    final fields = <Map<String, String>>[];
    final fieldPattern = RegExp(r'final\s+(_\w+)\s+=\s+(\w+Field)\(');

    for (final match in fieldPattern.allMatches(classBody)) {
      final fieldName = match.group(1)!;
      final fieldType = match.group(2)!;
      final propertyName = fieldName.substring(1); // Remove underscore

      fields.add({
        'fieldName': fieldName,
        'propertyName': propertyName,
        'fieldType': fieldType,
        'dartType': _getDartType(fieldType),
      });
    }

    return fields;
  }

  /// Extract relationship method definitions from class body
  List<Map<String, String>> _extractRelationships(String classBody) {
    final relationships = <Map<String, String>>[];
    final relationshipPattern = RegExp(r'(\w+)<(\w+)>\s+(\w+)\(\)');

    for (final match in relationshipPattern.allMatches(classBody)) {
      final relationshipType = match.group(1)!; // HasOne, HasMany, etc.
      final relatedModel = match.group(2)!; // User, Post, etc.
      final relationshipName = match.group(3)!; // posts, user, etc.

      // Skip invalid relationship types (like constructors)
      if (![
        'HasOne',
        'HasMany',
        'BelongsTo',
        'BelongsToMany',
      ].contains(relationshipType)) {
        continue;
      }

      relationships.add({
        'type': relationshipType,
        'relatedModel': relatedModel,
        'name': relationshipName,
      });
    }

    return relationships;
  }

  /// Generate code for a single class
  void _generateClassCode(StringBuffer buffer, Map<String, dynamic> classData) {
    final className = classData['name'] as String;
    final fields = classData['fields'] as List<Map<String, String>>;
    final relationships =
        classData['relationships'] as List<Map<String, String>>;

    // Generate extension to provide public field access
    buffer.writeln('extension _\$${className}FieldAccess on $className {');
    for (final field in fields) {
      buffer.writeln(
        '  /// Get ${field['propertyName']} field for registration',
      );
      buffer.writeln(
        '  Field get ${field['propertyName']}FieldRef => ${field['fieldName']};',
      );
    }
    buffer.writeln('}');
    buffer.writeln();

    // Generate mixin
    buffer.writeln('mixin _\$${className}Fields on Model<$className> {');

    // Generate property getters and setters that access fields by name
    for (final field in fields) {
      final columnName = _getColumnName(field['propertyName']!);
      buffer.writeln('  /// ${field['propertyName']} property getter');
      buffer.writeln(
        '  ${field['dartType']} get ${field['propertyName']} => getValue<${field['dartType']?.replaceAll('?', '')}>(\'$columnName\');',
      );
      buffer.writeln();
      buffer.writeln('  /// ${field['propertyName']} property setter');
      buffer.writeln(
        '  set ${field['propertyName']}(${field['dartType']} value) => setValue(\'$columnName\', value);',
      );
      buffer.writeln();
    }

    // Generate automatic field registration
    buffer.writeln('  @override');
    buffer.writeln('  void registerFields() {');
    for (final field in fields) {
      final columnName = _getColumnName(field['propertyName']!);
      buffer.writeln(
        '    registerField(\'$columnName\', (this as $className).${field['propertyName']}FieldRef);',
      );
    }
    buffer.writeln('  }');
    buffer.writeln();

    // Generate automatic relationship registration with lazy loading
    if (relationships.isNotEmpty) {
      buffer.writeln('  @override');
      buffer.writeln('  void initializeRelationships() {');
      buffer.writeln('    super.initializeRelationships();');
      for (final rel in relationships) {
        buffer.writeln(
          '    relationships.registerLazy(\'${rel['name']}\', () => (this as $className).${rel['name']}());',
        );
      }
      buffer.writeln('  }');
      buffer.writeln();
    }

    // Generate all the query builder methods for this class
    _generateQueryBuilderMethods(buffer, className);

    buffer.writeln('}');
    buffer.writeln();

    // Generate type-safe field references for this class (outside the mixin)
    _generateFieldReferences(buffer, className, fields);
  }

  /// Generate query builder methods for a class
  void _generateQueryBuilderMethods(StringBuffer buffer, String className) {
    // Generate instance query builder methods
    buffer.writeln('  /// Create new query builder for this model');
    buffer.writeln('  QueryBuilder<$className> query() {');
    buffer.writeln('    return Model.query<$className>(() => $className());');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add WHERE condition using type-safe field reference');
    buffer.writeln(
      '  QueryBuilder<$className> where(String fieldRef, dynamic operator, [dynamic value]) {',
    );
    buffer.writeln('    return query().where(fieldRef, operator, value);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln(
      '  /// Add WHERE IN condition using type-safe field reference',
    );
    buffer.writeln(
      '  QueryBuilder<$className> whereIn(String fieldRef, List<dynamic> values) {',
    );
    buffer.writeln('    return query().whereIn(fieldRef, values);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln(
      '  /// Add WHERE NOT IN condition using type-safe field reference',
    );
    buffer.writeln(
      '  QueryBuilder<$className> whereNotIn(String fieldRef, List<dynamic> values) {',
    );
    buffer.writeln('    return query().whereNotIn(fieldRef, values);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln(
      '  /// Add WHERE NULL condition using type-safe field reference',
    );
    buffer.writeln('  QueryBuilder<$className> whereNull(String fieldRef) {');
    buffer.writeln('    return query().whereNull(fieldRef);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln(
      '  /// Add WHERE NOT NULL condition using type-safe field reference',
    );
    buffer.writeln(
      '  QueryBuilder<$className> whereNotNull(String fieldRef) {',
    );
    buffer.writeln('    return query().whereNotNull(fieldRef);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln(
      '  /// Add WHERE BETWEEN condition using type-safe field reference',
    );
    buffer.writeln(
      '  QueryBuilder<$className> whereBetween(String fieldRef, dynamic min, dynamic max) {',
    );
    buffer.writeln('    return query().whereBetween(fieldRef, min, max);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add ORDER BY clause using type-safe field reference');
    buffer.writeln(
      '  QueryBuilder<$className> orderBy(String fieldRef, [String direction = \'ASC\']) {',
    );
    buffer.writeln('    return query().orderBy(fieldRef, direction);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add ORDER BY ASC using type-safe field reference');
    buffer.writeln('  QueryBuilder<$className> orderByAsc(String fieldRef) {');
    buffer.writeln('    return query().orderByAsc(fieldRef);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add ORDER BY DESC using type-safe field reference');
    buffer.writeln('  QueryBuilder<$className> orderByDesc(String fieldRef) {');
    buffer.writeln('    return query().orderByDesc(fieldRef);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Set LIMIT');
    buffer.writeln('  QueryBuilder<$className> limit(int count) {');
    buffer.writeln('    return query().limit(count);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Set OFFSET');
    buffer.writeln('  QueryBuilder<$className> offset(int count) {');
    buffer.writeln('    return query().offset(count);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Take records (alias for limit)');
    buffer.writeln('  QueryBuilder<$className> take(int count) {');
    buffer.writeln('    return query().take(count);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Skip records (alias for offset)');
    buffer.writeln('  QueryBuilder<$className> skip(int count) {');
    buffer.writeln('    return query().skip(count);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln(
      '  /// Select specific columns using type-safe field references',
    );
    buffer.writeln(
      '  QueryBuilder<$className> select(List<String> fieldRefs) {',
    );
    buffer.writeln('    return query().select(fieldRefs);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Apply scope callback');
    buffer.writeln(
      '  QueryBuilder<$className> scope(QueryBuilder<$className> Function(QueryBuilder<$className>) callback) {',
    );
    buffer.writeln('    return query().scope(callback);');
    buffer.writeln('  }');
    buffer.writeln();

    // Add execution methods
    buffer.writeln('  /// Execute query and return all results');
    buffer.writeln('  Future<List<$className>> get() {');
    buffer.writeln('    return query().get();');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Execute query and return first result');
    buffer.writeln('  Future<$className?> first() {');
    buffer.writeln('    return query().first();');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Execute query and return count');
    buffer.writeln('  Future<int> count() {');
    buffer.writeln('    return query().count();');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Check if any records exist');
    buffer.writeln('  Future<bool> existsQuery() {');
    buffer.writeln('    return query().exists();');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Paginate results');
    buffer.writeln(
      '  Future<PaginationResult<$className>> paginate({int page = 1, int perPage = 15}) {',
    );
    buffer.writeln(
      '    return query().paginate(page: page, perPage: perPage);',
    );
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Include relationships for eager loading');
    buffer.writeln(
      '  QueryBuilder<$className> include(dynamic relationships) {',
    );
    buffer.writeln('    return query().include(relationships);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Load relationships eagerly (alias for include)');
    buffer.writeln(
      '  QueryBuilder<$className> withRelations(dynamic relationships) {',
    );
    buffer.writeln('    return query().withRelations(relationships);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Apply conditional query logic');
    buffer.writeln(
      '  QueryBuilder<$className> when(bool condition, QueryBuilder<$className> Function(QueryBuilder<$className>) callback) {',
    );
    buffer.writeln('    return query().when(condition, callback);');
    buffer.writeln('  }');
    buffer.writeln();

    // Add exists queries
    buffer.writeln('  /// Add WHERE EXISTS condition with relationship');
    buffer.writeln(
      '  QueryBuilder<$className> whereHas<TRelated extends Model<TRelated>>(String relationshipName, [QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback]) {',
    );
    buffer.writeln('    return query().whereHas<TRelated>(relationshipName, callback);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add WHERE NOT EXISTS condition with relationship');
    buffer.writeln(
      '  QueryBuilder<$className> whereDoesntHave<TRelated extends Model<TRelated>>(String relationshipName, [QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback]) {',
    );
    buffer.writeln('    return query().whereDoesntHave<TRelated>(relationshipName, callback);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add WHERE condition for relationship count');
    buffer.writeln(
      '  QueryBuilder<$className> whereHasCount<TRelated extends Model<TRelated>>(String relationshipName, String operator, int count, [QueryBuilder<TRelated> Function(QueryBuilder<TRelated>)? callback]) {',
    );
    buffer.writeln('    return query().whereHasCount<TRelated>(relationshipName, operator, count, callback);');
    buffer.writeln('  }');
    buffer.writeln();

    // Add soft delete utilities
    buffer.writeln('  /// Include soft deleted records in query');
    buffer.writeln('  QueryBuilder<$className> withTrashed() {');
    buffer.writeln('    return query().withTrashed();');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Only show soft deleted records');
    buffer.writeln('  QueryBuilder<$className> onlyTrashed() {');
    buffer.writeln('    return query().onlyTrashed();');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Restore soft deleted records matching conditions');
    buffer.writeln('  Future<int> restoreWhere() {');
    buffer.writeln('    return query().restore();');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Force delete records matching conditions');
    buffer.writeln('  Future<int> forceDeleteWhere() {');
    buffer.writeln('    return query().forceDelete();');
    buffer.writeln('  }');
    buffer.writeln();

    // Add aggregation methods
    buffer.writeln('  /// Calculate sum of a column');
    buffer.writeln('  Future<double?> sum(String column) {');
    buffer.writeln('    return query().sum(column);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Calculate average of a column');
    buffer.writeln('  Future<double?> avg(String column) {');
    buffer.writeln('    return query().avg(column);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Find maximum value of a column');
    buffer.writeln('  Future<dynamic> max(String column) {');
    buffer.writeln('    return query().max(column);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Find minimum value of a column');
    buffer.writeln('  Future<dynamic> min(String column) {');
    buffer.writeln('    return query().min(column);');
    buffer.writeln('  }');
    buffer.writeln();

    // Add OR WHERE methods
    buffer.writeln('  /// Add OR WHERE condition');
    buffer.writeln(
      '  QueryBuilder<$className> orWhere(String fieldRef, dynamic operator, [dynamic value]) {',
    );
    buffer.writeln('    return query().orWhere(fieldRef, operator, value);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add OR WHERE IN condition');
    buffer.writeln(
      '  QueryBuilder<$className> orWhereIn(String fieldRef, List<dynamic> values) {',
    );
    buffer.writeln('    return query().orWhereIn(fieldRef, values);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add OR WHERE NOT IN condition');
    buffer.writeln(
      '  QueryBuilder<$className> orWhereNotIn(String fieldRef, List<dynamic> values) {',
    );
    buffer.writeln('    return query().orWhereNotIn(fieldRef, values);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add OR WHERE NULL condition');
    buffer.writeln('  QueryBuilder<$className> orWhereNull(String fieldRef) {');
    buffer.writeln('    return query().orWhereNull(fieldRef);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add OR WHERE NOT NULL condition');
    buffer.writeln(
      '  QueryBuilder<$className> orWhereNotNull(String fieldRef) {',
    );
    buffer.writeln('    return query().orWhereNotNull(fieldRef);');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  /// Add OR WHERE BETWEEN condition');
    buffer.writeln(
      '  QueryBuilder<$className> orWhereBetween(String fieldRef, dynamic min, dynamic max) {',
    );
    buffer.writeln('    return query().orWhereBetween(fieldRef, min, max);');
    buffer.writeln('  }');
    buffer.writeln();
  }

  /// Generate type-safe field references for a class
  void _generateFieldReferences(
    StringBuffer buffer,
    String className,
    List<Map<String, String>> fields,
  ) {
    // Generate top-level field references map for type-safe queries
    buffer.writeln('/// Type-safe field references for $className queries');
    buffer.writeln(
      '/// Use ${className}Fields.name instead of \'name\' string literals',
    );
    buffer.writeln('abstract class ${className}Fields {');
    for (final field in fields) {
      final columnName = _getColumnName(field['propertyName']!);
      buffer.writeln(
        '  static const ${field['propertyName']} = \'$columnName\';',
      );
    }
    buffer.writeln('}');
    buffer.writeln();
  }

  /// Get Dart type for field type
  String _getDartType(String fieldType) {
    switch (fieldType) {
      case 'AutoIncrementField':
        return 'int?';
      case 'IntField':
        return 'int?';
      case 'DoubleField':
        return 'double?';
      case 'StringField':
      case 'TextField':
      case 'UuidField':
        return 'String?';
      case 'BoolField':
        return 'bool?';
      case 'DateTimeField':
      case 'TimestampField':
        return 'DateTime?';
      case 'JsonField':
        return 'Map<String, dynamic>?';
      case 'BlobField':
        return 'List<int>?';
      case 'ForeignKeyField':
        return 'int?';
      default:
        return 'dynamic';
    }
  }

  String _getColumnName(String propertyName) {
    // Convert camelCase to snake_case for database column names
    return _camelToSnakeCase(propertyName);
  }

  String _camelToSnakeCase(String camelCase) {
    return camelCase.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}
