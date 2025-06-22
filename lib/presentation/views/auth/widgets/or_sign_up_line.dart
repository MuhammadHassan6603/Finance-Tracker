import 'package:finance_tracker/generated/l10n.dart';
import 'package:flutter/material.dart';

class OrSignUpWithWidget extends StatelessWidget {
  const OrSignUpWithWidget({super.key, this.text});
  final String? text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Line
        Expanded(
          child: Divider(
            color: Colors.grey.shade400,
            thickness: 1,
            endIndent: 10,
          ),
        ),
        // Text
        Text(
          text ?? AppLocalizations.of(context).orSignUpWith,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        // Right Line
        Expanded(
          child: Divider(
            color: Colors.grey.shade400,
            thickness: 1,
            indent: 10,
          ),
        ),
      ],
    );
  }
}
