import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color surfaceOverlay;
  final Color surfaceBorder;
  final Color statIconColor;
  final Color logoutBg;
  final Color logoutBorder;
  final Color logoutText;

  const CustomColors({
    required this.surfaceOverlay,
    required this.surfaceBorder,
    required this.statIconColor,
    required this.logoutBg,
    required this.logoutBorder,
    required this.logoutText,
  });

  @override
  CustomColors copyWith({
    Color? surfaceOverlay,
    Color? surfaceBorder,
    Color? statIconColor,
    Color? logoutBg,
    Color? logoutBorder,
    Color? logoutText,
  }) {
    return CustomColors(
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      statIconColor: statIconColor ?? this.statIconColor,
      logoutBg: logoutBg ?? this.logoutBg,
      logoutBorder: logoutBorder ?? this.logoutBorder,
      logoutText: logoutText ?? this.logoutText,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      statIconColor: Color.lerp(statIconColor, other.statIconColor, t)!,
      logoutBg: Color.lerp(logoutBg, other.logoutBg, t)!,
      logoutBorder: Color.lerp(logoutBorder, other.logoutBorder, t)!,
      logoutText: Color.lerp(logoutText, other.logoutText, t)!,
    );
  }

  static const light = CustomColors(
    surfaceOverlay: Color(0x12000000), // onSurface.withValues(alpha: 0.07)
    surfaceBorder: Color(0x0F000000),  // onSurface.withValues(alpha: 0.06)
    statIconColor: Color(0x61000000),  // onSurface.withValues(alpha: 0.38)
    logoutBg: Color(0x14FF0000),      // Colors.red.withValues(alpha: 0.08)
    logoutBorder: Color(0x26FF0000),  // Colors.red.withValues(alpha: 0.15)
    logoutText: Colors.redAccent,
  );

  static const dark = CustomColors(
    surfaceOverlay: Color(0x12FFFFFF), // onSurface.withValues(alpha: 0.07)
    surfaceBorder: Color(0x0FFFFFFF),  // onSurface.withValues(alpha: 0.06)
    statIconColor: Color(0x61FFFFFF),  // onSurface.withValues(alpha: 0.38)
    logoutBg: Color(0x14FF5252),      // Colors.red.withValues(alpha: 0.08)
    logoutBorder: Color(0x26FF5252),  // Colors.red.withValues(alpha: 0.15)
    logoutText: Colors.redAccent,
  );
}
