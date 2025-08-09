import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

void main() {
  group('Special Fields Tests', () {
    group('JsonField Tests', () {
      test('should serialize and deserialize JSON data', () {
        final field = JsonField<Map<String, dynamic>>();

        final data = {'name': 'John', 'age': 30, 'active': true};
        final serialized = field.serializeValue(data);

        expect(serialized, contains('John'));
        expect(serialized, startsWith("'"));
        expect(serialized, endsWith("'"));

        // Remove quotes for deserialization test
        final jsonString = serialized.substring(1, serialized.length - 1);
        final deserialized = field.deserializeValue(jsonString);

        expect(deserialized, equals(data));
      });

      test('should validate JSON serializability', () {
        final field = JsonField<dynamic>();

        // Valid JSON data
        field.value = {'key': 'value'};
        var result = field.validate();
        expect(result.isValid, isTrue);

        // Note: In Dart, most objects are JSON-serializable by default
        // Complex validation would require custom objects that throw on jsonEncode
      });
    });

    group('EnumField Tests', () {
      test('should handle enum values correctly', () {
        final field = EnumField<TestEnum>(enumValues: TestEnum.values);

        field.value = TestEnum.first;
        expect(field.value, equals(TestEnum.first));

        final serialized = field.serializeValue(TestEnum.second);
        expect(serialized, equals("'second'"));

        final deserialized = field.deserializeValue('first');
        expect(deserialized, equals(TestEnum.first));
      });

      test('should validate enum values', () {
        final field = EnumField<TestEnum>(enumValues: TestEnum.values);

        field.value = TestEnum.first;
        var result = field.validate();
        expect(result.isValid, isTrue);

        // Direct enum assignment is type-safe, so invalid values
        // would be caught at compile time
      });
    });

    group('ForeignKeyField Tests', () {
      test('should generate correct SQL constraints', () {
        final field = ForeignKeyField(
          referencedTable: 'users',
          referencedColumn: 'id',
          onUpdate: ForeignKeyAction.cascade,
          onDelete: ForeignKeyAction.setNull,
        );

        expect(field.getSqlType(), equals('INTEGER'));

        final constraints = field.getSqlConstraints();
        final foreignKeyConstraint = constraints.firstWhere(
          (c) => c.contains('REFERENCES'),
        );

        expect(foreignKeyConstraint, contains('REFERENCES users(id)'));
        expect(foreignKeyConstraint, contains('ON UPDATE CASCADE'));
        expect(foreignKeyConstraint, contains('ON DELETE SET NULL'));
      });
    });

    group('UuidField Tests', () {
      test('should validate UUID format', () {
        final field = UuidField();

        field.value = 'not-a-uuid';
        var result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Please enter a valid UUID'));

        field.value = '550e8400-e29b-41d4-a716-446655440000';
        result = field.validate();
        expect(result.isValid, isTrue);

        // Test case insensitive
        field.value = '550E8400-E29B-41D4-A716-446655440000';
        result = field.validate();
        expect(result.isValid, isTrue);
      });

      test('should have correct constraints', () {
        final field = UuidField();

        expect(field.unique, isTrue);
        expect(field.maxLength, equals(36));
      });
    });
  });
}

// Test enum for EnumField tests
enum TestEnum { first, second, third }
