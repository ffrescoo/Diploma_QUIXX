import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedMeshGradient(
            colors: const [
              Color(0xFFCCB3D1),
              Color(0xFF4C4A6C),
              Color(0xFF22052D),
              Color(0xFF000000),
            ],
            seed: 120,
            options: AnimatedMeshGradientOptions(
              speed: 1,
              frequency: 6,
              amplitude: 15,
              grain: 0.1,
            ),
          )
        ),
        child,
      ],
    );
  }
}