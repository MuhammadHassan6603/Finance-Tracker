import 'package:finance_tracker/presentation/views/portfolio_screen/widgets/assets_laibilities_list.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../../core/constants/theme_constants.dart';

class AssetsLiabilityCart extends StatelessWidget {
  const AssetsLiabilityCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetLiabilityViewModel>(
      builder: (context, viewModel, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final total = viewModel.totalAssets + viewModel.totalLiabilities;

        return Row(
          children: [
            // Pie Chart
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 150,
                child: PieChart(
                  swapAnimationDuration: const Duration(milliseconds: 300),
                  swapAnimationCurve: Curves.easeInOut,
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: viewModel.totalAssets,
                        color: ThemeConstants.primaryColor.withOpacity(0.7),
                        title:
                            '${(viewModel.totalAssets / total * 100).toStringAsFixed(1)}%',
                        radius: 35,
                        titleStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      PieChartSectionData(
                        value: viewModel.totalLiabilities,
                        color: isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                        title:
                            '${(viewModel.totalLiabilities / total * 100).toStringAsFixed(1)}%',
                        radius: 35,
                        titleStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    sectionsSpace: 0,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
            ),
            // Assets and Liabilities List
            const Expanded(
              flex: 3,
              child: AssetLiabilitiesList(),
            ),
          ],
        );
      },
    );
  }
}
