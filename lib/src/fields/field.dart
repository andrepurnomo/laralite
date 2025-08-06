import 'package:meta/meta.dart';

/// Base class for all field types in laralite ORM
/// 
/// Fields are the core building blocks that define model properties
/// and handle validation, serialization, and database column mapping.
abstract class Field<T> {
  /// The current value of this field
  T? _value;
  
  /// Whether this field is required (NOT NULL)
  final bool required;
  
  /// Default value for this field
  final T? defaultValue;
  
  /// Whether this field should be unique
  final bool unique;
  
  /// Whether this field can be null
  final bool nullable;
  
  /// Custom column name (defaults to field name)
  final String? columnName;
  
  /// Custom validation rules
  final List<ValidationRule<T>> validationRules;
  
  /// Whether this field has been modified
  bool _isDirty = false;
  
  /// Whether this field has been loaded from database
  bool _isLoaded = false;
  
  Field({
    this.required = false,
    this.defaultValue,
    this.unique = false,
    this.nullable = true,
    this.columnName,
    this.validationRules = const [],
  }) {
    // Apply default value if provided
    if (defaultValue != null) {
      _value = defaultValue;
    }
  }
  
  /// Get the current value of this field
  T? get value => _value;
  
  /// Set the value of this field
  set value(T? newValue) {
    if (_value != newValue) {
      _value = newValue;
      _isDirty = true;
    }
  }
  
  /// Whether this field has been modified since last save
  bool get isDirty => _isDirty;
  
  /// Whether this field has been loaded from database
  bool get isLoaded => _isLoaded;
  
  /// Mark this field as clean (not dirty)
  void markClean() {
    _isDirty = false;
  }
  
  /// Mark this field as loaded from database
  void markLoaded() {
    _isLoaded = true;
  }
  
  /// Reset the field to its default state
  void reset() {
    _value = defaultValue;
    _isDirty = false;
    _isLoaded = false;
  }
  
  /// Get the SQL column type for this field
  String getSqlType();
  
  /// Get SQL column constraints (NOT NULL, UNIQUE, etc.)
  List<String> getSqlConstraints() {
    final constraints = <String>[];
    
    if (required && !nullable) {
      constraints.add('NOT NULL');
    }
    
    if (unique) {
      constraints.add('UNIQUE');
    }
    
    if (defaultValue != null) {
      constraints.add('DEFAULT ${formatDefaultValue()}');
    }
    
    return constraints;
  }
  
  /// Format the default value for SQL
  String formatDefaultValue() {
    if (defaultValue == null) return 'NULL';
    return serializeValue(defaultValue);
  }
  
  /// Serialize value for database storage
  String serializeValue(T? value);
  
  /// Deserialize value from database
  T? deserializeValue(dynamic value);
  
  /// Validate the current value
  ValidationResult validate() {
    final errors = <String>[];
    
    // Check required constraint
    if (required && (_value == null || (T == String && (_value as String).isEmpty))) {
      errors.add('This field is required');
    }
    
    // Run custom validation rules
    for (final rule in validationRules) {
      if (!rule.validate(_value)) {
        errors.add(rule.message);
      }
    }
    
    // Run field-specific validation
    final fieldErrors = validateValue(_value);
    errors.addAll(fieldErrors);
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Field-specific validation logic (override in subclasses)
  @protected
  List<String> validateValue(T? value) => [];
  
  /// Convert field to map representation for debugging
  Map<String, dynamic> toDebugMap() {
    return {
      'type': runtimeType.toString(),
      'value': _value,
      'required': required,
      'nullable': nullable,
      'unique': unique,
      'defaultValue': defaultValue,
      'isDirty': _isDirty,
      'isLoaded': _isLoaded,
      'sqlType': getSqlType(),
      'constraints': getSqlConstraints(),
    };
  }
  
  @override
  String toString() => 'Field<$T>(value: $_value, isDirty: $_isDirty)';
}

/// Validation rule interface
abstract class ValidationRule<T> {
  bool validate(T? value);
  String get message;
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  
  const ValidationResult({
    required this.isValid,
    required this.errors,
  });
  
  @override
  String toString() => 'ValidationResult(isValid: $isValid, errors: $errors)';
}

/// Common validation rules
class RequiredRule<T> implements ValidationRule<T> {
  @override
  bool validate(T? value) {
    if (value == null) return false;
    if (T == String && (value as String).isEmpty) return false;
    return true;
  }
  
  @override
  String get message => 'This field is required';
}

class MinLengthRule implements ValidationRule<String> {
  final int minLength;
  
  const MinLengthRule(this.minLength);
  
  @override
  bool validate(String? value) {
    if (value == null) return true; // Let required rule handle null
    return value.length >= minLength;
  }
  
  @override
  String get message => 'Minimum length is $minLength characters';
}

class MaxLengthRule implements ValidationRule<String> {
  final int maxLength;
  
  const MaxLengthRule(this.maxLength);
  
  @override
  bool validate(String? value) {
    if (value == null) return true;
    return value.length <= maxLength;
  }
  
  @override
  String get message => 'Maximum length is $maxLength characters';
}

class MinValueRule<T extends num> implements ValidationRule<T> {
  final T minValue;
  
  const MinValueRule(this.minValue);
  
  @override
  bool validate(T? value) {
    if (value == null) return true;
    return value >= minValue;
  }
  
  @override
  String get message => 'Minimum value is $minValue';
}

class MaxValueRule<T extends num> implements ValidationRule<T> {
  final T maxValue;
  
  const MaxValueRule(this.maxValue);
  
  @override
  bool validate(T? value) {
    if (value == null) return true;
    return value <= maxValue;
  }
  
  @override
  String get message => 'Maximum value is $maxValue';
}
