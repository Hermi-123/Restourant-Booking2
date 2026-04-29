import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  List<dynamic> _orders = [];
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // Poll the backend every 10 seconds for real-time kitchen updates
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
    final orders = await ApiService.getStaffOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    bool success = await ApiService.updateOrderStatus(orderId, newStatus);
    if (success) {
      _fetchOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order marked as $newStatus!')),
        );
      }
    }
  }

  Widget _buildStatusButton(String currentStatus, String targetStatus, String label, String orderId) {
    bool isActive = currentStatus == targetStatus;
    
    // Define logic for what the next status should be
    List<String> flow = ['received', 'cooking', 'ready', 'delivered'];
    int currentIndex = flow.indexOf(currentStatus);
    int targetIndex = flow.indexOf(targetStatus);
    
    bool isNext = targetIndex == currentIndex + 1;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive 
            ? AppTheme.accentTeal 
            : (isNext ? AppTheme.primarySalmon : AppTheme.surfaceColor),
        foregroundColor: (isActive || isNext) ? Colors.white : AppTheme.textSecondary,
        elevation: isActive || isNext ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: isNext ? () => _updateStatus(orderId, targetStatus) : null,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'Kitchen Dashboard',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppTheme.accentTeal))
        : _orders.isEmpty
          ? Center(
              child: Text(
                'No active orders right now.',
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
                    border: Border.all(
                      color: order['status'] == 'ready' 
                          ? AppTheme.accentTeal.withValues(alpha: 0.5) 
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
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
                            'Table ${order['session']['table']['table_number'] ?? '?'}',
                            style: TextStyle(
                              color: AppTheme.primarySalmon,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '#${order['order_number']}',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 15),
                      ...((order['items'] as List).map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.textSecondary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${item['quantity']}x',
                                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  item['menu_item']['name'],
                                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusButton(order['status'], 'cooking', 'Start Cooking', order['id']),
                          _buildStatusButton(order['status'], 'ready', 'Mark Ready', order['id']),
                          _buildStatusButton(order['status'], 'delivered', 'Delivered', order['id']),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
