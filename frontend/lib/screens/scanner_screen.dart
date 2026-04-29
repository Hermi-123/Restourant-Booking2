import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'menu_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool isLoading = false;

  void _onScan(String code) async {
    setState(() => isLoading = true);
    final session = await ApiService.startSession(code);
    setState(() => isLoading = false);

    if (session != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR Code. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.darkBg, Color(0xFF000000)],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  child: const Icon(Icons.restaurant_menu, size: 80, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  child: Text(
                    'Smart Dine',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Step in, scan your table, and start the feast.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(height: 60),
                FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        const Center(child: Icon(Icons.qr_code_scanner, size: 100, color: Colors.white24)),
                        if (isLoading)
                          const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: ElevatedButton(
                    onPressed: () => _onScan('TABLE1'), // Simulation
                    child: const Text("CLAIM TABLE #1 & LET'S EAT!"),
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
