import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:http/http.dart' as http;
import 'package:tuk_meal/screens/meal/CartPage.dart';
import 'package:tuk_meal/screens/meal/MealDetailsPage.dart';
import 'package:tuk_meal/services/shared_prefs_service.dart';

class MenuTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MenuTab({super.key, required this.userData});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> with TickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color accentOrange = Color(0xFFFF6B35);

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  
  // Cart count variable
  int cartItemsCount = 0;
  
  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMoreData = true;

  List<Map<String, dynamic>> allMeals = [];
  List<Map<String, dynamic>> _filteredMeals = [];
  List<Map<String, dynamic>> _displayedMeals = [];

  String _currentMealTime = "Breakfast";
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.restaurant_menu},
    {"name": "Breakfast", "icon": Icons.free_breakfast},
    {"name": "Lunch", "icon": Icons.lunch_dining},
    {"name": "Dinner", "icon": Icons.dinner_dining},
    {"name": "Snacks", "icon": Icons.cookie},
  ];

  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _determineMealTime();
    fetchMealsData();
    _loadCartCount(); // Load cart count on init
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cart count when returning to this page
    _loadCartCount();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _determineMealTime() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      _currentMealTime = "Breakfast";
    } else if (hour >= 11 && hour < 15) {
      _currentMealTime = "Lunch";
    } else if (hour >= 15 && hour < 19) {
      _currentMealTime = "Snacks";
    } else {
      _currentMealTime = "Dinner";
    }
  }

  // Load cart count from API
  Future<void> _loadCartCount() async {
    try {
      // Check if user is logged in
      final isLoggedIn = await SharedPrefsService.isLoggedIn();
      final token = await SharedPrefsService.getToken();
      
      if (!isLoggedIn || token == null) {
        setState(() {
          cartItemsCount = 0;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/count_cart.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobile_number': token,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          setState(() {
            cartItemsCount = data['cart_count'] ?? 0;
          });
          print('MenuTab - Cart count loaded: $cartItemsCount');
        } else {
          print('MenuTab - Failed to load cart count: ${data['message']}');
          setState(() {
            cartItemsCount = 0;
          });
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('MenuTab - Error loading cart count: $e');
      setState(() {
        cartItemsCount = 0;
      });
    }
  }

  // Add to cart API integration
  Future<void> _addToCart(Map<String, dynamic> item) async {
    try {
      // Check if user is logged in
      final isLoggedIn = await SharedPrefsService.isLoggedIn();
      final token = await SharedPrefsService.getToken();
      
      if (!isLoggedIn || token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 12),
                Text('Please login to add items to cart'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'LOGIN',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to login page
                // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
              },
            ),
          ),
        );
        return;
      }

      print('MenuTab - Adding to cart: ${item['name']}');
      print('Item ID: ${item['id']}');

      // Convert string ID to integer
      final productId = int.tryParse(item['id'].toString()) ?? 0;
      
      if (productId == 0) {
        throw Exception('Invalid meal ID format');
      }

      final response = await http.post(
        Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/addcart.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobile_number': token,
          'product_id': productId,
          'quantity': 1,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          // Refresh cart count from API
          await _loadCartCount();
          
          // Add animation feedback
          if (!_fabController.isAnimating && mounted) {
            _fabController.forward().then((_) => _fabController.reverse());
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('${item["name"]} added to cart!'),
                ],
              ),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          print('MenuTab - API returned error: ${data['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(data['message'] ?? 'Failed to add to cart'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('MenuTab - Error in _addToCart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Error: ${e.toString()}'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> fetchMealsData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
        _currentPage = 1;
        _hasMoreData = true;
      });

      final response = await http
          .get(
            Uri.parse('https://tuk.onenetwork-system.com/mobileapp/v1/homefetch.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          // Combine both meals and popular meals into one list
          List<Map<String, dynamic>> combinedMeals = [];
          if (data['meals'] != null) {
            combinedMeals.addAll(List<Map<String, dynamic>>.from(data['meals']));
          }
          if (data['popular'] != null) {
            combinedMeals.addAll(List<Map<String, dynamic>>.from(data['popular']));
          }

          // Remove duplicates based on meal ID if available
          final uniqueMeals = _removeDuplicates(combinedMeals);

          setState(() {
            allMeals = uniqueMeals;
            _filteredMeals = _getFilteredMeals();
            _displayedMeals = _filteredMeals.take(_itemsPerPage).toList();
            _hasMoreData = _displayedMeals.length < _filteredMeals.length;
            isLoading = false;
          });
        } else {
          throw Exception('Invalid data format received');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().contains('SocketException') ||
                e.toString().contains('TimeoutException')
            ? 'Network error. Please check your internet connection and try again.'
            : 'Failed to load meals: $e';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _removeDuplicates(List<Map<String, dynamic>> meals) {
    final seenIds = <String>{};
    final uniqueMeals = <Map<String, dynamic>>[];
    
    for (final meal in meals) {
      final id = meal['id']?.toString() ?? meal['name']?.toString();
      if (id != null && !seenIds.contains(id)) {
        seenIds.add(id);
        uniqueMeals.add(meal);
      }
    }
    
    return uniqueMeals;
  }

  List<Map<String, dynamic>> _getFilteredMeals() {
    if (_selectedCategoryIndex == 0) {
      // Show ALL meals when "All" category is selected
      return allMeals;
    } else {
      // Show meals for selected category
      final selectedCategory = categories[_selectedCategoryIndex]["name"].toString().toLowerCase();
      return allMeals.where((meal) {
        final category = (meal["category"] ?? "").toString().toLowerCase();
        return category == selectedCategory;
      }).toList();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (isLoadingMore || !_hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      final startIndex = _currentPage * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;

      if (startIndex < _filteredMeals.length) {
        setState(() {
          _currentPage++;
          _displayedMeals.addAll(_filteredMeals.sublist(
            startIndex,
            endIndex < _filteredMeals.length ? endIndex : _filteredMeals.length,
          ));
          _hasMoreData = _displayedMeals.length < _filteredMeals.length;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMoreData = false;
          isLoadingMore = false;
        });
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredMeals = _getFilteredMeals();
      } else {
        _filteredMeals = allMeals.where((meal) {
          final name = (meal["name"] ?? "").toString().toLowerCase();
          final category = (meal["category"] ?? "").toString().toLowerCase();
          final description = (meal["description"] ?? "").toString().toLowerCase();
          return name.contains(value.toLowerCase()) ||
              category.contains(value.toLowerCase()) ||
              description.contains(value.toLowerCase());
        }).toList();
      }
      _currentPage = 1;
      _displayedMeals = _filteredMeals.take(_itemsPerPage).toList();
      _hasMoreData = _displayedMeals.length < _filteredMeals.length;
    });
  }

  void filterMealsByCategory(int categoryIndex) {
    setState(() {
      _selectedCategoryIndex = categoryIndex;
      _filteredMeals = _getFilteredMeals();
      _currentPage = 1;
      _displayedMeals = _filteredMeals.take(_itemsPerPage).toList();
      _hasMoreData = _displayedMeals.length < _filteredMeals.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: fetchMealsData,
        color: primaryGreen,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            _buildGreetingSection(),
            _buildSearchBar(),
            _buildCategorySection(),
            _buildContentSection(),
            if (isLoadingMore) _buildLoadingMoreIndicator(),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      floating: true,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Personalized Menu",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _buildAppBarButton(
          icon: Icons.shopping_cart_outlined,
          badge: cartItemsCount > 0 ? cartItemsCount.toString() : null,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          ).then((_) {
            // Refresh cart count when returning from cart page
            _loadCartCount();
          }),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    String? badge,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(icon, color: Colors.black87, size: 22),
              onPressed: onPressed,
            ),
          ),
          if (badge != null)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: accentOrange,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildGreetingSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good ${_getTimeGreeting()}, ${widget.userData['name'] ?? 'there'}!",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCategoryIndex == 0 
                ? "All meals available for you"
                : "${categories[_selectedCategoryIndex]['name']} options",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Hero(
          tag: 'menu_search_bar',
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: "Search for delicious food...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tune, color: Colors.grey[600], size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategorySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = index == _selectedCategoryIndex;
              return GestureDetector(
                onTap: () => filterMealsByCategory(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 12),
                  width: 80,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [primaryGreen, Color(0xFF0D6A0D)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? primaryGreen.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: isSelected ? 16 : 8,
                              offset: Offset(0, isSelected ? 6 : 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          category["icon"] as IconData,
                          color: isSelected ? Colors.white : Colors.grey[700],
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category["name"] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? primaryGreen : Colors.grey[700],
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    if (isLoading && _displayedMeals.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildShimmerCard(),
            childCount: 6,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return SliverToBoxAdapter(child: _buildErrorState());
    }

    if (_displayedMeals.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = _displayedMeals[index];
            return _buildFoodItemCard(item, index);
          },
          childCount: _displayedMeals.length,
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildLoadingMoreIndicator() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: primaryGreen),
              const SizedBox(height: 8),
              Text(
                'Loading more meals...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MealDetailPage(meal: item),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with blur hash
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      item["image"] ?? "",
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return BlurHash(
                          hash: "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
                          curve: Curves.easeIn,
                          duration: const Duration(milliseconds: 500),
                          imageFit: BoxFit.cover,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_selectedCategoryIndex == 0 && 
                    item["category"]?.toString().toLowerCase() == _currentMealTime.toLowerCase())
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Recommended",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          (item["rating"] ?? "0.0").toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Food details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["name"] ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item["prep_time"] ?? "N/A",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "KES ${item["price"] ?? "0"}",
                          style: const TextStyle(
                            color: primaryGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _addToCart(item),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primaryGreen, Color(0xFF0D6A0D)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... Rest of the helper methods remain the same (_buildShimmerCard, _buildErrorState, _buildEmptyState, _getTimeGreeting)
  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 16,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off, color: Colors.red, size: 64),
          ),
          const SizedBox(height: 24),
          const Text(
            "Oops! Something went wrong",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage ?? "Unable to load meals",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: fetchMealsData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: primaryGreen,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No meals found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Try selecting a different category\nor check back later for new items!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => filterMealsByCategory(0),
            icon: const Icon(Icons.refresh),
            label: const Text('View All Meals'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,
              side: const BorderSide(color: primaryGreen, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}