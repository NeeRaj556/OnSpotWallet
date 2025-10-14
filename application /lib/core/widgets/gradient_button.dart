import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// GradientButton - A premium button widget with gradient background
/// Follows MeshPay design standards with smooth gradients and proper shadows
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final double elevation;
  final Color? shadowColor;
  final bool isLoading;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    this.textStyle,
    this.elevation = 8,
    this.shadowColor,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Default gradient based on theme
    final Gradient effectiveGradient = gradient ??
        (isDarkMode ? AppColors.darkGradient : AppColors.primaryGradient);

    // Default shadow color
    final Color effectiveShadowColor = shadowColor ??
        (isDarkMode
            ? AppColors.accentCyan.withOpacity(0.4)
            : AppColors.primaryBlue.withOpacity(0.4));

    // Default text style
    final TextStyle effectiveTextStyle = textStyle ??
        const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        );

    return Material(
      color: Colors.transparent,
      elevation: onPressed == null ? 0 : elevation,
      shadowColor: effectiveShadowColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: onPressed == null ? null : effectiveGradient,
            color: onPressed == null ? Colors.grey[400] : null,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            padding: padding,
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: effectiveTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// MeshPayButton - Alternative button style with more customization options
class MeshPayButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final MeshPayButtonStyle style;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;

  const MeshPayButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = MeshPayButtonStyle.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    Widget buttonContent;

    switch (style) {
      case MeshPayButtonStyle.primary:
        buttonContent = GradientButton(
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          padding: EdgeInsets.symmetric(
            horizontal: 32,
            vertical: (height - 24) / 2,
          ),
        );
        break;

      case MeshPayButtonStyle.secondary:
        buttonContent = _OutlinedButton(
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          height: height,
          isDarkMode: isDarkMode,
        );
        break;

      case MeshPayButtonStyle.success:
        buttonContent = GradientButton(
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          gradient: AppColors.successGradient,
          shadowColor: AppColors.successGreen.withOpacity(0.4),
          padding: EdgeInsets.symmetric(
            horizontal: 32,
            vertical: (height - 24) / 2,
          ),
        );
        break;

      case MeshPayButtonStyle.violet:
        buttonContent = GradientButton(
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          gradient: AppColors.violetGradient,
          shadowColor: AppColors.softViolet.withOpacity(0.4),
          padding: EdgeInsets.symmetric(
            horizontal: 32,
            vertical: (height - 24) / 2,
          ),
        );
        break;
    }

    if (width != null) {
      return SizedBox(
        width: width,
        height: height,
        child: buttonContent,
      );
    }

    return SizedBox(
      height: height,
      child: buttonContent,
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double height;
  final bool isDarkMode;

  const _OutlinedButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
    required this.icon,
    required this.height,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        isDarkMode ? AppColors.accentCyan : AppColors.primaryBlue;
    final Color textColor =
        isDarkMode ? AppColors.accentCyan : AppColors.primaryBlue;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 32,
            vertical: (height - 24) / 2,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: onPressed == null ? Colors.grey : borderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onPressed == null ? Colors.grey : textColor,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

enum MeshPayButtonStyle {
  primary,
  secondary,
  success,
  violet,
}
