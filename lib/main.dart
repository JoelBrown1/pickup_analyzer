import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/screens/analyzer_screen.dart';

void main() {
  runApp(const ProviderScope(child: PickupAnalyzerApp()));
}

class PickupAnalyzerApp extends StatelessWidget {
  const PickupAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickup Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF58A6FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const AnalyzerScreen(),
    );
  }
}
