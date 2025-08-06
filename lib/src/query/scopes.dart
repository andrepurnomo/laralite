import 'query_builder.dart';
import '../model/model.dart';

/// Base class for query scopes
abstract class Scope<T extends Model<T>> {
  /// Apply the scope to a query builder
  QueryBuilder<T> apply(QueryBuilder<T> query);
}

/// Local scope - a function that modifies the query
typedef LocalScope<T extends Model<T>> = QueryBuilder<T> Function(QueryBuilder<T> query);

/// Global scope - automatically applied to all queries for a model
abstract class GlobalScope<T extends Model<T>> extends Scope<T> {
  /// Whether this scope should be applied to the given query
  bool shouldApply(QueryBuilder<T> query) => true;
}

/// Scope registry for managing model scopes
class ScopeRegistry<T extends Model<T>> {
  /// Local scopes registered by name
  final Map<String, LocalScope<T>> _localScopes = {};
  
  /// Global scopes
  final List<GlobalScope<T>> _globalScopes = [];
  
  /// Register a local scope
  void registerLocal(String name, LocalScope<T> scope) {
    _localScopes[name] = scope;
  }
  
  /// Register a global scope
  void registerGlobal(GlobalScope<T> scope) {
    _globalScopes.add(scope);
  }
  
  /// Get a local scope by name
  LocalScope<T>? getLocal(String name) {
    return _localScopes[name];
  }
  
  /// Get all global scopes
  List<GlobalScope<T>> getGlobalScopes() {
    return List.unmodifiable(_globalScopes);
  }
  
  /// Apply all global scopes to a query
  QueryBuilder<T> applyGlobalScopes(QueryBuilder<T> query) {
    QueryBuilder<T> result = query;
    for (final scope in _globalScopes) {
      if (scope.shouldApply(result)) {
        result = scope.apply(result);
      }
    }
    return result;
  }
  
  /// Apply a local scope to a query
  QueryBuilder<T> applyLocalScope(QueryBuilder<T> query, String scopeName) {
    final scope = _localScopes[scopeName];
    if (scope != null) {
      return scope(query);
    }
    return query;
  }
  
  /// Check if a local scope exists
  bool hasLocalScope(String name) {
    return _localScopes.containsKey(name);
  }
  
  /// Get all local scope names
  List<String> getLocalScopeNames() {
    return _localScopes.keys.toList();
  }
}

/// Common built-in scopes

/// Active scope - filters for active records
class ActiveScope<T extends Model<T>> extends GlobalScope<T> {
  final String activeColumn;
  final dynamic activeValue;
  
  ActiveScope({this.activeColumn = 'active', this.activeValue = true});
  
  @override
  QueryBuilder<T> apply(QueryBuilder<T> query) {
    return query.where(activeColumn, activeValue);
  }
}

/// Soft delete scope - excludes soft deleted records
class SoftDeleteScope<T extends Model<T>> extends GlobalScope<T> {
  final String deletedAtColumn;
  
  SoftDeleteScope({this.deletedAtColumn = 'deleted_at'});
  
  @override
  bool shouldApply(QueryBuilder<T> query) {
    // Don't apply soft delete scope if withTrashed() was called
    return !query.includesTrashed;
  }
  
  @override
  QueryBuilder<T> apply(QueryBuilder<T> query) {
    return query.whereNull(deletedAtColumn);
  }
}

/// Published scope - filters for published content
class PublishedScope<T extends Model<T>> extends GlobalScope<T> {
  final String publishedColumn;
  final dynamic publishedValue;
  
  PublishedScope({this.publishedColumn = 'published', this.publishedValue = true});
  
  @override
  QueryBuilder<T> apply(QueryBuilder<T> query) {
    return query.where(publishedColumn, publishedValue);
  }
}

/// Recent scope - orders by creation date (most recent first)
class RecentScope<T extends Model<T>> extends Scope<T> {
  final String createdAtColumn;
  
  RecentScope({this.createdAtColumn = 'created_at'});
  
  @override
  QueryBuilder<T> apply(QueryBuilder<T> query) {
    return query.orderByDesc(createdAtColumn);
  }
}

/// Popular scope - orders by a popularity field
class PopularScope<T extends Model<T>> extends Scope<T> {
  final String popularityColumn;
  
  PopularScope({this.popularityColumn = 'view_count'});
  
  @override
  QueryBuilder<T> apply(QueryBuilder<T> query) {
    return query.orderByDesc(popularityColumn);
  }
}

/// Helpers for creating common local scopes

/// Create a scope for filtering by a specific field value
LocalScope<T> whereScope<T extends Model<T>>(String column, dynamic value) {
  return (query) => query.where(column, value);
}

/// Create a scope for filtering by date range
LocalScope<T> dateRangeScope<T extends Model<T>>(String column, DateTime start, DateTime end) {
  return (query) => query.where(column, '>=', start).where(column, '<=', end);
}

/// Create a scope for searching by text
LocalScope<T> searchScope<T extends Model<T>>(String column, String searchTerm) {
  return (query) => query.where(column, 'LIKE', '%$searchTerm%');
}

/// Create a scope for limiting results
LocalScope<T> limitScope<T extends Model<T>>(int count) {
  return (query) => query.limit(count);
}

/// Create a scope for recent records within a time period
LocalScope<T> recentScope<T extends Model<T>>(String column, Duration period) {
  final cutoff = DateTime.now().subtract(period);
  return (query) => query.where(column, '>=', cutoff).orderByDesc(column);
}
