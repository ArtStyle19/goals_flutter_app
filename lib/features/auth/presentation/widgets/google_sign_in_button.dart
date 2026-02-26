import 'package:flutter/material.dart';

/// Google Sign-In button following Google's branding guidelines.
///
/// Renders a Material 3 button with the Google "G" logo on the left
/// and customizable text. Follows the official guidelines:
/// https://developers.google.com/identity/branding-guidelines
class GoogleSignInButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GoogleLogo(),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Google "G" logo rendered using the official brand colors.
///
/// Uses a [CustomPainter] to draw the multi-colored "G" accurately
/// without requiring an image asset — avoids licensing concerns and
/// works at any resolution.
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Scale factor to normalize the path coordinates
    final double sx = w / 48;
    final double sy = h / 48;

    // Blue arc (right)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final bluePath = Path()
      ..moveTo(43.611 * sx, 20.083 * sy)
      ..lineTo(43.611 * sx, 20.083 * sy)
      ..cubicTo(43.611 * sx, 18.683 * sy, 43.493 * sx, 17.333 * sy, 43.273 * sx, 16.033 * sy)
      ..lineTo(24 * sx, 16.033 * sy)
      ..lineTo(24 * sx, 23.533 * sy)
      ..lineTo(35.128 * sx, 23.533 * sy)
      ..cubicTo(34.633 * sx, 26.133 * sy, 33.133 * sx, 28.317 * sy, 31 * sx, 29.817 * sy)
      ..lineTo(31 * sx, 34.817 * sy)
      ..lineTo(37.563 * sx, 34.817 * sy)
      ..cubicTo(41.378 * sx, 31.267 * sy, 43.611 * sx, 26.133 * sy, 43.611 * sx, 20.083 * sy)
      ..close();

    canvas.drawPath(bluePath, bluePaint);

    // Green arc (bottom-right)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;

    final greenPath = Path()
      ..moveTo(24 * sx, 44 * sy)
      ..cubicTo(29.4 * sx, 44 * sy, 33.95 * sx, 42.183 * sy, 37.563 * sx, 34.817 * sy)
      ..lineTo(31 * sx, 29.817 * sy)
      ..cubicTo(29.233 * sx, 30.983 * sy, 26.883 * sx, 31.683 * sy, 24 * sx, 31.683 * sy)
      ..cubicTo(18.783 * sx, 31.683 * sy, 14.35 * sx, 28.1 * sy, 12.833 * sx, 23.333 * sy)
      ..lineTo(6.067 * sx, 23.333 * sy)
      ..lineTo(6.067 * sx, 28.483 * sy)
      ..cubicTo(9.667 * sx, 35.617 * sy, 16.267 * sx, 44 * sy, 24 * sx, 44 * sy)
      ..close();

    canvas.drawPath(greenPath, greenPaint);

    // Yellow arc (bottom-left)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;

    final yellowPath = Path()
      ..moveTo(12.833 * sx, 23.333 * sy)
      ..cubicTo(12.367 * sx, 21.933 * sy, 12.1 * sx, 20.433 * sy, 12.1 * sx, 18.9 * sy)
      ..cubicTo(12.1 * sx, 17.367 * sy, 12.367 * sx, 15.867 * sy, 12.833 * sx, 14.467 * sy)
      ..lineTo(12.833 * sx, 9.317 * sy)
      ..lineTo(6.067 * sx, 9.317 * sy)
      ..cubicTo(4.483 * sx, 12.467 * sy, 3.611 * sx, 16.017 * sy, 3.611 * sx, 19.833 * sy)
      ..cubicTo(3.611 * sx, 23.05 * sy, 4.483 * sx, 26.117 * sy, 6.067 * sx, 28.483 * sy)
      ..lineTo(12.833 * sx, 23.333 * sy)
      ..close();

    canvas.drawPath(yellowPath, yellowPaint);

    // Red arc (top-left)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;

    final redPath = Path()
      ..moveTo(24 * sx, 7.117 * sy)
      ..cubicTo(27.15 * sx, 7.117 * sy, 29.983 * sx, 8.183 * sy, 32.2 * sx, 10.2 * sy)
      ..lineTo(37.633 * sx, 4.767 * sy)
      ..cubicTo(33.933 * sx, 1.317 * sy, 29.383 * sx, -0.583 * sy, 24 * sx, -0.583 * sy)
      ..cubicTo(16.267 * sx, -0.583 * sy, 9.667 * sx, 4.05 * sy, 6.067 * sx, 9.317 * sy)
      ..lineTo(12.833 * sx, 14.467 * sy)
      ..cubicTo(14.35 * sx, 9.7 * sy, 18.783 * sx, 7.117 * sy, 24 * sx, 7.117 * sy)
      ..close();

    canvas.drawPath(redPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
