import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tds_data_provider.dart';

class TDSGraph extends StatefulWidget {
  const TDSGraph({Key? key}) : super(key: key);

  @override
  State<TDSGraph> createState() => _TDSGraphState();
}

class _TDSGraphState extends State<TDSGraph> {
  double _zoomLevel = 1.0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.1).clamp(1.0, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.1).clamp(1.0, 3.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TDSDataProvider>(
      builder: (context, tdsProvider, _) {
        final tdsHistory = tdsProvider.tdsHistory;

        if (tdsHistory.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No historical data available'),
            ),
          );
        }

        return Column(
          children: [
            // Zoom Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: _zoomOut,
                  tooltip: 'Zoom Out',
                ),
                Text('Zoom: ${_zoomLevel.toStringAsFixed(1)}x'),
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: _zoomIn,
                  tooltip: 'Zoom In',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Graph Container
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: SizedBox(
                  width: 400 * _zoomLevel,
                  height: 300,
                  child: CustomPaint(
                    painter: TDSGraphPainter(
                      tdsHistory: tdsHistory,
                      zoomLevel: _zoomLevel,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TDSGraphPainter extends CustomPainter {
  final List<Map<String, dynamic>> tdsHistory;
  final double zoomLevel;

  TDSGraphPainter({
    required this.tdsHistory,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tdsHistory.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    // Draw grid
    for (int i = 0; i <= 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Get min and max TDS values
    final values = tdsHistory.map((e) => e['value'] as double).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    // Draw line chart
    for (int i = 0; i < tdsHistory.length - 1; i++) {
      final current = tdsHistory[i]['value'] as double;
      final next = tdsHistory[i + 1]['value'] as double;

      final x1 = (size.width / (tdsHistory.length - 1)) * i;
      final y1 = size.height -
          ((current - minValue) / (range > 0 ? range : 1)) * size.height;

      final x2 = (size.width / (tdsHistory.length - 1)) * (i + 1);
      final y2 = size.height -
          ((next - minValue) / (range > 0 ? range : 1)) * size.height;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      canvas.drawCircle(Offset(x1, y1), 3, pointPaint);
    }

    // Draw last point
    if (tdsHistory.isNotEmpty) {
      final lastValue = tdsHistory.last['value'] as double;
      final lastX =
          (size.width / (tdsHistory.length - 1)) * (tdsHistory.length - 1);
      final lastY = size.height -
          ((lastValue - minValue) / (range > 0 ? range : 1)) * size.height;
      canvas.drawCircle(Offset(lastX, lastY), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(TDSGraphPainter oldDelegate) {
    return oldDelegate.tdsHistory != tdsHistory ||
        oldDelegate.zoomLevel != zoomLevel;
  }
}