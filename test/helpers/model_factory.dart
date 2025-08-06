import '../fixtures/test_models.dart';

/// Factory pattern for creating test models with consistent data and builder patterns.
/// Provides sequence generators, trait-based creation, and complex model setup utilities.

class ModelFactory {
  static int _userSequence = 0;
  static int _postSequence = 0;
  static int _commentSequence = 0;
  static int _categorySequence = 0;
  static int _productSequence = 0;
  static int _orderSequence = 0;

  /// Reset all sequences (useful for test isolation)
  static void resetSequences() {
    _userSequence = 0;
    _postSequence = 0;
    _commentSequence = 0;
    _categorySequence = 0;
    _productSequence = 0;
    _orderSequence = 0;
  }

  /// Get next unique sequence number for a model type
  static int nextUserSequence() => ++_userSequence;
  static int nextPostSequence() => ++_postSequence;
  static int nextCommentSequence() => ++_commentSequence;
  static int nextCategorySequence() => ++_categorySequence;
  static int nextProductSequence() => ++_productSequence;
  static int nextOrderSequence() => ++_orderSequence;
}

/// Builder class for creating TestUser instances
class UserBuilder {
  final Map<String, dynamic> _data = {};

  UserBuilder() {
    // Set default values with unique sequence
    final seq = ModelFactory.nextUserSequence();
    _data.addAll({
      'name': 'User $seq',
      'email': 'user$seq@example.com',
      'password': 'Password$seq',
      'status': 'active',
    });
  }

  UserBuilder withName(String name) {
    _data['name'] = name;
    return this;
  }

  UserBuilder withEmail(String email) {
    _data['email'] = email;
    return this;
  }

  UserBuilder withPassword(String password) {
    _data['password'] = password;
    return this;
  }

  UserBuilder withStatus(String status) {
    _data['status'] = status;
    return this;
  }

  UserBuilder withRoleId(int roleId) {
    _data['role_id'] = roleId;
    return this;
  }

  UserBuilder active() {
    _data['status'] = 'active';
    return this;
  }

  UserBuilder inactive() {
    _data['status'] = 'inactive';
    return this;
  }

  UserBuilder banned() {
    _data['status'] = 'banned';
    return this;
  }

  UserBuilder admin() {
    _data['role_id'] = 1;
    _data['status'] = 'active';
    return this;
  }

  UserBuilder withTimestamps() {
    final now = DateTime.now();
    _data['created_at'] = now.toIso8601String();
    _data['updated_at'] = now.toIso8601String();
    return this;
  }

  UserBuilder deleted() {
    _data['deleted_at'] = DateTime.now().toIso8601String();
    return this;
  }

  /// Build the user model
  TestUser build() {
    final user = TestUser();
    // Set field values directly instead of fromMap to avoid marking as existing
    for (final entry in _data.entries) {
      user.setValue(entry.key, entry.value);
    }
    return user;
  }

  /// Build and save the user model
  Future<TestUser> create() async {
    final user = build();
    await user.save();
    return user;
  }

  /// Build multiple users with variations
  List<TestUser> buildMany(int count) {
    return List.generate(count, (index) {
      final seq = ModelFactory.nextUserSequence();
      final userData = Map<String, dynamic>.from(_data);
      userData['name'] = '${_data['name']} ${index + 1}';
      userData['email'] = 'user$seq@example.com';

      final user = TestUser();
      user.fromMap(userData);
      return user;
    });
  }

  /// Create multiple users and save them
  Future<List<TestUser>> createMany(int count) async {
    final users = buildMany(count);
    for (final user in users) {
      await user.save();
    }
    return users;
  }
}

/// Builder class for creating TestPost instances
class PostBuilder {
  final Map<String, dynamic> _data = {};

  PostBuilder() {
    final seq = ModelFactory.nextPostSequence();
    _data.addAll({
      'title': 'Test Post $seq',
      'slug': 'test-post-$seq',
      'content': 'This is the content for test post $seq.',
      'excerpt': 'Excerpt for test post $seq.',
      'status': 'draft',
      'author_id': 1, // Default author
      'view_count': 0,
      'is_published': false,
    });
  }

  PostBuilder withTitle(String title) {
    _data['title'] = title;
    return this;
  }

  PostBuilder withSlug(String slug) {
    _data['slug'] = slug;
    return this;
  }

  PostBuilder withContent(String content) {
    _data['content'] = content;
    return this;
  }

  PostBuilder withExcerpt(String excerpt) {
    _data['excerpt'] = excerpt;
    return this;
  }

  PostBuilder withAuthor(int authorId) {
    _data['author_id'] = authorId;
    return this;
  }

  PostBuilder withCategory(int categoryId) {
    _data['category_id'] = categoryId;
    return this;
  }

  PostBuilder withViewCount(int viewCount) {
    _data['view_count'] = viewCount;
    return this;
  }

  PostBuilder draft() {
    _data['status'] = 'draft';
    _data['is_published'] = false;
    return this;
  }

  PostBuilder published() {
    _data['status'] = 'published';
    _data['is_published'] = true;
    _data['published_at'] = DateTime.now().toIso8601String();
    return this;
  }

  PostBuilder pending() {
    _data['status'] = 'pending';
    _data['is_published'] = false;
    return this;
  }

  PostBuilder withMeta(String title, String description) {
    _data['meta_title'] = title;
    _data['meta_description'] = description;
    return this;
  }

  PostBuilder popular() {
    _data['view_count'] = 1000 + (ModelFactory.nextPostSequence() * 100);
    return this;
  }

  PostBuilder withTimestamps() {
    final now = DateTime.now();
    _data['created_at'] = now.toIso8601String();
    _data['updated_at'] = now.toIso8601String();
    return this;
  }

  PostBuilder deleted() {
    _data['deleted_at'] = DateTime.now().toIso8601String();
    return this;
  }

  TestPost build() {
    final post = TestPost();
    post.fromMap(_data);
    return post;
  }

  Future<TestPost> create() async {
    final post = build();
    await post.save();
    return post;
  }

  List<TestPost> buildMany(int count) {
    return List.generate(count, (index) {
      final seq = ModelFactory.nextPostSequence();
      final postData = Map<String, dynamic>.from(_data);
      postData['title'] = '${_data['title']} ${index + 1}';
      postData['slug'] = 'test-post-$seq';

      final post = TestPost();
      post.fromMap(postData);
      return post;
    });
  }

  Future<List<TestPost>> createMany(int count) async {
    final posts = buildMany(count);
    for (final post in posts) {
      await post.save();
    }
    return posts;
  }
}

/// Builder class for creating TestComment instances
class CommentBuilder {
  final Map<String, dynamic> _data = {};

  CommentBuilder() {
    final seq = ModelFactory.nextCommentSequence();
    _data.addAll({
      'content': 'This is test comment $seq.',
      'author_id': 1,
      'post_id': 1,
      'is_approved': false,
      'author_email': 'commenter$seq@example.com',
      'author_name': 'Commenter $seq',
    });
  }

  CommentBuilder withContent(String content) {
    _data['content'] = content;
    return this;
  }

  CommentBuilder byAuthor(int authorId) {
    _data['author_id'] = authorId;
    return this;
  }

  CommentBuilder onPost(int postId) {
    _data['post_id'] = postId;
    return this;
  }

  CommentBuilder replyTo(int parentId) {
    _data['parent_id'] = parentId;
    return this;
  }

  CommentBuilder withAuthorInfo(String email, String name) {
    _data['author_email'] = email;
    _data['author_name'] = name;
    return this;
  }

  CommentBuilder approved() {
    _data['is_approved'] = true;
    return this;
  }

  CommentBuilder pending() {
    _data['is_approved'] = false;
    return this;
  }

  CommentBuilder withTimestamps() {
    final now = DateTime.now();
    _data['created_at'] = now.toIso8601String();
    _data['updated_at'] = now.toIso8601String();
    return this;
  }

  CommentBuilder deleted() {
    _data['deleted_at'] = DateTime.now().toIso8601String();
    return this;
  }

  TestComment build() {
    final comment = TestComment();
    comment.fromMap(_data);
    return comment;
  }

  Future<TestComment> create() async {
    final comment = build();
    await comment.save();
    return comment;
  }

  List<TestComment> buildMany(int count) {
    return List.generate(count, (index) {
      final seq = ModelFactory.nextCommentSequence();
      final commentData = Map<String, dynamic>.from(_data);
      commentData['content'] = '${_data['content']} Reply ${index + 1}';
      commentData['author_email'] = 'commenter$seq@example.com';
      commentData['author_name'] = 'Commenter $seq';

      final comment = TestComment();
      comment.fromMap(commentData);
      return comment;
    });
  }

  Future<List<TestComment>> createMany(int count) async {
    final comments = buildMany(count);
    for (final comment in comments) {
      await comment.save();
    }
    return comments;
  }
}

/// Builder class for creating TestCategory instances
class CategoryBuilder {
  final Map<String, dynamic> _data = {};

  CategoryBuilder() {
    final seq = ModelFactory.nextCategorySequence();
    _data.addAll({
      'name': 'Category $seq',
      'slug': 'category-$seq',
      'description': 'Description for category $seq.',
      'sort_order': seq,
      'is_active': true,
    });
  }

  CategoryBuilder withName(String name) {
    _data['name'] = name;
    return this;
  }

  CategoryBuilder withSlug(String slug) {
    _data['slug'] = slug;
    return this;
  }

  CategoryBuilder withDescription(String description) {
    _data['description'] = description;
    return this;
  }

  CategoryBuilder withParent(int parentId) {
    _data['parent_id'] = parentId;
    return this;
  }

  CategoryBuilder withSortOrder(int sortOrder) {
    _data['sort_order'] = sortOrder;
    return this;
  }

  CategoryBuilder active() {
    _data['is_active'] = true;
    return this;
  }

  CategoryBuilder inactive() {
    _data['is_active'] = false;
    return this;
  }

  CategoryBuilder root() {
    _data.remove('parent_id');
    return this;
  }

  CategoryBuilder withTimestamps() {
    final now = DateTime.now();
    _data['created_at'] = now.toIso8601String();
    _data['updated_at'] = now.toIso8601String();
    return this;
  }

  TestCategory build() {
    final category = TestCategory();
    category.fromMap(_data);
    return category;
  }

  Future<TestCategory> create() async {
    final category = build();
    await category.save();
    return category;
  }

  List<TestCategory> buildMany(int count) {
    return List.generate(count, (index) {
      final seq = ModelFactory.nextCategorySequence();
      final categoryData = Map<String, dynamic>.from(_data);
      categoryData['name'] = '${_data['name']} ${index + 1}';
      categoryData['slug'] = 'category-$seq';
      categoryData['sort_order'] = seq;

      final category = TestCategory();
      category.fromMap(categoryData);
      return category;
    });
  }

  Future<List<TestCategory>> createMany(int count) async {
    final categories = buildMany(count);
    for (final category in categories) {
      await category.save();
    }
    return categories;
  }
}

/// Builder class for creating TestProduct instances
class ProductBuilder {
  final Map<String, dynamic> _data = {};

  ProductBuilder() {
    final seq = ModelFactory.nextProductSequence();
    _data.addAll({
      'name': 'Product $seq',
      'sku': 'PRD-${seq.toString().padLeft(3, '0')}',
      'price': 10.0 + (seq * 5.0),
      'cost_price': 5.0 + (seq * 2.0),
      'weight': 100.0,
      'stock_quantity': 50,
      'min_stock_level': 10,
      'is_active': true,
      'tags': ['test-product'],
    });
  }

  ProductBuilder withName(String name) {
    _data['name'] = name;
    return this;
  }

  ProductBuilder withSku(String sku) {
    _data['sku'] = sku;
    return this;
  }

  ProductBuilder withPrice(double price) {
    _data['price'] = price;
    return this;
  }

  ProductBuilder withCostPrice(double costPrice) {
    _data['cost_price'] = costPrice;
    return this;
  }

  ProductBuilder withWeight(double weight) {
    _data['weight'] = weight;
    return this;
  }

  ProductBuilder withStock(int quantity) {
    _data['stock_quantity'] = quantity;
    return this;
  }

  ProductBuilder withMinStock(int minLevel) {
    _data['min_stock_level'] = minLevel;
    return this;
  }

  ProductBuilder withDimensions(Map<String, dynamic> dimensions) {
    _data['dimensions'] = dimensions;
    return this;
  }

  ProductBuilder withTags(List<String> tags) {
    _data['tags'] = tags;
    return this;
  }

  ProductBuilder addTag(String tag) {
    final currentTags = List<String>.from(_data['tags'] ?? []);
    if (!currentTags.contains(tag)) {
      currentTags.add(tag);
      _data['tags'] = currentTags;
    }
    return this;
  }

  ProductBuilder active() {
    _data['is_active'] = true;
    return this;
  }

  ProductBuilder inactive() {
    _data['is_active'] = false;
    return this;
  }

  ProductBuilder inStock() {
    _data['stock_quantity'] = 50;
    return this;
  }

  ProductBuilder lowStock() {
    _data['stock_quantity'] = 3;
    _data['min_stock_level'] = 5;
    return this;
  }

  ProductBuilder outOfStock() {
    _data['stock_quantity'] = 0;
    return this;
  }

  ProductBuilder expensive() {
    _data['price'] = 500.0 + (ModelFactory.nextProductSequence() * 100.0);
    return this;
  }

  ProductBuilder cheap() {
    _data['price'] = 5.0 + (ModelFactory.nextProductSequence() * 2.0);
    return this;
  }

  ProductBuilder withTimestamps() {
    final now = DateTime.now();
    _data['created_at'] = now.toIso8601String();
    _data['updated_at'] = now.toIso8601String();
    return this;
  }

  TestProduct build() {
    final product = TestProduct();
    product.fromMap(_data);
    return product;
  }

  Future<TestProduct> create() async {
    final product = build();
    await product.save();
    return product;
  }

  List<TestProduct> buildMany(int count) {
    return List.generate(count, (index) {
      final seq = ModelFactory.nextProductSequence();
      final productData = Map<String, dynamic>.from(_data);
      productData['name'] = '${_data['name']} ${index + 1}';
      productData['sku'] = 'PRD-${seq.toString().padLeft(3, '0')}';

      final product = TestProduct();
      product.fromMap(productData);
      return product;
    });
  }

  Future<List<TestProduct>> createMany(int count) async {
    final products = buildMany(count);
    for (final product in products) {
      await product.save();
    }
    return products;
  }
}

/// Builder class for creating TestOrder instances
class OrderBuilder {
  final Map<String, dynamic> _data = {};

  OrderBuilder() {
    final seq = ModelFactory.nextOrderSequence();
    _data.addAll({
      'order_number': 'ORD-${DateTime.now().millisecondsSinceEpoch}-$seq',
      'customer_id': 1,
      'status': 'pending',
      'total_amount': 100.0,
      'shipping_cost': 10.0,
      'tax_amount': 8.0,
      'discount_amount': 0.0,
      'shipping_address': {
        'name': 'Customer $seq',
        'street': '$seq Main Street',
        'city': 'Test City',
        'state': 'TS',
        'postal_code': '12345',
        'country': 'USA',
      },
      'notes': 'Test order $seq',
    });
  }

  OrderBuilder withOrderNumber(String orderNumber) {
    _data['order_number'] = orderNumber;
    return this;
  }

  OrderBuilder forCustomer(int customerId) {
    _data['customer_id'] = customerId;
    return this;
  }

  OrderBuilder withStatus(String status) {
    _data['status'] = status;
    return this;
  }

  OrderBuilder withTotal(double total) {
    _data['total_amount'] = total;
    return this;
  }

  OrderBuilder withShipping(double shipping) {
    _data['shipping_cost'] = shipping;
    return this;
  }

  OrderBuilder withTax(double tax) {
    _data['tax_amount'] = tax;
    return this;
  }

  OrderBuilder withDiscount(double discount) {
    _data['discount_amount'] = discount;
    return this;
  }

  OrderBuilder withShippingAddress(Map<String, dynamic> address) {
    _data['shipping_address'] = address;
    return this;
  }

  OrderBuilder withBillingAddress(Map<String, dynamic> address) {
    _data['billing_address'] = address;
    return this;
  }

  OrderBuilder withNotes(String notes) {
    _data['notes'] = notes;
    return this;
  }

  OrderBuilder pending() {
    _data['status'] = 'pending';
    return this;
  }

  OrderBuilder processing() {
    _data['status'] = 'processing';
    _data['processed_at'] = DateTime.now().toIso8601String();
    return this;
  }

  OrderBuilder shipped() {
    _data['status'] = 'shipped';
    _data['processed_at'] = DateTime.now()
        .subtract(Duration(days: 1))
        .toIso8601String();
    _data['shipped_at'] = DateTime.now().toIso8601String();
    return this;
  }

  OrderBuilder delivered() {
    _data['status'] = 'delivered';
    final now = DateTime.now();
    _data['processed_at'] = now.subtract(Duration(days: 3)).toIso8601String();
    _data['shipped_at'] = now.subtract(Duration(days: 1)).toIso8601String();
    _data['delivered_at'] = now.toIso8601String();
    return this;
  }

  OrderBuilder cancelled() {
    _data['status'] = 'cancelled';
    return this;
  }

  OrderBuilder expensive() {
    _data['total_amount'] = 500.0 + (ModelFactory.nextOrderSequence() * 100.0);
    return this;
  }

  OrderBuilder withTimestamps() {
    final now = DateTime.now();
    _data['created_at'] = now.toIso8601String();
    _data['updated_at'] = now.toIso8601String();
    return this;
  }

  OrderBuilder deleted() {
    _data['deleted_at'] = DateTime.now().toIso8601String();
    return this;
  }

  TestOrder build() {
    final order = TestOrder();
    order.fromMap(_data);
    return order;
  }

  Future<TestOrder> create() async {
    final order = build();
    await order.save();
    return order;
  }

  List<TestOrder> buildMany(int count) {
    return List.generate(count, (index) {
      final seq = ModelFactory.nextOrderSequence();
      final orderData = Map<String, dynamic>.from(_data);
      orderData['order_number'] =
          'ORD-${DateTime.now().millisecondsSinceEpoch}-$seq';

      final order = TestOrder();
      order.fromMap(orderData);
      return order;
    });
  }

  Future<List<TestOrder>> createMany(int count) async {
    final orders = buildMany(count);
    for (final order in orders) {
      await order.save();
    }
    return orders;
  }
}

/// Factory methods using builder pattern
class Factory {
  /// Create a user builder
  static UserBuilder user() => UserBuilder();

  /// Create a post builder
  static PostBuilder post() => PostBuilder();

  /// Create a comment builder
  static CommentBuilder comment() => CommentBuilder();

  /// Create a category builder
  static CategoryBuilder category() => CategoryBuilder();

  /// Create a product builder
  static ProductBuilder product() => ProductBuilder();

  /// Create an order builder
  static OrderBuilder order() => OrderBuilder();

  /// Create related models (user with posts and comments)
  static Future<UserWithContent> createUserWithContent({
    int postCount = 3,
    int commentCount = 5,
  }) async {
    final user = await Factory.user().active().create();

    final posts = await Factory.post()
        .withAuthor(user.id!)
        .createMany(postCount);

    final comments = await Factory.comment()
        .byAuthor(user.id!)
        .onPost(posts.first.id!)
        .approved()
        .createMany(commentCount);

    return UserWithContent(user: user, posts: posts, comments: comments);
  }

  /// Create a blog scenario (categories, users, posts, comments)
  static Future<BlogScenario> createBlogScenario() async {
    // Create categories
    final techCategory = await Factory.category()
        .withName('Web Development')
        .withSlug('web-development')
        .create();

    final programmingCategory = await Factory.category()
        .withName('JavaScript')
        .withSlug('javascript')
        .withParent(techCategory.id!)
        .create();

    // Create users
    final author = await Factory.user()
        .withName('John Author')
        .withEmail('blog.author@example.com')
        .active()
        .create();

    final commenter = await Factory.user()
        .withName('Jane Commenter')
        .withEmail('commenter@example.com')
        .active()
        .create();

    // Create posts
    final publishedPost = await Factory.post()
        .withTitle('Published Programming Tutorial')
        .withAuthor(author.id!)
        .withCategory(programmingCategory.id!)
        .published()
        .popular()
        .create();

    final draftPost = await Factory.post()
        .withTitle('Draft Article')
        .withAuthor(author.id!)
        .withCategory(techCategory.id!)
        .draft()
        .create();

    // Create comments
    final topComment = await Factory.comment()
        .withContent('Great tutorial! Very helpful.')
        .byAuthor(commenter.id!)
        .onPost(publishedPost.id!)
        .approved()
        .create();

    final replyComment = await Factory.comment()
        .withContent('Thanks for the feedback!')
        .byAuthor(author.id!)
        .onPost(publishedPost.id!)
        .replyTo(topComment.id!)
        .approved()
        .create();

    return BlogScenario(
      categories: [techCategory, programmingCategory],
      users: [author, commenter],
      posts: [publishedPost, draftPost],
      comments: [topComment, replyComment],
    );
  }

  /// Create an e-commerce scenario
  static Future<EcommerceScenario> createEcommerceScenario() async {
    // Create customer
    final customer = await Factory.user()
        .withName('John Customer')
        .withEmail('customer@example.com')
        .active()
        .create();

    // Create products
    final expensiveProduct = await Factory.product()
        .withName('Premium Headphones')
        .withSku('PREM-HP-001')
        .expensive()
        .inStock()
        .addTag('premium')
        .addTag('electronics')
        .create();

    final cheapProduct = await Factory.product()
        .withName('Basic Cable')
        .withSku('BASIC-CBL-001')
        .cheap()
        .lowStock()
        .addTag('accessories')
        .create();

    // Create orders
    final pendingOrder = await Factory.order()
        .forCustomer(customer.id!)
        .pending()
        .withTotal(125.50)
        .create();

    final deliveredOrder = await Factory.order()
        .forCustomer(customer.id!)
        .delivered()
        .withTotal(75.00)
        .create();

    return EcommerceScenario(
      customer: customer,
      products: [expensiveProduct, cheapProduct],
      orders: [pendingOrder, deliveredOrder],
    );
  }
}

/// Data containers for complex scenarios
class UserWithContent {
  final TestUser user;
  final List<TestPost> posts;
  final List<TestComment> comments;

  UserWithContent({
    required this.user,
    required this.posts,
    required this.comments,
  });
}

class BlogScenario {
  final List<TestCategory> categories;
  final List<TestUser> users;
  final List<TestPost> posts;
  final List<TestComment> comments;

  BlogScenario({
    required this.categories,
    required this.users,
    required this.posts,
    required this.comments,
  });

  TestCategory get rootCategory => categories.first;
  TestCategory get subCategory => categories.last;
  TestUser get author => users.first;
  TestUser get commenter => users.last;
  TestPost get publishedPost => posts.first;
  TestPost get draftPost => posts.last;
  TestComment get topComment => comments.first;
  TestComment get replyComment => comments.last;
}

class EcommerceScenario {
  final TestUser customer;
  final List<TestProduct> products;
  final List<TestOrder> orders;

  EcommerceScenario({
    required this.customer,
    required this.products,
    required this.orders,
  });

  TestProduct get expensiveProduct => products.first;
  TestProduct get cheapProduct => products.last;
  TestOrder get pendingOrder => orders.first;
  TestOrder get deliveredOrder => orders.last;
}
