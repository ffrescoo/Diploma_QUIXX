import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';


class ShowcaseGlassTheme {
  ShowcaseGlassTheme._();

  static const double standardLightAngle = 0.25 * math.pi;
  static const double modalLightAngle = 130.0;

  static LiquidGlassSettings get profileButton => LiquidGlassSettings(
        blur: 8,
        thickness: 40,
        ambientStrength: 0.5,
        lightIntensity: 0.7,
        lightAngle: standardLightAngle,
        glassColor: Colors.white12,
      );

  static const GlassQuality standardQuality = GlassQuality.standard;
  static const GlassQuality premiumQuality = GlassQuality.premium;
}
