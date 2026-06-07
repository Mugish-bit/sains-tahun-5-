import 'dart:math';
import 'package:flutter/material.dart';
import 'leaderboard_screen.dart';
import 'badges_screen.dart';
import 'nota_screen.dart';
import 'kuiz_menu_screen.dart';
import '../services/score_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  late AnimationController _headerController;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerFade;

  late List<AnimationController> _menuControllers;
  late List<Animation<Offset>> _menuSlides;
  late List<Animation<double>> _menuFades;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bgAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    const count = 4;
    _menuControllers = List.generate(count, (_) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    ));
    _menuSlides = _menuControllers.map((c) => Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic))).toList();
    _menuFades = _menuControllers.map((c) => Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: c, curve: Curves.easeOut),
    )).toList();

    _headerController.forward();
    for (var i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 120), () {
        if (mounted) _menuControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _headerController.dispose();
    for (final c in _menuControllers) {
      c.dispose();
    }
    super.dispose();
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final s = (size.width / 375).clamp(0.8, 1.4);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFFE8F5E9), const Color(0xFFC8E6C9), _bgAnimation.value)!,
                  Color.lerp(const Color(0xFFC8E6C9), const Color(0xFFA5D6A7), _bgAnimation.value)!,
                  Color.lerp(const Color(0xFFA5D6A7), const Color(0xFF81C784), _bgAnimation.value)!,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  ...List.generate(isTablet ? 12 : 8, (i) => _buildEnhancedEmoji(i)),
                  Column(
                    children: [
                      _buildAnimatedHeader(context, isTablet, s),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(top: 10 * s, bottom: 40 * s),
                          child: _buildMenuButtons(context, isTablet, s),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedEmoji(int index) {
    final emojis = ['🌿', '🌱', '🌸', '🍃', '🌻', '🌴', '🌺', '🍀'];
    final random = Random(index * 7 + 3);
    final x = random.nextDouble() * 0.92;
    final y = random.nextDouble() * 0.9;
    final size = 24.0 + random.nextDouble() * 24;
    final duration = 3.0 + random.nextDouble() * 4;
    final delay = index * 0.4;
    return Positioned(
      left: MediaQuery.of(context).size.width * x - size / 2,
      top: MediaQuery.of(context).size.height * y - size / 2,
      child: _EnhancedFloatingEmoji(
        emoji: emojis[index % emojis.length],
        size: size,
        duration: duration,
        delay: delay,
        opacity: 0.15 + random.nextDouble() * 0.15,
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context, bool isTablet, double s) {
    return SlideTransition(
      position: _headerSlide,
      child: FadeTransition(
        opacity: _headerFade,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20 * s, isTablet ? 32 * s : 20 * s, 20 * s, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Sains Tahun 5',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 13 * s,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 10 : 6 * s),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.green.shade800, Colors.green.shade600, Colors.teal.shade400],
                      ).createShader(bounds),
                      child: Text(
                        'Manusia & Tumbuhan',
                        style: TextStyle(
                          fontSize: isTablet ? 44 : 30 * s.clamp(0.85, 1.15),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 2 * s),
                    Text(
                      'Belajar Sains dengan lebih seronok!',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 13 * s,
                        color: Colors.green.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: Colors.grey, size: isTablet ? 28 : 24),
                  onPressed: () => _resetForNewUser(context),
                  tooltip: 'Reset untuk pengguna baru',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context, bool isTablet, double s) {
    final menuItems = [
      _MenuData(
        icon: Icons.book,
        label: 'Nota',
        subtitle: 'Video pembelajaran',
        color1: const Color(0xFF7B1FA2),
        color2: const Color(0xFF4A0072),
        emoji: '📖',
        screen: const NotaHomeScreen(),
      ),
      _MenuData(
        icon: Icons.quiz,
        label: 'Kuiz',
        subtitle: 'Tumbuhan & Manusia',
        color1: const Color(0xFF00897B),
        color2: const Color(0xFF004D40),
        emoji: '📝',
        screen: const KuizMenuScreen(),
      ),
      _MenuData(
        icon: Icons.emoji_events,
        label: 'Papan Pendahulu',
        subtitle: 'Markah terkumpul',
        color1: const Color(0xFFFB8C00),
        color2: const Color(0xFFEF6C00),
        emoji: '🏆',
        screen: const LeaderboardScreen(),
      ),
      _MenuData(
        icon: Icons.star,
        label: 'Lencana Saya',
        subtitle: 'Pencapaian',
        color1: const Color(0xFF8E24AA),
        color2: const Color(0xFF6A1B9A),
        emoji: '⭐',
        screen: const BadgesScreen(),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 * s : 24 * s),
      child: Column(
        children: List.generate(menuItems.length, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: isTablet ? 20 * s : 14 * s),
            child: SlideTransition(
              position: _menuSlides[i],
              child: FadeTransition(
                opacity: _menuFades[i],
                child: _EnhancedMenuButton(
                  data: menuItems[i],
                  index: i,
                  isTablet: isTablet,
                  s: s,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color1;
  final Color color2;
  final String emoji;
  final Widget screen;

  const _MenuData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.emoji,
    required this.screen,
  });
}

class _EnhancedFloatingEmoji extends StatefulWidget {
  final String emoji;
  final double size;
  final double duration;
  final double delay;
  final double opacity;

  const _EnhancedFloatingEmoji({
    required this.emoji,
    required this.size,
    required this.duration,
    required this.delay,
    required this.opacity,
  });

  @override
  State<_EnhancedFloatingEmoji> createState() => _EnhancedFloatingEmojiState();
}

class _EnhancedFloatingEmojiState extends State<_EnhancedFloatingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _float;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.duration * 1000).round()),
    );
    _float = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _rotate = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
      animation: _controller,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: Transform.rotate(
            angle: _rotate.value,
            child: Opacity(
              opacity: widget.opacity,
              child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
            ),
          ),
        );
      },
    );
  }
}

class _EnhancedMenuButton extends StatefulWidget {
  final _MenuData data;
  final int index;
  final bool isTablet;
  final double s;

  const _EnhancedMenuButton({
    required this.data,
    required this.index,
    this.isTablet = false,
    this.s = 1.0,
  });

  @override
  State<_EnhancedMenuButton> createState() => _EnhancedMenuButtonState();
}

class _EnhancedMenuButtonState extends State<_EnhancedMenuButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final isTablet = widget.isTablet;

    return AnimatedBuilder(
      animation: Listenable.merge([_pressScale, _glowAnimation]),
      builder: (_, __) {
        return Transform.scale(
          scale: _pressScale.value,
          child: GestureDetector(
            onTapDown: (_) => _pressController.forward(),
            onTapUp: (_) {
              _pressController.reverse();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => widget.data.screen,
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
            onTapCancel: () => _pressController.reverse(),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
                gradient: LinearGradient(
                  colors: [widget.data.color1, widget.data.color2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.data.color2.withValues(alpha: 0.3 * _glowAnimation.value),
                    blurRadius: 12 + 4 * (1 - _glowAnimation.value),
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 28 * s : 18 * s,
                  horizontal: isTablet ? 28 * s : 20 * s,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 18 : 12 * s),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      ),
                      child: Text(
                        widget.data.emoji,
                        style: TextStyle(fontSize: isTablet ? 40 : 28 * s.clamp(0.85, 1.15)),
                      ),
                    ),
                    SizedBox(width: isTablet ? 24 : 16 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data.label,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 28 : 20 * s.clamp(0.85, 1.15),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isTablet ? 6 : 2 * s),
                          Text(
                            widget.data.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: isTablet ? 18 : 13 * s,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 8 * s),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: isTablet ? 24 : 16 * s,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
