import 'field.dart';

/// DateTime field with automatic UTC/local conversion
class DateTimeField extends Field<DateTime> {
  /// Whether to store only date (no time component)
  final bool dateOnly;

  /// Whether to store only time (no date component)
  final bool timeOnly;

  DateTimeField({
    this.dateOnly = false,
    this.timeOnly = false,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  });

  @override
  String getSqlType() => 'TEXT'; // Store as ISO 8601 string

  @override
  String serializeValue(DateTime? value) {
    if (value == null) return 'NULL';

    if (dateOnly) {
      // Always store dates in UTC
      final utcValue = value.toUtc();
      return "'${utcValue.toIso8601String().split('T')[0]}'";
    } else if (timeOnly) {
      // For time-only, use local time (no UTC conversion)
      final timeStr = value.toIso8601String().split('T')[1];
      return "'${timeStr.replaceAll('Z', '')}'";
    } else {
      // Always store full datetimes in UTC
      final utcValue = value.toUtc();
      return "'${utcValue.toIso8601String()}'";
    }
  }

  @override
  DateTime? deserializeValue(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();

    if (value is String) {
      try {
        if (dateOnly) {
          // Parse date-only string and return as local midnight
          final parts = value.split('-');
          if (parts.length == 3) {
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final day = int.parse(parts[2]);
            return DateTime(year, month, day);
          }
          // Fallback to original method if parsing fails
          final date = DateTime.parse('${value}T00:00:00.000Z');
          return date.toLocal();
        } else if (timeOnly) {
          // Parse time-only string as today's date with that time
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          // Add 'Z' if not present for parsing
          final timeStr = value.contains('Z') ? value : '${value}Z';
          final time = DateTime.parse('1970-01-01T$timeStr');
          return DateTime(
            today.year,
            today.month,
            today.day,
            time.hour,
            time.minute,
            time.second,
            time.millisecond,
          );
        } else {
          // Parse full datetime and convert to local
          return DateTime.parse(value).toLocal();
        }
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  @override
  List<String> validateValue(DateTime? value) {
    final errors = <String>[];

    // Add any datetime-specific validation here
    // For example, future date validation, business hours, etc.

    return errors;
  }
}

/// Timestamp field with automatic creation/update
class TimestampField extends DateTimeField {
  /// Whether to automatically set value on creation
  final bool autoCreate;

  /// Whether to automatically update value on modification
  final bool autoUpdate;

  TimestampField({
    this.autoCreate = false,
    this.autoUpdate = false,
    super.dateOnly = false,
    super.timeOnly = false,
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  });

  /// Update timestamp if auto-update is enabled
  void touchIfAutoUpdate() {
    if (autoUpdate) {
      value = DateTime.now();
    }
  }

  /// Set timestamp if auto-create is enabled and value is null
  void touchIfAutoCreate() {
    if (autoCreate && value == null) {
      value = DateTime.now();
    }
  }
}

/// Date-only field (no time component)
class DateField extends DateTimeField {
  DateField({
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  }) : super(dateOnly: true);
}

/// Time-only field (no date component)
class TimeField extends DateTimeField {
  TimeField({
    super.required = false,
    super.defaultValue,
    super.unique = false,
    super.nullable = true,
    super.columnName,
    super.validationRules = const [],
  }) : super(timeOnly: true);
}
