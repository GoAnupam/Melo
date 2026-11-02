import 'package:flutter/painting.dart';

/// Melo colour tokens.
///
/// A deliberately small palette: warm ivory surfaces, one deep plum brand
/// colour, and warm near-black ink. Avoid introducing new colours in feature
/// code — add a token here instead.
abstract final class AppColors {
  // Brand
  static const plum = Color(0xFF5A1E3E);
  static const plumPressed = Color(0xFF461630);
  // Selected chips, subtle highlights.
  static const plumSoft = Color(0xFFF2E6EC);
  static const plumMuted = Color(0xFFB98CA3); // decorative accents only

  // Surfaces
  static const ivory = Color(0xFFFBF7F2); // app background
  static const surface = Color(0xFFFFFDFA); // cards, inputs
  static const sand = Color(0xFFF2EBE3); // subtle neutral fills
  static const sandDeep = Color(0xFFE7DDD2);
  static const border = Color(0xFFE5DBD1);

  // Ink
  static const ink = Color(0xFF1C1517);
  static const inkMuted = Color(0xFF6B6064);
  static const inkSubtle = Color(0xFF9D9296);
  static const onPlum = Color(0xFFFFF8F3);

  // Feedback
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF2F6B4F);
}
