import 'package:flutter/material.dart';

/// Design tokens and color palette for RunMate
class AppColors {
  AppColors._();

  // Primary & Accents
  static const Color mint = Color(0xFFB8E5DE);
  static const Color primaryTeal = Color(0xFF77CFC3);
  static const Color darkNavigation = Color(0xFF0D0D0D);
  static const Color primaryText = Color(0xFF111111);

  // Light Surfaces
  static const Color background = Color(0xFFF3F4F4);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color secondarySurface = Color(0xFFE9ECEC);
  static const Color secondaryButton = Color(0xFFE8ECEB);

  // Supporting Semantic Colors
  static const Color success = Color(0xFF65C7A7);
  static const Color warning = Color(0xFFF2C76B);
  static const Color danger = Color(0xFFEA7777);
  static const Color mutedText = Color(0xFF8C9292);
  static const Color divider = Color(0xFFE4E7E7);

  // Dark Mode Tokens
  static const Color darkBackground = Color(0xFF111313);
  static const Color darkCard = Color(0xFF1B1E1E);
  static const Color darkSecondarySurface = Color(0xFF242929);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkMutedText = Color(0xFFA8B0AE);
  static const Color darkMint = Color(0xFF9EDFD5);
  static const Color darkDivider = Color(0xFF282D2D);

  // Gradients
  static const LinearGradient mintTealGradient = LinearGradient(
    colors: [mint, primaryTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E2222), Color(0xFF161818)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroMintGradient = LinearGradient(
    colors: [Color(0xFFC6ECE7), Color(0xFFA8E0D7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
