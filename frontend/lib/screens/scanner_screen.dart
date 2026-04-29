import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'menu_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isProcessing = false;

  Future<void> _mockScan() async {
    setState(() => _isProcessing = true);
    
    // Simulate QR processing
    final session = await ApiService.startSession('TABLE_1');
    
    if (mounted) {
      if (session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuScreen()),
        );
      } else {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to identify table. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Elegant Background Pattern
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.primarySalmon.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Premium Logo/Icon
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: AppTheme.glassDecoration(opacity: 0.05),
                  child: Column(
                    children: [
                      const Icon(Icons.restaurant_menu_rounded, size: 80, color: AppTheme.primarySalmon),
                      const SizedBox(height: 20),
                      Text(
                        'FINE DINE',
                        style: AppTheme.darkTheme.textTheme.headlineLarge?.copyWith(
                          letterSpacing: 8,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                Text(
                  'Your table is ready.',
                  style: AppTheme.darkTheme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 15),
                Text(
                  'Scan the QR code on your table to browse our exclusive menu.',
                  textAlign: TextAlign.center,
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(flex: 2),
                
                // Animated Scan Button
                GestureDetector(
                  onTap: _isProcessing ? null : _mockScan,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isProcessing ? AppTheme.surface : AppTheme.primarySalmon,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primarySalmon.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: _isProcessing 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.qr_code_scanner_rounded, size: 45, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'TAP TO SCAN',
                  style: TextStyle(
                    color: AppTheme.primarySalmon,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
