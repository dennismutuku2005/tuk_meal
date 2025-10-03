import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tuk_meal/screens/meal/CartPage.dart';
import 'package:tuk_meal/screens/meal/MealDetailsPage.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color accentOrange = Color(0xFFFF6B35);

  int _selectedCategoryIndex = 0;
  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.restaurant_menu},
    {"name": "Breakfast", "icon": Icons.free_breakfast},
    {"name": "Lunch", "icon": Icons.lunch_dining},
    {"name": "Dinner", "icon": Icons.dinner_dining},
    {"name": "Snacks", "icon": Icons.cookie},
    {"name": "Drinks", "icon": Icons.local_cafe},
  ];

  final List<Map<String, String>> bannerData = [
    {
      "url": "https://www.thecountrycook.net/wp-content/uploads/2024/01/thumbnail-Red-Beans-and-Rice-scaled.jpg",
      "title": "Hearty Meals",
      "subtitle": "Comfort food delivered fresh"
    },
    {
      "url": "https://formationsofanoblewoman.com/wp-content/uploads/2024/10/20241010_160608_00001.png",
      "title": "Daily Specials",
      "subtitle": "Don't miss today's offer!"
    },
    {
      "url": "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
      "title": "Fresh & Healthy",
      "subtitle": "Nutritious options available"
    },
  ];

  List<Map<String, dynamic>> allMeals = [];
  List<Map<String, dynamic>> popularMeals = [];
  List<Map<String, dynamic>> filteredMeals = [];
  bool isLoading = true;
  String? errorMessage;

  late PageController _bannerController;
  late Timer _bannerTimer;
  int _currentBannerPage = 0;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.9);
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fetchMealsData();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _bannerTimer.cancel();
    _fabController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = (_currentBannerPage + 1) % bannerData.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        setState(() => _currentBannerPage = nextPage);
      }
    });
  }

  Future<void> fetchMealsData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
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
          setState(() {
            allMeals = List<Map<String, dynamic>>.from(data['meals'] ?? []);
            popularMeals = List<Map<String, dynamic>>.from(data['popular'] ?? []);
            filteredMeals = allMeals;
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

  void filterMealsByCategory(int categoryIndex) {
    setState(() {
      _selectedCategoryIndex = categoryIndex;
      filteredMeals = categoryIndex == 0
          ? allMeals
          : allMeals
              .where((meal) =>
                  (meal['category'] ?? '').toLowerCase() == 
                  categories[categoryIndex]["name"].toString().toLowerCase())
              .toList();
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
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            _buildSearchBar(context),
            _buildBannerSection(),
            _buildCategorySection(),
            _buildMealsSection(context),
            if (!isLoading && errorMessage == null && popularMeals.isNotEmpty) ...[
              _buildMostLovedHeader(context),
              _buildMostLovedSection(context),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryGreen, Color(0xFF0D6A0D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "School Canteen",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "Order your favorite meal",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _buildAppBarButton(
          icon: Icons.shopping_cart_outlined,
          badge: "3",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          ),
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
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
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

  SliverToBoxAdapter _buildSearchBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Hero(
          tag: 'search_bar',
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () => showSearch(
                context: context,
                delegate: FoodSearchDelegate(foodItems: allMeals),
              ),
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
                      child: const Icon(Icons.search, color: primaryGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Search for delicious food...",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
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
      ),
    );
  }

  SliverToBoxAdapter _buildBannerSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) => setState(() => _currentBannerPage = index),
              itemCount: bannerData.length,
              itemBuilder: (context, index) {
                final banner = bannerData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: AnimatedBuilder(
                    animation: _bannerController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_bannerController.position.haveDimensions) {
                        value = _bannerController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                      }
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            banner["url"]!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return _buildShimmer();
                            },
                            errorBuilder: (context, error, trace) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, color: Colors.grey, size: 40),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            bottom: 24,
                            right: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentOrange,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "🔥 HOT DEAL",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  banner["title"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  banner["subtitle"]!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              bannerData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentBannerPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentBannerPage == index ? primaryGreen : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildMealsSection(BuildContext context) {
    if (isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildShimmerCard(),
            ),
            childCount: 4,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return SliverToBoxAdapter(
        child: _buildErrorState(),
      );
    }

    if (filteredMeals.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = filteredMeals[index];
            return _buildMealCard(context, item, index);
          },
          childCount: filteredMeals.length,
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> item, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
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
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: Stack(
                  children: [
                    _buildMealImage(item["image"], width: 120, height: 140),
                    if (item["trending"] == true)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.local_fire_department,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 2),
                              Text(
                                "Trending",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"] ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item["description"] != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          item["description"],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  item["rating"]?.toString() ?? "0.0",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, color: Colors.grey[400], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            item["prep_time"] ?? "N/A",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "KES ${item["price"] ?? "0"}",
                            style: const TextStyle(
                              color: primaryGreen,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildAddButton(item),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(Map<String, dynamic> item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Add haptic feedback and animation
          _fabController.forward().then((_) => _fabController.reverse());
          // Add to cart logic here
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
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryGreen, Color(0xFF0D6A0D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMostLovedHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text(
                  "❤️",
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(width: 8),
                Text(
                  "Most Loved",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => filterMealsByCategory(0),
              style: TextButton.styleFrom(
                foregroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Row(
                children: [
                  Text(
                    "View all",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMostLovedSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: popularMeals.length,
          itemBuilder: (context, index) {
            final item = popularMeals[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MealDetailPage(meal: item)),
              ),
              child: Container(
                width: 180,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Stack(
                        children: [
                          _buildMealImage(item["image"], width: 180, height: 140),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    item["rating"]?.toString() ?? "0.0",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (item["category"] != null)
                                  Text(
                                    item["category"],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: primaryGreen,
                                    size: 18,
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
          },
        ),
      ),
    );
  }

  Widget _buildMealImage(String? imageUrl, {double width = 120, double height = 120}) {
    return Image.network(
      imageUrl ?? "",
      height: height,
      width: width,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildShimmer(width: width, height: height);
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              "No image",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1500),
        tween: Tween<double>(begin: -1, end: 2),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(value * 200, 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
        onEnd: () => setState(() {}),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildShimmer(width: 120, height: 140),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 20,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
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
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
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
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
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
}

class FoodSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> foodItems;

  FoodSearchDelegate({required this.foodItems});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final results = query.isEmpty
        ? foodItems.take(10).toList()
        : foodItems
            .where((item) =>
                (item["name"] ?? "").toLowerCase().contains(query.toLowerCase()) ||
                (item["category"] ?? "").toLowerCase().contains(query.toLowerCase()))
            .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No results found for '$query'",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item["image"] ?? "",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              item["name"] ?? "Unknown",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  "KES ${item["price"] ?? "0"}",
                  style: const TextStyle(
                    color: Color(0xFF0F7B0F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(item["rating"]?.toString() ?? "0.0"),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              close(context, null);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailPage(meal: item),
                ),
              );
            },
          ),
        );
      },
    );
  }
}