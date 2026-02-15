import 'package:flutter/material.dart';
import '../../config/retro_theme.dart';

class DeviceFrame extends StatelessWidget {
  final Widget child;
  final double padding;
  final bool showControls;

  const DeviceFrame({
    super.key,
    required this.child,
    this.padding = 20.0,
    this.showControls = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RetroColors.pink,
        border: Border.all(color: RetroColors.black, width: 4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 0, offset: Offset(6, 6)),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showControls) _buildControls(),
          Container(
            decoration: BoxDecoration(
              color: RetroColors.light,
              border: Border.all(color: RetroColors.black, width: 2),
            ),
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton('A', RetroColors.green),
          _buildButton('B', RetroColors.orange),
          _buildButton('C', RetroColors.blue),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: RetroColors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 0, offset: Offset(2, 2)),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'VT323',
            fontSize: 16,
            color: RetroColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
