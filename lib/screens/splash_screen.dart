import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF064E3B), Color(0xFF0F172A)],
          ),
        ),
        child: Stack(
          children: [
            // ── Lightweight glow orbs (no BackdropFilter) ──
            Positioned(
              top: -80, left: -100,
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF10B981).withOpacity(0.15),
                    const Color(0xFF10B981).withOpacity(0.0),
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: -120, right: -80,
              child: Container(
                width: 320, height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF3B82F6).withOpacity(0.12),
                    const Color(0xFF3B82F6).withOpacity(0.0),
                  ]),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35, right: -50,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                    const Color(0xFF8B5CF6).withOpacity(0.0),
                  ]),
                ),
              ),
            ),

            // ── Main content ──
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // ── Animated Logo ──
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoController, _pulseController]),
                    builder: (context, child) {
                      final pulse = 1.0 + (sin(_pulseController.value * pi * 2) * 0.03);
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value * pulse,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 40, spreadRadius: 8),
                                BoxShadow(color: const Color(0xFF10B981).withOpacity(0.15), blurRadius: 80, spreadRadius: 15),
                              ],
                            ),
                            child: const Icon(Icons.health_and_safety, size: 56, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── App Name ──
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFF6EE7B7), Colors.white],
                            ).createShader(bounds),
                            child: const Text(
                              'HealthScope BD',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Digital Health Companion',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Progress Bar ──
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return Column(
                        children: [
                          Container(
                            width: 200,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _progressValue.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF34D399), Color(0xFF6EE7B7)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF10B981).withOpacity(0.6), blurRadius: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _progressValue.value < 0.3
                                ? 'Initializing...'
                                : _progressValue.value < 0.6
                                    ? 'Connecting to cloud...'
                                    : _progressValue.value < 0.9
                                        ? 'Loading health data...'
                                        : 'Ready!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // ── Bottom branding ──
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Text(
                        'Powered by Firebase & Flutter',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
