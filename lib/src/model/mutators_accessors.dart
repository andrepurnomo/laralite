import 'model.dart';

/// Base class for mutators (transformers that run when setting values)
abstract class Mutator<TInput, TOutput> {
  /// Transform the input value when setting
  TOutput mutate(TInput value);
}

/// Base class for accessors (transformers that run when getting values)
abstract class Accessor<TInput, TOutput> {
  /// Transform the stored value when retrieving
  TOutput access(TInput value);
}

/// Mutator for hashing passwords
class PasswordMutator extends Mutator<String, String> {
  @override
  String mutate(String value) {
    // Simple hash for demonstration - in real app use bcrypt or similar
    return 'hashed_${value.hashCode}';
  }
}

/// Mutator for normalizing email addresses
class EmailMutator extends Mutator<String, String> {
  @override
  String mutate(String value) {
    return value.toLowerCase().trim();
  }
}

/// Mutator for normalizing phone numbers
class PhoneMutator extends Mutator<String, String> {
  @override
  String mutate(String value) {
    // Remove all non-digit characters
    return value.replaceAll(RegExp(r'[^\d]'), '');
  }
}

/// Mutator for capitalizing text
class CapitalizeMutator extends Mutator<String, String> {
  @override
  String mutate(String value) {
    return value.split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : word
    ).join(' ');
  }
}

/// Mutator for converting to uppercase
class UppercaseMutator extends Mutator<String, String> {
  @override
  String mutate(String value) {
    return value.toUpperCase();
  }
}

/// Mutator for converting to lowercase
class LowercaseMutator extends Mutator<String, String> {
  @override
  String mutate(String value) {
    return value.toLowerCase();
  }
}

/// Mutator for trimming whitespace
class TrimMutator extends Mutator<String, String> {
  @override
  String mutate(String value) {
    return value.trim();
  }
}

/// Mutator for converting cents to dollars
class CentsToDollarsMutator extends Mutator<int, double> {
  @override
  double mutate(int value) {
    return value / 100.0;
  }
}

/// Mutator for converting dollars to cents
class DollarsToCentsMutator extends Mutator<double, int> {
  @override
  int mutate(double value) {
    return (value * 100).round();
  }
}

/// Accessor for formatting currency values
class CurrencyAccessor extends Accessor<double, String> {
  final String symbol;
  final int decimals;
  
  CurrencyAccessor({this.symbol = '\$', this.decimals = 2});
  
  @override
  String access(double value) {
    return '$symbol${value.toStringAsFixed(decimals)}';
  }
}

/// Accessor for formatting dates
class DateAccessor extends Accessor<DateTime, String> {
  final String format;
  
  DateAccessor({this.format = 'yyyy-MM-dd'});
  
  @override
  String access(DateTime value) {
    // Simple date formatting - in real app use intl package
    switch (format) {
      case 'yyyy-MM-dd':
        return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
      case 'dd/MM/yyyy':
        return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
      case 'MM/dd/yyyy':
        return '${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}/${value.year}';
      default:
        return value.toString();
    }
  }
}

/// Accessor for combining first and last name
class FullNameAccessor extends Accessor<Map<String, String?>, String> {
  @override
  String access(Map<String, String?> value) {
    final first = value['first'] ?? '';
    final last = value['last'] ?? '';
    return '$first $last'.trim();
  }
}

/// Accessor for getting initials
class InitialsAccessor extends Accessor<Map<String, String?>, String> {
  @override
  String access(Map<String, String?> value) {
    final first = value['first'] ?? '';
    final last = value['last'] ?? '';
    final firstInitial = first.isNotEmpty ? first[0].toUpperCase() : '';
    final lastInitial = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
}

/// Accessor for hiding parts of sensitive data
class MaskAccessor extends Accessor<String, String> {
  final int visibleStart;
  final int visibleEnd;
  final String maskChar;
  
  MaskAccessor({
    this.visibleStart = 0,
    this.visibleEnd = 4,
    this.maskChar = '*',
  });
  
  @override
  String access(String value) {
    if (value.length <= visibleStart + visibleEnd) {
      return value;
    }
    
    final start = value.substring(0, visibleStart);
    final end = value.substring(value.length - visibleEnd);
    final mask = maskChar * (value.length - visibleStart - visibleEnd);
    
    return '$start$mask$end';
  }
}

/// Registry for managing mutators and accessors for a model
class MutatorAccessorRegistry {
  /// Map of field name to mutator
  final Map<String, Mutator> _mutators = {};
  
  /// Map of field name to accessor
  final Map<String, Accessor> _accessors = {};
  
  /// Register a mutator for a field
  void registerMutator(String fieldName, Mutator mutator) {
    _mutators[fieldName] = mutator;
  }
  
  /// Register an accessor for a field
  void registerAccessor(String fieldName, Accessor accessor) {
    _accessors[fieldName] = accessor;
  }
  
  /// Get mutator for a field
  Mutator? getMutator(String fieldName) {
    return _mutators[fieldName];
  }
  
  /// Get accessor for a field
  Accessor? getAccessor(String fieldName) {
    return _accessors[fieldName];
  }
  
  /// Check if field has a mutator
  bool hasMutator(String fieldName) {
    return _mutators.containsKey(fieldName);
  }
  
  /// Check if field has an accessor
  bool hasAccessor(String fieldName) {
    return _accessors.containsKey(fieldName);
  }
  
  /// Apply mutator to a value if one exists
  dynamic applyMutator(String fieldName, dynamic value) {
    final mutator = _mutators[fieldName];
    if (mutator != null && value != null) {
      return mutator.mutate(value);
    }
    return value;
  }
  
  /// Apply accessor to a value if one exists
  dynamic applyAccessor(String fieldName, dynamic value) {
    final accessor = _accessors[fieldName];
    if (accessor != null && value != null) {
      return accessor.access(value);
    }
    return value;
  }
  
  /// Get all mutator field names
  List<String> getMutatorFields() {
    return _mutators.keys.toList();
  }
  
  /// Get all accessor field names
  List<String> getAccessorFields() {
    return _accessors.keys.toList();
  }
  
  /// Clear all mutators and accessors
  void clear() {
    _mutators.clear();
    _accessors.clear();
  }
}

/// Mixin to add mutator/accessor support to models
mixin MutatorAccessorMixin<T extends Model<T>> on Model<T> {
  /// Registry for mutators and accessors
  final MutatorAccessorRegistry _mutatorAccessorRegistry = MutatorAccessorRegistry();
  
  /// Get the mutator/accessor registry
  MutatorAccessorRegistry get mutatorAccessorRegistry => _mutatorAccessorRegistry;
  
  /// Register a mutator for a field
  void registerMutator(String fieldName, Mutator mutator) {
    _mutatorAccessorRegistry.registerMutator(fieldName, mutator);
  }
  
  /// Register an accessor for a field
  void registerAccessor(String fieldName, Accessor accessor) {
    _mutatorAccessorRegistry.registerAccessor(fieldName, accessor);
  }
  
  /// Get value with accessor applied
  TValue? getValueWithAccessor<TValue>(String fieldName) {
    final rawValue = getValue(fieldName);
    final accessedValue = _mutatorAccessorRegistry.applyAccessor(fieldName, rawValue);
    return accessedValue as TValue?;
  }
  
  /// Set value with mutator applied
  void setValueWithMutator<TValue>(String fieldName, TValue? value) {
    final mutatedValue = _mutatorAccessorRegistry.applyMutator(fieldName, value);
    setValue(fieldName, mutatedValue);
  }
  
  /// Initialize mutators and accessors (to be overridden by subclasses)
  void initializeMutatorAccessors() {
    // Subclasses can override this to register their mutators and accessors
  }
  
  /// Override setValue to apply mutators automatically
  @override
  void setValue<TValue>(String columnName, TValue? value) {
    final mutatedValue = _mutatorAccessorRegistry.applyMutator(columnName, value);
    super.setValue(columnName, mutatedValue);
  }
}
