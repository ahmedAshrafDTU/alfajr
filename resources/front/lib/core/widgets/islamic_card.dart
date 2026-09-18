import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class IslamicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool hasPattern;

  const IslamicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
    this.hasPattern = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: AppColors.primary.withOpacity(0.05),
          splashColor: AppColors.primary.withOpacity(0.05),
          child: Stack(
            children: [
              if (hasPattern)
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Opacity(
                    opacity: isDark ? 0.05 : 0.03,
                    child: Icon(
                      Icons.mosque,
                      size: 140,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              Padding(
                padding: padding!,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
