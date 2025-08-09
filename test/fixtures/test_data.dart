import 'test_models.dart';

/// Predefined test datasets and factory methods for creating consistent test data.
/// This file provides sample data for different scenarios including valid, invalid, and edge cases.

class TestData {
  /// Sample user data
  static const Map<String, dynamic> validUserData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'password': 'Password123',
    'status': 'active',
  };

  static const Map<String, dynamic> anotherValidUserData = {
    'name': 'Jane Smith',
    'email': 'jane.smith@example.com',
    'password': 'SecurePass456',
    'status': 'active',
  };

  static const Map<String, dynamic> inactiveUserData = {
    'name': 'Bob Wilson',
    'email': 'bob.wilson@example.com',
    'password': 'Password789',
    'status': 'inactive',
  };

  static const Map<String, dynamic> invalidUserData = {
    'name': 'A', // Too short
    'email': 'invalid-email', // Invalid format
    'password': '', // Empty
    'status': 'unknown', // Not a valid status
  };

  /// Sample post data
  static const Map<String, dynamic> validPostData = {
    'title': 'Introduction to Flutter Development',
    'slug': 'introduction-to-flutter-development',
    'content': '''
Flutter is Google's UI toolkit for building beautiful, natively compiled applications 
for mobile, web, and desktop from a single codebase. In this comprehensive guide, 
we'll explore the fundamentals of Flutter development and how to get started.

## Getting Started

First, you'll need to install Flutter SDK and set up your development environment.
The process varies slightly depending on your operating system.

## Key Concepts

Understanding widgets is crucial to Flutter development. Everything in Flutter 
is a widget, from simple text and buttons to complex layouts and animations.
''',
    'excerpt':
        'A comprehensive guide to getting started with Flutter development, covering installation, setup, and key concepts.',
    'status': 'published',
    'author_id': 1,
    'category_id': 1,
    'view_count': 150,
    'is_published': true,
    'meta_title': 'Flutter Development Guide - Complete Tutorial',
    'meta_description':
        'Learn Flutter development from scratch with our complete tutorial covering setup, widgets, and best practices.',
  };

  static const Map<String, dynamic> draftPostData = {
    'title': 'Advanced State Management in Flutter',
    'slug': 'advanced-state-management-flutter',
    'content':
        'This article covers advanced state management patterns in Flutter...',
    'excerpt':
        'Deep dive into state management solutions for complex Flutter applications.',
    'status': 'draft',
    'author_id': 1,
    'category_id': 1,
    'view_count': 0,
    'is_published': false,
  };

  static const Map<String, dynamic> invalidPostData = {
    'title': 'Hi', // Too short
    'slug': '', // Empty slug
    'content': 'Short content',
    'status': 'unknown', // Invalid status
    // Missing required author_id
  };

  /// Sample comment data
  static const Map<String, dynamic> validCommentData = {
    'content':
        'Great article! This really helped me understand Flutter widgets better.',
    'author_id': 2,
    'post_id': 1,
    'is_approved': true,
    'author_email': 'commenter@example.com',
    'author_name': 'Alex Thompson',
  };

  static const Map<String, dynamic> pendingCommentData = {
    'content':
        'I have a question about the state management section. Can you elaborate?',
    'author_id': 3,
    'post_id': 1,
    'is_approved': false,
    'author_email': 'question@example.com',
    'author_name': 'Maria Garcia',
  };

  static const Map<String, dynamic> replyCommentData = {
    'content': 'Thanks for asking! I\'ll update the article with more details.',
    'author_id': 1,
    'post_id': 1,
    'parent_id': 2,
    'is_approved': true,
    'author_email': 'author@example.com',
    'author_name': 'John Doe',
  };

  /// Sample category data
  static const Map<String, dynamic> rootCategoryData = {
    'name': 'Technology',
    'slug': 'technology',
    'description':
        'Articles about technology, programming, and software development.',
    'sort_order': 1,
    'is_active': true,
  };

  static const Map<String, dynamic> subCategoryData = {
    'name': 'Mobile Development',
    'slug': 'mobile-development',
    'description':
        'Content related to mobile app development for iOS and Android.',
    'parent_id': 1,
    'sort_order': 1,
    'is_active': true,
  };

  static const Map<String, dynamic> inactiveCategoryData = {
    'name': 'Deprecated Tech',
    'slug': 'deprecated-tech',
    'description': 'Legacy technology content.',
    'sort_order': 99,
    'is_active': false,
  };

  /// Sample product data
  static const Map<String, dynamic> validProductData = {
    'name': 'Wireless Bluetooth Headphones',
    'sku': 'WBH-001',
    'price': 99.99,
    'cost_price': 45.50,
    'weight': 250.0,
    'stock_quantity': 50,
    'min_stock_level': 10,
    'is_active': true,
    'dimensions': {'length': 18.5, 'width': 16.0, 'height': 8.0, 'unit': 'cm'},
    'tags': ['electronics', 'audio', 'wireless', 'bluetooth'],
  };

  static const Map<String, dynamic> lowStockProductData = {
    'name': 'USB-C Cable',
    'sku': 'USB-C-001',
    'price': 15.99,
    'cost_price': 8.00,
    'weight': 50.0,
    'stock_quantity': 3,
    'min_stock_level': 5,
    'is_active': true,
    'tags': ['accessories', 'cables'],
  };

  static const Map<String, dynamic> outOfStockProductData = {
    'name': 'Limited Edition Smartphone',
    'sku': 'LES-001',
    'price': 899.99,
    'cost_price': 650.00,
    'weight': 180.0,
    'stock_quantity': 0,
    'min_stock_level': 1,
    'is_active': false,
    'tags': ['electronics', 'mobile', 'limited-edition'],
  };

  /// Sample order data
  static const Map<String, dynamic> validOrderData = {
    'order_number': 'ORD-20241201-001',
    'customer_id': 1,
    'status': 'pending',
    'total_amount': 125.98,
    'shipping_cost': 10.00,
    'tax_amount': 15.98,
    'discount_amount': 0.00,
    'shipping_address': {
      'name': 'John Doe',
      'street': '123 Main Street',
      'city': 'New York',
      'state': 'NY',
      'postal_code': '10001',
      'country': 'USA',
    },
    'billing_address': {
      'name': 'John Doe',
      'street': '123 Main Street',
      'city': 'New York',
      'state': 'NY',
      'postal_code': '10001',
      'country': 'USA',
    },
    'notes': 'Please leave package at front door.',
  };

  static const Map<String, dynamic> processedOrderData = {
    'order_number': 'ORD-20241201-002',
    'customer_id': 2,
    'status': 'processing',
    'total_amount': 75.50,
    'shipping_cost': 5.00,
    'tax_amount': 8.50,
    'discount_amount': 10.00,
    'shipping_address': {
      'name': 'Jane Smith',
      'street': '456 Oak Avenue',
      'city': 'Los Angeles',
      'state': 'CA',
      'postal_code': '90210',
      'country': 'USA',
    },
  };

  /// Edge case data
  static const Map<String, dynamic> unicodeUserData = {
    'name': 'José María González-García',
    'email': 'josé.maría@example.com',
    'password': 'Contraseña123',
    'status': 'active',
  };

  static const Map<String, dynamic> longContentPostData = {
    'title':
        'The Ultimate Guide to Everything You Need to Know About Modern Web Development Practices and Methodologies in 2024',
    'content': '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor 
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia 
deserunt mollit anim id est laborum.

[Content continues for several more paragraphs to test large text handling...]

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque 
laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi 
architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas 
sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione 
voluptatem sequi nesciunt.
''',
    'author_id': 1,
    'category_id': 1,
  };

  /// Bulk data sets for testing performance and pagination
  static List<Map<String, dynamic>> generateBulkUserData(int count) {
    return List.generate(
      count,
      (index) => {
        'name': 'User ${index + 1}',
        'email': 'user${index + 1}@example.com',
        'password': 'password${index + 1}',
        'status': index % 3 == 0 ? 'inactive' : 'active',
      },
    );
  }

  static List<Map<String, dynamic>> generateBulkPostData(
    int count,
    int authorId,
  ) {
    return List.generate(
      count,
      (index) => {
        'title': 'Blog Post ${index + 1}: Test Article',
        'slug': 'blog-post-${index + 1}-test-article',
        'content':
            'This is the content for blog post ${index + 1}. Lorem ipsum dolor sit amet.',
        'excerpt': 'Excerpt for blog post ${index + 1}.',
        'status': index % 4 == 0 ? 'draft' : 'published',
        'author_id': authorId,
        'category_id': (index % 3) + 1,
        'view_count': index * 10,
        'is_published': index % 4 != 0,
      },
    );
  }

  static List<Map<String, dynamic>> generateBulkProductData(int count) {
    final categories = [
      'Electronics',
      'Clothing',
      'Books',
      'Home & Garden',
      'Sports',
    ];

    return List.generate(
      count,
      (index) => {
        'name': 'Product ${index + 1}',
        'sku': 'PRD-${(index + 1).toString().padLeft(3, '0')}',
        'price': 10.0 + (index * 5.5),
        'cost_price': 5.0 + (index * 2.5),
        'weight': 100.0 + (index * 10),
        'stock_quantity': 20 - (index % 25),
        'min_stock_level': 5,
        'is_active': index % 10 != 0,
        'tags': [categories[index % categories.length], 'test-product'],
      },
    );
  }

  /// Data for specific test scenarios
  static Map<String, dynamic> get validationTestData => {
    'users': {
      'missing_required_field': {
        'email': 'test@example.com',
        'password': 'password123',
        // Missing required 'name' field
      },
      'invalid_email_format': {
        'name': 'Test User',
        'email': 'not-an-email',
        'password': 'password123',
      },
      'name_too_short': {
        'name': 'A',
        'email': 'test@example.com',
        'password': 'password123',
      },
      'name_too_long': {
        'name': 'A' * 150, // Exceeds maxLength of 100
        'email': 'test@example.com',
        'password': 'password123',
      },
    },
    'posts': {
      'title_too_short': {
        'title': 'Hi', // Less than minLength of 5
        'content': 'Some content here',
        'author_id': 1,
      },
      'title_too_long': {
        'title': 'A' * 250, // Exceeds maxLength of 200
        'content': 'Some content here',
        'author_id': 1,
      },
      'missing_author': {
        'title': 'Valid Title',
        'content': 'Some content here',
        // Missing required author_id
      },
    },
  };

  /// Time-based test data
  static Map<String, dynamic> get timestampTestData => {
    'past_date': DateTime.now().subtract(Duration(days: 30)),
    'future_date': DateTime.now().add(Duration(days: 30)),
    'current_date': DateTime.now(),
    'epoch_date': DateTime.fromMillisecondsSinceEpoch(0),
    'year_2000': DateTime(2000, 1, 1),
    'leap_year_date': DateTime(2020, 2, 29),
  };

  /// JSON test data
  static const Map<String, dynamic> jsonTestData = {
    'simple_object': {'key': 'value', 'number': 42},
    'nested_object': {
      'user': {
        'id': 1,
        'profile': {
          'name': 'John',
          'preferences': ['dark_mode', 'notifications'],
        },
      },
    },
    'array_data': [
      1,
      2,
      3,
      'four',
      {'five': 5},
    ],
    'mixed_types': {
      'string': 'text',
      'number': 123,
      'boolean': true,
      'null_value': null,
      'array': [1, 2, 3],
      'object': {'nested': 'value'},
    },
  };

  /// Performance test data generators
  static Map<String, dynamic> generateLargeJsonData() {
    final data = <String, dynamic>{};
    for (int i = 0; i < 1000; i++) {
      data['field_$i'] = 'value_$i';
    }
    return data;
  }

  static String generateLargeTextData(int paragraphs) {
    const loremIpsum = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor 
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia 
deserunt mollit anim id est laborum.
''';

    return List.generate(paragraphs, (index) => loremIpsum).join('\n\n');
  }
}

/// Factory methods for creating test instances
class TestModelFactory {
  /// Create a user with optional custom data
  static TestUser createUser([Map<String, dynamic>? data]) {
    final user = TestUser();
    final userData = {...TestData.validUserData, ...?data};
    user.fromMap(userData);
    return user;
  }

  /// Create a post with optional custom data
  static TestPost createPost([Map<String, dynamic>? data]) {
    final post = TestPost();
    final postData = {...TestData.validPostData, ...?data};
    post.fromMap(postData);
    return post;
  }

  /// Create a comment with optional custom data
  static TestComment createComment([Map<String, dynamic>? data]) {
    final comment = TestComment();
    final commentData = {...TestData.validCommentData, ...?data};
    comment.fromMap(commentData);
    return comment;
  }

  /// Create a category with optional custom data
  static TestCategory createCategory([Map<String, dynamic>? data]) {
    final category = TestCategory();
    final categoryData = {...TestData.rootCategoryData, ...?data};
    category.fromMap(categoryData);
    return category;
  }

  /// Create a product with optional custom data
  static TestProduct createProduct([Map<String, dynamic>? data]) {
    final product = TestProduct();
    final productData = {...TestData.validProductData, ...?data};
    product.fromMap(productData);
    return product;
  }

  /// Create an order with optional custom data
  static TestOrder createOrder([Map<String, dynamic>? data]) {
    final order = TestOrder();
    final orderData = {...TestData.validOrderData, ...?data};
    order.fromMap(orderData);
    return order;
  }

  /// Create multiple users
  static List<TestUser> createUsers(
    int count, [
    Map<String, dynamic>? baseData,
  ]) {
    return List.generate(count, (index) {
      final data = {
        'name': 'User ${index + 1}',
        'email': 'user${index + 1}@example.com',
        'password': 'password${index + 1}',
        ...?baseData,
      };
      return createUser(data);
    });
  }

  /// Create multiple posts
  static List<TestPost> createPosts(
    int count,
    int authorId, [
    Map<String, dynamic>? baseData,
  ]) {
    return List.generate(count, (index) {
      final data = {
        'title': 'Test Post ${index + 1}',
        'slug': 'test-post-${index + 1}',
        'content': 'Content for test post ${index + 1}',
        'author_id': authorId,
        ...?baseData,
      };
      return createPost(data);
    });
  }
}
