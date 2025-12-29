import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

/// Botón de acción con animaciones y haptic feedback
class AnimatedActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final FeedbackType feedbackType;

  const AnimatedActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.feedbackType,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() async {
    // Reproducir haptic feedback
    await FeedbackService.playHaptic(widget.feedbackType);

    // Ejecutar callback
    widget.onPressed();

    // Animación de rebote
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: null, // El tap lo maneja el GestureDetector
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween(begin: 1.0, end: _isPressed ? 1.2 : 1.0),
                      curve: Curves.easeOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Icon(
                            widget.icon,
                            size: 28,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
