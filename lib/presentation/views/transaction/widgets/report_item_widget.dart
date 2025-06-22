import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:flutter/material.dart';

class ReportItemWidget extends StatelessWidget {
  const ReportItemWidget(
      {super.key, required this.label, required this.value, this.textColor});

  final String label;
  final String value;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text('${Helpers.storeCurrency(context)}$value',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  )),
        ],
      ),
    );
  }
}
