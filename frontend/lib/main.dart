import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/scanner_screen.dart';
import 'theme/app_theme.dart';
import 'providers/cart_provider.dart';

void main() {
  runApp(const SmartDineApp());
}

class SmartDineApp extends StatelessWidget {
  const SmartDineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Dine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const ScannerScreen(),
      ),
    );
  }
}
