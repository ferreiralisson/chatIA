import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final Color? tintColor;
  final double tintOpacity;
  final bool showBorder;
  final BoxConstraints? constraints;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.blurSigma = 20,
    this.tintColor,
    this.tintOpacity = 0.12,
    this.showBorder = true,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      constraints: constraints,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (tintColor ?? Colors.white)
                      .withValues(alpha: tintOpacity + 0.06),
                  (tintColor ?? Colors.white)
                      .withValues(alpha: tintOpacity * 0.3),
                ],
              ),
              border: showBorder
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 0.8,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
