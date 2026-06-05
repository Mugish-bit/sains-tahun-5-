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
      duration: const Duration(milliseconds: 600),
    );
    _starAnimation = CurvedAnimation(
      parent: _starController,
      curve: Curves.easeOutBack,
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scoreController.addListener(() {
      setState(() {
        _displayScore = (widget.score * _scoreAnimation.value).round();
      });
    });

    _loadCumulativeScore();
    _scoreController.forward();
    _starController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _starController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _loadCumulativeScore() async {
    _cumulativeScore = await ScoreService.getScore();
    if (mounted) setState(() {});
  }

  List<String> _getEarnedBadges() {
    List<String> badges = [];
    if (_cumulativeScore >= 10) badges.add('🌱 Pemula');
    if (_cumulativeScore >= 100) badges.add('🌿 Peneroka');
    if (_cumulativeScore >= 250) badges.add('🌳 Pencinta Alam');
    return badges;
  }

  int _getStars() {
    final pct = widget.score / (widget.totalQuestions * 10);
    if (pct >= 0.9) return 3;
    if (pct >= 0.7) return 2;
    if (pct >= 0.4) return 1;
    return 0;
  }

  String _getMessage() {
    final stars = _getStars();
    if (stars == 3) return 'Luar Biasa! 🏆';
    if (stars == 2) return 'Syabas! 👍';
    if (stars == 1) return 'Teruskan Usaha! 💪';
    return 'Jangan Putus Asa! 🌱';
  }

  @override
  Widget build(BuildContext context) {
    final earnedBadges = _getEarnedBadges();
    final stars = _getStars();
    final newBadges = earnedBadges.where((b) {
      final before = _cumulativeScore - widget.score;
      final name = b.split(' ').last;
      if (name == 'Pemula') return before < 10 && _cumulativeScore >= 10;
      if (name == 'Peneroka') return before < 100 && _cumulativeScore >= 100;
      if (name == 'Pencinta Alam') return before < 250 && _cumulativeScore >= 250;
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _starAnimation,
                    builder: (_, __) => Transform.scale(
                      scale: 0.5 + _starAnimation.value * 0.5,
                      child: Text(
                        _getStarsEmoji(stars),
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMessage(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Text(
                          'Markah Anda',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_displayScore',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ ${widget.totalQuestions * 10}',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildStarRow(stars),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Jumlah terkumpul: $_cumulativeScore',
                                style: const TextStyle(
                                  fontSize: 16,
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
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (_, __) => Transform.scale(
                        scale: 0.9 + _bounceController.value * 0.1,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber.shade300, Colors.orange.shade400],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text('🎉',
                                  style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              const Text(
                                'Lencana Baharu!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...newBadges.map((b) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    b,
                                    style: const TextStyle(
                                      fontSize: 18,
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
                    const SizedBox(height: 20),
                    Text(
                      'Lencana: ${earnedBadges.join(' | ')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Laman Utama',
                          style: TextStyle(
                            fontSize: 20,
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
      ),
    );
  }

  String _getStarsEmoji(int stars) {
    if (stars == 3) return '🌟🌟🌟';
    if (stars == 2) return '🌟🌟';
    if (stars == 1) return '🌟';
    return '⭐';
  }

  Widget _buildStarRow(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
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
                child: Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: i < stars ? Colors.amber : Colors.white.withOpacity(0.4),
                  size: 40,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
