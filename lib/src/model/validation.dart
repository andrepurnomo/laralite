import 'model.dart';

/// Enhanced validation result with detailed error information
class ModelValidationResult {
  /// Whether the validation passed
  final bool isValid;
  
  /// Map of field names to their error messages
  final Map<String, List<String>> fieldErrors;
  
  /// General validation errors (not field-specific)
  final List<String> generalErrors;
  
  ModelValidationResult({
    required this.isValid,
    this.fieldErrors = const {},
    this.generalErrors = const [],
  });
  
  /// Get all error messages as a flat list
  List<String> get allErrors {
    final errors = <String>[];
    errors.addAll(generalErrors);
    for (final fieldErrorList in fieldErrors.values) {
      errors.addAll(fieldErrorList);
    }
    return errors;
  }
  
  /// Get the first error message (useful for simple error display)
  String? get firstError {
    if (generalErrors.isNotEmpty) {
      return generalErrors.first;
    }
    for (final errorList in fieldErrors.values) {
      if (errorList.isNotEmpty) {
        return errorList.first;
      }
    }
    return null;
  }
  
  /// Check if a specific field has errors
  bool hasFieldError(String fieldName) {
    return fieldErrors.containsKey(fieldName) && fieldErrors[fieldName]!.isNotEmpty;
  }
  
  /// Get errors for a specific field
  List<String> getFieldErrors(String fieldName) {
    return fieldErrors[fieldName] ?? [];
  }
  
  /// Get the first error for a specific field
  String? getFirstFieldError(String fieldName) {
    final errors = getFieldErrors(fieldName);
    return errors.isNotEmpty ? errors.first : null;
  }
  
  /// Combine multiple validation results
  static ModelValidationResult combine(List<ModelValidationResult> results) {
    final combinedFieldErrors = <String, List<String>>{};
    final combinedGeneralErrors = <String>[];
    bool isValid = true;
    
    for (final result in results) {
      if (!result.isValid) {
        isValid = false;
      }
      
      combinedGeneralErrors.addAll(result.generalErrors);
      
      for (final entry in result.fieldErrors.entries) {
        final fieldName = entry.key;
        final errors = entry.value;
        
        if (combinedFieldErrors.containsKey(fieldName)) {
          combinedFieldErrors[fieldName]!.addAll(errors);
        } else {
          combinedFieldErrors[fieldName] = List<String>.from(errors);
        }
      }
    }
    
    return ModelValidationResult(
      isValid: isValid,
      fieldErrors: combinedFieldErrors,
      generalErrors: combinedGeneralErrors,
    );
  }
  
  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult(valid)';
    }
    
    final errorCount = allErrors.length;
    return 'ValidationResult(invalid, $errorCount errors: ${allErrors.join(', ')})';
  }
}

/// Base class for validation rules
abstract class ModelValidationRule<T> {
  /// Validate the value
  bool validate(T? value);
  
  /// Get the error message for this rule
  String get message;
  
  /// Get a customized error message with context
  String getMessageFor(String fieldName) => message;
}

/// Required field validation
class RequiredRule<T> extends ModelValidationRule<T> {
  @override
  bool validate(T? value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
  
  @override
  String get message => 'This field is required';
  
  @override
  String getMessageFor(String fieldName) => '$fieldName is required';
}

/// Minimum length validation for strings
class MinLengthRule extends ModelValidationRule<String> {
  final int minLength;
  
  MinLengthRule(this.minLength);
  
  @override
  bool validate(String? value) {
    return value == null || value.length >= minLength;
  }
  
  @override
  String get message => 'Must be at least $minLength characters';
  
  @override
  String getMessageFor(String fieldName) => '$fieldName must be at least $minLength characters';
}

/// Maximum length validation for strings
class MaxLengthRule extends ModelValidationRule<String> {
  final int maxLength;
  
  MaxLengthRule(this.maxLength);
  
  @override
  bool validate(String? value) {
    return value == null || value.length <= maxLength;
  }
  
  @override
  String get message => 'Must be no more than $maxLength characters';
  
  @override
  String getMessageFor(String fieldName) => '$fieldName must be no more than $maxLength characters';
}

/// Email format validation
class EmailRule extends ModelValidationRule<String> {
  static final RegExp _emailRegex = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
  );
  
  @override
  bool validate(String? value) {
    return value == null || _emailRegex.hasMatch(value);
  }
  
  @override
  String get message => 'Must be a valid email address';
  
  @override
  String getMessageFor(String fieldName) => '$fieldName must be a valid email address';
}

/// Numeric range validation
class RangeRule<T extends num> extends ModelValidationRule<T> {
  final T? min;
  final T? max;
  
  RangeRule({this.min, this.max}) {
    assert(min != null || max != null, 'At least one of min or max must be provided');
  }
  
  @override
  bool validate(T? value) {
    if (value == null) return true;
    
    if (min != null && value < min!) return false;
    if (max != null && value > max!) return false;
    
    return true;
  }
  
  @override
  String get message {
    if (min != null && max != null) {
      return 'Must be between $min and $max';
    } else if (min != null) {
      return 'Must be at least $min';
    } else {
      return 'Must be no more than $max';
    }
  }
  
  @override
  String getMessageFor(String fieldName) {
    if (min != null && max != null) {
      return '$fieldName must be between $min and $max';
    } else if (min != null) {
      return '$fieldName must be at least $min';
    } else {
      return '$fieldName must be no more than $max';
    }
  }
}

/// Regular expression validation
class RegexRule extends ModelValidationRule<String> {
  final RegExp regex;
  final String customMessage;
  
  RegexRule(this.regex, {this.customMessage = 'Invalid format'});
  
  @override
  bool validate(String? value) {
    return value == null || regex.hasMatch(value);
  }
  
  @override
  String get message => customMessage;
  
  @override
  String getMessageFor(String fieldName) => customMessage;
}

/// Date range validation
class DateRangeRule extends ModelValidationRule<DateTime> {
  final DateTime? minDate;
  final DateTime? maxDate;
  
  DateRangeRule({this.minDate, this.maxDate}) {
    assert(minDate != null || maxDate != null, 'At least one of minDate or maxDate must be provided');
  }
  
  @override
  bool validate(DateTime? value) {
    if (value == null) return true;
    
    if (minDate != null && value.isBefore(minDate!)) return false;
    if (maxDate != null && value.isAfter(maxDate!)) return false;
    
    return true;
  }
  
  @override
  String get message {
    if (minDate != null && maxDate != null) {
      return 'Must be between ${minDate!.toIso8601String()} and ${maxDate!.toIso8601String()}';
    } else if (minDate != null) {
      return 'Must be after ${minDate!.toIso8601String()}';
    } else {
      return 'Must be before ${maxDate!.toIso8601String()}';
    }
  }
}

/// Custom validation rule with function
class CustomRule<T> extends ModelValidationRule<T> {
  final bool Function(T? value) validator;
  final String customMessage;
  
  CustomRule(this.validator, {required this.customMessage});
  
  @override
  bool validate(T? value) => validator(value);
  
  @override
  String get message => customMessage;
}

/// Validation registry for managing model validation rules
class ValidationRegistry {
  /// Map of field name to list of validation rules
  final Map<String, List<ModelValidationRule>> _fieldRules = {};
  
  /// List of model-level validation rules
  final List<ModelValidationRule> _modelRules = [];
  
  /// Register validation rules for a field
  void registerFieldRules(String fieldName, List<ModelValidationRule> rules) {
    _fieldRules[fieldName] = rules;
  }
  
  /// Add a validation rule for a field
  void addFieldRule(String fieldName, ModelValidationRule rule) {
    if (!_fieldRules.containsKey(fieldName)) {
      _fieldRules[fieldName] = [];
    }
    _fieldRules[fieldName]!.add(rule);
  }
  
  /// Register model-level validation rules
  void registerModelRules(List<ModelValidationRule> rules) {
    _modelRules.addAll(rules);
  }
  
  /// Add a model-level validation rule
  void addModelRule(ModelValidationRule rule) {
    _modelRules.add(rule);
  }
  
  /// Get validation rules for a field
  List<ModelValidationRule> getFieldRules(String fieldName) {
    return _fieldRules[fieldName] ?? [];
  }
  
  /// Get all model-level validation rules
  List<ModelValidationRule> getModelRules() {
    return List.unmodifiable(_modelRules);
  }
  
  /// Check if a field has validation rules
  bool hasFieldRules(String fieldName) {
    return _fieldRules.containsKey(fieldName) && _fieldRules[fieldName]!.isNotEmpty;
  }
  
  /// Get all field names that have validation rules
  List<String> getValidatedFields() {
    return _fieldRules.keys.toList();
  }
  
  /// Clear all validation rules
  void clear() {
    _fieldRules.clear();
    _modelRules.clear();
  }
}

/// Mixin to add enhanced validation support to models
mixin ValidationMixin<T extends Model<T>> on Model<T> {
  /// Registry for validation rules
  final ValidationRegistry _validationRegistry = ValidationRegistry();
  
  /// Get the validation registry
  ValidationRegistry get validationRegistry => _validationRegistry;
  
  /// Register validation rules for a field
  void registerFieldValidation(String fieldName, List<ModelValidationRule> rules) {
    _validationRegistry.registerFieldRules(fieldName, rules);
  }
  
  /// Add a validation rule for a field
  void addFieldValidation(String fieldName, ModelValidationRule rule) {
    _validationRegistry.addFieldRule(fieldName, rule);
  }
  
  /// Register model-level validation rules
  void registerModelValidation(List<ModelValidationRule> rules) {
    _validationRegistry.registerModelRules(rules);
  }
  
  /// Add a model-level validation rule
  void addModelValidation(ModelValidationRule rule) {
    _validationRegistry.addModelRule(rule);
  }
  
  /// Initialize validation rules (to be overridden by subclasses)
  void initializeValidation() {
    // Subclasses can override this to register their validation rules
  }
  
  /// Validate the model using registered rules
  ModelValidationResult validateModel() {
    final fieldErrors = <String, List<String>>{};
    final generalErrors = <String>[];
    bool isValid = true;
    
    // Validate each field with its rules
    for (final fieldName in _validationRegistry.getValidatedFields()) {
      final rules = _validationRegistry.getFieldRules(fieldName);
      final value = getValue(fieldName);
      final errors = <String>[];
      
      for (final rule in rules) {
        if (!rule.validate(value)) {
          errors.add(rule.getMessageFor(fieldName));
        }
      }
      
      if (errors.isNotEmpty) {
        fieldErrors[fieldName] = errors;
        isValid = false;
      }
    }
    
    // Apply model-level validation rules
    for (final rule in _validationRegistry.getModelRules()) {
      if (!rule.validate(this as T)) {
        generalErrors.add(rule.message);
        isValid = false;
      }
    }
    
    return ModelValidationResult(
      isValid: isValid,
      fieldErrors: fieldErrors,
      generalErrors: generalErrors,
    );
  }
  
  /// Validate and throw exception if invalid
  void validateOrThrow() {
    final result = validateModel();
    if (!result.isValid) {
      throw ModelValidationException(result);
    }
  }
  

}

/// Enhanced validation exception with detailed error information
class ModelValidationException implements Exception {
  final ModelValidationResult result;
  
  const ModelValidationException(this.result);
  
  /// Get all error messages
  List<String> get errors => result.allErrors;
  
  /// Get field-specific errors
  Map<String, List<String>> get fieldErrors => result.fieldErrors;
  
  /// Get general errors
  List<String> get generalErrors => result.generalErrors;
  
  /// Get the first error message
  String? get firstError => result.firstError;
  
  @override
  String toString() => 'ModelValidationException: ${result.firstError ?? 'Validation failed'}';
}
