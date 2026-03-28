import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class ShowcaseGlassTheme {
  ShowcaseGlassTheme._();

  static const double standardLightAngle = 0.25 * math.pi;
  static const double modalLightAngle = 130.0;

  static LiquidGlassSettings get profileButtonWhite => LiquidGlassSettings(
    blur: 8,
    thickness: 10,
    ambientStrength: 0.9,
    lightIntensity: 0.9,
    lightAngle: standardLightAngle,
    glassColor: Color(0xA5616161),
  );

  static LiquidGlassSettings get profileButtonDark => LiquidGlassSettings(
    blur: 8,
    thickness: 10,
    ambientStrength: 0.9,
    lightIntensity: 0.9,
    lightAngle: modalLightAngle,
    glassColor: Color(0xA5000000),
  );

  static LiquidGlassSettings get profilePanelDark => LiquidGlassSettings(
    blur: 6,
    thickness: 1,
    ambientStrength: 0.2,
    lightIntensity: 0.2,
    lightAngle: modalLightAngle,
    glassColor: Color(0xCB000000),
  );

  static LiquidGlassSettings get profileButtonBar => LiquidGlassSettings(
    blur: 8.0,
    thickness: 45,
    ambientStrength: 0.5,
    lightIntensity: 0.1,
    lightAngle: 45,
    glassColor: Color(0xD0494949),
    refractiveIndex: 1.3,
    saturation: 1,
    chromaticAberration: 0.002,
  );

  static LiquidGlassSettings get profileButtonTopBar => LiquidGlassSettings(
    blur: 8.0,
    thickness: 25,
    ambientStrength: 0.5,
    lightIntensity: 0.1,
    lightAngle: 45,
    glassColor: Color(0xD0494949),
    refractiveIndex: 1.3,
    saturation: 1,
    chromaticAberration: 0.002,
  );

  static const GlassQuality standardQuality = GlassQuality.standard;
  static const GlassQuality premiumQuality = GlassQuality.premium;
}
