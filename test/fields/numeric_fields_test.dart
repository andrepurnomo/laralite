import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

void main() {
  group('Numeric Fields Tests', () {
    
    group('AutoIncrementField Tests', () {
      test('should generate correct SQL type and constraints', () {
        final field = AutoIncrementField();
        
        expect(field.getSqlType(), equals('INTEGER PRIMARY KEY AUTOINCREMENT'));
        expect(field.getSqlConstraints(), isEmpty);
        expect(field.required, isFalse);
        expect(field.nullable, isFalse);
        expect(field.unique, isTrue);
      });
      
      test('should serialize and deserialize integer values', () {
        final field = AutoIncrementField();
        
        expect(field.serializeValue(42), equals('42'));
        expect(field.serializeValue(null), equals('NULL'));
        
        expect(field.deserializeValue(42), equals(42));
        expect(field.deserializeValue('42'), equals(42));
        expect(field.deserializeValue(42.7), equals(42));
        expect(field.deserializeValue(null), isNull);
      });
    });
    
    group('IntField Tests', () {
      test('should generate correct SQL type', () {
        final field = IntField();
        expect(field.getSqlType(), equals('INTEGER'));
      });
      
      test('should handle min/max validation', () {
        final field = IntField(min: 10, max: 100);
        
        field.value = 5;
        var result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Value must be at least 10'));
        
        field.value = 150;
        result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Value must be at most 100'));
        
        field.value = 50;
        result = field.validate();
        expect(result.isValid, isTrue);
      });
      
      test('should handle required validation', () {
        final field = IntField(required: true);
        
        var result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('This field is required'));
        
        field.value = 42;
        result = field.validate();
        expect(result.isValid, isTrue);
      });
      
      test('should serialize and deserialize correctly', () {
        final field = IntField();
        
        expect(field.serializeValue(42), equals('42'));
        expect(field.serializeValue(null), equals('NULL'));
        
        expect(field.deserializeValue(42), equals(42));
        expect(field.deserializeValue('42'), equals(42));
        expect(field.deserializeValue(42.7), equals(42));
        expect(field.deserializeValue(null), isNull);
      });
    });
    
    group('DoubleField Tests', () {
      test('should generate correct SQL type', () {
        final field = DoubleField();
        expect(field.getSqlType(), equals('REAL'));
      });
      
      test('should handle decimal places formatting', () {
        final field = DoubleField(decimalPlaces: 2);
        
        expect(field.serializeValue(3.14159), equals('3.14'));
        expect(field.serializeValue(10.0), equals('10.00'));
        expect(field.serializeValue(null), equals('NULL'));
      });
      
      test('should handle min/max validation', () {
        final field = DoubleField(min: 0.0, max: 100.5);
        
        field.value = -1.0;
        var result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Value must be at least 0.0'));
        
        field.value = 101.0;
        result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Value must be at most 100.5'));
        
        field.value = 50.5;
        result = field.validate();
        expect(result.isValid, isTrue);
      });
      
      test('should deserialize numeric values correctly', () {
        final field = DoubleField();
        
        expect(field.deserializeValue(3.14), equals(3.14));
        expect(field.deserializeValue(42), equals(42.0));
        expect(field.deserializeValue('3.14'), equals(3.14));
        expect(field.deserializeValue(null), isNull);
      });
    });
    
    group('BoolField Tests', () {
      test('should use INTEGER SQL type for SQLite compatibility', () {
        final field = BoolField();
        expect(field.getSqlType(), equals('INTEGER'));
      });
      
      test('should serialize booleans as 0/1', () {
        final field = BoolField();
        
        expect(field.serializeValue(true), equals('1'));
        expect(field.serializeValue(false), equals('0'));
        expect(field.serializeValue(null), equals('NULL'));
      });
      
      test('should deserialize various formats to boolean', () {
        final field = BoolField();
        
        expect(field.deserializeValue(true), isTrue);
        expect(field.deserializeValue(false), isFalse);
        expect(field.deserializeValue(1), isTrue);
        expect(field.deserializeValue(0), isFalse);
        expect(field.deserializeValue('1'), isTrue);
        expect(field.deserializeValue('0'), isFalse);
        expect(field.deserializeValue('true'), isTrue);
        expect(field.deserializeValue('false'), isFalse);
        expect(field.deserializeValue(null), isNull);
      });
    });
  });
}
