import 'package:flutter/material.dart';
import 'dart:async';

/// Animation avec fade + slide
class DelayedAnimation extends StatefulWidget {
  final Widget child;
  final int delay;
  const DelayedAnimation({required this.delay, required this.child});

  @override
  _DelayedAnimationState createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<DelayedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.decelerate);

    _animOffset = Tween<Offset>(
      begin: Offset(0.0, -0.35),
      end: Offset.zero,
    ).animate(curve);

    Timer(Duration(milliseconds: widget.delay), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(position: _animOffset, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Animation fly to ticket
class AnimatedImageFly extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final Size size;
  final String image;
  final VoidCallback onEnd;

  const AnimatedImageFly({
    required this.startOffset,
    required this.endOffset,
    required this.size,
    required this.image,
    required this.onEnd,
  });

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
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));

    _position = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

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
            child: Image.asset(widget.image),
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

/// Widget compteur avec pulse
class AnimatedTicketCounter extends StatefulWidget {
  final int count;
  final GlobalKey keyCounter;

  const AnimatedTicketCounter({required this.count, required this.keyCounter, Key? key})
      : super(key: key);

  @override
  AnimatedTicketCounterState createState() => AnimatedTicketCounterState();
}

// Expose l’état pour GlobalKey
class AnimatedTicketCounterState extends State<AnimatedTicketCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 1.0, end: 1.4)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
  }

  void pop() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        key: widget.keyCounter,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          widget.count.toString(),
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
