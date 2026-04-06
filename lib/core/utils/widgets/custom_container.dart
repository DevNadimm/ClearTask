import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const CustomContainer({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? context.cardColor,
        gradient: gradient,
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          width: 1,
          color: context.inputBorderColor,
        ),
      ),
      child: child,
    );
  }
}
