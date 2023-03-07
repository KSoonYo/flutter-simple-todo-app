import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme.highContrastLight(
    background: Color(0xfffffbff),
    primary: Color(0xff4455BA),
    onPrimaryContainer: Color(0xff000f5d),
    inversePrimary: Color(0xffbbc3ff),
    outline: Color(0xff767680),
    secondary: Color(0xff5b5d72),
    secondaryContainer: Color(0xffE0E1F9),
    tertiary: Color(0xff77536d),
    error: Color(0xffBA1A1A),
    errorContainer: Color(0xffffdad6),
    onErrorContainer: Color(0xff410002),
    surfaceTint: Color(0xff4455ba),
    onSurface: Color(0xff1B1B1F),
    onInverseSurface: Color(0xfff3f0f4),
    onSurfaceVariant: Color(0xff46464F));

ColorScheme _selectedlightColorScheme = lightColorScheme;

ColorScheme get selectedlightkColorScheme => _selectedlightColorScheme;
set selectedlightColorScheme(ColorScheme? dynamiclightColors) {
  if (dynamiclightColors == null) return;
  _selectedlightColorScheme = dynamiclightColors;
}
