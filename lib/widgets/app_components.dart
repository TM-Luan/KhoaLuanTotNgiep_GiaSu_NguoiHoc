import 'package:flutter/material.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_spacing.dart';
import 'package:khoa_luan_tot_ngiep_gia_su_nguoi_hoc/constants/app_colors.dart';

/// Standardized card component for consistent styling across the app
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? borderRadius;
  final Border? border;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.border,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient ?? AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.cardBorderRadius),
        border: border,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );

    return Card(
      elevation: elevation ?? AppSpacing.cardElevation,
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.cardMargin),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.cardBorderRadius),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.cardBorderRadius),
              child: cardContent,
            )
          : cardContent,
    );
  }
}

/// Standardized button component for consistent styling
class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isLoading;
  final ButtonType type;

  const AppButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.border,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.type = ButtonType.primary,
  }) : super(key: key);

  const AppButton.primary({
    Key? key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
  }) : backgroundColor = null,
       foregroundColor = Colors.white,
       gradient = null,
       border = null,
       padding = null,
       borderRadius = null,
       type = ButtonType.primary,
       super(key: key);

  const AppButton.secondary({
    Key? key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
  }) : backgroundColor = Colors.transparent,
       foregroundColor = null,
       gradient = null,
       border = null,
       padding = null,
       borderRadius = null,
       type = ButtonType.secondary,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    Color? bgColor = backgroundColor;
    Color? fgColor = foregroundColor;
    Border? buttonBorder = border;
    Gradient? buttonGradient = gradient;

    switch (type) {
      case ButtonType.primary:
        bgColor = backgroundColor ?? AppColors.primary;
        fgColor = foregroundColor ?? AppColors.textLight;
        buttonGradient = gradient ?? AppGradients.buttonGradient;
        break;
      case ButtonType.secondary:
        bgColor = backgroundColor ?? Colors.transparent;
        fgColor = foregroundColor ?? AppColors.primary;
        buttonBorder = border ?? Border.all(color: AppColors.primary);
        break;
      case ButtonType.success:
        bgColor = backgroundColor ?? AppColors.success;
        fgColor = foregroundColor ?? AppColors.textLight;
        buttonBorder = border ?? Border.all(color: AppColors.success);
        break;
      case ButtonType.warning:
        bgColor = backgroundColor ?? AppColors.warning;
        fgColor = foregroundColor ?? AppColors.textLight;
        buttonBorder = border ?? Border.all(color: AppColors.warning);
        break;
      case ButtonType.error:
        bgColor = backgroundColor ?? AppColors.error;
        fgColor = foregroundColor ?? AppColors.textLight;
        buttonBorder = border ?? Border.all(color: AppColors.error);
        break;
    }

    final buttonContent = Container(
      decoration: BoxDecoration(
        color: buttonGradient == null ? bgColor : null,
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.buttonBorderRadius),
        border: buttonBorder,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: fgColor,
            fontSize: AppTypography.buttonText,
            fontWeight: FontWeight.w500,
          ),
          child: child,
        ),
      ),
    );

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.buttonBorderRadius),
      child: buttonContent,
    );
  }
}

enum ButtonType { primary, secondary, success, warning, error }

/// Standardized icon container for consistent styling
class AppIconContainer extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final double? iconSize;
  final double? borderRadius;
  final Border? border;
  final VoidCallback? onTap;

  const AppIconContainer({
    Key? key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.iconSize,
    this.borderRadius,
    this.border,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: EdgeInsets.all(size ?? AppSpacing.iconContainerPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.iconContainerRadius),
        border: border,
      ),
      child: Icon(
        icon,
        color: iconColor ?? AppColors.primary,
        size: iconSize ?? AppSpacing.smallIconSize,
      ),
    );

    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.iconContainerRadius),
            child: container,
          )
        : container;
  }
}

/// Standardized app bar for consistent header styling
class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;

  const StandardAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (leadingIcon != null) ...[
            AppIconContainer(
              icon: leadingIcon!,
              backgroundColor: AppColors.white.withValues(alpha:AppOpacity.iconBackground),
              iconColor: AppColors.textLight,
              iconSize: AppSpacing.iconSize,
            ),
            const SizedBox(width: AppSpacing.appBarIconSpacing),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTypography.appBarTitle,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textLight.withValues(alpha:AppOpacity.subtle),
                      fontSize: AppTypography.caption,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}