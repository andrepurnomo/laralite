import 'package:flutter_test/flutter_test.dart';
import 'package:laralite/laralite.dart';

// Simple test model for pagination
class Article extends Model<Article> {
  final _id = AutoIncrementField();
  final _title = StringField(required: true);
  final _content = TextField();
  final _published = BoolField(defaultValue: false);
  final _views = IntField(defaultValue: 0);
  final _createdAt = TimestampField(autoCreate: true);
  
  @override
  String get table => 'articles';
  
  @override
  void registerFields() {
    registerField('id', _id);
    registerField('title', _title);
    registerField('content', _content);
    registerField('published', _published);
    registerField('views', _views);
    registerField('created_at', _createdAt);
  }
  
  // Getters and setters
  int? get id => getValue<int>('id');
  set id(int? value) => setValue<int>('id', value);
  
  String? get title => getValue<String>('title');
  set title(String? value) => setValue<String>('title', value);
  
  String? get content => getValue<String>('content');
  set content(String? value) => setValue<String>('content', value);
  
  bool? get published => getValue<bool>('published');
  set published(bool? value) => setValue<bool>('published', value);
  
  int? get views => getValue<int>('views');
  set views(int? value) => setValue<int>('views', value);
  
  DateTime? get createdAt => getValue<DateTime>('created_at');
}

void main() async {
  // Initialize database connection
  await Database.initialize(databasePath: ':memory:');
  
  group('Pagination Tests', () {
    setUp(() async {
      // Create tables
      await Database.execute('''
        CREATE TABLE articles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT,
          published INTEGER DEFAULT 0,
          views INTEGER DEFAULT 0,
          created_at TEXT
        )
      ''');
      
      // Insert test data - 25 articles
      for (int i = 1; i <= 25; i++) {
        final article = Article()
          ..title = 'Article $i'
          ..content = 'Content for article $i'
          ..published = i % 3 == 0  // Every 3rd article is published
          ..views = i * 10;
        await article.save();
      }
    });
    
    tearDown(() async {
      await Database.execute('DROP TABLE IF EXISTS articles');
    });
    
    group('Basic Pagination Tests', () {
      test('should paginate with default parameters', () async {
        final result = await Model.query<Article>(() => Article()).paginate();
        
        expect(result.data, hasLength(15)); // default perPage
        expect(result.currentPage, equals(1));
        expect(result.perPage, equals(15));
        expect(result.total, equals(25));
        expect(result.lastPage, equals(2));
        expect(result.hasMorePages, isTrue);
        expect(result.hasPreviousPages, isFalse);
      });
      
      test('should paginate with custom per page', () async {
        final result = await Model.query<Article>(() => Article()).paginate(perPage: 10);
        
        expect(result.data, hasLength(10));
        expect(result.currentPage, equals(1));
        expect(result.perPage, equals(10));
        expect(result.total, equals(25));
        expect(result.lastPage, equals(3));
        expect(result.hasMorePages, isTrue);
        expect(result.hasPreviousPages, isFalse);
      });
      
      test('should paginate specific page', () async {
        final result = await Model.query<Article>(() => Article()).paginate(page: 2, perPage: 10);
        
        expect(result.data, hasLength(10));
        expect(result.currentPage, equals(2));
        expect(result.perPage, equals(10));
        expect(result.total, equals(25));
        expect(result.lastPage, equals(3));
        expect(result.hasMorePages, isTrue);
        expect(result.hasPreviousPages, isTrue);
      });
      
      test('should paginate last page', () async {
        final result = await Model.query<Article>(() => Article()).paginate(page: 3, perPage: 10);
        
        expect(result.data, hasLength(5)); // Only 5 items on last page
        expect(result.currentPage, equals(3));
        expect(result.perPage, equals(10));
        expect(result.total, equals(25));
        expect(result.lastPage, equals(3));
        expect(result.hasMorePages, isFalse);
        expect(result.hasPreviousPages, isTrue);
      });
      
      test('should handle page beyond total pages', () async {
        final result = await Model.query<Article>(() => Article()).paginate(page: 10, perPage: 10);
        
        expect(result.data, isEmpty);
        expect(result.currentPage, equals(10));
        expect(result.perPage, equals(10));
        expect(result.total, equals(25));
        expect(result.lastPage, equals(3));
        expect(result.hasMorePages, isFalse);
        expect(result.hasPreviousPages, isTrue);
      });
    });
    
    group('Pagination with WHERE Conditions', () {
      test('should paginate filtered results', () async {
        final result = await Model.query<Article>(() => Article())
            .where('published', true)
            .paginate(perPage: 5);
        
        expect(result.data, hasLength(5));
        expect(result.total, equals(8)); // 25/3 ≈ 8 published articles
        expect(result.lastPage, equals(2));
        
        // Verify all returned articles are published
        for (final article in result.data) {
          expect(article.published, isTrue);
        }
      });
      
      test('should paginate with multiple conditions', () async {
        final result = await Model.query<Article>(() => Article())
            .where('published', true)
            .where('views', '>', 50)
            .paginate(perPage: 3);
        
        expect(result.data, hasLength(3));
        
        // Verify conditions
        for (final article in result.data) {
          expect(article.published, isTrue);
          expect(article.views!, greaterThan(50));
        }
      });
      
      test('should paginate with no results', () async {
        final result = await Model.query<Article>(() => Article())
            .where('views', '>', 1000)
            .paginate();
        
        expect(result.data, isEmpty);
        expect(result.total, equals(0));
        expect(result.lastPage, equals(0));
        expect(result.hasMorePages, isFalse);
        expect(result.hasPreviousPages, isFalse);
      });
    });
    
    group('Pagination with ORDER BY', () {
      test('should paginate with ORDER BY ASC', () async {
        final result = await Model.query<Article>(() => Article())
            .orderBy('views')
            .paginate(perPage: 5);
        
        expect(result.data, hasLength(5));
        
        // Verify ordering (views should be ascending)
        for (int i = 0; i < result.data.length - 1; i++) {
          expect(result.data[i].views!, lessThanOrEqualTo(result.data[i + 1].views!));
        }
      });
      
      test('should paginate with ORDER BY DESC', () async {
        final result = await Model.query<Article>(() => Article())
            .orderByDesc('views')
            .paginate(perPage: 5);
        
        expect(result.data, hasLength(5));
        
        // Verify ordering (views should be descending)
        for (int i = 0; i < result.data.length - 1; i++) {
          expect(result.data[i].views!, greaterThanOrEqualTo(result.data[i + 1].views!));
        }
      });
      
      test('should maintain order across pages', () async {
        final page1 = await Model.query<Article>(() => Article())
            .orderByDesc('views')
            .paginate(page: 1, perPage: 5);
            
        final page2 = await Model.query<Article>(() => Article())
            .orderByDesc('views')
            .paginate(page: 2, perPage: 5);
        
        // Last item of page 1 should have higher or equal views than first item of page 2
        expect(page1.data.last.views!, greaterThanOrEqualTo(page2.data.first.views!));
      });
    });
    
    group('PaginationResult Helper Methods', () {
      test('should calculate correct URLs/info', () async {
        final result = await Model.query<Article>(() => Article()).paginate(page: 2, perPage: 10);
        
        expect(result.from, equals(11)); // First item number on page 2
        expect(result.to, equals(20));   // Last item number on page 2
        expect(result.hasMorePages, isTrue);
        expect(result.hasPreviousPages, isTrue);
      });
      
      test('should handle first page correctly', () async {
        final result = await Model.query<Article>(() => Article()).paginate(page: 1, perPage: 10);
        
        expect(result.from, equals(1));
        expect(result.to, equals(10));
        expect(result.hasPreviousPages, isFalse);
      });
      
      test('should handle last page correctly', () async {
        final result = await Model.query<Article>(() => Article()).paginate(page: 3, perPage: 10);
        
        expect(result.from, equals(21));
        expect(result.to, equals(25));
        expect(result.hasMorePages, isFalse);
      });
      
      test('should handle empty results', () async {
        final result = await Model.query<Article>(() => Article())
            .where('views', '>', 1000)
            .paginate();
        
        expect(result.from, equals(0));
        expect(result.to, equals(0));
        expect(result.hasMorePages, isFalse);
        expect(result.hasPreviousPages, isFalse);
      });
    });
    
    group('Complex Pagination Scenarios', () {
      test('should work with scopes', () async {
        // Assuming we have a published scope
        final result = await Model.query<Article>(() => Article())
            .where('published', true)
            .orderByDesc('views')
            .paginate(perPage: 3);
        
        expect(result.data, hasLength(3));
        
        // Verify all are published and ordered by views desc
        for (final article in result.data) {
          expect(article.published, isTrue);
        }
        
        for (int i = 0; i < result.data.length - 1; i++) {
          expect(result.data[i].views!, greaterThanOrEqualTo(result.data[i + 1].views!));
        }
      });
      
      test('should work with LIMIT and OFFSET manually', () async {
        // This tests that pagination works correctly with explicit limit/offset
        final manualResult = await Model.query<Article>(() => Article())
            .limit(10)
            .offset(10)
            .get();
            
        final paginatedResult = await Model.query<Article>(() => Article())
            .paginate(page: 2, perPage: 10);
        
        expect(manualResult.length, equals(paginatedResult.data.length));
        
        // Should have same items (assuming no specific ordering)
        final manualIds = manualResult.map((a) => a.id).toSet();
        final paginatedIds = paginatedResult.data.map((a) => a.id).toSet();
        expect(manualIds, equals(paginatedIds));
      });
    });
    
    group('Pagination Edge Cases', () {
      test('should handle zero perPage gracefully', () async {
        // Should use default or minimum value
        final result = await Model.query<Article>(() => Article()).paginate(perPage: 0);
        expect(result.perPage, greaterThan(0));
      });
      
      test('should handle negative page gracefully', () async {
        // Should treat as page 1
        final result = await Model.query<Article>(() => Article()).paginate(page: -1);
        expect(result.currentPage, equals(1));
      });
      
      test('should handle very large perPage', () async {
        final result = await Model.query<Article>(() => Article()).paginate(perPage: 1000);
        
        expect(result.data, hasLength(25)); // All items fit on one page
        expect(result.currentPage, equals(1));
        expect(result.lastPage, equals(1));
        expect(result.hasMorePages, isFalse);
      });
    });
  });
}
