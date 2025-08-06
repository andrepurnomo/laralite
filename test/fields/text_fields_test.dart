import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

void main() {
  group('Text Fields Tests', () {
    
    group('StringField Tests', () {
      test('should generate VARCHAR or TEXT SQL type', () {
        final field1 = StringField(maxLength: 255);
        expect(field1.getSqlType(), equals('VARCHAR(255)'));
        
        final field2 = StringField();
        expect(field2.getSqlType(), equals('TEXT'));
      });
      
      test('should handle length validation', () {
        final field = StringField(minLength: 3, maxLength: 10);
        
        field.value = 'ab';
        var result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Minimum length is 3 characters'));
        
        field.value = 'abcdefghijk';
        result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Maximum length is 10 characters'));
        
        field.value = 'valid';
        result = field.validate();
        expect(result.isValid, isTrue);
      });
      
      test('should escape single quotes in SQL', () {
        final field = StringField();
        
        expect(field.serializeValue("test"), equals("'test'"));
        expect(field.serializeValue("test's value"), equals("'test''s value'"));
        expect(field.serializeValue(null), equals('NULL'));
      });
      
      test('should handle pattern validation', () {
        final field = StringField(pattern: RegExp(r'^\d+$')); // Numbers only
        
        field.value = 'abc123';
        var result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Value does not match required pattern'));
        
        field.value = '12345';
        result = field.validate();
        expect(result.isValid, isTrue);
      });
    });
    
    group('TextField Tests', () {
      test('should always use TEXT SQL type for large content', () {
        final field = TextField();
        expect(field.getSqlType(), equals('TEXT'));
      });
      
      test('should handle basic string storage', () {
        final field = TextField();
        
        field.value = 'This is a long text content that can be stored in a TEXT field';
        expect(field.value, equals('This is a long text content that can be stored in a TEXT field'));
        
        var result = field.validate();
        expect(result.isValid, isTrue);
      });
    });
    
    group('EmailField Tests', () {
      test('should validate email format', () {
        final field = EmailField();
        
        field.value = 'invalid-email';
        var result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Please enter a valid email address'));
        
        field.value = 'user@example.com';
        result = field.validate();
        expect(result.isValid, isTrue);
        
        field.value = 'user.name+tag@example.co.uk';
        result = field.validate();
        expect(result.isValid, isTrue);
      });
    });
    
    group('UrlField Tests', () {
      test('should validate URL format', () {
        final field = UrlField();
        
        field.value = 'not-a-url';
        var result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Please enter a valid URL'));
        
        field.value = 'https://example.com';
        result = field.validate();
        expect(result.isValid, isTrue);
        
        field.value = 'http://www.example.com/path?query=value';
        result = field.validate();
        expect(result.isValid, isTrue);
      });
    });
    
    group('BlobField Tests', () {
      test('should handle binary data', () {
        final field = BlobField();
        
        expect(field.getSqlType(), equals('BLOB'));
        
        final data = [0x48, 0x65, 0x6C, 0x6C, 0x6F]; // "Hello" in bytes
        final serialized = field.serializeValue(data);
        
        expect(serialized.toUpperCase(), equals("X'48656C6C6F'"));
        
        final deserialized = field.deserializeValue('48656C6C6F');
        expect(deserialized, equals(data));
      });
      
      test('should validate max size', () {
        final field = BlobField(maxSize: 5);
        
        field.value = [1, 2, 3, 4, 5, 6]; // 6 bytes
        var result = field.validate();
        expect(result.isValid, isFalse);
        expect(result.errors, contains('Maximum size is 5 bytes'));
        
        field.value = [1, 2, 3]; // 3 bytes
        result = field.validate();
        expect(result.isValid, isTrue);
      });
    });
  });
}
