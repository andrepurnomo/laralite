import 'package:laralite/laralite.dart';

void main() async {
  // Initialize Laralite with new API
  await Laralite.initialize(databaseName: 'example.db');
  
  print('✅ Laralite initialized successfully!');
  print('Database path: ${Laralite.databasePath}');
  print('Is initialized: ${Laralite.isInitialized}');
  
  // Test basic database operations
  try {
    // Create a simple table for testing
    await Laralite.execute('''
      CREATE TABLE IF NOT EXISTS test_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT
      )
    ''');
    
    print('✅ Test table created');
    
    // Insert test data
    await Laralite.execute(
      'INSERT INTO test_table (name, created_at) VALUES (?, ?)',
      ['Test User', DateTime.now().toIso8601String()],
    );
    
    print('✅ Test data inserted');
    
    // Query test data
    final results = await Laralite.query('SELECT * FROM test_table');
    print('✅ Query results: $results');
    
    // Test transaction
    await Laralite.withTransaction(() async {
      await Laralite.execute(
        'INSERT INTO test_table (name, created_at) VALUES (?, ?)',
        ['Transaction User', DateTime.now().toIso8601String()],
      );
      print('✅ Transaction completed');
    });
    
    // Check table exists
    final tableExists = await Laralite.tableExists('test_table');
    print('✅ Table exists: $tableExists');
    
    // Get table info
    final tableInfo = await Laralite.getTableInfo('test_table');
    print('✅ Table info: $tableInfo');
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    // Clean up
    await Laralite.close();
    print('✅ Database connection closed');
  }
}
