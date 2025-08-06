import 'field.dart';

/// Variable-length string field
class StringField extends Field<String> {
  final int? maxLength;
  final int? minLength;
  final RegExp? pattern;
  
  StringField({
    this.maxLength,
    this.minLength,
    this.pattern,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  });
  
  @override
  String getSqlType() {
    if (maxLength != null) {
      return 'VARCHAR($maxLength)';
    }
    return 'TEXT';
  }
  
  @override
  String serializeValue(String? value) {
    if (value == null) return 'NULL';
    // Escape single quotes for SQL
    final escaped = value.replaceAll("'", "''");
    return "'$escaped'";
  }
  
  @override
  String? deserializeValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
  
  @override
  List<String> validateValue(String? value) {
    final errors = <String>[];
    
    if (value != null) {
      if (minLength != null && value.length < minLength!) {
        errors.add('Minimum length is $minLength characters');
      }
      if (maxLength != null && value.length > maxLength!) {
        errors.add('Maximum length is $maxLength characters');
      }
      if (pattern != null && !pattern!.hasMatch(value)) {
        errors.add('Value does not match required pattern');
      }
    }
    
    return errors;
  }
}

/// Large text field for long content
class TextField extends Field<String> {
  final int? maxLength;
  
  TextField({
    this.maxLength,
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
  String serializeValue(String? value) {
    if (value == null) return 'NULL';
    // Escape single quotes for SQL
    final escaped = value.replaceAll("'", "''");
    return "'$escaped'";
  }
  
  @override
  String? deserializeValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
  
  @override
  List<String> validateValue(String? value) {
    final errors = <String>[];
    
    if (value != null && maxLength != null && value.length > maxLength!) {
      errors.add('Maximum length is $maxLength characters');
    }
    
    return errors;
  }
}

/// Email field with built-in validation
class EmailField extends StringField {
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  
  EmailField({
    super.maxLength = 255,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  }) : super(pattern: _emailPattern);
  
  @override
  List<String> validateValue(String? value) {
    final errors = super.validateValue(value);
    
    if (value != null && value.isNotEmpty && !_emailPattern.hasMatch(value)) {
      errors.add('Please enter a valid email address');
    }
    
    return errors;
  }
}

/// URL field with built-in validation
class UrlField extends StringField {
  static final RegExp _urlPattern = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
  );
  
  UrlField({
    super.maxLength = 2048,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  }) : super(pattern: _urlPattern);
  
  @override
  List<String> validateValue(String? value) {
    final errors = super.validateValue(value);
    
    if (value != null && value.isNotEmpty && !_urlPattern.hasMatch(value)) {
      errors.add('Please enter a valid URL');
    }
    
    return errors;
  }
}

/// Binary data field
class BlobField extends Field<List<int>> {
  final int? maxSize;
  
  BlobField({
    this.maxSize,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  });
  
  @override
  String getSqlType() => 'BLOB';
  
  @override
  String serializeValue(List<int>? value) {
    if (value == null) return 'NULL';
    // Convert to hex string for SQL
    final hex = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return "X'$hex'";
  }
  
  @override
  List<int>? deserializeValue(dynamic value) {
    if (value == null) return null;
    if (value is List<int>) return value;
    if (value is String) {
      // Decode hex string
      final bytes = <int>[];
      for (int i = 0; i < value.length; i += 2) {
        final hex = value.substring(i, i + 2);
        bytes.add(int.parse(hex, radix: 16));
      }
      return bytes;
    }
    return null;
  }
  
  @override
  List<String> validateValue(List<int>? value) {
    final errors = <String>[];
    
    if (value != null && maxSize != null && value.length > maxSize!) {
      errors.add('Maximum size is $maxSize bytes');
    }
    
    return errors;
  }
}
