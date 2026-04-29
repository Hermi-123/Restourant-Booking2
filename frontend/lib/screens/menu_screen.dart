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
  String _selectedCategory = 'All';
  bool _isLoading = true;

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: AppTheme.accentTeal))
              : AnimationLimiter(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
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
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item['price']}',
                      style: TextStyle(
                        color: AppTheme.accentTeal,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '~${item['prep_time'] ?? 10}m',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primarySalmon.withValues(alpha: 0.1),
                      foregroundColor: AppTheme.primarySalmon,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
                    child: const Text('Add to Feast', style: TextStyle(fontWeight: FontWeight.bold)),
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
