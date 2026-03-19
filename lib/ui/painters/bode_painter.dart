import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../dsp/bode_data.dart';
import '../../dsp/peak_detector.dart';

const _dbMin = -80.0;
const _dbMax = 0.0;
const _freqMin = 20.0;

const _gridFreqs = [50.0, 100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0, 10000.0, 20000.0];
const _gridDbs = [0.0, -20.0, -40.0, -60.0, -80.0];

class BodePainter extends CustomPainter {
  final BodeData? bodeData;
  final List<SpectralPeak> peaks;

  const BodePainter({required this.bodeData, required this.peaks});

  double _freqToX(double freq, double width) {
    final fMax = bodeData != null ? bodeData!.nyquist : 22050.0;
    if (freq <= _freqMin) return 0;
    if (freq >= fMax) return width;
    return log(freq / _freqMin) / log(fMax / _freqMin) * width;
  }

  double _dbToY(double db, double height) {
    return (1 - (db - _dbMin) / (_dbMax - _dbMin)) * height;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawBackground(canvas, size);
    _drawGrid(canvas, size);
    if (bodeData != null) {
      _drawSpectrum(canvas, size);
      _drawPeaks(canvas, size);
    }
    _drawAxisLabels(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0D1117),
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = const Color(0xFF21262D)
      ..strokeWidth = 1;

    for (final freq in _gridFreqs) {
      final x = _freqToX(freq, w);
      canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
    }

    for (final db in _gridDbs) {
      final y = _dbToY(db, h);
      canvas.drawLine(Offset(0, y), Offset(w, y), paint);
    }
  }

  void _drawSpectrum(Canvas canvas, Size size) {
    final data = bodeData!;
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = const Color(0xFF58A6FF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF58A6FF).withOpacity(0.3),
          const Color(0xFF58A6FF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final linePath = Path();
    final fillPath = Path();
    bool first = true;

    for (var i = 0; i < data.numBins; i++) {
      final freq = data.frequencies[i];
      if (freq < _freqMin) continue;

      final db = data.magnitudeDb(i).clamp(_dbMin, _dbMax);
      final x = _freqToX(freq, w);
      final y = _dbToY(db, h);

      if (first) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, h);
        fillPath.lineTo(x, y);
        first = false;
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    if (!first) {
      final lastFreq = data.frequencies[data.numBins - 1];
      fillPath.lineTo(_freqToX(lastFreq, w), h);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(linePath, linePaint);
    }
  }

  void _drawPeaks(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final linePaint = Paint()
      ..color = const Color(0xFFF78166)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const textStyle = TextStyle(
      color: Color(0xFFF78166),
      fontSize: 10,
      fontFeatures: [FontFeature.tabularFigures()],
    );

    for (final peak in peaks) {
      final x = _freqToX(peak.frequency, w);
      canvas.drawLine(Offset(x, 0), Offset(x, h), linePaint);

      final db = (20 * log(peak.magnitude) / ln10).clamp(_dbMin, _dbMax);
      final y = _dbToY(db, h);

      final label = '${peak.frequency.toStringAsFixed(0)} Hz';
      final span = TextSpan(text: label, style: textStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
        ..layout();

      var labelX = x + 3;
      if (labelX + tp.width > w) labelX = x - tp.width - 3;
      tp.paint(canvas, Offset(labelX, (y - tp.height - 2).clamp(0, h - tp.height)));
    }
  }

  void _drawAxisLabels(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const freqStyle = TextStyle(color: Color(0xFF8B949E), fontSize: 9);
    const dbStyle = TextStyle(color: Color(0xFF8B949E), fontSize: 9);

    for (final freq in _gridFreqs) {
      final x = _freqToX(freq, w);
      final label = freq >= 1000 ? '${(freq / 1000).toStringAsFixed(0)}k' : freq.toStringAsFixed(0);
      final tp = TextPainter(
        text: TextSpan(text: label, style: freqStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, h - tp.height - 2));
    }

    for (final db in _gridDbs) {
      final y = _dbToY(db, h);
      final label = '${db.toStringAsFixed(0)}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: dbStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(BodePainter old) =>
      !identical(old.bodeData, bodeData) || !identical(old.peaks, peaks);
}
