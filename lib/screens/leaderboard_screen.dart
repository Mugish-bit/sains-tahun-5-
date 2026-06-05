import 'package:flutter/material.dart';
import '../services/score_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  int _currentScore = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadScore();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadScore() async {
    _currentScore = await ScoreService.getScore();
    if (mounted) setState(() {});
  }

  String _getRankEmoji() {
    if (_currentScore >= 250) return '🥇';
    if (_currentScore >= 100) return '🥈';
    if (_currentScore >= 50) return '🥉';
    return '🏃';
  }

  String _getRankTitle() {
    if (_currentScore >= 250) return 'Pencinta Alam Sejati!';
    if (_currentScore >= 100) return 'Peneroka Aktif!';
    if (_currentScore >= 50) return 'Pengembara!';
    return 'Teruskan Belajar!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade600,
              Colors.deepOrange.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Papan Pendahulu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getRankEmoji(),
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getRankTitle(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      'JUMLAH MARKAH',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_currentScore',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star,
                              color: Colors.amber.shade300, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            _getNextMilestone(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMiniBadge('🌱', 10),
                  const SizedBox(width: 16),
                  _buildMiniBadge('🌿', 100),
                  const SizedBox(width: 16),
                  _buildMiniBadge('🌳', 250),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await ScoreService.resetScore();
                      await _loadScore();
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Markah telah direset!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    label: const Text(
                      'Reset Markah',
                      style: TextStyle(color: Colors.white70),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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

  String _getNextMilestone() {
    if (_currentScore < 10) return '${10 - _currentScore} mata lagi ke 🌱 Pemula';
    if (_currentScore < 100) return '${100 - _currentScore} mata lagi ke 🌿 Peneroka';
    if (_currentScore < 250) return '${250 - _currentScore} mata lagi ke 🌳 Pencinta Alam';
    return 'Tahniah! Semua lencana diperoleh! 🎉';
  }

  Widget _buildMiniBadge(String emoji, int required) {
    final unlocked = _currentScore >= required;
    return AnimatedOpacity(
      opacity: unlocked ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          Text(
            '$required',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(unlocked ? 1 : 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
