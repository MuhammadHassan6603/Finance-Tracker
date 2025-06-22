import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../../viewmodels/budget_viewmodel.dart';
import '../../../../widgets/line_chart_widget.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../widgets/app_header_text.dart';
import 'progress_indicator_widget.dart';

class AnalyticsRow extends StatelessWidget {
  const AnalyticsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Container(
          height: 155,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeConstants.primaryColor,
                ThemeConstants.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const ProgressIndicatorWidget(),
        ),
      ],
    );
  }
}
