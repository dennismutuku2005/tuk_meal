import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:tuk_meal/screens/meal/CartPage.dart';
import 'package:tuk_meal/screens/meal/MealDetailsPage.dart';

class MenuTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MenuTab({super.key, required this.userData});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  static const Color primaryGreen = Color(0xFF0F7B0F);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  List<Map<String, dynamic>> _allFoodItems = [];
  List<Map<String, dynamic>> _filteredFoodItems = [];
  List<Map<String, dynamic>> _displayedFoodItems = [];

  String _currentMealTime = "Breakfast";

  @override
  void initState() {
    super.initState();
    _determineMealTime();
    _loadFoodItems();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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

  void _loadFoodItems() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(milliseconds: 800), () {
      List<Map<String, dynamic>> newItems = [
        {
          "name": "Chapo Beans",
          "price": 70,
          "rating": 4.5,
          "calories": 450,
          "prepTime": "15 min",
          "category": "Breakfast",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": true,
        },
        {
          "name": "Ugali Nyama",
          "price": 120,
          "rating": 4.8,
          "calories": 620,
          "prepTime": "25 min",
          "category": "Lunch",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": true,
        },
        {
          "name": "Rice Ndengu",
          "price": 90,
          "rating": 4.2,
          "calories": 520,
          "prepTime": "20 min",
          "category": "Lunch",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": false,
        },
        {
          "name": "Mandazi Chai",
          "price": 50,
          "rating": 4.7,
          "calories": 320,
          "prepTime": "10 min",
          "category": "Breakfast",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": true,
        },
        {
          "name": "Chapati & Beans",
          "price": 80,
          "rating": 4.6,
          "calories": 480,
          "prepTime": "15 min",
          "category": "Dinner",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": true,
        },
        {
          "name": "Pilau Beef",
          "price": 150,
          "rating": 4.9,
          "calories": 680,
          "prepTime": "30 min",
          "category": "Lunch",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": false,
        },
        {
          "name": "Fruit Salad",
          "price": 60,
          "rating": 4.3,
          "calories": 180,
          "prepTime": "5 min",
          "category": "Snacks",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": true,
        },
        {
          "name": "Vegetable Curry",
          "price": 85,
          "rating": 4.4,
          "calories": 380,
          "prepTime": "20 min",
          "category": "Dinner",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": false,
        },
        {
          "name": "Chicken Stew",
          "price": 130,
          "rating": 4.7,
          "calories": 550,
          "prepTime": "25 min",
          "category": "Lunch",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": true,
        },
        {
          "name": "Tea with Snacks",
          "price": 40,
          "rating": 4.2,
          "calories": 220,
          "prepTime": "5 min",
          "category": "Snacks",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": false,
        },
      ];

      for (int i = 0; i < 20; i++) {
        newItems.add({
          "name": "Special Meal ${i + 1}",
          "price": 100 + (i * 10),
          "rating": 4.0 + (i * 0.1),
          "calories": 400 + (i * 50),
          "prepTime": "${10 + (i % 15)} min",
          "category": i % 4 == 0 ? "Breakfast" : i % 4 == 1 ? "Lunch" : i % 4 == 2 ? "Dinner" : "Snacks",
          "image": "https://i.pinimg.com/736x/16/55/34/1655344a57f56f0815b6579bc8201405.jpg",
          "blurHash": "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
          "isRecommended": i % 3 == 0,
        });
      }

      setState(() {
        _allFoodItems = newItems;
        _filteredFoodItems = _getRecommendedItems();
        _displayedFoodItems = _filteredFoodItems.take(_itemsPerPage).toList();
        _isLoading = false;
      });
    });
  }

  List<Map<String, dynamic>> _getRecommendedItems() {
    return _allFoodItems.where((item) {
      return item["category"] == _currentMealTime || item["isRecommended"];
    }).toList();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _currentPage++;
        int startIndex = (_currentPage - 1) * _itemsPerPage;
        int endIndex = startIndex + _itemsPerPage;

        if (startIndex < _filteredFoodItems.length) {
          if (endIndex > _filteredFoodItems.length) {
            endIndex = _filteredFoodItems.length;
          }
          _displayedFoodItems.addAll(_filteredFoodItems.sublist(startIndex, endIndex));
        }
        _isLoading = false;
      });
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredFoodItems = _getRecommendedItems();
      } else {
        _filteredFoodItems = _allFoodItems.where((item) {
          return item["name"].toLowerCase().contains(value.toLowerCase());
        }).toList();
      }
      _currentPage = 1;
      _displayedFoodItems = _filteredFoodItems.take(_itemsPerPage).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            floating: true,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Text(
              "Personalized Menu",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.black87, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage()),
                  );
                },
              ),
              SizedBox(width: 8),
            ],
          ),

          // Time-based greeting and recommendation
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good ${_getTimeGreeting()}, ${widget.userData['name'] ?? 'there'}!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Recommended $_currentMealTime options for you",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search for food...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Food items grid
          if (_displayedFoodItems.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _displayedFoodItems[index];
                    return _buildFoodItemCard(item, index);
                  },
                  childCount: _displayedFoodItems.length,
                ),
              ),
            )
          else if (!_isLoading)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "No food items found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(color: primaryGreen),
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

  Widget _buildFoodItemCard(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailPage(meal: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: Offset(0, 4),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      item["image"],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return BlurHash(
                          hash: item["blurHash"] ?? "L9BX]k}@D*D*~qD%M{RjD%M{Rj-;",
                          curve: Curves.easeIn,
                          duration: Duration(milliseconds: 500),
                          imageFit: BoxFit.cover,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.error, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                if (item["isRecommended"])
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
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
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 2),
                        Text(
                          item["rating"].toString(),
                          style: TextStyle(
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["name"],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        item["prepTime"],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.local_fire_department, size: 12, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        "${item["calories"]} cal",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "KES ${item["price"]}",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}