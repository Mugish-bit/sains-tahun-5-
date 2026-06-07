import 'package:flutter/material.dart';
import '../services/score_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with TickerProviderStateMixin {
  int _score = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _loadScore();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadScore() async {
    _score = await ScoreService.getScore();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final s = (size.width / 375).clamp(0.8, 1.4);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7), Color(0xFFCE93D8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 28 : 20 * s),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.grey, size: isTablet ? 28 : 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: isTablet ? 12 : 8 * s),
                        Text(
                          'Lencana Saya',
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 24 * s.clamp(0.85, 1.15),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4A148C),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 16 : 12 * s),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 36 : 24 * s,
                        vertical: isTablet ? 18 : 12 * s,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade300, Colors.orange.shade400],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: isTablet ? 36 : 28),
                          SizedBox(width: isTablet ? 12 : 8 * s),
                          Text(
                            '$_score Mata',
                            style: TextStyle(
                              fontSize: isTablet ? 30 : 22 * s.clamp(0.85, 1.15),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 28 : 20 * s),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20 * s),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      childAspectRatio: isTablet ? 1.0 : 0.85,
                      crossAxisSpacing: isTablet ? 24 : 16 * s,
                      mainAxisSpacing: isTablet ? 24 : 16 * s,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return _BadgeCard(
                        index: index,
                        score: _score,
                        pulseController: _pulseController,
                        isTablet: isTablet,
                        s: s,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final int index;
  final int score;
  final AnimationController pulseController;
  final bool isTablet;
  final double s;

  const _BadgeCard({
    required this.index,
    required this.score,
    required this.pulseController,
    this.isTablet = false,
    this.s = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String emoji;
    String requirement;
    bool isUnlocked;

    if (index == 0) {
      title = 'Pemula';
      emoji = '🌱';
      requirement = '10 mata';
      isUnlocked = score >= 10;
    } else if (index == 1) {
      title = 'Peneroka';
      emoji = '🌿';
      requirement = '100 mata';
      isUnlocked = score >= 100;
    } else {
      title = 'Pencinta Alam';
      emoji = '🌳';
      requirement = '250 mata';
      isUnlocked = score >= 250;
    }

    final progress = isUnlocked
        ? 1.0
        : (score / _getRequiredScore()).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.amber.shade50],
              )
            : null,
        color: isUnlocked ? null : Colors.white.withValues(alpha: 0.5),
        border: Border.all(
          color: isUnlocked
              ? Colors.amber.shade300
              : Colors.grey.shade300,
          width: isTablet ? 3 : 2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseController,
            builder: (_, __) {
              final glow = isUnlocked
                  ? 0.8 + pulseController.value * 0.2
                  : 1.0;
              return Transform.scale(
                scale: glow,
                child: Opacity(
                  opacity: isUnlocked ? 1.0 : 0.4,
                  child: Text(emoji, style: TextStyle(fontSize: (48 + (isUnlocked ? 8 : 0)) * s.clamp(0.85, 1.15))),
                ),
              );
            },
          ),
          SizedBox(height: isTablet ? 12 : 8 * s),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 24 : 18 * s.clamp(0.85, 1.15),
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.deepPurple.shade800 : Colors.grey,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 4 * s),
          if (isUnlocked)
            Container(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12 * s, vertical: isTablet ? 8 : 4 * s),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: isTablet ? 22 : 16),
                  SizedBox(width: isTablet ? 8 : 4 * s),
                  Text('Dibuka', style: TextStyle(fontSize: isTablet ? 16 : 12 * s, color: Colors.green)),
                ],
              ),
            )
          else ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 20 * s),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: isTablet ? 10 : 6 * s,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.amber.shade600,
                  ),
                ),
              ),
            ),
            SizedBox(height: isTablet ? 8 : 4 * s),
            Text(
              requirement,
              style: TextStyle(
                fontSize: isTablet ? 16 : 11 * s,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getRequiredScore() {
    if (index == 0) return 10;
    if (index == 1) return 100;
    return 250;
  }
}
