import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _particleController;
  final List<_SplashParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _initParticles();

    Future.delayed(const Duration(milliseconds: 600), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  void _initParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_SplashParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speedX: (_random.nextDouble() - 0.5) * 2,
        speedY: -_random.nextDouble() * 3 - 1,
        size: _random.nextDouble() * 16 + 8,
        rotation: _random.nextDouble() * 6,
        rotationSpeed: (_random.nextDouble() - 0.5) * 8,
        color: [
          Colors.green,
          Colors.teal,
          Colors.lightGreen,
          Colors.amber,
          Colors.orange,
        ][_random.nextInt(5)],
      ));
    }
    _particleController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final s = size.width / 375;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _fadeAnimation, _particleController]),
        builder: (_, __) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
              ),
            ),
            child: Stack(
              children: [
                for (final p in _particles)
                  Positioned(
                    left: ((p.x + p.speedX * _particleController.value * 2) * size.width).clamp(-50, size.width + 50),
                    top: ((p.y + p.speedY * _particleController.value * 2 + 200 * _particleController.value * _particleController.value) * size.height / 800 + 100).clamp(-50, size.height + 50),
                    child: Transform.rotate(
                      angle: p.rotation + p.rotationSpeed * _particleController.value,
                      child: Opacity(
                        opacity: (1 - _particleController.value * 0.5).clamp(0, 1),
                        child: Container(
                          width: p.size,
                          height: p.size * 0.6,
                          decoration: BoxDecoration(
                            color: p.color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 0.5 + _scaleAnimation.value * 0.5,
                        child: Container(
                          width: isTablet ? 180 : 120 * s.clamp(0.8, 1.2),
                          height: isTablet ? 180 : 120 * s.clamp(0.8, 1.2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Sains',
                              style: TextStyle(
                                fontSize: isTablet ? 40 : 28 * s.clamp(0.8, 1.2),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 32 : 24 * s.clamp(0.8, 1.2)),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Manusia & Tumbuhan',
                              style: TextStyle(
                                fontSize: isTablet ? 40 : 28 * s.clamp(0.8, 1.2),
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: isTablet ? 12 : 8 * s.clamp(0.8, 1.2)),
                            Text(
                              'Sains Tahun 5',
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 16 * s.clamp(0.8, 1.2),
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: isTablet ? 48 : 32 * s.clamp(0.8, 1.2)),
                            SizedBox(
                              width: isTablet ? 56 : 40 * s.clamp(0.8, 1.2),
                              height: isTablet ? 56 : 40 * s.clamp(0.8, 1.2),
                              child: CircularProgressIndicator(
                                strokeWidth: isTablet ? 4 : 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SplashParticle {
  final double x, y, speedX, speedY, size, rotation, rotationSpeed;
  final Color color;

  _SplashParticle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}
