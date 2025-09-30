import 'package:flutter/material.dart';

class NFCAnimationIcon extends StatefulWidget {
  final bool isScanning;

  const NFCAnimationIcon({super.key, required this.isScanning});

  @override
  State<NFCAnimationIcon> createState() => _NFCAnimationIconState();
}

class _NFCAnimationIconState extends State<NFCAnimationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isScanning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NFCAnimationIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Vòng tròn ngoài (pulse effect)
            if (widget.isScanning)
              Container(
                width: 180 * _scaleAnimation.value,
                height: 180 * _scaleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(
                      _opacityAnimation.value,
                    ),
                    width: 3,
                  ),
                ),
              ),

            // Icon NFC chính
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isScanning
                    ? colorScheme.primary
                    : colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: widget.isScanning ? 20 : 10,
                    spreadRadius: widget.isScanning ? 5 : 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.nfc,
                size: 60,
                color: widget.isScanning
                    ? Colors.white
                    : colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        );
      },
    );
  }
}
