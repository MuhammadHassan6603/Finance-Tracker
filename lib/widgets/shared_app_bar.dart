import 'package:finance_tracker/core/constants/theme_constants.dart';
import 'package:flutter/material.dart';

class SharedAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function()? onLeading;
  final String? desc;
  final Color? backgroundColor;
  final List<Widget>? actions;
  const SharedAppbar({
    super.key,
    required this.title,
    this.onLeading,
    this.desc,
    this.backgroundColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDarkMode ? ThemeConstants.backgroundDark : Colors.white);

    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: bgColor,
      titleSpacing: 0,
      elevation: 0,
      leading: IconButton(
        onPressed: onLeading ?? () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios,
          weight: 600,
          size: 20,
          color: ThemeConstants.primaryColor,
        ),
      ),
      title: desc == null
          ? Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  desc ?? "",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: ThemeConstants.primaryColor),
                ),
              ],
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 60);
}
