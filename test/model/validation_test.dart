import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';
import '../fixtures/test_data.dart';

// Test model with validation mixin
class TestValidationUser extends Model<TestValidationUser>
    with ValidationMixin<TestValidationUser> {
  final _id = AutoIncrementField();
  final _name = StringField();
  final _email = StringField();
  final _age = IntField();
  final _phone = StringField();
  final _password = StringField();
  final _birthDate = DateTimeField();
  final _score = DoubleField();

  @override
  String get table => 'validation_users';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('email', _email);
    registerField('age', _age);
    registerField('phone', _phone);
    registerField('password', _password);
    registerField('birth_date', _birthDate);
    registerField('score', _score);
  }

  @override
  void initializeValidation() {
    // Field validations
    registerFieldValidation('name', [
      RequiredRule<String>(),
      MinLengthRule(2),
      MaxLengthRule(50),
    ]);

    registerFieldValidation('email', [RequiredRule<String>(), EmailRule()]);

    registerFieldValidation('age', [RangeRule<int>(min: 0, max: 120)]);

    registerFieldValidation('phone', [
      RegexRule(
        RegExp(r'^\+?[\d\s\-\(\)]+$'),
        customMessage: 'Invalid phone format',
      ),
    ]);

    registerFieldValidation('password', [
      RequiredRule<String>(),
      MinLengthRule(8),
      RegexRule(
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)'),
        customMessage: 'Password must contain uppercase, lowercase and digit',
      ),
    ]);

    registerFieldValidation('birth_date', [
      DateRangeRule(maxDate: DateTime.now()),
    ]);

    registerFieldValidation('score', [RangeRule<double>(min: 0.0, max: 100.0)]);

    // Model-level validation
    registerModelValidation([
      CustomRule<TestValidationUser>(
        (user) => user!.name?.toLowerCase() != 'admin',
        customMessage: 'Username cannot be admin',
      ),
    ]);
  }

  // Getters/setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get name => _name.value;
  set name(String? value) => _name.value = value;

  String? get email => _email.value;
  set email(String? value) => _email.value = value;

  int? get age => _age.value;
  set age(int? value) => _age.value = value;

  String? get phone => _phone.value;
  set phone(String? value) => _phone.value = value;

  String? get password => _password.value;
  set password(String? value) => _password.value = value;

  DateTime? get birthDate => _birthDate.value;
  set birthDate(DateTime? value) => _birthDate.value = value;

  double? get score => _score.value;
  set score(double? value) => _score.value = value;
}

void main() {
  group('Validation System Tests', () {
    group('ModelValidationResult Tests', () {
      test('should create valid result correctly', () {
        final result = ModelValidationResult(isValid: true);

        expect(result.isValid, isTrue);
        expect(result.fieldErrors, isEmpty);
        expect(result.generalErrors, isEmpty);
        expect(result.allErrors, isEmpty);
        expect(result.firstError, isNull);
      });

      test('should create invalid result with field errors', () {
        final result = ModelValidationResult(
          isValid: false,
          fieldErrors: {
            'name': ['Name is required'],
            'email': ['Invalid email format'],
          },
        );

        expect(result.isValid, isFalse);
        expect(result.fieldErrors, hasLength(2));
        expect(result.hasFieldError('name'), isTrue);
        expect(result.hasFieldError('email'), isTrue);
        expect(result.hasFieldError('age'), isFalse);
        expect(result.getFieldErrors('name'), contains('Name is required'));
        expect(
          result.getFirstFieldError('email'),
          equals('Invalid email format'),
        );
        expect(result.allErrors, hasLength(2));
        expect(result.firstError, isNotNull);
      });

      test('should create invalid result with general errors', () {
        final result = ModelValidationResult(
          isValid: false,
          generalErrors: ['Model-level validation failed', 'Another error'],
        );

        expect(result.isValid, isFalse);
        expect(result.generalErrors, hasLength(2));
        expect(result.allErrors, hasLength(2));
        expect(result.firstError, equals('Model-level validation failed'));
      });

      test('should combine multiple validation results', () {
        final result1 = ModelValidationResult(
          isValid: false,
          fieldErrors: {
            'name': ['Required'],
          },
          generalErrors: ['General error 1'],
        );

        final result2 = ModelValidationResult(
          isValid: false,
          fieldErrors: {
            'email': ['Invalid'],
            'name': ['Too short'],
          },
          generalErrors: ['General error 2'],
        );

        final combined = ModelValidationResult.combine([result1, result2]);

        expect(combined.isValid, isFalse);
        expect(combined.fieldErrors['name'], hasLength(2));
        expect(combined.fieldErrors['email'], hasLength(1));
        expect(combined.generalErrors, hasLength(2));
        expect(combined.allErrors, hasLength(5));
      });

      test('should handle toString formatting', () {
        final validResult = ModelValidationResult(isValid: true);
        expect(validResult.toString(), equals('ValidationResult(valid)'));

        final invalidResult = ModelValidationResult(
          isValid: false,
          fieldErrors: {
            'name': ['Required'],
          },
          generalErrors: ['General error'],
        );
        expect(
          invalidResult.toString(),
          contains('ValidationResult(invalid, 2 errors:'),
        );
      });
    });

    group('Validation Rules Tests', () {
      test('RequiredRule should validate correctly', () {
        final rule = RequiredRule<String>();

        expect(rule.validate(null), isFalse);
        expect(rule.validate(''), isFalse);
        expect(rule.validate('  '), isFalse);
        expect(rule.validate('value'), isTrue);
        expect(rule.message, equals('This field is required'));
        expect(rule.getMessageFor('name'), equals('name is required'));

        // Test with different types
        final listRule = RequiredRule<List>();
        expect(listRule.validate([]), isFalse);
        expect(listRule.validate([1, 2]), isTrue);

        final mapRule = RequiredRule<Map>();
        expect(mapRule.validate({}), isFalse);
        expect(mapRule.validate({'key': 'value'}), isTrue);
      });

      test('MinLengthRule should validate correctly', () {
        final rule = MinLengthRule(5);

        expect(rule.validate(null), isTrue);
        expect(rule.validate('abc'), isFalse);
        expect(rule.validate('abcde'), isTrue);
        expect(rule.validate('abcdef'), isTrue);
        expect(rule.message, equals('Must be at least 5 characters'));
        expect(
          rule.getMessageFor('password'),
          equals('password must be at least 5 characters'),
        );
      });

      test('MaxLengthRule should validate correctly', () {
        final rule = MaxLengthRule(10);

        expect(rule.validate(null), isTrue);
        expect(rule.validate('short'), isTrue);
        expect(rule.validate('exactly10c'), isTrue);
        expect(rule.validate('toolongstring'), isFalse);
        expect(rule.message, equals('Must be no more than 10 characters'));
        expect(
          rule.getMessageFor('name'),
          equals('name must be no more than 10 characters'),
        );
      });

      test('EmailRule should validate correctly', () {
        final rule = EmailRule();

        expect(rule.validate(null), isTrue);
        expect(rule.validate('invalid'), isFalse);
        expect(rule.validate('user@'), isFalse);
        expect(rule.validate('user@domain'), isFalse);
        expect(rule.validate('user@example.com'), isTrue);
        expect(rule.validate('user.name+tag@example.co.uk'), isTrue);
        expect(rule.validate('test123@sub.domain.org'), isTrue);
        expect(rule.message, equals('Must be a valid email address'));
        expect(
          rule.getMessageFor('email'),
          equals('email must be a valid email address'),
        );
      });

      test('RangeRule should validate numbers correctly', () {
        final rule = RangeRule<int>(min: 10, max: 100);

        expect(rule.validate(null), isTrue);
        expect(rule.validate(5), isFalse);
        expect(rule.validate(10), isTrue);
        expect(rule.validate(50), isTrue);
        expect(rule.validate(100), isTrue);
        expect(rule.validate(150), isFalse);
        expect(rule.message, equals('Must be between 10 and 100'));
        expect(
          rule.getMessageFor('age'),
          equals('age must be between 10 and 100'),
        );

        final minOnlyRule = RangeRule<double>(min: 0.0);
        expect(minOnlyRule.message, equals('Must be at least 0.0'));

        final maxOnlyRule = RangeRule<int>(max: 50);
        expect(maxOnlyRule.message, equals('Must be no more than 50'));
      });

      test('RegexRule should validate patterns correctly', () {
        final phoneRule = RegexRule(
          RegExp(r'^\+?[\d\s\-\(\)]+$'),
          customMessage: 'Invalid phone',
        );

        expect(phoneRule.validate(null), isTrue);
        expect(phoneRule.validate('abc'), isFalse);
        expect(phoneRule.validate('123-456-7890'), isTrue);
        expect(phoneRule.validate('+1 (555) 123-4567'), isTrue);
        expect(phoneRule.message, equals('Invalid phone'));
        expect(phoneRule.getMessageFor('phone'), equals('Invalid phone'));

        final defaultRule = RegexRule(RegExp(r'^\d+$'));
        expect(defaultRule.message, equals('Invalid format'));
      });

      test('DateRangeRule should validate dates correctly', () {
        final now = DateTime.now();
        final yesterday = now.subtract(Duration(days: 1));
        final tomorrow = now.add(Duration(days: 1));

        final rule = DateRangeRule(minDate: yesterday, maxDate: now);

        expect(rule.validate(null), isTrue);
        expect(rule.validate(yesterday.subtract(Duration(hours: 1))), isFalse);
        expect(rule.validate(yesterday), isTrue);
        expect(rule.validate(now), isTrue);
        expect(rule.validate(tomorrow), isFalse);

        final minOnlyRule = DateRangeRule(minDate: yesterday);
        expect(minOnlyRule.message, contains('Must be after'));

        final maxOnlyRule = DateRangeRule(maxDate: now);
        expect(maxOnlyRule.message, contains('Must be before'));
      });

      test('CustomRule should validate with custom logic', () {
        final rule = CustomRule<int>(
          (value) => value != null && value % 2 == 0,
          customMessage: 'Must be even number',
        );

        expect(rule.validate(null), isFalse);
        expect(rule.validate(3), isFalse);
        expect(rule.validate(4), isTrue);
        expect(rule.message, equals('Must be even number'));
      });
    });

    group('ValidationRegistry Tests', () {
      test('should register and retrieve field rules', () {
        final registry = ValidationRegistry();
        final rules = [RequiredRule<String>(), MinLengthRule(5)];

        registry.registerFieldRules('name', rules);

        expect(registry.hasFieldRules('name'), isTrue);
        expect(registry.hasFieldRules('email'), isFalse);
        expect(registry.getFieldRules('name'), hasLength(2));
        expect(registry.getFieldRules('email'), isEmpty);
        expect(registry.getValidatedFields(), contains('name'));
      });

      test('should add individual field rules', () {
        final registry = ValidationRegistry();

        registry.addFieldRule('name', RequiredRule<String>());
        registry.addFieldRule('name', MinLengthRule(3));
        registry.addFieldRule('email', EmailRule());

        expect(registry.getFieldRules('name'), hasLength(2));
        expect(registry.getFieldRules('email'), hasLength(1));
        expect(registry.getValidatedFields(), hasLength(2));
      });

      test('should register and retrieve model rules', () {
        final registry = ValidationRegistry();
        final rules = [
          CustomRule<dynamic>((model) => true, customMessage: 'Test rule'),
        ];

        registry.registerModelRules(rules);
        registry.addModelRule(
          CustomRule<dynamic>((model) => false, customMessage: 'Second rule'),
        );

        expect(registry.getModelRules(), hasLength(2));
      });

      test('should clear all rules', () {
        final registry = ValidationRegistry();

        registry.addFieldRule('name', RequiredRule<String>());
        registry.addModelRule(
          CustomRule<dynamic>((model) => true, customMessage: 'Test'),
        );

        expect(registry.getValidatedFields(), isNotEmpty);
        expect(registry.getModelRules(), isNotEmpty);

        registry.clear();

        expect(registry.getValidatedFields(), isEmpty);
        expect(registry.getModelRules(), isEmpty);
      });
    });

    group('ValidationMixin Tests', () {
      test('should initialize validation on model creation', () {
        final user = TestValidationUser();
        user.initializeValidation();

        expect(user.validationRegistry.hasFieldRules('name'), isTrue);
        expect(user.validationRegistry.hasFieldRules('email'), isTrue);
        expect(user.validationRegistry.getModelRules(), isNotEmpty);
      });

      test('should validate individual field rules', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Valid data
        user.name = 'John Doe';
        user.email = 'john@example.com';
        user.age = 30;
        user.phone = '+1-555-123-4567';
        user.password = 'SecurePass123';
        user.birthDate = DateTime(1990, 1, 1);
        user.score = 85.5;

        final result = user.validateModel();
        expect(result.isValid, isTrue);
        expect(result.allErrors, isEmpty);
      });

      test('should catch field validation errors', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Invalid data
        user.name = 'A'; // Too short
        user.email = 'invalid-email'; // Invalid format
        user.age = 150; // Too high
        user.phone = 'abc123'; // Invalid format
        user.password = 'weak'; // Too short, no uppercase/digit
        user.birthDate = DateTime.now().add(Duration(days: 1)); // Future date
        user.score = 150.0; // Too high

        final result = user.validateModel();
        expect(result.isValid, isFalse);
        expect(result.hasFieldError('name'), isTrue);
        expect(result.hasFieldError('email'), isTrue);
        expect(result.hasFieldError('age'), isTrue);
        expect(result.hasFieldError('phone'), isTrue);
        expect(result.hasFieldError('password'), isTrue);
        expect(result.hasFieldError('birth_date'), isTrue);
        expect(result.hasFieldError('score'), isTrue);
        expect(result.allErrors.length, greaterThan(7));
      });

      test('should catch model-level validation errors', () {
        final user = TestValidationUser();
        user.initializeValidation();

        user.name = 'admin'; // Should fail model-level validation
        user.email = 'admin@example.com';
        user.password = 'SecurePass123';

        final result = user.validateModel();
        expect(result.isValid, isFalse);
        expect(result.generalErrors, contains('Username cannot be admin'));
      });

      test('should validate required fields correctly', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Missing required fields
        final result = user.validateModel();
        expect(result.isValid, isFalse);
        expect(result.hasFieldError('name'), isTrue);
        expect(result.hasFieldError('email'), isTrue);
        expect(result.hasFieldError('password'), isTrue);
      });

      test('should validate complex password requirements', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Test various password combinations
        user.password = 'lowercase'; // Missing uppercase and digit
        var result = user.validateModel();
        expect(result.hasFieldError('password'), isTrue);

        user.password = 'UPPERCASE'; // Missing lowercase and digit
        result = user.validateModel();
        expect(result.hasFieldError('password'), isTrue);

        user.password = '12345678'; // Missing letters
        result = user.validateModel();
        expect(result.hasFieldError('password'), isTrue);

        user.password = 'ValidPass123'; // Should pass
        result = user.validateModel();
        expect(result.getFieldErrors('password'), isEmpty);
      });

      test('should handle null values in optional fields', () {
        final user = TestValidationUser();
        user.initializeValidation();

        user.name = 'John Doe';
        user.email = 'john@example.com';
        user.password = 'SecurePass123';
        // Leave optional fields null

        final result = user.validateModel();
        expect(result.isValid, isTrue);
      });

      test('should add validation rules dynamically', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Add additional validation rule
        user.addFieldValidation(
          'name',
          RegexRule(
            RegExp(r'^[A-Z]'),
            customMessage: 'Name must start with uppercase',
          ),
        );

        user.name = 'john'; // Starts with lowercase
        user.email = 'john@example.com';
        user.password = 'SecurePass123';

        final result = user.validateModel();
        expect(result.isValid, isFalse);
        expect(
          result.getFieldErrors('name'),
          contains('Name must start with uppercase'),
        );
      });
    });

    group('ModelValidationException Tests', () {
      test('should create exception from validation result', () {
        final result = ModelValidationResult(
          isValid: false,
          fieldErrors: {
            'name': ['Required'],
          },
          generalErrors: ['Model error'],
        );

        final exception = ModelValidationException(result);

        expect(exception.result, same(result));
        expect(exception.errors, hasLength(2));
        expect(exception.fieldErrors, hasLength(1));
        expect(exception.generalErrors, hasLength(1));
        expect(exception.firstError, equals('Model error'));
        expect(exception.toString(), contains('ModelValidationException'));
      });

      test('should handle empty error lists', () {
        final result = ModelValidationResult(isValid: false);
        final exception = ModelValidationException(result);

        expect(exception.errors, isEmpty);
        expect(exception.firstError, isNull);
        expect(
          exception.toString(),
          equals('ModelValidationException: Validation failed'),
        );
      });
    });

    group('ValidationMixin Integration Tests', () {
      test('should throw exception on validateOrThrow with invalid data', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Invalid data
        user.name = 'A';
        user.email = 'invalid';

        expect(
          () => user.validateOrThrow(),
          throwsA(isA<ModelValidationException>()),
        );
      });

      test('should not throw exception on validateOrThrow with valid data', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Valid data
        user.name = 'John Doe';
        user.email = 'john@example.com';
        user.password = 'SecurePass123';

        expect(() => user.validateOrThrow(), returnsNormally);
      });

      test('should validate edge cases correctly', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Test edge cases
        user.name = 'AB'; // Minimum length
        user.email = 'a@b.co'; // Short but valid email
        user.age = 0; // Minimum age
        user.password = 'Pass1234'; // Minimum requirements
        user.score = 0.0; // Minimum score

        final result = user.validateModel();
        expect(result.isValid, isTrue);

        // Test maximum edge cases
        user.name = 'A' * 50; // Maximum length
        user.age = 120; // Maximum age
        user.score = 100.0; // Maximum score

        final result2 = user.validateModel();
        expect(result2.isValid, isTrue);
      });

      test('should handle special characters in validation', () {
        final user = TestValidationUser();
        user.initializeValidation();

        user.name = 'José María';
        user.email = 'jose@domain.com';
        user.password = 'Contraseña123';
        user.phone = '+34 (91) 123-4567';

        final result = user.validateModel();
        expect(result.isValid, isTrue);
      });
    });

    group('Test Data Helpers Demonstration', () {
      test('should validate with predefined test data', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Use test data for valid user
        final validData = TestData.validUserData;
        user.name = validData['name'];
        user.email = validData['email'];
        user.password = validData['password'];

        final result = user.validateModel();
        expect(result.isValid, isTrue);
      });

      test('should validate with invalid test data', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Use test data for invalid user
        final invalidData = TestData.invalidUserData;
        user.name = invalidData['name']; // Too short
        user.email = invalidData['email']; // Invalid format
        user.password = invalidData['password']; // Empty

        final result = user.validateModel();
        expect(result.isValid, isFalse);
        expect(result.hasFieldError('name'), isTrue);
        expect(result.hasFieldError('email'), isTrue);
        expect(result.hasFieldError('password'), isTrue);
      });

      test('should validate with validation test data scenarios', () {
        final testCases = TestData.validationTestData['users'];

        // Test missing required field
        final user1 = TestValidationUser();
        user1.initializeValidation();
        final missingRequiredData = testCases['missing_required_field'];
        user1.email = missingRequiredData['email'];
        user1.password = missingRequiredData['password'];
        // Note: missing name field

        final result1 = user1.validateModel();
        expect(result1.isValid, isFalse);
        expect(result1.hasFieldError('name'), isTrue);

        // Test invalid email format
        final user2 = TestValidationUser();
        user2.initializeValidation();
        final invalidEmailData = testCases['invalid_email_format'];
        user2.name = invalidEmailData['name'];
        user2.email = invalidEmailData['email'];
        user2.password = invalidEmailData['password'];

        final result2 = user2.validateModel();
        expect(result2.isValid, isFalse);
        expect(result2.hasFieldError('email'), isTrue);

        // Test name too short
        final user3 = TestValidationUser();
        user3.initializeValidation();
        final nameShortData = testCases['name_too_short'];
        user3.name = nameShortData['name'];
        user3.email = nameShortData['email'];
        user3.password = nameShortData['password'];

        final result3 = user3.validateModel();
        expect(result3.isValid, isFalse);
        expect(result3.hasFieldError('name'), isTrue);

        // Test name too long
        final user4 = TestValidationUser();
        user4.initializeValidation();
        final nameLongData = testCases['name_too_long'];
        user4.name = nameLongData['name'];
        user4.email = nameLongData['email'];
        user4.password = nameLongData['password'];

        final result4 = user4.validateModel();
        expect(result4.isValid, isFalse);
        expect(result4.hasFieldError('name'), isTrue);
      });

      test('should handle unicode validation with test data', () {
        final user = TestValidationUser();
        user.initializeValidation();

        // Use Unicode test data
        final unicodeData = TestData.unicodeUserData;
        user.name = unicodeData['name'];
        user.email = unicodeData['email'];
        user.password = unicodeData['password'];

        final result = user.validateModel();
        expect(result.isValid, isTrue);

        // Verify Unicode characters are handled correctly
        expect(user.name, contains('José'));
        expect(user.name, contains('María'));
        expect(user.email, contains('é'));
      });
    });
  });
}
