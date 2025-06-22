import 'package:flutter/material.dart';

import '../core/constants/theme_constants.dart';

class AppHeaderText extends StatelessWidget {
  const AppHeaderText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w700,
  });

  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: isDarkMode
                ? ThemeConstants.textPrimaryDark
                : ThemeConstants.textPrimaryLight,
            fontWeight: fontWeight,
            fontSize: fontSize,
          ),
      textAlign: TextAlign.center,
    );
  }
}
