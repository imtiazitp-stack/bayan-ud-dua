import 'package:flutter/material.dart';

/// The Figma "Home & search" background: a soft cream-to-green gradient
/// in light mode. Dark mode keeps the app's normal dark surface instead —
/// the gradient was designed against the light palette only.
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFBF9E2),
                  Color(0xFFE1EBC8),
                  Color(0xFFCCDEA3),
                ],
              ),
      ),
      child: child,
    );
  }
}
