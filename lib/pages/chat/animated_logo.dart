import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<StatefulWidget> createState() => AnimatedLogoState();
}

class AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, -0.2), end: const Offset(0, 0))
            .animate(CurveTween(curve: Curves.easeInQuad).animate(_controller));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.removeStatusListener((status) {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SlideTransition(
        position: _offsetAnimation,
        child: SizedBox(
            height: size.width / 2,
            width: size.width / 2,
            child: Image.asset('assets/images/chat/main.png')));
  }
}
