import 'model.dart';
import '../query/query_builder.dart';
import '../fields/datetime_fields.dart';
import '../database/database.dart';

/// Mixin to add soft delete functionality to models
mixin SoftDeletesMixin<T extends Model<T>> on Model<T> {
  /// Deleted at field name
  String get deletedAtColumn => 'deleted_at';

  /// Whether this model uses soft deletes
  bool get softDeletes => true;

  /// Check if the model is soft deleted
  bool get isTrashed => getValue<DateTime?>(deletedAtColumn) != null;

  /// Check if the model is not soft deleted
  bool get isNotTrashed => !isTrashed;

  /// Restore a soft deleted model
  Future<bool> restore() async {
    if (!isTrashed) {
      return false; // Already not deleted
    }

    setValue(deletedAtColumn, null);
    return await save();
  }

  /// Force delete the model (permanent delete)
  Future<bool> forceDelete() async {
    return await super.delete();
  }

  /// Override delete to soft delete instead
  @override
  Future<bool> delete() async {
    if (!softDeletes) {
      return await forceDelete();
    }

    if (isTrashed) {
      return false; // Already deleted
    }

    setValue(deletedAtColumn, DateTime.now().toUtc());
    return await save();
  }

  /// Initialize soft delete field
  void _initializeSoftDeletes() {
    if (softDeletes) {
      // Add deleted_at field if it doesn't exist
      if (!fields.containsKey(deletedAtColumn)) {
        registerField(deletedAtColumn, TimestampField());
      }
    }
  }

  /// Override registerFields to include soft delete field
  @override
  void registerFields() {
    super.registerFields();
    _initializeSoftDeletes();
  }

  /// Get a query builder that includes trashed models
  static QueryBuilder<TModel> withTrashed<TModel extends Model<TModel>>(
    TModel Function() constructor,
  ) {
    // Create query builder without applying global soft delete scope
    return QueryBuilder<TModel>(constructor);
  }

  /// Get a query builder that only includes trashed models
  static QueryBuilder<TModel> onlyTrashed<TModel extends Model<TModel>>(
    TModel Function() constructor,
  ) {
    final instance = constructor();
    if (instance is SoftDeletesMixin) {
      return QueryBuilder<TModel>(
        constructor,
      ).whereNotNull((instance as SoftDeletesMixin).deletedAtColumn);
    }
    return QueryBuilder<TModel>(constructor);
  }

  /// Restore multiple soft deleted models
  static Future<int> restoreMany<TModel extends Model<TModel>>(
    TModel Function() constructor, {
    Map<String, dynamic>? where,
  }) async {
    final instance = constructor();
    if (instance is! SoftDeletesMixin) {
      return 0;
    }

    final softDeleteInstance = instance as SoftDeletesMixin;
    String query =
        'UPDATE ${instance.table} SET ${softDeleteInstance.deletedAtColumn} = NULL WHERE ${softDeleteInstance.deletedAtColumn} IS NOT NULL';
    List<dynamic> parameters = [];

    if (where != null && where.isNotEmpty) {
      final whereConditions = where.entries
          .map((entry) => '${entry.key} = ?')
          .join(' AND ');
      query += ' AND $whereConditions';
      parameters.addAll(where.values);
    }

    return await Database.execute(query, parameters);
  }

  /// Force delete multiple models (permanent delete)
  static Future<int> forceDeleteMany<TModel extends Model<TModel>>(
    TModel Function() constructor, {
    Map<String, dynamic>? where,
  }) async {
    final instance = constructor();
    String query = 'DELETE FROM ${instance.table}';
    List<dynamic> parameters = [];

    if (where != null && where.isNotEmpty) {
      final whereConditions = where.entries
          .map((entry) => '${entry.key} = ?')
          .join(' AND ');
      query += ' WHERE $whereConditions';
      parameters.addAll(where.values);
    }

    return await Database.execute(query, parameters);
  }
}

/// Enhanced timestamp mixin with better UTC handling
mixin TimestampsMixin<T extends Model<T>> on Model<T> {
  /// Whether to automatically manage timestamps
  @override
  bool get timestamps => true;

  /// Created at field name
  @override
  String get createdAtColumn => 'created_at';

  /// Updated at field name
  @override
  String get updatedAtColumn => 'updated_at';

  /// Get created at timestamp in local time
  DateTime? get createdAt => getValue<DateTime?>(createdAtColumn)?.toLocal();

  /// Get updated at timestamp in local time
  DateTime? get updatedAt => getValue<DateTime?>(updatedAtColumn)?.toLocal();

  /// Set created at timestamp (converts to UTC)
  set createdAt(DateTime? value) => setValue(createdAtColumn, value?.toUtc());

  /// Set updated at timestamp (converts to UTC)
  set updatedAt(DateTime? value) => setValue(updatedAtColumn, value?.toUtc());

  /// Touch the updated_at timestamp
  void touch() {
    setValue(updatedAtColumn, DateTime.now().toUtc());
  }

  /// Update the updated_at timestamp and save
  Future<bool> touchAndSave() async {
    touch();
    return await save();
  }

  /// Override save to automatically update timestamps
  @override
  Future<bool> save() async {
    _touchTimestamps();
    return await super.save();
  }

  /// Touch timestamp fields if auto-update is enabled
  void _touchTimestamps() {
    if (timestamps) {
      // Always update updated_at on save
      setValue(updatedAtColumn, DateTime.now().toUtc());

      // Only set created_at for new records
      if (!exists) {
        setValue(createdAtColumn, DateTime.now().toUtc());
      }
    }
  }
}

/// Combined mixin for models that need both timestamps and soft deletes
mixin TimestampsAndSoftDeletesMixin<T extends Model<T>> on Model<T>
    implements TimestampsMixin<T>, SoftDeletesMixin<T> {
  @override
  bool get timestamps => true;

  @override
  bool get softDeletes => true;

  @override
  String get createdAtColumn => 'created_at';

  @override
  String get updatedAtColumn => 'updated_at';

  @override
  String get deletedAtColumn => 'deleted_at';

  /// Get created at timestamp in local time
  @override
  DateTime? get createdAt => getValue<DateTime?>(createdAtColumn)?.toLocal();

  /// Get updated at timestamp in local time
  @override
  DateTime? get updatedAt => getValue<DateTime?>(updatedAtColumn)?.toLocal();

  /// Get deleted at timestamp in local time
  DateTime? get deletedAt => getValue<DateTime?>(deletedAtColumn)?.toLocal();

  /// Set created at timestamp (converts to UTC)
  @override
  set createdAt(DateTime? value) => setValue(createdAtColumn, value?.toUtc());

  /// Set updated at timestamp (converts to UTC)
  @override
  set updatedAt(DateTime? value) => setValue(updatedAtColumn, value?.toUtc());

  /// Set deleted at timestamp (converts to UTC)
  set deletedAt(DateTime? value) => setValue(deletedAtColumn, value?.toUtc());

  /// Check if the model is soft deleted
  @override
  bool get isTrashed => getValue<DateTime?>(deletedAtColumn) != null;

  /// Check if the model is not soft deleted
  @override
  bool get isNotTrashed => !isTrashed;

  /// Touch the updated_at timestamp
  @override
  void touch() {
    setValue(updatedAtColumn, DateTime.now().toUtc());
  }

  /// Update the updated_at timestamp and save
  @override
  Future<bool> touchAndSave() async {
    touch();
    return await save();
  }

  /// Restore a soft deleted model
  @override
  Future<bool> restore() async {
    if (!isTrashed) {
      return false; // Already not deleted
    }

    setValue(deletedAtColumn, null);
    touch(); // Update the updated_at timestamp
    return await save();
  }

  /// Force delete the model (permanent delete)
  @override
  Future<bool> forceDelete() async {
    return await super.delete();
  }

  /// Override delete to soft delete instead
  @override
  Future<bool> delete() async {
    if (!softDeletes) {
      return await forceDelete();
    }

    if (isTrashed) {
      return false; // Already deleted
    }

    setValue(deletedAtColumn, DateTime.now().toUtc());
    touch(); // Update the updated_at timestamp
    return await save();
  }

  /// Initialize timestamp and soft delete fields
  void _initializeTimestampsAndSoftDeletes() {
    if (timestamps) {
      // Add timestamp fields if they don't exist
      if (!fields.containsKey(createdAtColumn)) {
        registerField(createdAtColumn, TimestampField(autoCreate: true));
      }
      if (!fields.containsKey(updatedAtColumn)) {
        registerField(updatedAtColumn, TimestampField(autoUpdate: true));
      }
    }

    if (softDeletes) {
      // Add deleted_at field if it doesn't exist
      if (!fields.containsKey(deletedAtColumn)) {
        registerField(deletedAtColumn, TimestampField());
      }
    }
  }

  /// Override registerFields to include timestamp and soft delete fields
  @override
  void registerFields() {
    super.registerFields();
    _initializeTimestampsAndSoftDeletes();
  }

  /// Override save to automatically update timestamps
  @override
  Future<bool> save() async {
    _touchTimestamps();
    return await super.save();
  }

  /// Touch timestamp fields if auto-update is enabled
  @override
  void _touchTimestamps() {
    if (timestamps) {
      final updatedAtField = getField<DateTime>(updatedAtColumn);
      if (updatedAtField is TimestampField) {
        updatedAtField.touchIfAutoUpdate();
      }
      
      // Touch created_at only for new records
      if (!exists) {
        final createdAtField = getField<DateTime>(createdAtColumn);
        if (createdAtField is TimestampField) {
          createdAtField.touchIfAutoCreate();
        }
      }
    }
  }
}
