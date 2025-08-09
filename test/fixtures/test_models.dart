import 'package:laralite/laralite.dart';

/// Standardized test models used across multiple test files.
/// These models provide consistent test data structures and demonstrate
/// various Laralite features like relationships, validation, soft deletes, and timestamps.

/// Basic User model with timestamps and soft deletes
class TestUser extends Model<TestUser>
    with TimestampsAndSoftDeletesMixin<TestUser> {
  final _id = AutoIncrementField();
  final _name = StringField(required: true, minLength: 2, maxLength: 100);
  final _email = EmailField(unique: true);
  final _password = StringField();
  final _status = StringField(defaultValue: 'active');
  final _roleId = IntField(nullable: true);

  @override
  String get table => 'test_users';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('email', _email);
    registerField('password', _password);
    registerField('status', _status);
    registerField('role_id', _roleId);
    super.registerFields();
  }

  // Getters/Setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get name => _name.value;
  set name(String? value) => _name.value = value;

  String? get email => _email.value;
  set email(String? value) => _email.value = value;

  String? get password => _password.value;
  set password(String? value) => _password.value = value;

  String? get status => _status.value;
  set status(String? value) => _status.value = value;

  int? get roleId => _roleId.value;
  set roleId(int? value) => _roleId.value = value;

  // Mutators
  void setPassword(String plainPassword) {
    password = 'hashed_$plainPassword';
  }

  // Accessors
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isBanned => status == 'banned';
}

/// Blog Post model with relationships and validation
class TestPost extends Model<TestPost>
    with TimestampsAndSoftDeletesMixin<TestPost> {
  final _id = AutoIncrementField();
  final _title = StringField(required: true, minLength: 5, maxLength: 200);
  final _slug = StringField(unique: true, maxLength: 250);
  final _content = TextField();
  final _excerpt = StringField(maxLength: 500);
  final _status = StringField(defaultValue: 'draft');
  final _authorId = IntField(required: true);
  final _categoryId = IntField(nullable: true);
  final _viewCount = IntField(defaultValue: 0);
  final _isPublished = BoolField(defaultValue: false);
  final _publishedAt = TimestampField(nullable: true);
  final _metaTitle = StringField(maxLength: 60);
  final _metaDescription = StringField(maxLength: 160);

  @override
  String get table => 'test_posts';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('title', _title);
    registerField('slug', _slug);
    registerField('content', _content);
    registerField('excerpt', _excerpt);
    registerField('status', _status);
    registerField('author_id', _authorId);
    registerField('category_id', _categoryId);
    registerField('view_count', _viewCount);
    registerField('is_published', _isPublished);
    registerField('published_at', _publishedAt);
    registerField('meta_title', _metaTitle);
    registerField('meta_description', _metaDescription);
    super.registerFields();
  }

  // Getters/Setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get title => _title.value;
  set title(String? value) => _title.value = value;

  String? get slug => _slug.value;
  set slug(String? value) => _slug.value = value;

  String? get content => _content.value;
  set content(String? value) => _content.value = value;

  String? get excerpt => _excerpt.value;
  set excerpt(String? value) => _excerpt.value = value;

  String? get status => _status.value;
  set status(String? value) => _status.value = value;

  int? get authorId => _authorId.value;
  set authorId(int? value) => _authorId.value = value;

  int? get categoryId => _categoryId.value;
  set categoryId(int? value) => _categoryId.value = value;

  int? get viewCount => _viewCount.value;
  set viewCount(int? value) => _viewCount.value = value;

  bool? get isPublished => _isPublished.value;
  set isPublished(bool? value) => _isPublished.value = value;

  DateTime? get publishedAt => _publishedAt.value?.toLocal();
  set publishedAt(DateTime? value) => _publishedAt.value = value?.toUtc();

  String? get metaTitle => _metaTitle.value;
  set metaTitle(String? value) => _metaTitle.value = value;

  String? get metaDescription => _metaDescription.value;
  set metaDescription(String? value) => _metaDescription.value = value;

  // Mutators
  void generateSlug() {
    if (title != null) {
      slug = title!
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-')
          .replaceAll(RegExp(r'-+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');
    }
  }

  void incrementViewCount() {
    viewCount = (viewCount ?? 0) + 1;
  }

  void publish() {
    isPublished = true;
    status = 'published';
    publishedAt = DateTime.now();
  }

  void unpublish() {
    isPublished = false;
    status = 'draft';
    publishedAt = null;
  }

  // Accessors
  bool get isDraft => status == 'draft';
  bool get isPending => status == 'pending';
  bool get isPublic => status == 'published' && isPublished == true;
  String get displayTitle => title ?? 'Untitled';
  String get displayExcerpt => excerpt ?? content?.substring(0, 100) ?? '';
}

/// Comment model for testing relationships
class TestComment extends Model<TestComment>
    with TimestampsAndSoftDeletesMixin<TestComment> {
  final _id = AutoIncrementField();
  final _content = TextField(required: true);
  final _authorId = IntField(required: true);
  final _postId = IntField(required: true);
  final _parentId = IntField(nullable: true);
  final _isApproved = BoolField(defaultValue: false);
  final _authorEmail = EmailField();
  final _authorName = StringField(maxLength: 100);

  @override
  String get table => 'test_comments';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('content', _content);
    registerField('author_id', _authorId);
    registerField('post_id', _postId);
    registerField('parent_id', _parentId);
    registerField('is_approved', _isApproved);
    registerField('author_email', _authorEmail);
    registerField('author_name', _authorName);
    super.registerFields();
  }

  // Getters/Setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get content => _content.value;
  set content(String? value) => _content.value = value;

  int? get authorId => _authorId.value;
  set authorId(int? value) => _authorId.value = value;

  int? get postId => _postId.value;
  set postId(int? value) => _postId.value = value;

  int? get parentId => _parentId.value;
  set parentId(int? value) => _parentId.value = value;

  bool? get isApproved => _isApproved.value;
  set isApproved(bool? value) => _isApproved.value = value;

  String? get authorEmail => _authorEmail.value;
  set authorEmail(String? value) => _authorEmail.value = value;

  String? get authorName => _authorName.value;
  set authorName(String? value) => _authorName.value = value;

  // Methods
  void approve() => isApproved = true;
  void reject() => isApproved = false;
  bool get isReply => parentId != null;
  bool get isTopLevel => parentId == null;
}

/// Category model for hierarchical data
class TestCategory extends Model<TestCategory>
    with TimestampsMixin<TestCategory> {
  final _id = AutoIncrementField();
  final _name = StringField(required: true, maxLength: 100);
  final _slug = StringField(unique: true, maxLength: 120);
  final _description = TextField();
  final _parentId = IntField(nullable: true);
  final _sortOrder = IntField(defaultValue: 0);
  final _isActive = BoolField(defaultValue: true);

  @override
  String get table => 'test_categories';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('slug', _slug);
    registerField('description', _description);
    registerField('parent_id', _parentId);
    registerField('sort_order', _sortOrder);
    registerField('is_active', _isActive);
    super.registerFields();
  }

  // Getters/Setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get name => _name.value;
  set name(String? value) => _name.value = value;

  String? get slug => _slug.value;
  set slug(String? value) => _slug.value = value;

  String? get description => _description.value;
  set description(String? value) => _description.value = value;

  int? get parentId => _parentId.value;
  set parentId(int? value) => _parentId.value = value;

  int? get sortOrder => _sortOrder.value;
  set sortOrder(int? value) => _sortOrder.value = value;

  bool? get isActive => _isActive.value;
  set isActive(bool? value) => _isActive.value = value;

  // Accessors
  bool get isRootCategory => parentId == null;
  bool get isSubCategory => parentId != null;
}

/// Simple Product model for testing various field types
class TestProduct extends Model<TestProduct> with TimestampsMixin<TestProduct> {
  final _id = AutoIncrementField();
  final _name = StringField(required: true, maxLength: 200);
  final _sku = StringField(unique: true, maxLength: 50);
  final _price = DoubleField();
  final _costPrice = DoubleField();
  final _weight = DoubleField(nullable: true);
  final _stockQuantity = IntField(defaultValue: 0);
  final _minStockLevel = IntField(defaultValue: 5);
  final _isActive = BoolField(defaultValue: true);
  final _dimensions = JsonField(nullable: true);
  final _tags = JsonField(nullable: true);

  @override
  String get table => 'test_products';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('name', _name);
    registerField('sku', _sku);
    registerField('price', _price);
    registerField('cost_price', _costPrice);
    registerField('weight', _weight);
    registerField('stock_quantity', _stockQuantity);
    registerField('min_stock_level', _minStockLevel);
    registerField('is_active', _isActive);
    registerField('dimensions', _dimensions);
    registerField('tags', _tags);
    super.registerFields();
  }

  // Getters/Setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get name => _name.value;
  set name(String? value) => _name.value = value;

  String? get sku => _sku.value;
  set sku(String? value) => _sku.value = value;

  double? get price => _price.value;
  set price(double? value) => _price.value = value;

  double? get costPrice => _costPrice.value;
  set costPrice(double? value) => _costPrice.value = value;

  double? get weight => _weight.value;
  set weight(double? value) => _weight.value = value;

  int? get stockQuantity => _stockQuantity.value;
  set stockQuantity(int? value) => _stockQuantity.value = value;

  int? get minStockLevel => _minStockLevel.value;
  set minStockLevel(int? value) => _minStockLevel.value = value;

  bool? get isActive => _isActive.value;
  set isActive(bool? value) => _isActive.value = value;

  Map<String, dynamic>? get dimensions => _dimensions.value;
  set dimensions(Map<String, dynamic>? value) => _dimensions.value = value;

  List<String>? get tags => _tags.value?.cast<String>();
  set tags(List<String>? value) => _tags.value = value;

  // Business methods
  double? get profitMargin =>
      price != null && costPrice != null ? price! - costPrice! : null;

  double? get profitMarginPercentage =>
      price != null && costPrice != null && costPrice! > 0
      ? ((price! - costPrice!) / costPrice!) * 100
      : null;

  bool get isLowStock => (stockQuantity ?? 0) <= (minStockLevel ?? 0);
  bool get isOutOfStock => (stockQuantity ?? 0) <= 0;
  bool get isInStock => (stockQuantity ?? 0) > 0;

  void adjustStock(int adjustment) {
    stockQuantity = (stockQuantity ?? 0) + adjustment;
  }

  void addTag(String tag) {
    final currentTags = tags ?? <String>[];
    if (!currentTags.contains(tag)) {
      currentTags.add(tag);
      tags = currentTags;
    }
  }

  void removeTag(String tag) {
    final currentTags = tags ?? <String>[];
    currentTags.remove(tag);
    tags = currentTags;
  }
}

/// Order model for testing relationships and complex scenarios
class TestOrder extends Model<TestOrder>
    with TimestampsAndSoftDeletesMixin<TestOrder> {
  final _id = AutoIncrementField();
  final _orderNumber = StringField(unique: true, required: true);
  final _customerId = IntField(required: true);
  final _status = StringField(defaultValue: 'pending');
  final _totalAmount = DoubleField();
  final _shippingCost = DoubleField(defaultValue: 0.0);
  final _taxAmount = DoubleField(defaultValue: 0.0);
  final _discountAmount = DoubleField(defaultValue: 0.0);
  final _shippingAddress = JsonField();
  final _billingAddress = JsonField();
  final _notes = TextField();
  final _processedAt = TimestampField(nullable: true);
  final _shippedAt = TimestampField(nullable: true);
  final _deliveredAt = TimestampField(nullable: true);

  @override
  String get table => 'test_orders';

  @override
  void registerFields() {
    registerField('id', _id);
    registerField('order_number', _orderNumber);
    registerField('customer_id', _customerId);
    registerField('status', _status);
    registerField('total_amount', _totalAmount);
    registerField('shipping_cost', _shippingCost);
    registerField('tax_amount', _taxAmount);
    registerField('discount_amount', _discountAmount);
    registerField('shipping_address', _shippingAddress);
    registerField('billing_address', _billingAddress);
    registerField('notes', _notes);
    registerField('processed_at', _processedAt);
    registerField('shipped_at', _shippedAt);
    registerField('delivered_at', _deliveredAt);
    super.registerFields();
  }

  // Getters/Setters
  int? get id => _id.value;
  set id(int? value) => _id.value = value;

  String? get orderNumber => _orderNumber.value;
  set orderNumber(String? value) => _orderNumber.value = value;

  int? get customerId => _customerId.value;
  set customerId(int? value) => _customerId.value = value;

  String? get status => _status.value;
  set status(String? value) => _status.value = value;

  double? get totalAmount => _totalAmount.value;
  set totalAmount(double? value) => _totalAmount.value = value;

  double? get shippingCost => _shippingCost.value;
  set shippingCost(double? value) => _shippingCost.value = value;

  double? get taxAmount => _taxAmount.value;
  set taxAmount(double? value) => _taxAmount.value = value;

  double? get discountAmount => _discountAmount.value;
  set discountAmount(double? value) => _discountAmount.value = value;

  Map<String, dynamic>? get shippingAddress => _shippingAddress.value;
  set shippingAddress(Map<String, dynamic>? value) =>
      _shippingAddress.value = value;

  Map<String, dynamic>? get billingAddress => _billingAddress.value;
  set billingAddress(Map<String, dynamic>? value) =>
      _billingAddress.value = value;

  String? get notes => _notes.value;
  set notes(String? value) => _notes.value = value;

  DateTime? get processedAt => _processedAt.value?.toLocal();
  set processedAt(DateTime? value) => _processedAt.value = value?.toUtc();

  DateTime? get shippedAt => _shippedAt.value?.toLocal();
  set shippedAt(DateTime? value) => _shippedAt.value = value?.toUtc();

  DateTime? get deliveredAt => _deliveredAt.value?.toLocal();
  set deliveredAt(DateTime? value) => _deliveredAt.value = value?.toUtc();

  // Status methods
  void markAsProcessed() {
    status = 'processing';
    processedAt = DateTime.now();
  }

  void markAsShipped() {
    status = 'shipped';
    shippedAt = DateTime.now();
  }

  void markAsDelivered() {
    status = 'delivered';
    deliveredAt = DateTime.now();
  }

  void cancel() {
    status = 'cancelled';
  }

  // Calculated properties
  double get subtotalAmount =>
      (totalAmount ?? 0) -
      (shippingCost ?? 0) -
      (taxAmount ?? 0) +
      (discountAmount ?? 0);

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'delivered';

  static String generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    return 'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$timestamp';
  }
}
