import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  List<dynamic> _orders = [];
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // Poll the backend every 10 seconds for real-time tracking
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchOrders();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final orders = await ApiService.getSessionOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  Widget _buildStatusIndicator(String currentStatus, String targetStatus, String label, IconData icon) {
    bool isCompleted = false;
    bool isActive = false;

    // Ordered logic for statuses
    List<String> statuses = ['received', 'cooking', 'ready', 'delivered'];
    int currentIndex = statuses.indexOf(currentStatus);
    int targetIndex = statuses.indexOf(targetStatus);

    if (currentIndex > targetIndex) {
      isCompleted = true;
    } else if (currentIndex == targetIndex) {
      isActive = true;
    }

    Color color = isCompleted 
        ? AppTheme.accentTeal 
        : (isActive ? AppTheme.primarySalmon : AppTheme.textSecondary.withValues(alpha: 0.3));

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isActive ? 0.2 : 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: isActive ? 3 : 1),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Track Your Feast',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppTheme.accentTeal))
        : _orders.isEmpty
          ? Center(
              child: Text(
                'No orders placed yet.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order['order_number']}',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${order['total_price']}',
                            style: TextStyle(
                              color: AppTheme.accentTeal,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusIndicator(order['status'], 'received', 'Received', Icons.receipt),
                          _buildStatusIndicator(order['status'], 'cooking', 'Cooking', Icons.soup_kitchen),
                          _buildStatusIndicator(order['status'], 'ready', 'Ready', Icons.room_service),
                          _buildStatusIndicator(order['status'], 'delivered', 'Delivered', Icons.check_circle),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      Text(
                        'Items:',
                        style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...((order['items'] as List).map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item['quantity']}x ${item['menu_item']['name']}',
                                style: TextStyle(color: AppTheme.textPrimary),
                              ),
                              Text(
                                '\$${item['price']}',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
