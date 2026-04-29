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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading 
              ? const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.secondaryMint)),
                )
              : _orders.isEmpty
                  ? _buildEmptyState()
                  : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        title: const Text(
          'Track Your Feast',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.primarySalmon.withValues(alpha: 0.3), AppTheme.background],
                ),
              ),
            ),
            const Positioned(
              right: -30,
              top: -20,
              child: Icon(Icons.restaurant, size: 150, color: Colors.white10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.history, size: 80, color: AppTheme.glassBorder),
        const SizedBox(height: 20),
        const Text('No active orders found.', style: TextStyle(color: Colors.white70, fontSize: 18)),
      ],
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final status = order['status'];
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(25),
      decoration: AppTheme.glassDecoration(opacity: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ${order['order_number']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildStatusStepper(status),
          const SizedBox(height: 30),
          const Divider(color: Colors.white10),
          const SizedBox(height: 15),
          ...((order['items'] as List).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text('${item['quantity']}x', style: const TextStyle(color: AppTheme.secondaryMint, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 15),
                  Expanded(child: Text(item['menu_item']['name'], style: const TextStyle(color: AppTheme.textSecondary))),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(String currentStatus) {
    final steps = ['received', 'cooking', 'ready', 'delivered'];
    final currentIndex = steps.indexOf(currentStatus);

    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index <= currentIndex;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primarySalmon : AppTheme.glassColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: isActive ? AppTheme.primarySalmon : AppTheme.glassBorder, width: 2),
                  boxShadow: isActive ? [BoxShadow(color: AppTheme.primarySalmon.withValues(alpha: 0.4), blurRadius: 10)] : null,
                ),
                child: Center(
                  child: Icon(
                    _getStatusIcon(steps[index]),
                    size: 16,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive && (index < currentIndex) ? AppTheme.primarySalmon : AppTheme.glassBorder,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'received': return Colors.blueAccent;
      case 'cooking': return Colors.orangeAccent;
      case 'ready': return AppTheme.secondaryMint;
      case 'delivered': return Colors.greenAccent;
      default: return Colors.white;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'received': return Icons.receipt_long;
      case 'cooking': return Icons.soup_kitchen;
      case 'ready': return Icons.notifications_active;
      case 'delivered': return Icons.check;
      default: return Icons.timer;
    }
  }
}
