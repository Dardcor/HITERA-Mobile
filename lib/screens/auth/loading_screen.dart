import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      body: Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * 3.14159,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border(
                          top: const BorderSide(color: HiteraColors.accentBlue, width: 4),
                          right: const BorderSide(color: HiteraColors.accentGreen, width: 4),
                          bottom: const BorderSide(color: HiteraColors.accentRed, width: 4),
                          left: const BorderSide(color: HiteraColors.accentYellow, width: 4),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Image.asset('image/logo.png', width: 64, height: 64),
            ],
          ),
        ),
      ),
    );
  }
}
