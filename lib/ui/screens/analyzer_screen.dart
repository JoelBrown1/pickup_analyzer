import 'package:flutter/material.dart';

import '../widgets/bode_chart.dart';
import '../widgets/device_picker.dart';
import '../widgets/peak_list.dart';
import '../widgets/record_button.dart';

class AnalyzerScreen extends StatelessWidget {
  const AnalyzerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010409),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: const Color(0xFFE6EDF3),
        title: const Text('Pickup Analyzer', style: TextStyle(fontSize: 16)),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DevicePicker(),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: BodeChart()),
            SizedBox(height: 12),
            PeakList(),
            SizedBox(height: 16),
            RecordButton(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
