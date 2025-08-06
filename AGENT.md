# Agent Workflows

This document defines three main workflow agents for working with this codebase and the proven sequential workflow pattern.

## Auto-Sequential Workflow Pattern ⭐

**Proven Pattern**: Dev Mode → Test Mode → Git Mode

This sequential workflow has been successfully tested and provides optimal development efficiency:

### Usage
```
lanjut next step, pakai auto switch agent dev mode dan test mode. jalan pake satu agent berurutan aja
```

### Benefits
- **Focused Development**: Each mode has specific responsibilities
- **Comprehensive Coverage**: Implementation → Testing → Documentation → Commit
- **Clean Git History**: Logical separation of concerns in commits
- **Quality Assurance**: Built-in testing and validation at each step

### Example Sequence
1. **Dev Mode**: Implement Field system (IntField, StringField, etc.)
2. **Test Mode**: Create comprehensive tests for Field system
3. **Git Mode**: Organize commits by logical categories

## 1. Dev Mode

**Purpose**: Develop new features or fix bugs in the system.

**Workflow**:
- Mark task as "in-progress" in todo system
- Analyze the codebase structure and existing patterns
- Understand the feature requirements or bug description
- Implement the solution following existing code conventions
- Create necessary files and directory structure
- Ensure code follows project conventions and patterns
- Run diagnostics to verify code quality (`dart analyze lib/`, `get_diagnostics`)
- Fix any compilation errors or warnings found
- Mark task as "completed" when implementation is done
- Hand off to Test Mode

**Focus**: Feature development, bug fixes, code implementation

**Tools Used**: create_file, edit_file, Read, codebase_search_agent

**Example Implementation**:
- Database connection dengan sqlite3 + isolates
- Field system (IntField, StringField, AutoIncrementField, etc.)
- Base Model class dengan field registry

## 2. Test Mode

**Purpose**: Create comprehensive tests for features and maintain test coverage.

**Workflow**:
- Mark testing task as "in-progress" 
- Analyze existing test patterns and frameworks used in the codebase
- Create comprehensive test files covering all functionality
- Test edge cases, validation, serialization, and error handling
- Use in-memory database (:memory:) for fast, isolated testing
- If bugs are found in the system itself (not test logic), fix the system code
- Ensure tests follow existing naming conventions and structure
- Run test suite to verify all tests pass (`flutter test`)
- Mark testing task as "completed"
- Hand off to Git Mode

**Focus**: Test creation, test coverage, system validation

**Tools Used**: create_file, Bash (flutter test), edit_file

**Test Strategy**:
- Group tests by functionality (Database Connection Tests, Field System Tests)
- Cover positive and negative test cases
- Test serialization/deserialization round-trips
- Validate SQL generation and constraints
- Performance testing for async operations

**Important**: When encountering system bugs during testing, fix the underlying system code rather than modifying test expectations to match incorrect behavior.

### Test Quality Assurance

**Anti-Pattern Detection**: Watch for test logic that accommodates buggy system behavior instead of ensuring correct behavior:

**❌ Avoid**:
- Comments like `// TODO fix`, `// workaround`, `// known issue`, `// for now`
- Test assertions that expect incorrect behavior to pass
- Loose expectations that mask performance/functionality issues
- Tests disabled or skipped due to system bugs

**✅ Best Practice**:
- Fix system bugs immediately when found during testing
- Write tests that enforce correct behavior specifications
- Use strict assertions that catch regressions
- Document expected behavior clearly in test descriptions

**Example Issues Found**:
- `test/model/soft_deletes_test.dart`: Tests accommodate missing soft delete scope implementation
- `test/integration/error_handling_test.dart`: Some tests expect incorrect behavior to work
- `test/integration/performance_test.dart`: Loose performance thresholds mask poor performance

**Clean Test Examples**:
- `test/fields/`: All field tests properly validate correct behavior without accommodating bugs

## 3. Git Mode

**Purpose**: Organize and commit changes by logical categories for better version control history.

**Workflow**:
- Analyze all staged and unstaged changes with `git status`
- Group changes by logical categories and commit order
- Create separate commits for each category with descriptive messages
- Follow conventional commit format consistently
- Ensure each commit is atomic and focused on a single concern
- Update documentation to reflect completed milestones
- Verify clean working tree with `git status`

**Focus**: Version control organization, commit history clarity, change categorization

**Tools Used**: Bash (git commands), edit_file (for documentation updates)

**Commit Order Strategy**:
1. **Dependencies** (`deps:`): Package and dependency changes
2. **Implementation** (`feat:`): Core feature implementation
3. **Testing** (`test:`): Test suite additions and updates
4. **Documentation** (`docs:`): README, PLAN.md, and documentation updates

**Commit Categories**:
- `feat:` New features or functionality
- `fix:` Bug fixes and error corrections
- `test:` Adding or updating tests
- `docs:` Documentation updates
- `deps:` Dependency updates and configuration
- `refactor:` Code improvements without changing functionality
- `style:` Code formatting and style changes
- `perf:` Performance improvements
- `chore:` Maintenance tasks and dependency updates

## Project Context

### Technology Stack
- **Language**: Dart/Flutter
- **Database**: SQLite with sqlite3 package
- **Architecture**: Isolate-based for non-blocking operations
- **Code Generation**: build_runner for @laralite annotations
- **Testing**: flutter_test with in-memory database

### Testing Commands
```bash
flutter test                    # Run all tests
flutter test test/fields_test.dart  # Run specific test file
flutter pub get                 # Install dependencies
dart analyze lib/               # Static analysis
```

### Dependencies
```yaml
dependencies:
  sqlite3: ^2.8.0    # SQLite database operations
  path: ^1.9.1       # File path handling
  meta: ^1.16.0      # Annotations support

dev_dependencies:
  build_runner: ^2.6.0    # Code generation
  source_gen: ^3.0.0     # Source code generation
  analyzer: ^7.4.0       # Code analysis
  flutter_test: sdk: flutter  # Testing framework
```

### Project Structure
```
lib/
├── src/
│   ├── database/          # Database connection and isolates
│   ├── fields/           # Field system (IntField, StringField, etc.)
│   ├── model/            # Base Model class (planned)
│   ├── query/            # Query builder (planned)
│   └── generator/        # Code generator (planned)
└── laralite.dart         # Main library exports

test/
├── database_test.dart    # Database connection tests (12 tests)
└── fields_test.dart      # Field system tests (41 tests)
```

## Proven Success Examples

### Phase 1 Completion Status
✅ **Database Connection**: Isolate-based SQLite operations with comprehensive testing
✅ **Field System**: 11 field types with validation, serialization, and SQL generation
⏳ **Base Model**: Field registry and serialization (next)
⏳ **Code Generator**: @laralite annotation processing (next)

### Recent Successful Workflows

#### Database Connection Implementation
1. **Dev Mode**: Implemented DatabaseConnection, DatabaseIsolate, Database classes
2. **Test Mode**: Created 12 comprehensive tests covering all functionality
3. **Git Mode**: Organized into deps → feat → test → docs commits

#### Field System Implementation  
1. **Dev Mode**: Implemented 11 field types with validation and SQL generation
2. **Test Mode**: Created 41 comprehensive tests covering all field functionality
3. **Git Mode**: Organized into feat → test → docs commits

### Performance Metrics
- **Tests**: 53 total tests, all passing
- **Coverage**: Core database and field functionality fully tested
- **Build Time**: Fast compilation with proper dependency management
- **Test Speed**: In-memory database enables fast test execution
