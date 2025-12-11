import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Speedometer extends StatelessWidget {
  final double speed;

  const Speedometer({super.key, required this.speed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 180,
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 0.15,
              thicknessUnit: GaugeSizeUnit.factor,
              color: Colors.white,
            ),

            pointers: [
              NeedlePointer(
                value: speed,
                needleLength: 0.7,
                needleStartWidth: 0,
                needleEndWidth: 1,
                knobStyle: KnobStyle(
                  knobRadius: 0.05,
                  borderWidth: 0,
                  color: Colors.white,
                  borderColor: Colors.white,
                ),
                tailStyle: TailStyle(
                  width: 2,
                  length: 0.2,
                  color: Colors.white,
                  borderColor: Colors.white,
                ),
              ),
            ],
            ranges: [
              GaugeRange(
                startValue: 0,
                endValue: 180,
                startWidth: 0.15,
                endWidth: 0.15,
                color: Colors.white,
                rangeOffset: 0.05,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
