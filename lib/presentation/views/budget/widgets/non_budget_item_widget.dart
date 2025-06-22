import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class NonBudgetItem extends StatelessWidget {
  const NonBudgetItem({
    super.key,
    required this.name,
    required this.icon,
    required this.onPress,
  });

  final String name;
  final IconData icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey[600]),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 130,
            child: TextButton(
              onPressed: onPress,
              style: TextButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Text('SET BUDGET'),
            ),
          ),
        ],
      ),
    );
  }
}
