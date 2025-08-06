import 'dart:convert';
import 'field.dart';
import 'text_fields.dart';

/// JSON field for storing structured data
class JsonField<T> extends Field<T> {
  /// Custom serializer function
  final String Function(T value)? customSerializer;
  
  /// Custom deserializer function
  final T Function(String json)? customDeserializer;
  
  JsonField({
    this.customSerializer,
    this.customDeserializer,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  });
  
  @override
  String getSqlType() => 'TEXT'; // Store as JSON string
  
  @override
  String serializeValue(T? value) {
    if (value == null) return 'NULL';
    
    try {
      if (customSerializer != null) {
        final json = customSerializer!(value);
        return "'${json.replaceAll("'", "''")}'";
      } else {
        final json = jsonEncode(value);
        return "'${json.replaceAll("'", "''")}'";
      }
    } catch (e) {
      throw FormatException('Failed to serialize JSON value: $e');
    }
  }
  
  @override
  T? deserializeValue(dynamic value) {
    if (value == null) return null;
    
    if (value is String) {
      try {
        if (customDeserializer != null) {
          return customDeserializer!(value);
        } else {
          return jsonDecode(value) as T;
        }
      } catch (e) {
        throw FormatException('Failed to deserialize JSON value: $e');
      }
    }
    
    return null;
  }
  
  @override
  List<String> validateValue(T? value) {
    final errors = <String>[];
    
    // Test serialization to ensure value is JSON-serializable
    if (value != null) {
      try {
        serializeValue(value);
      } catch (e) {
        errors.add('Value must be JSON-serializable');
      }
    }
    
    return errors;
  }
}

/// Enum field for storing enumerated values
class EnumField<T extends Enum> extends Field<T> {
  /// All possible enum values
  final List<T> enumValues;
  
  EnumField({
    required this.enumValues,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  });
  
  @override
  String getSqlType() => 'TEXT';
  
  @override
  String serializeValue(T? value) {
    if (value == null) return 'NULL';
    return "'${value.name}'";
  }
  
  @override
  T? deserializeValue(dynamic value) {
    if (value == null) return null;
    
    if (value is String) {
      try {
        return enumValues.firstWhere((e) => e.name == value);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }
  
  @override
  List<String> validateValue(T? value) {
    final errors = <String>[];
    
    if (value != null && !enumValues.contains(value)) {
      final validValues = enumValues.map((e) => e.name).join(', ');
      errors.add('Value must be one of: $validValues');
    }
    
    return errors;
  }
}

/// Foreign key field for relationships
class ForeignKeyField extends Field<int> {
  /// The referenced table name
  final String referencedTable;
  
  /// The referenced column name (defaults to 'id')
  final String referencedColumn;
  
  /// Foreign key constraint action on update
  final ForeignKeyAction onUpdate;
  
  /// Foreign key constraint action on delete
  final ForeignKeyAction onDelete;
  
  ForeignKeyField({
    required this.referencedTable,
    this.referencedColumn = 'id',
    this.onUpdate = ForeignKeyAction.noAction,
    this.onDelete = ForeignKeyAction.noAction,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  });
  
  @override
  String getSqlType() => 'INTEGER';
  
  @override
  List<String> getSqlConstraints() {
    final constraints = super.getSqlConstraints();
    
    final onUpdateAction = _getForeignKeyActionSql(onUpdate);
    final onDeleteAction = _getForeignKeyActionSql(onDelete);
    
    constraints.add(
      'REFERENCES $referencedTable($referencedColumn) '
      'ON UPDATE $onUpdateAction ON DELETE $onDeleteAction'
    );
    
    return constraints;
  }
  
  String _getForeignKeyActionSql(ForeignKeyAction action) {
    switch (action) {
      case ForeignKeyAction.cascade:
        return 'CASCADE';
      case ForeignKeyAction.setNull:
        return 'SET NULL';
      case ForeignKeyAction.setDefault:
        return 'SET DEFAULT';
      case ForeignKeyAction.restrict:
        return 'RESTRICT';
      case ForeignKeyAction.noAction:
        return 'NO ACTION';
    }
  }
  
  @override
  String serializeValue(int? value) {
    if (value == null) return 'NULL';
    return value.toString();
  }
  
  @override
  int? deserializeValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
}

/// Foreign key constraint actions
enum ForeignKeyAction {
  cascade,
  setNull,
  setDefault,
  restrict,
  noAction,
}

/// UUID field for unique identifiers
class UuidField extends StringField {
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  
  UuidField({
    super.required = false,
    super.defaultValue,
    super.unique = true, // UUIDs are typically unique
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  }) : super(
         maxLength: 36,
         pattern: _uuidPattern,
       );
  
  @override
  List<String> validateValue(String? value) {
    final errors = super.validateValue(value);
    
    if (value != null && value.isNotEmpty && !_uuidPattern.hasMatch(value)) {
      errors.add('Please enter a valid UUID');
    }
    
    return errors;
  }
}
