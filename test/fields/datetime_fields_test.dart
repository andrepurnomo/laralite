import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

void main() {
  group('DateTime Fields Tests', () {
    group('DateTimeField Tests', () {
      test('should use TEXT SQL type for ISO 8601 storage', () {
        final field = DateTimeField();
        expect(field.getSqlType(), equals('TEXT'));
      });

      test('should serialize DateTime to UTC ISO 8601', () {
        final field = DateTimeField();
        final dateTime = DateTime(2023, 12, 25, 15, 30, 45);

        final serialized = field.serializeValue(dateTime);
        expect(serialized, contains('2023-12-25'));
        expect(serialized, startsWith("'"));
        expect(serialized, endsWith("'"));
      });

      test('should deserialize to local DateTime', () {
        final field = DateTimeField();
        final isoString = '2023-12-25T15:30:45.000Z';

        final deserialized = field.deserializeValue(isoString);
        expect(deserialized, isA<DateTime>());
        expect(deserialized!.year, equals(2023));
        expect(deserialized.month, equals(12));
        expect(deserialized.day, equals(25));
      });

      test('should handle date-only mode', () {
        final field = DateTimeField(dateOnly: true);
        final dateTime = DateTime(2023, 12, 25, 15, 30, 45);

        final serialized = field.serializeValue(dateTime);
        expect(serialized, equals("'2023-12-25'"));

        final deserialized = field.deserializeValue('2023-12-25');
        expect(deserialized!.year, equals(2023));
        expect(deserialized.month, equals(12));
        expect(deserialized.day, equals(25));
      });

      test('should handle time-only mode', () {
        final field = DateTimeField(timeOnly: true);
        final dateTime = DateTime(2023, 12, 25, 15, 30, 45);

        final serialized = field.serializeValue(dateTime);
        expect(serialized, equals("'15:30:45.000'"));

        final deserialized = field.deserializeValue('15:30:45.000');
        expect(deserialized!.hour, equals(15));
        expect(deserialized.minute, equals(30));
        expect(deserialized.second, equals(45));
      });
    });

    group('TimestampField Tests', () {
      test('should have auto-create and auto-update functionality', () async {
        final field = TimestampField(autoCreate: true, autoUpdate: true);

        expect(field.autoCreate, isTrue);
        expect(field.autoUpdate, isTrue);

        // Test auto-create
        field.touchIfAutoCreate();
        expect(field.value, isNotNull);

        final firstValue = field.value;

        // Small delay to ensure different timestamp
        await Future.delayed(Duration(milliseconds: 10));

        // Test auto-update
        field.touchIfAutoUpdate();
        expect(field.value, isNot(equals(firstValue)));
      });
    });

    group('DateField Tests', () {
      test('should be date-only DateTimeField', () {
        final field = DateField();
        expect(field.dateOnly, isTrue);
        expect(field.timeOnly, isFalse);
      });

      test('should serialize only date portion', () {
        final field = DateField();
        final dateTime = DateTime(2023, 12, 25, 15, 30, 45);

        final serialized = field.serializeValue(dateTime);
        expect(serialized, equals("'2023-12-25'"));
      });
    });

    group('TimeField Tests', () {
      test('should be time-only DateTimeField', () {
        final field = TimeField();
        expect(field.timeOnly, isTrue);
        expect(field.dateOnly, isFalse);
      });

      test('should serialize only time portion', () {
        final field = TimeField();
        final dateTime = DateTime(2023, 12, 25, 15, 30, 45);

        final serialized = field.serializeValue(dateTime);
        expect(serialized, equals("'15:30:45.000'"));
      });
    });
  });
}
