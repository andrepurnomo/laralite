import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

// Test model with mutators and accessors
class TestMutatorUser extends Model<TestMutatorUser>
    with MutatorAccessorMixin<TestMutatorUser> {
  final _id = AutoIncrementField();
  final _name = StringField();
  final _email = StringField();
  final _phone = StringField();
  final _password = StringField();
  final _firstName = StringField();
  final _lastName = StringField();
  final _creditCard = StringField();
  final _price =
      IntField(); // Changed to IntField since DollarsToCentsMutator outputs int
  final _birthDate = DateTimeField();
  final _score = DoubleField();
  final _description = StringField();
  final _title = StringField();
  final _website = StringField();

  @override
  String get table => 'mutator_users';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('email', _email);
    registerField('phone', _phone);
    registerField('password', _password);
    registerField('first_name', _firstName);
    registerField('last_name', _lastName);
    registerField('credit_card', _creditCard);
    registerField('price', _price);
    registerField('birth_date', _birthDate);
    registerField('score', _score);
    registerField('description', _description);
    registerField('title', _title);
    registerField('website', _website);
  }

  @override
  void initializeMutatorAccessors() {
    // Register mutators
    registerMutator('password', PasswordMutator());
    registerMutator('email', EmailMutator());
    registerMutator('phone', PhoneMutator());
    registerMutator('name', CapitalizeMutator());
    registerMutator('description', TrimMutator());
    registerMutator('title', UppercaseMutator());
    registerMutator('website', LowercaseMutator());
    registerMutator('price', DollarsToCentsMutator());

    // Register accessors
    registerAccessor('price', _CentsToCurrencyAccessor());
    registerAccessor('birth_date', DateAccessor());
    registerAccessor(
      'credit_card',
      MaskAccessor(visibleStart: 0, visibleEnd: 4),
    );
    registerAccessor('score', CurrencyAccessor(symbol: '', decimals: 1));
  }

  // Getters/setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get name => _name.value;
  set name(String? value) => setValue('name', value);

  String? get email => _email.value;
  set email(String? value) => setValue('email', value);

  String? get phone => _phone.value;
  set phone(String? value) => setValue('phone', value);

  String? get password => _password.value;
  set password(String? value) => setValue('password', value);

  String? get firstName => _firstName.value;
  set firstName(String? value) => setValue('first_name', value);

  String? get lastName => _lastName.value;
  set lastName(String? value) => setValue('last_name', value);

  String? get creditCard => _creditCard.value;
  set creditCard(String? value) => setValue('credit_card', value);

  // Price field raw value (stored in cents)
  int? get priceInCents => _price.value;
  set priceInCents(int? value) => _price.value = value;

  // Price setter that accepts dollars and converts to cents through mutator
  set price(double? value) => setValue('price', value);

  DateTime? get birthDate => _birthDate.value;
  set birthDate(DateTime? value) => setValue('birth_date', value);

  double? get score => _score.value;
  set score(double? value) => setValue('score', value);

  String? get description => _description.value;
  set description(String? value) => setValue('description', value);

  String? get title => _title.value;
  set title(String? value) => setValue('title', value);

  String? get website => _website.value;
  set website(String? value) => setValue('website', value);

  // Convenience methods for testing accessors
  String? getFormattedPrice() => getValueWithAccessor<String>('price');
  String? getFormattedBirthDate() => getValueWithAccessor<String>('birth_date');
  String? getMaskedCreditCard() => getValueWithAccessor<String>('credit_card');
  String? getFormattedScore() => getValueWithAccessor<String>('score');

  // Convenience method for getting full name
  String getFullName() {
    final fullNameAccessor = FullNameAccessor();
    return fullNameAccessor.access({'first': firstName, 'last': lastName});
  }

  String getInitials() {
    final initialsAccessor = InitialsAccessor();
    return initialsAccessor.access({'first': firstName, 'last': lastName});
  }
}

void main() {
  group('Mutators and Accessors System Tests', () {
    group('Built-in Mutators Tests', () {
      test('PasswordMutator should hash passwords', () {
        final mutator = PasswordMutator();

        final result1 = mutator.mutate('password123');
        final result2 = mutator.mutate('password123');
        final result3 = mutator.mutate('different');

        expect(result1, startsWith('hashed_'));
        expect(result1, equals(result2)); // Same input should give same hash
        expect(
          result1,
          isNot(equals(result3)),
        ); // Different input should give different hash
        expect(result1, contains('hashed_')); // Should contain prefix
      });

      test('EmailMutator should normalize email addresses', () {
        final mutator = EmailMutator();

        expect(mutator.mutate('USER@EXAMPLE.COM'), equals('user@example.com'));
        expect(
          mutator.mutate('  user@example.com  '),
          equals('user@example.com'),
        );
        expect(
          mutator.mutate('User.Name@Domain.Com'),
          equals('user.name@domain.com'),
        );
        expect(
          mutator.mutate('test+label@sub.domain.org'),
          equals('test+label@sub.domain.org'),
        );
      });

      test('PhoneMutator should remove non-digits', () {
        final mutator = PhoneMutator();

        expect(mutator.mutate('+1 (555) 123-4567'), equals('15551234567'));
        expect(mutator.mutate('555-123-4567'), equals('5551234567'));
        expect(mutator.mutate('555.123.4567'), equals('5551234567'));
        expect(mutator.mutate('+44 20 1234 5678'), equals('442012345678'));
        expect(mutator.mutate('abc123def456'), equals('123456'));
      });

      test('CapitalizeMutator should capitalize words', () {
        final mutator = CapitalizeMutator();

        expect(mutator.mutate('john doe'), equals('John Doe'));
        expect(mutator.mutate('MARY JANE'), equals('Mary Jane'));
        expect(mutator.mutate('josé maría'), equals('José María'));
        expect(
          mutator.mutate('  spaced  words  '),
          equals('  Spaced  Words  '),
        );
        expect(mutator.mutate('single'), equals('Single'));
        expect(mutator.mutate(''), equals(''));
      });

      test('UppercaseMutator should convert to uppercase', () {
        final mutator = UppercaseMutator();

        expect(mutator.mutate('hello world'), equals('HELLO WORLD'));
        expect(mutator.mutate('Mixed CaSe'), equals('MIXED CASE'));
        expect(mutator.mutate('123abc'), equals('123ABC'));
        expect(mutator.mutate(''), equals(''));
        expect(mutator.mutate('ALREADY UPPER'), equals('ALREADY UPPER'));
      });

      test('LowercaseMutator should convert to lowercase', () {
        final mutator = LowercaseMutator();

        expect(mutator.mutate('HELLO WORLD'), equals('hello world'));
        expect(mutator.mutate('Mixed CaSe'), equals('mixed case'));
        expect(mutator.mutate('123ABC'), equals('123abc'));
        expect(mutator.mutate(''), equals(''));
        expect(mutator.mutate('already lower'), equals('already lower'));
      });

      test('TrimMutator should remove whitespace', () {
        final mutator = TrimMutator();

        expect(mutator.mutate('  hello world  '), equals('hello world'));
        expect(mutator.mutate('\n\ttext\n\t'), equals('text'));
        expect(mutator.mutate('   '), equals(''));
        expect(mutator.mutate('no spaces'), equals('no spaces'));
        expect(mutator.mutate(''), equals(''));
      });

      test('CentsToDollarsMutator should convert cents to dollars', () {
        final mutator = CentsToDollarsMutator();

        expect(mutator.mutate(100), equals(1.0));
        expect(mutator.mutate(2550), equals(25.5));
        expect(mutator.mutate(0), equals(0.0));
        expect(mutator.mutate(1), equals(0.01));
        expect(mutator.mutate(999), equals(9.99));
      });

      test('DollarsToCentsMutator should convert dollars to cents', () {
        final mutator = DollarsToCentsMutator();

        expect(mutator.mutate(1.0), equals(100));
        expect(mutator.mutate(25.5), equals(2550));
        expect(mutator.mutate(0.0), equals(0));
        expect(mutator.mutate(0.01), equals(1));
        expect(mutator.mutate(9.99), equals(999));
        expect(mutator.mutate(1.234), equals(123)); // Should round
      });
    });

    group('Built-in Accessors Tests', () {
      test('CurrencyAccessor should format currency values', () {
        final accessor = CurrencyAccessor();

        expect(accessor.access(1.0), equals('\$1.00'));
        expect(accessor.access(25.5), equals('\$25.50'));
        expect(accessor.access(0.0), equals('\$0.00'));
        expect(accessor.access(999.99), equals('\$999.99'));

        final euroAccessor = CurrencyAccessor(symbol: '€', decimals: 3);
        expect(euroAccessor.access(1.0), equals('€1.000'));
        expect(euroAccessor.access(25.567), equals('€25.567'));

        final noSymbolAccessor = CurrencyAccessor(symbol: '', decimals: 1);
        expect(noSymbolAccessor.access(1.0), equals('1.0'));
      });

      test('DateAccessor should format dates correctly', () {
        final date = DateTime(2023, 12, 25, 14, 30, 45);

        final defaultAccessor = DateAccessor();
        expect(defaultAccessor.access(date), equals('2023-12-25'));

        final usAccessor = DateAccessor(format: 'MM/dd/yyyy');
        expect(usAccessor.access(date), equals('12/25/2023'));

        final euAccessor = DateAccessor(format: 'dd/MM/yyyy');
        expect(euAccessor.access(date), equals('25/12/2023'));

        final customAccessor = DateAccessor(format: 'custom');
        expect(customAccessor.access(date), equals(date.toString()));

        // Test padding
        final earlyDate = DateTime(2023, 1, 5);
        expect(defaultAccessor.access(earlyDate), equals('2023-01-05'));
        expect(usAccessor.access(earlyDate), equals('01/05/2023'));
      });

      test('FullNameAccessor should combine names', () {
        final accessor = FullNameAccessor();

        expect(
          accessor.access({'first': 'John', 'last': 'Doe'}),
          equals('John Doe'),
        );
        expect(
          accessor.access({'first': 'Mary', 'last': null}),
          equals('Mary'),
        );
        expect(
          accessor.access({'first': null, 'last': 'Smith'}),
          equals('Smith'),
        );
        expect(accessor.access({'first': null, 'last': null}), equals(''));
        expect(accessor.access({'first': '', 'last': ''}), equals(''));
        expect(
          accessor.access({'first': 'Madonna', 'last': ''}),
          equals('Madonna'),
        );
      });

      test('InitialsAccessor should extract initials', () {
        final accessor = InitialsAccessor();

        expect(accessor.access({'first': 'John', 'last': 'Doe'}), equals('JD'));
        expect(
          accessor.access({'first': 'mary', 'last': 'jane'}),
          equals('MJ'),
        );
        expect(accessor.access({'first': 'John', 'last': null}), equals('J'));
        expect(accessor.access({'first': null, 'last': 'Smith'}), equals('S'));
        expect(accessor.access({'first': null, 'last': null}), equals(''));
        expect(accessor.access({'first': '', 'last': ''}), equals(''));
        expect(accessor.access({'first': 'A', 'last': 'B'}), equals('AB'));
      });

      test('MaskAccessor should mask sensitive data', () {
        final defaultAccessor = MaskAccessor();

        expect(
          defaultAccessor.access('1234567890123456'),
          equals('************3456'),
        );
        expect(
          defaultAccessor.access('abcd'),
          equals('abcd'),
        ); // Too short to mask (4 chars = visibleStart 0 + visibleEnd 4)
        expect(
          defaultAccessor.access('1234'),
          equals('1234'),
        ); // Exactly at threshold

        final customAccessor = MaskAccessor(
          visibleStart: 2,
          visibleEnd: 2,
          maskChar: '#',
        );
        expect(customAccessor.access('1234567890'), equals('12######90'));
        expect(customAccessor.access('123'), equals('123')); // Too short

        final startOnlyAccessor = MaskAccessor(visibleStart: 4, visibleEnd: 0);
        expect(startOnlyAccessor.access('1234567890'), equals('1234******'));

        final endOnlyAccessor = MaskAccessor(visibleStart: 0, visibleEnd: 4);
        expect(endOnlyAccessor.access('1234567890'), equals('******7890'));
      });
    });

    group('MutatorAccessorRegistry Tests', () {
      test('should register and retrieve mutators', () {
        final registry = MutatorAccessorRegistry();
        final mutator = EmailMutator();

        expect(registry.hasMutator('email'), isFalse);

        registry.registerMutator('email', mutator);

        expect(registry.hasMutator('email'), isTrue);
        expect(registry.getMutator('email'), same(mutator));
        expect(registry.getMutatorFields(), contains('email'));
      });

      test('should register and retrieve accessors', () {
        final registry = MutatorAccessorRegistry();
        final accessor = CurrencyAccessor();

        expect(registry.hasAccessor('price'), isFalse);

        registry.registerAccessor('price', accessor);

        expect(registry.hasAccessor('price'), isTrue);
        expect(registry.getAccessor('price'), same(accessor));
        expect(registry.getAccessorFields(), contains('price'));
      });

      test('should apply mutators to values', () {
        final registry = MutatorAccessorRegistry();
        registry.registerMutator('email', EmailMutator());

        expect(
          registry.applyMutator('email', 'USER@EXAMPLE.COM'),
          equals('user@example.com'),
        );
        expect(
          registry.applyMutator('name', 'John Doe'),
          equals('John Doe'),
        ); // No mutator
        expect(registry.applyMutator('email', null), isNull);
      });

      test('should apply accessors to values', () {
        final registry = MutatorAccessorRegistry();
        registry.registerAccessor('price', CurrencyAccessor());

        expect(registry.applyAccessor('price', 25.50), equals('\$25.50'));
        expect(
          registry.applyAccessor('name', 'John Doe'),
          equals('John Doe'),
        ); // No accessor
        expect(registry.applyAccessor('price', null), isNull);
      });

      test('should clear all registrations', () {
        final registry = MutatorAccessorRegistry();
        registry.registerMutator('email', EmailMutator());
        registry.registerAccessor('price', CurrencyAccessor());

        expect(registry.getMutatorFields(), isNotEmpty);
        expect(registry.getAccessorFields(), isNotEmpty);

        registry.clear();

        expect(registry.getMutatorFields(), isEmpty);
        expect(registry.getAccessorFields(), isEmpty);
      });
    });

    group('MutatorAccessorMixin Integration Tests', () {
      late TestMutatorUser user;

      setUp(() {
        user = TestMutatorUser();
        user.initializeMutatorAccessors();
      });

      test('should initialize mutators and accessors', () {
        expect(user.mutatorAccessorRegistry.hasMutator('password'), isTrue);
        expect(user.mutatorAccessorRegistry.hasMutator('email'), isTrue);
        expect(user.mutatorAccessorRegistry.hasAccessor('price'), isTrue);
        expect(user.mutatorAccessorRegistry.hasAccessor('birth_date'), isTrue);
      });

      test('should apply mutators automatically on setValue', () {
        user.email = 'USER@EXAMPLE.COM';
        expect(user.email, equals('user@example.com'));

        user.password = 'plaintext';
        expect(user.password, startsWith('hashed_'));

        user.phone = '+1 (555) 123-4567';
        expect(user.phone, equals('15551234567'));

        user.name = 'john doe';
        expect(user.name, equals('John Doe'));
      });

      test('should apply mutators through direct setValue calls', () {
        user.setValueWithMutator<String>('email', 'USER@EXAMPLE.COM');
        expect(user.getValue('email'), equals('user@example.com'));

        // Test price setter (goes through setValue which applies mutator)
        user.price = 25.50;
        expect(user.priceInCents, equals(2550)); // Converted to cents
      });

      test('should apply accessors through getValueWithAccessor', () {
        user.priceInCents = 2550; // Set raw value (cents)
        expect(user.getFormattedPrice(), equals('\$25.50'));

        user.setValue('birth_date', DateTime(1990, 5, 15));
        expect(user.getFormattedBirthDate(), equals('1990-05-15'));

        user.setValue('credit_card', '1234567890123456');
        expect(user.getMaskedCreditCard(), equals('************3456'));

        user.setValue('score', 85.7);
        expect(user.getFormattedScore(), equals('85.7'));
      });

      test('should handle string mutators correctly', () {
        user.description = '  trimmed content  ';
        expect(user.description, equals('trimmed content'));

        user.title = 'lowercase title';
        expect(user.title, equals('LOWERCASE TITLE'));

        user.website = 'HTTPS://EXAMPLE.COM';
        expect(user.website, equals('https://example.com'));
      });

      test('should work with FullNameAccessor and InitialsAccessor', () {
        user.firstName = 'john';
        user.lastName = 'doe';

        expect(user.getFullName(), equals('john doe'));
        expect(user.getInitials(), equals('JD'));

        user.firstName = 'Mary';
        user.lastName = null;

        expect(user.getFullName(), equals('Mary'));
        expect(user.getInitials(), equals('M'));
      });

      test('should handle null values gracefully', () {
        user.email = null;
        expect(user.email, isNull);

        user.setValueWithMutator<String>('email', null);
        expect(user.getValue('email'), isNull);

        expect(user.getValueWithAccessor<String>('price'), isNull);
      });

      test('should register additional mutators and accessors dynamically', () {
        final trimMutator = TrimMutator();
        final maskAccessor = MaskAccessor();

        user.registerMutator('first_name', trimMutator);
        user.registerAccessor('first_name', maskAccessor);

        user.firstName = '  John  ';
        expect(user.firstName, equals('John'));

        user.setValue('first_name', 'SecretName');
        expect(
          user.getValueWithAccessor<String>('first_name'),
          equals('******Name'),
        );
      });

      test('should work with complex field transformations', () {
        // Test complete flow: input -> mutator -> storage -> accessor -> output
        user.price = 123.45; // Input as dollars

        // Should be stored as cents (mutator applied)
        expect(user.getValue('price'), equals(12345));

        // Should be displayed as currency (accessor applied)
        expect(user.getFormattedPrice(), equals('\$123.45'));
      });

      test('should handle edge cases in date formatting', () {
        final earlyDate = DateTime(2000, 1, 1);
        final lateDate = DateTime(2099, 12, 31);

        user.birthDate = earlyDate;
        expect(user.getFormattedBirthDate(), equals('2000-01-01'));

        user.birthDate = lateDate;
        expect(user.getFormattedBirthDate(), equals('2099-12-31'));
      });

      test('should handle special characters in mutators', () {
        user.email = 'JOSÉ@ÉXAMPLE.COM';
        expect(user.email, equals('josé@éxample.com'));

        user.name = 'josé maría gonzález';
        expect(user.name, equals('José María González'));

        user.phone = '+34 (91) 123-4567 ext. 123';
        expect(user.phone, equals('34911234567123'));
      });

      test('should maintain type safety with generic accessor calls', () {
        user.priceInCents = 2550;

        final formattedPrice = user.getValueWithAccessor<String>('price');
        expect(formattedPrice, isA<String>());
        expect(formattedPrice, equals('\$25.50'));

        user.setValue('birth_date', DateTime(1990, 5, 15));
        final formattedDate = user.getValueWithAccessor<String>('birth_date');
        expect(formattedDate, isA<String>());
        expect(formattedDate, equals('1990-05-15'));
      });
    });

    group('Custom Mutators and Accessors Tests', () {
      test('should work with custom mutators', () {
        final user = TestMutatorUser();

        // Custom mutator to remove vowels
        final vowelRemover = _VowelRemoverMutator();
        user.registerMutator('description', vowelRemover);

        user.description = 'Hello World';
        expect(user.description, equals('Hll Wrld'));
      });

      test('should work with custom accessors', () {
        final user = TestMutatorUser();

        // Custom accessor to reverse string
        final reverser = _StringReverserAccessor();
        user.registerAccessor('name', reverser);

        user.setValue('name', 'Hello');
        expect(user.getValueWithAccessor<String>('name'), equals('olleH'));
      });

      test('should chain multiple transformations', () {
        final user = TestMutatorUser();

        // Apply both built-in and custom transformations
        user.registerMutator('name', TrimMutator()); // First, trim
        user.setValue('name', '  hello world  ');

        // Then register capitalizer (would need to reapply)
        user.registerMutator('name', CapitalizeMutator());
        user.name = user.name; // Trigger mutator again

        expect(user.name, equals('Hello World'));
      });
    });
  });
}

// Custom mutator for testing
class _VowelRemoverMutator extends Mutator<String, String> {
  @override
  String mutate(String value) {
    return value.replaceAll(RegExp(r'[aeiouAEIOU]'), '');
  }
}

// Custom accessor that converts cents (int) to currency formatted string
class _CentsToCurrencyAccessor extends Accessor<int, String> {
  @override
  String access(int value) {
    final dollars = value / 100.0;
    return '\$${dollars.toStringAsFixed(2)}';
  }
}

// Custom accessor for testing
class _StringReverserAccessor extends Accessor<String, String> {
  @override
  String access(String value) {
    return value.split('').reversed.join('');
  }
}
