import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CustomMarkerPointer extends StatelessWidget {
  final double value;
  final MarkerType markerType;
  final Color color;
  final double markerHeight;
  final double markerWidth;
  final String annotationText;

  CustomMarkerPointer({
    required this.value,
    this.markerType = MarkerType.triangle,
    this.color = Colors.black,
    this.markerHeight = 20,
    this.markerWidth = 20,
    this.annotationText = '',
  });

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 1,
          maximum: 10,
          ranges: <GaugeRange>[
            GaugeRange(startValue: -5, endValue: 3, color: Colors.blue),
            GaugeRange(startValue: 3, endValue: 8, color: Colors.green),
            GaugeRange(startValue: 8, endValue: 9.5, color: Colors.orange),
            GaugeRange(startValue: 9.5, endValue: 20, color: Colors.red),
          ],
          pointers: <GaugePointer>[
            MarkerPointer(
              value: value,
              markerType: markerType,
              color: color,
              markerHeight: markerHeight,
              markerWidth: markerWidth,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Container(
                child: Text(
                  annotationText,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              angle: 90,
              positionFactor: 0.5,
            ),
          ],
        ),
      ],
    );
  }
}
