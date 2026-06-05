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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
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
                          icon: const Icon(Icons.arrow_back, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Lencana Saya',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A148C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade300, Colors.orange.shade400],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            '$_score Mata',
                            style: const TextStyle(
                              fontSize: 22,
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
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return _BadgeCard(
                        index: index,
                        score: _score,
                        pulseController: _pulseController,
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

  const _BadgeCard({
    required this.index,
    required this.score,
    required this.pulseController,
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
        borderRadius: BorderRadius.circular(24),
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.amber.shade50],
              )
            : null,
        color: isUnlocked ? null : Colors.white.withOpacity(0.5),
        border: Border.all(
          color: isUnlocked
              ? Colors.amber.shade300
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
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
                  child: Text(emoji, style: TextStyle(fontSize: 48 + (isUnlocked ? 8 : 0))),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.deepPurple.shade800 : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('Dibuka', style: TextStyle(fontSize: 12, color: Colors.green)),
                ],
              ),
            )
          else ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.amber.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$requirement',
              style: const TextStyle(
                fontSize: 11,
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
