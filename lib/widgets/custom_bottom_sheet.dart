import 'package:flutter/material.dart';
import '../core/constants/theme_constants.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onSave;
  final bool showDragHandle;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.children,
    this.onSave,
    this.showDragHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? ThemeConstants.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isDarkMode 
                          ? ThemeConstants.textPrimaryDark 
                          : ThemeConstants.textPrimaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onSave != null)
                  SizedBox(
                    width: 80,
                    child: TextButton(
                      onPressed: onSave,
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: ThemeConstants.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            height: 1, 
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
