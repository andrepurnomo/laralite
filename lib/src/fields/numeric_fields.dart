import 'field.dart';

/// Auto-incrementing integer field (PRIMARY KEY)
class AutoIncrementField extends Field<int> {
  AutoIncrementField({super.columnName})
    : super(
        required: false, // Auto-increment fields don't need to be set manually
        nullable: false,
        unique: true,
      );

  @override
  String getSqlType() => 'INTEGER PRIMARY KEY AUTOINCREMENT';

  @override
  List<String> getSqlConstraints() => []; // Constraints included in type

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

/// Regular integer field
class IntField extends Field<int> {
  final int? min;
  final int? max;

  IntField({
    this.min,
    this.max,
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

  @override
  List<String> validateValue(int? value) {
    final errors = <String>[];

    if (value != null) {
      if (min != null && value < min!) {
        errors.add('Value must be at least $min');
      }
      if (max != null && value > max!) {
        errors.add('Value must be at most $max');
      }
    }

    return errors;
  }
}

/// Double/Float field
class DoubleField extends Field<double> {
  final double? min;
  final double? max;
  final int? decimalPlaces;

  DoubleField({
    this.min,
    this.max,
    this.decimalPlaces,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  });

  @override
  String getSqlType() => 'REAL';

  @override
  String serializeValue(double? value) {
    if (value == null) return 'NULL';
    if (decimalPlaces != null) {
      return value.toStringAsFixed(decimalPlaces!);
    }
    return value.toString();
  }

  @override
  double? deserializeValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  List<String> validateValue(double? value) {
    final errors = <String>[];

    if (value != null) {
      if (min != null && value < min!) {
        errors.add('Value must be at least $min');
      }
      if (max != null && value > max!) {
        errors.add('Value must be at most $max');
      }
    }

    return errors;
  }
}

/// Boolean field
class BoolField extends Field<bool> {
  BoolField({
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  });

  @override
  String getSqlType() => 'INTEGER'; // SQLite stores booleans as 0/1

  @override
  String serializeValue(bool? value) {
    if (value == null) return 'NULL';
    return value ? '1' : '0';
  }

  @override
  bool? deserializeValue(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null) return intValue != 0;
      return value.toLowerCase() == 'true';
    }
    return null;
  }
}
