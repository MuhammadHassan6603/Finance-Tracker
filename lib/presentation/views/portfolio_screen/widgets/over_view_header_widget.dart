import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../data/models/asset_liability_model.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';

class OverviewHeader extends StatelessWidget {
  const OverviewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Consumer<AssetLiabilityViewModel>(
      builder: (context, viewModel, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final healthStatus = viewModel.financialHealthStatus;
        final healthColor = viewModel.healthColor;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: healthColor.withOpacity(isDarkMode ? 0.3 : 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${local.financialHealth} ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? ThemeConstants.textSecondaryDark
                                  : ThemeConstants.textSecondaryLight,
                            ),
                      ),
                      Text(
                        healthStatus,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: healthColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => _showReportDialog(context),
              icon: Icon(
                Icons.analytics_outlined,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              tooltip: 'View Reports',
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final local = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDarkMode ? ThemeConstants.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppHeaderText(text: local.portfolioAnalysis, fontSize: 20),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showNetWorthTrendsDetail(context);
                      },
                      child: _buildReportSection(
                        context,
                        local.netWorthTrend,
                        local.trackNetWorthChanges,
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showAssetPerformanceDetail(context);
                      },
                      child: _buildReportSection(
                        context,
                        local.assetPerformance,
                        local.analyzeAssetsGrowth,
                        Icons.pie_chart,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showLiabilityAnalysisDetail(context);
                      },
                      child: _buildReportSection(
                        context,
                        local.liabilityAnalysis,
                        local.monitorDebtProgress,
                        Icons.show_chart,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showFinancialInsightsDetail(context);
                      },
                      child: _buildReportSection(
                        context,
                        local.financialInsights,
                        local.personalizedRecommendations,
                        Icons.lightbulb_outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNetWorthTrendsDetail(BuildContext context) {
    final viewModel =
        Provider.of<AssetLiabilityViewModel>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final netWorthData = viewModel.netWorthHistory;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final local = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDarkMode ? ThemeConstants.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.netWorthTrends,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    Card(
                      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              local.currentNetWorth,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormat.format(viewModel.netWorth),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              spacing: 5,
                              children: [
                                _buildMetricCard(
                                  context,
                                  local.oneMonthGrowth,
                                  '${viewModel.oneMonthGrowth.toStringAsFixed(1)}%',
                                  viewModel.oneMonthGrowth >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                _buildMetricCard(
                                  context,
                                  local.sixMonthGrowth,
                                  '${viewModel.sixMonthGrowth.toStringAsFixed(1)}%',
                                  viewModel.sixMonthGrowth >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                _buildMetricCard(
                                  context,
                                  local.oneYearGrowth,
                                  '${viewModel.oneYearGrowth.toStringAsFixed(1)}%',
                                  viewModel.oneYearGrowth >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      local.netWorthHistory,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${Helpers.storeCurrency(context)}${(value / 1000).toStringAsFixed(0)}K',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < netWorthData.length) {
                                    final date =
                                        netWorthData[value.toInt()].date;
                                    return Text(
                                      DateFormat('MMM yy').format(date),
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: netWorthData
                                  .mapIndexed((index, data) =>
                                      FlSpot(index.toDouble(), data.amount))
                                  .toList(),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppHeaderText(
                        text: local.monthlyBreakdown,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    const SizedBox(height: 16),
                    ..._buildMonthlyBreakdown(context, netWorthData),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssetPerformanceDetail(BuildContext context) {
    final viewModel =
        Provider.of<AssetLiabilityViewModel>(context, listen: false);
    final assets = viewModel.assets;
    final currencyFormat = NumberFormat.currency(
        symbol: Helpers.storeCurrency(context), decimalDigits: 0);

    // Calculate total assets value
    final totalAssetsValue =
        assets.fold(0.0, (sum, asset) => sum + asset.currentValue);

    // Group assets by type
    final assetsByType =
        groupBy(assets, (AssetLiabilityModel asset) => asset.type);

    // Calculate performance metrics
    final Map<String, double> typeDistribution = {};
    assetsByType.forEach((type, assets) {
      final typeTotal =
          assets.fold(0.0, (sum, asset) => sum + asset.currentValue);
      typeDistribution[type] = (typeTotal / totalAssetsValue) * 100;
    });
    final local = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ThemeConstants.cardDark
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.assetPerformance,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset Distribution
                    Card(
                      elevation: 0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              local.assetDistribution,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections:
                                      typeDistribution.entries.map((entry) {
                                    final color = Colors.primaries[
                                        entry.key.hashCode %
                                            Colors.primaries.length];
                                    return PieChartSectionData(
                                      value: entry.value,
                                      title:
                                          '${entry.key}\n${entry.value.toStringAsFixed(1)}%',
                                      color: color,
                                      radius: 80,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: assets.length,
                              itemBuilder: (context, index) {
                                final asset = assets[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(asset.name),
                                    subtitle: Text(asset.type),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          currencyFormat
                                              .format(asset.currentValue),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${asset.performancePercentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color:
                                                asset.performancePercentage >= 0
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLiabilityAnalysisDetail(BuildContext context) {
    final viewModel =
        Provider.of<AssetLiabilityViewModel>(context, listen: false);
    final liabilities = viewModel.liabilities;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    // Calculate total liabilities value
    final totalLiabilitiesValue =
        liabilities.fold(0.0, (sum, liability) => sum + liability.amount);

    // Group liabilities by type
    final liabilitiesByType =
        groupBy(liabilities, (AssetLiabilityModel liability) => liability.type);

    // Calculate debt distribution
    final Map<String, double> typeDistribution = {};
    liabilitiesByType.forEach((type, liabilities) {
      final typeTotal =
          liabilities.fold(0.0, (sum, liability) => sum + liability.amount);
      typeDistribution[type] = (typeTotal / totalLiabilitiesValue) * 100;
    });
    final local = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ThemeConstants.cardDark
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.liabilityAnalysis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Liabilities Card
                    Card(
                      elevation: 0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              local.totalLiabilities,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormat.format(totalLiabilitiesValue),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMetricCard(context, local.monthlyEmis,
                                    '25,000', Colors.red),
                                _buildMetricCard(
                                    context,
                                    local.debtRatio,
                                    '${viewModel.debtToAssetRatio.toStringAsFixed(1)}%',
                                    Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Debt Distribution Chart
                    Card(
                      elevation: 0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              local.debtDistribution,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections:
                                      typeDistribution.entries.map((entry) {
                                    final color = Colors.primaries[
                                        entry.key.hashCode %
                                            Colors.primaries.length];
                                    return PieChartSectionData(
                                      value: entry.value,
                                      title:
                                          '${entry.key}\n${entry.value.toStringAsFixed(1)}%',
                                      color: color,
                                      radius: 80,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Loan Details
                    Card(
                      elevation: 0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              local.loanDetails,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            ..._buildLoanDetailsList(context, liabilities),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinancialInsightsDetail(BuildContext context) {
    final viewModel =
        Provider.of<AssetLiabilityViewModel>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final local = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDarkMode ? ThemeConstants.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.financialInsights,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Financial Health Score
                    SizedBox(
                      width: double.maxFinite,
                      child: Card(
                        color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              AppHeaderText(
                                  text: local.financialHealthScore,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                              const SizedBox(height: 16),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 150,
                                    width: 150,
                                    child: CircularProgressIndicator(
                                      value: viewModel.financialHealthScore,
                                      strokeWidth: 12,
                                      backgroundColor: isDarkMode
                                          ? Colors.grey[700]
                                          : Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        viewModel.financialHealthColor,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        (viewModel.financialHealthScore * 100)
                                            .toStringAsFixed(0),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: viewModel
                                                  .financialHealthColor,
                                            ),
                                      ),
                                      Text(
                                        viewModel.financialHealthStatus,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: viewModel
                                                  .financialHealthColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Key Metrics
                    Card(
                      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppHeaderText(
                                text: local.keyMetrics,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                            const SizedBox(height: 16),
                            ..._buildKeyMetricsList(context),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Recommendations
                    Card(
                      elevation: 0,
                      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppHeaderText(
                                text: local.recommendations,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                            const SizedBox(height: 16),
                            ..._buildRecommendationsList(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      BuildContext context, String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMonthlyBreakdown(
      BuildContext context, List<NetWorthHistory> data) {
    return data.map((entry) {
      final isPositive = entry.percentageChange >= 0;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM y').format(entry.date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Row(
              children: [
                Text(
                  '${Helpers.storeCurrency(context)}${NumberFormat('#,##,###').format(entry.amount)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${isPositive ? '+' : ''}${entry.percentageChange.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildReportSection(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLoanDetailsList(
      BuildContext context, List<AssetLiabilityModel> liabilities) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final local = AppLocalizations.of(context);
    return liabilities
        .map((liability) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        liability.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        currencyFormat.format(liability.amount),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${local.emiLabel}: ${currencyFormat.format(liability.emi)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${local.interestLabel}: ${liability.interestRate}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${local.remainingLabel}: ${liability.calculateLoanTermInMonths()} months',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ))
        .toList();
  }

  List<Widget> _buildKeyMetricsList(BuildContext context) {
    final viewModel =
        Provider.of<AssetLiabilityViewModel>(context, listen: false);
    final local = AppLocalizations.of(context);
    final metrics = [
      {
        'name': 'Savings Rate',
        'value': '25%',
        'status': 'Good',
        'color': Colors.green
      },
      {
        'name': 'Debt-to-Income',
        'value': '${(viewModel.debtToAssetRatio * 100).toStringAsFixed(1)}%',
        'status': viewModel.debtToAssetRatio > 0.5 ? 'Risky' : 'Moderate',
        'color': viewModel.debtToAssetRatio > 0.5 ? Colors.red : Colors.orange
      },
      {
        'name': 'Emergency Fund',
        'value': '3 months',
        'status': 'Need Attention',
        'color': Colors.red
      },
      {
        'name': 'Investment Rate',
        'value': '15%',
        'status': 'Good',
        'color': Colors.green
      },
    ];
    return metrics
        .map((metric) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric['name'].toString(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        metric['value'].toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (metric['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      metric['status'].toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: metric['color'] as Color,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  List<Widget> _buildRecommendationsList(BuildContext context) {
    final viewModel =
        Provider.of<AssetLiabilityViewModel>(context, listen: false);
    final recommendations = _generateRecommendations(context, viewModel);

    return recommendations
        .map((rec) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(rec['priority'].toString())
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.priority_high,
                      size: 16,
                      color: _getPriorityColor(rec['priority'].toString()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppHeaderText(
                            text: rec['title'].toString(),
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                        const SizedBox(height: 4),
                        Text(
                          rec['description'].toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  // Helper method to generate recommendations based on financial data
  List<Map<String, String>> _generateRecommendations(
      BuildContext context, AssetLiabilityViewModel viewModel) {
    final List<Map<String, String>> recommendations = [];
    final local = AppLocalizations.of(context);
    // Add recommendations based on financial health
    if (viewModel.financialHealthScore < 0.6) {
      recommendations.add({
        'title': local.buildEmergencyFund,
        'description': local.increaseEmergencyFund,
        'priority': local.high,
      });
    }

    if (viewModel.debtToAssetRatio > 0.5) {
      recommendations.add({
        'title': local.reduceDebt,
        'description': local.focusOnHighInterestDebt,
        'priority': local.high,
      });
    }

    if (viewModel.totalAssets < viewModel.totalLiabilities * 2) {
      recommendations.add({
        'title': local.increaseSavings,
        'description': local.saveMoreToBuildFoundation,
        'priority': local.medium,
      });
    }

    if (viewModel.investmentRate < 0.15) {
      recommendations.add({
        'title': local.optimizeInvestments,
        'description': local.considerDiversifyingInvestments,
        'priority': local.medium,
      });
    }

    // Add a default recommendation if no specific issues are found
    if (recommendations.isEmpty) {
      recommendations.add({
        'title': local.maintainFinancialHealth,
        'description': local.continueGoodHabits,
        'priority': local.low,
      });
    }

    return recommendations;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
