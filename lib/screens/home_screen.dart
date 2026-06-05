import 'dart:math';
import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'leaderboard_screen.dart';
import 'badges_screen.dart';
import '../services/score_service.dart';
import '../services/quiz_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _resetForNewUser(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text('Reset untuk Pengguna Baru'),
        content: const Text('Semua markah dan lencana akan dihapuskan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ScoreService.resetScore();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Markah dan lencana telah direset!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ...List.generate(6, (i) => _buildFloatingEmoji(i)),
              Column(
                children: [
                  _buildHeader(context),
                  const Spacer(),
                  _buildMenuButtons(context),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingEmoji(int index) {
    final emojis = ['🌿', '🌱', '🌸', '🍃', '🌻', '🌴'];
    final random = Random(index * 7);
    final x = random.nextDouble() * 0.85 + 0.05;
    final y = random.nextDouble() * 0.8 + 0.1;
    final delay = index * 0.3;
    return Positioned(
      left: MediaQuery.of(context).size.width * x - 20,
      top: MediaQuery.of(context).size.height * y - 20,
      child: _FloatingEmoji(
        emoji: emojis[index],
        delay: delay,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌟 Sains Tahun 5',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manusia & Tumbuhan',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.grey),
              onPressed: () => _resetForNewUser(context),
              tooltip: 'Reset untuk pengguna baru',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          _MenuButton(
            icon: Icons.eco,
            label: '🌿 Tumbuhan',
            subtitle: '20 soalan',
            color1: const Color(0xFF43A047),
            color2: const Color(0xFF2E7D32),
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => QuizScreen(
                  questions: QuizService.getPlantQuestions(),
                ),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.accessibility_new,
            label: '🦴 Rangka Manusia',
            subtitle: '10 soalan',
            color1: const Color(0xFF1E88E5),
            color2: const Color(0xFF1565C0),
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => QuizScreen(
                  questions: QuizService.getSkeletonQuestions(),
                ),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.emoji_events,
            label: '🏆 Papan Pendahulu',
            subtitle: 'Markah terkumpul',
            color1: const Color(0xFFFB8C00),
            color2: const Color(0xFFEF6C00),
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const LeaderboardScreen(),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.star,
            label: '⭐ Lencana Saya',
            subtitle: 'Pencapaian',
            color1: const Color(0xFF8E24AA),
            color2: const Color(0xFF6A1B9A),
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const BadgesScreen(),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingEmoji extends StatefulWidget {
  final String emoji;
  final double delay;
  const _FloatingEmoji({required this.emoji, required this.delay});

  @override
  State<_FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<_FloatingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _float = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _float.value),
        child: Opacity(
          opacity: 0.3,
          child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [widget.color1, widget.color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color2.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.label.split(' ').first,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.8), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringSplitFirst on String {
  String get first => split(' ').first;
}
