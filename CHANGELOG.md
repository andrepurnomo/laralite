## 0.0.1-dev

### Added
- **Automatic DateTime Parameter Conversion**: DateTime objects are now automatically converted to ISO 8601 string format when used as query parameters
  - Applies to all WHERE conditions: `where()`, `whereBetween()`, `whereIn()`, `whereNotIn()`
  - No more manual `DateFormatter.formatForSql()` calls needed
  - DateTime objects are converted to UTC ISO strings automatically
  - Example: `query.whereBetween('created_at', startDate, endDate)` now works directly with DateTime objects
- **Database Encryption Support**: Full SQLCipher integration for encrypted databases
  - Optional `encryptionKey` parameter in `Laralite.initialize()`
  - Automatic platform-specific SQLCipher configuration (Android override, iOS/macOS support)
  - Built-in encryption verification with `PRAGMA cipher_version`
  - Fallback to non-encrypted SQLite when no encryption key provided
- **Field System**: Comprehensive field type system with validation and SQL generation
  - 11 field types: AutoIncrement, String, Text, Int, Double, Bool, DateTime, Date, Time, Timestamp, UUID
  - Field validation and serialization support
  - Foreign key field support
- **Database Connection**: Isolate-based SQLite operations for non-blocking performance
  - Background isolate handling for all database operations
  - Request/response pattern with proper error handling
  - Support for queries, executions, and transactions
- **Base Model Architecture**: Foundation for Eloquent-style ORM
  - Field registry system for model definitions
  - Type-safe model operations
  - Code generation support with build_runner

### Dependencies
- Added `sqlcipher_flutter_libs: ^0.6.2` for encryption support
- Core dependencies: `sqlite3: ^2.8.0`, `path: ^1.9.1`, `meta: ^1.16.0`

### Development Status
- 🚧 **DEVELOPMENT VERSION** - Not ready for production use
- 📝 API subject to breaking changes without notice
- 🧪 Experimental features and ongoing development
