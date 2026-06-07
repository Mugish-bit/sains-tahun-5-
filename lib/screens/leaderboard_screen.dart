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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final s = (size.width / 375).clamp(0.8, 1.4);

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 20 * s),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: isTablet ? 28 : 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: isTablet ? 12 : 8 * s),
                      Text(
                        'Papan Pendahulu',
                        style: TextStyle(
                          fontSize: isTablet ? 32 : 24 * s.clamp(0.85, 1.15),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 48 : 32 * s),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (_, __) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: isTablet ? 160 : 120 * s.clamp(0.85, 1.15),
                      height: isTablet ? 160 : 120 * s.clamp(0.85, 1.15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: isTablet ? 5 : 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getRankEmoji(),
                          style: TextStyle(fontSize: isTablet ? 72 : 56 * s.clamp(0.85, 1.15)),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 28 : 24 * s),
                Text(
                  _getRankTitle(),
                  style: TextStyle(
                    fontSize: isTablet ? 30 : 22 * s.clamp(0.85, 1.15),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isTablet ? 40 : 28 * s),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 80 : 24 * s),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(isTablet ? 36 : 30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: isTablet ? 3 : 2,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 40 : 28 * s,
                    horizontal: isTablet ? 36 : 20 * s,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'JUMLAH MARKAH',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 16 * s,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8 * s),
                      Text(
                        '$_currentScore',
                        style: TextStyle(
                          fontSize: isTablet ? 96 : 72 * s.clamp(0.8, 1.1),
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          height: 1,
                        ),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star,
                                color: Colors.amber.shade300, size: isTablet ? 24 : 18),
                            SizedBox(width: isTablet ? 10 : 6 * s),
                            Text(
                              _getNextMilestone(),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isTablet ? 18 : 14 * s,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 24 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMiniBadge('🌱', 10, isTablet, s),
                    SizedBox(width: isTablet ? 24 : 16 * s),
                    _buildMiniBadge('🌿', 100, isTablet, s),
                    SizedBox(width: isTablet ? 24 : 16 * s),
                    _buildMiniBadge('🌳', 250, isTablet, s),
                  ],
                ),
                SizedBox(height: isTablet ? 32 : 20 * s),
                Padding(
                  padding: EdgeInsets.all(isTablet ? 28 : 20 * s),
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
                      icon: Icon(Icons.refresh, color: Colors.white70, size: isTablet ? 24 : 20),
                      label: Text(
                        'Reset Markah',
                        style: TextStyle(fontSize: isTablet ? 20 : 16 * s, color: Colors.white70),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: isTablet ? 2 : 1),
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 14 * s),
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
      ),
    );
  }

  String _getNextMilestone() {
    if (_currentScore < 10) return '${10 - _currentScore} mata lagi ke 🌱 Pemula';
    if (_currentScore < 100) return '${100 - _currentScore} mata lagi ke 🌿 Peneroka';
    if (_currentScore < 250) return '${250 - _currentScore} mata lagi ke 🌳 Pencinta Alam';
    return 'Tahniah! Semua lencana diperoleh! 🎉';
  }

  Widget _buildMiniBadge(String emoji, int required, bool isTablet, double s) {
    final unlocked = _currentScore >= required;
    return AnimatedOpacity(
      opacity: unlocked ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: isTablet ? 36 : 28 * s.clamp(0.85, 1.15))),
          Text(
            '$required',
            style: TextStyle(
              fontSize: isTablet ? 18 : 12 * s,
              color: Colors.white.withValues(alpha: unlocked ? 1 : 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
