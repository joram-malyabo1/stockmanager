import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Animation fly to ticket (MISE À JOUR POUR LE RÉSEAU)
class AnimatedImageFly extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final Size size;
  final String image; // Peut être un lien http ou un asset
  final VoidCallback onEnd;

  const AnimatedImageFly({
    Key? key,
    required this.startOffset,
    required this.endOffset,
    required this.size,
    required this.image,
    required this.onEnd,
  }) : super(key: key);

  @override
  _AnimatedImageFlyState createState() => _AnimatedImageFlyState();
}

class _AnimatedImageFlyState extends State<AnimatedImageFly>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _position = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart));

    _controller.forward().whenComplete(widget.onEnd);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (context, child) {
        return Positioned(
          top: _position.value.dy,
          left: _position.value.dx,
          child: SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.image.startsWith('http')
                  ? Image.network(widget.image, fit: BoxFit.cover) // ✅ Gère les URLs
                  : Image.asset(widget.image, fit: BoxFit.cover),  // ✅ Gère les assets
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}