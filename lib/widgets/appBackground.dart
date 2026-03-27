import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {

    final List<MeshGradientPoint> points = [
      MeshGradientPoint(
        position: const Offset(0.0, 0.0),
        color: const Color(0x7C06002B),
      ),

      MeshGradientPoint(
        position: const Offset(0.9, 0.1),
        color: const Color(0xFF080025),
      ),

      MeshGradientPoint(
        position: const Offset(0.3, 0.3),
        color: const Color(0xFF000000)
      ),

      MeshGradientPoint(
        position: const Offset(0.5, 0.5),
        color: const Color(0xFFC1C1C1),
      ),

      MeshGradientPoint(
        position: const Offset(0.5, 0.9),
        color: const Color(0x7C07001E),
      ),

      MeshGradientPoint(
        position: const Offset(0.2, 0.4),
        color: const Color(0xFF000000)
      ),
    ];

    final options = MeshGradientOptions(
      blend: 4.0,
      noiseIntensity: 0.3,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: MeshGradient(
            points: points,
            options: options,
          ),
        ),
        child,
      ],
    );
  }
}