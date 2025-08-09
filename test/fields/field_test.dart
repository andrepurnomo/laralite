import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

void main() {
  group('Base Field System Tests', () {
    group('Base Field Tests', () {
      test('should handle value assignment and dirty tracking', () {
        final field = IntField();

        // Initial state
        expect(field.value, isNull);
        expect(field.isDirty, isFalse);
        expect(field.isLoaded, isFalse);

        // Set value
        field.value = 42;
        expect(field.value, equals(42));
        expect(field.isDirty, isTrue);

        // Mark clean
        field.markClean();
        expect(field.isDirty, isFalse);

        // Mark loaded
        field.markLoaded();
        expect(field.isLoaded, isTrue);
      });

      test('should handle reset functionality', () {
        final field = IntField(defaultValue: 100);

        field.value = 42;
        field.markClean();
        field.markLoaded();

        field.reset();

        expect(field.value, equals(100));
        expect(field.isDirty, isFalse);
        expect(field.isLoaded, isFalse);
      });

      test('should detect value changes correctly', () {
        final field = StringField();

        field.value = 'test';
        field.markClean();

        // Same value shouldn't mark dirty
        field.value = 'test';
        expect(field.isDirty, isFalse);

        // Different value should mark dirty
        field.value = 'changed';
        expect(field.isDirty, isTrue);
      });
    });

    group('Validation Rules Tests', () {
      test('RequiredRule should validate correctly', () {
        final rule = RequiredRule<String>();

        expect(rule.validate(null), isFalse);
        expect(rule.validate(''), isFalse);
        expect(rule.validate('value'), isTrue);
      });

      test('MinLengthRule should validate correctly', () {
        final rule = MinLengthRule(5);

        expect(rule.validate(null), isTrue); // Let required rule handle null
        expect(rule.validate('abc'), isFalse);
        expect(rule.validate('abcdef'), isTrue);
      });

      test('MaxLengthRule should validate correctly', () {
        final rule = MaxLengthRule(5);

        expect(rule.validate(null), isTrue);
        expect(rule.validate('abcdef'), isFalse);
        expect(rule.validate('abc'), isTrue);
      });

      test('MinValueRule should validate correctly', () {
        final rule = MinValueRule<int>(10);

        expect(rule.validate(null), isTrue);
        expect(rule.validate(5), isFalse);
        expect(rule.validate(15), isTrue);
      });

      test('MaxValueRule should validate correctly', () {
        final rule = MaxValueRule<int>(100);

        expect(rule.validate(null), isTrue);
        expect(rule.validate(150), isFalse);
        expect(rule.validate(50), isTrue);
      });
    });

    group('Field Debug Information Tests', () {
      test('should provide comprehensive debug information', () {
        final field = StringField(
          required: true,
          maxLength: 100,
          unique: true,
          defaultValue: 'default',
        );

        field.value = 'test value';

        final debugMap = field.toDebugMap();

        expect(debugMap['type'], equals('StringField'));
        expect(debugMap['value'], equals('test value'));
        expect(debugMap['required'], isTrue);
        expect(debugMap['unique'], isTrue);
        expect(debugMap['defaultValue'], equals('default'));
        expect(debugMap['isDirty'], isTrue);
        expect(debugMap['sqlType'], equals('VARCHAR(100)'));
        expect(debugMap['constraints'], isA<List<String>>());
      });
    });
  });
}
