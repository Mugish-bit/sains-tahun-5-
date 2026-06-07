import 'dart:math';
import 'package:flutter/material.dart';
import '../services/score_service.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  int _displayScore = 0;
  int _cumulativeScore = 0;

  late AnimationController _starController;
  late Animation<double> _starAnimation;

  late AnimationController _bounceController;

  late AnimationController _confettiController;
  final List<_ResultConfetti> _confettiParticles = [];
  final Random _random = Random();

  late AnimationController _slideUpController;
  late Animation<Offset> _slideUpAnimation;

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _starAnimation = CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() => setState(() {}))
     ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _confettiParticles.clear();
        }
      });

    _slideUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideUpController,
      curve: Curves.easeOutCubic,
    ));

    _scoreController.addListener(() {
      setState(() {
        _displayScore = (widget.score * _scoreAnimation.value).round();
      });
    });

    _loadCumulativeScore();
    _scoreController.forward();
    _starController.forward();
    _bounceController.forward();
    _slideUpController.forward();

    _spawnConfetti();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _starController.dispose();
    _bounceController.dispose();
    _confettiController.dispose();
    _slideUpController.dispose();
    super.dispose();
  }

  Future<void> _loadCumulativeScore() async {
    _cumulativeScore = await ScoreService.getScore();
    if (mounted) setState(() {});
  }

  void _spawnConfetti() {
    _confettiParticles.clear();
    final stars = _getStars();
    final count = stars == 3 ? 50 : stars == 2 ? 30 : 10;
    for (int i = 0; i < count; i++) {
      _confettiParticles.add(_ResultConfetti(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.3,
        speedX: (_random.nextDouble() - 0.5) * 3,
        speedY: _random.nextDouble() * 4 + 2,
        rotation: _random.nextDouble() * 6,
        rotationSpeed: (_random.nextDouble() - 0.5) * 12,
        size: _random.nextDouble() * 10 + 4,
        color: [
          Colors.red, Colors.orange, Colors.yellow, Colors.green,
          Colors.blue, Colors.purple, Colors.pink, Colors.amber,
        ][_random.nextInt(8)],
      ));
    }
    _confettiController.forward(from: 0.0);
  }

  List<String> _getEarnedBadges() {
    List<String> badges = [];
    if (_cumulativeScore >= 5) badges.add('Gangsa');
    if (_cumulativeScore >= 15) badges.add('Perak');
    if (_cumulativeScore >= 25) badges.add('Emas');
    return badges;
  }

  String _getBadgeEmoji(String badge) {
    if (badge == 'Gangsa') return '🥉';
    if (badge == 'Perak') return '🥈';
    return '🥇';
  }

  int _getStars() {
    final pct = widget.score / widget.totalQuestions;
    if (pct >= 0.9) return 3;
    if (pct >= 0.7) return 2;
    if (pct >= 0.4) return 1;
    return 0;
  }

  double _getPercentage() {
    return widget.score / widget.totalQuestions;
  }

  String _getMessage() {
    final stars = _getStars();
    if (stars == 3) return 'Luar Biasa!';
    if (stars == 2) return 'Syabas!';
    if (stars == 1) return 'Teruskan Usaha!';
    return 'Jangan Putus Asa!';
  }

  String _getEmoji() {
    final stars = _getStars();
    if (stars == 3) return '🏆';
    if (stars == 2) return '👍';
    if (stars == 1) return '💪';
    return '🌱';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final s = (size.width / 375).clamp(0.8, 1.4);
    final earnedBadges = _getEarnedBadges();
    final stars = _getStars();
    final pct = _getPercentage();
    final newBadges = earnedBadges.where((b) {
      final before = _cumulativeScore - widget.score;
      if (b == 'Gangsa') return before < 5 && _cumulativeScore >= 5;
      if (b == 'Perak') return before < 15 && _cumulativeScore >= 15;
      if (b == 'Emas') return before < 25 && _cumulativeScore >= 25;
      return false;
    }).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade400,
              Colors.green.shade600,
              Colors.green.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (_confettiParticles.isNotEmpty)
                IgnorePointer(
                  child: CustomPaint(
                    size: size,
                    painter: _ResultConfettiPainter(_confettiParticles, _confettiController.value),
                  ),
                ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 32 * s : 20 * s),
                  child: SlideTransition(
                    position: _slideUpAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _starAnimation,
                          builder: (_, __) {
                            final scale = 0.5 + _starAnimation.value * 0.5;
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: isTablet ? 140 : 100 * s.clamp(0.85, 1.15),
                                height: isTablet ? 140 : 100 * s.clamp(0.85, 1.15),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: isTablet ? 4 : 3,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _getEmoji(),
                                    style: TextStyle(fontSize: (40 + _starAnimation.value * 10) * s.clamp(0.85, 1.15)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: isTablet ? 16 : 12 * s),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.amber, Colors.orange, Colors.yellow],
                          ).createShader(bounds),
                          child: Text(
                            _getMessage(),
                            style: TextStyle(
                              fontSize: isTablet ? 42 : 30 * s.clamp(0.85, 1.15),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 20 * s),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(isTablet ? 36 : 30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: isTablet ? 3 : 2,
                            ),
                          ),
                          padding: EdgeInsets.all(isTablet ? 36 : 24 * s),
                          child: Column(
                            children: [
                              Text(
                                'Markah Anda',
                                style: TextStyle(
                                  fontSize: isTablet ? 22 : 16 * s,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: isTablet ? 8 : 4 * s),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$_displayScore',
                                    style: TextStyle(
                                      fontSize: isTablet ? 80 : 64 * s.clamp(0.8, 1.1),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: isTablet ? 12 : 8 * s),
                                    child: Text(
                                      '/ ${widget.totalQuestions}',
                                      style: TextStyle(
                                        fontSize: isTablet ? 28 : 20 * s.clamp(0.85, 1.15),
                                        color: Colors.white.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isTablet ? 16 : 12 * s),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 24 : 16 * s,
                                  vertical: isTablet ? 10 : 6 * s,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                ),
                                child: Text(
                                  '${(pct * 100).round()}% betul',
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 15 * s,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 20 : 16 * s),
                              _buildStarRow(stars, isTablet, s),
                              SizedBox(height: isTablet ? 20 : 16 * s),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 28 : 20 * s,
                                  vertical: isTablet ? 14 : 10 * s,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: isTablet ? 28 : 20),
                                    SizedBox(width: isTablet ? 10 : 6 * s),
                                    Text(
                                      'Jumlah: $_cumulativeScore / 30',
                                      style: TextStyle(
                                        fontSize: isTablet ? 20 : 15 * s,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (newBadges.isNotEmpty) ...[
                          SizedBox(height: isTablet ? 24 : 20 * s),
                          AnimatedBuilder(
                            animation: _bounceController,
                            builder: (_, __) => Transform.scale(
                              scale: 0.9 + _bounceController.value * 0.1,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isTablet ? 28 : 20 * s),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.amber.shade300, Colors.orange.shade400],
                                  ),
                                  borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text('🎉', style: TextStyle(fontSize: isTablet ? 52 : 40 * s.clamp(0.85, 1.15))),
                                    SizedBox(height: isTablet ? 12 : 8 * s),
                                    Text(
                                      'Lencana Baharu!',
                                      style: TextStyle(
                                        fontSize: isTablet ? 28 : 20 * s.clamp(0.85, 1.15),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 12 : 8 * s),
                                    ...newBadges.map((b) => Padding(
                                      padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 4 * s),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isTablet ? 24 : 16 * s,
                                          vertical: isTablet ? 12 : 8 * s,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          '${_getBadgeEmoji(b)} $b',
                                          style: TextStyle(
                                            fontSize: isTablet ? 24 : 18 * s.clamp(0.85, 1.15),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (earnedBadges.isNotEmpty && newBadges.isEmpty) ...[
                          SizedBox(height: isTablet ? 24 : 20 * s),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: earnedBadges.map((b) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 18 : 12 * s,
                                vertical: isTablet ? 10 : 6 * s,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${_getBadgeEmoji(b)} $b',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 14 * s,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                        SizedBox(height: isTablet ? 36 : 28 * s),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green.shade800,
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 64 : 48 * s,
                              vertical: isTablet ? 20 : 16 * s,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: 0.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home, size: isTablet ? 28 : 22),
                              SizedBox(width: isTablet ? 12 : 8 * s),
                              Text(
                                'Laman Utama',
                                style: TextStyle(
                                  fontSize: isTablet ? 24 : 18 * s.clamp(0.85, 1.15),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRow(int stars, bool isTablet, double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
          child: AnimatedBuilder(
            animation: _starAnimation,
            builder: (_, __) {
              final delay = i * 0.2;
              final start = delay;
              final end = delay + 0.3;
              final animValue = ((_starAnimation.value - start) / (end - start))
                  .clamp(0.0, 1.0);
              return Transform.scale(
                scale: i < stars ? animValue : 1.0,
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 6),
                  decoration: BoxDecoration(
                    color: i < stars
                        ? Colors.amber.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: i < stars ? Colors.amber : Colors.white.withValues(alpha: 0.4),
                    size: isTablet ? 48 : 36 * s.clamp(0.85, 1.15),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _ResultConfetti {
  final double x, y, speedX, speedY, rotation, rotationSpeed, size;
  final Color color;

  _ResultConfetti({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });
}

class _ResultConfettiPainter extends CustomPainter {
  final List<_ResultConfetti> particles;
  final double progress;

  _ResultConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = (p.x + p.speedX * progress) * size.width;
      final y = (p.y + p.speedY * progress + 200 * progress * progress) * size.height / 800;
      final rotation = p.rotation + p.rotationSpeed * progress;
      if (y < -50 || y > size.height + 50) continue;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      final paint = Paint()..color = p.color.withValues(alpha: (1 - progress * 0.6) * 0.8);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ResultConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
