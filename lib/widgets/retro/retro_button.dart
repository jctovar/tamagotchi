import 'package:flutter/material.dart';
import '../../config/retro_theme.dart';

class RetroButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final double width;
  final double height;

  const RetroButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.onLongPress,
    this.width = 100,
    this.height = 80,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  int _frame = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _frame = 1),
      onTapUp: (_) {
        setState(() => _frame = 0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _frame = 0),
      onLongPress: widget.onLongPress,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _frame == 1
              ? widget.color.withValues(alpha: 0.8)
              : widget.color,
          border: Border.all(color: RetroColors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 0,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, _frame == 1 ? 2 : 0),
              child: Icon(widget.icon, size: 32, color: RetroColors.dark),
            ),
            const SizedBox(height: 4),
            Transform.translate(
              offset: Offset(0, _frame == 1 ? 2 : 0),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 16,
                  color: RetroColors.dark,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RetroActionButton extends StatefulWidget {
  final String label;
  final String imagePath;
  final Color color;
  final VoidCallback onPressed;

  const RetroActionButton({
    super.key,
    required this.label,
    required this.imagePath,
    required this.color,
    required this.onPressed,
  });

  @override
  State<RetroActionButton> createState() => _RetroActionButtonState();
}

class _RetroActionButtonState extends State<RetroActionButton> {
  int _frame = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _frame = 1),
      onTapUp: (_) {
        setState(() => _frame = 0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _frame = 0),
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          color: _frame == 1
              ? widget.color.withValues(alpha: 0.8)
              : widget.color,
          border: Border.all(color: RetroColors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 0,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_frame == 1)
              Container(width: 32, height: 32, color: widget.color)
            else
              Image.asset(
                widget.imagePath,
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    size: 32,
                    color: RetroColors.dark,
                  );
                },
              ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'VT323',
                fontSize: 16,
                color: RetroColors.dark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
