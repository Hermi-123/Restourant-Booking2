import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/menu_models.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> _menuItems = [];
  List<dynamic> _recommendations = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _isLoadingRecs = true;

  final List<String> _categories = [
    'All',
    'Bite-sized Joy',
    'The Main Event',
    'Sweet Endings',
    'Liquid Love',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenu();
    _loadRecommendations();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    final items = await ApiService.getMenuItems(
        _selectedCategory == 'All' ? null : _selectedCategory);
    if (mounted) {
      setState(() {
        _menuItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecommendations() async {
    final recs = await ApiService.getRecommendations();
    if (mounted) {
      setState(() {
        _recommendations = recs;
        _isLoadingRecs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Smart Dine',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: AppTheme.primarySalmon,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              'View Feast (${cart.itemCount})',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chef's Recommendations Section
            if (!_isLoadingRecs && _recommendations.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.primarySalmon, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Chef's Recommendations",
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final item = _recommendations[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        width: 160,
                        child: _buildItemCard(item, isCompact: true),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'What are you craving?',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 18,
                ),
              ),
            ),
            
            // Category Filter
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategory == _categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primarySalmon,
                      backgroundColor: AppTheme.surfaceColor,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = _categories[index];
                        });
                        _loadMenu();
                      },
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Menu Grid
            _isLoading 
              ? SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator(color: AppTheme.accentTeal)),
                )
              : AnimationLimiter(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: _buildItemCard(item),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item, {bool isCompact = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: isCompact ? Border.all(color: AppTheme.primarySalmon.withValues(alpha: 0.3), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=400'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isCompact ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isCompact ? 2 : 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item['price']}',
                      style: TextStyle(
                        color: AppTheme.accentTeal,
                        fontSize: isCompact ? 14 : 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          '~${item['prep_time'] ?? 10}m',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isCompact ? 5 : 10),
                SizedBox(
                  width: double.infinity,
                  height: isCompact ? 30 : null,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primarySalmon.withValues(alpha: 0.1),
                      foregroundColor: AppTheme.primarySalmon,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                      ),
                    ),
                    onPressed: () {
                      final menuItem = MenuItem.fromJson(item);
                      Provider.of<CartProvider>(context, listen: false).addItem(menuItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item['name']} added to feast!'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text('Add to Feast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isCompact ? 12 : 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
