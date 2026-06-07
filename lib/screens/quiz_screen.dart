import 'dart:math';
import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/score_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _streak = 0;
  late List<QuizQuestion> _questions;
  bool _isAnswered = false;
  int _selectedOption = -1;
  bool _isCorrect = false;

  static const int _timerDuration = 20;
  int _timeRemaining = _timerDuration;
  late AnimationController _timerController;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  late AnimationController _confettiController;
  final List<_ConfettiParticle> _confettiParticles = [];

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<_FloatingPopup> _popups = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.questions);

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _timerDuration),
    )..addListener(() {
      if (!_isAnswered) {
        final elapsed = (_timerController.value * _timerDuration).round();
        if (elapsed != _timeRemaining) {
          setState(() => _timeRemaining = _timerDuration - elapsed);
        }
      }
    })..addStatusListener((status) {
      if (status == AnimationStatus.dismissed && !_isAnswered) {
        _checkAnswer(-1);
      }
    });
    _timerController.forward();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() => setState(() {}))
     ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _confettiParticles.clear();
        }
      });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _bounceController.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;

    _timerController.stop();
    final correct = selectedIndex >= 0 && selectedIndex == _questions[_currentQuestionIndex].correctOptionIndex;

    setState(() {
      _isAnswered = true;
      _selectedOption = selectedIndex;
      _isCorrect = correct;

      if (correct) {
        _streak++;
        _score += 1;
        ScoreService.addScore(1);
        _bounceController.forward(from: 0.0);
        _spawnConfetti();
        _showPopup('+1 ✅');
      } else {
        _streak = 0;
        _shakeController.forward(from: 0.0);
        _showPopup('❌');
      }
    });
  }

  void _showPopup(String text) {
    _popups.add(_FloatingPopup(text: text, id: DateTime.now().millisecondsSinceEpoch));
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _popups.removeAt(0));
      }
    });
  }

  void _spawnConfetti() {
    _confettiParticles.clear();
    for (int i = 0; i < 30; i++) {
      _confettiParticles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speedX: (_random.nextDouble() - 0.5) * 4,
        speedY: -_random.nextDouble() * 6 - 2,
        rotation: _random.nextDouble() * 6,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        size: _random.nextDouble() * 10 + 5,
        color: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink][_random.nextInt(7)],
      ));
    }
    _confettiController.forward(from: 0.0);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 < _questions.length) {
      _timerController.reset();
      _timeRemaining = _timerDuration;
      _timerController.forward();
      _slideController.forward(from: 0.0);
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedOption = -1;
        _isCorrect = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: _score,
            totalQuestions: _questions.length,
          ),
        ),
      );
    }
  }

  String _getScoreEmoji() {
    if (_score >= 15) return '🌟';
    if (_score >= 10) return '⭐';
    if (_score >= 5) return '👍';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final s = (size.width / 375).clamp(0.8, 1.4);
    final question = _questions[_currentQuestionIndex];
    final isImageOptions = question.optionImagePaths != null && question.optionImagePaths!.isNotEmpty;
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(progress, isTablet, s),
                  _buildQuestionDots(isTablet, s),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isTablet ? 24 * s : 16 * s),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            if (question.imagePath != null)
                              Container(
                                margin: EdgeInsets.only(bottom: isTablet ? 20 : 16 * s),
                                padding: EdgeInsets.all(isTablet ? 12 : 8 * s),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.green.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    question.imagePath!,
                                    height: isTablet ? 200 : 120 * s.clamp(0.8, 1.2),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (_, child) {
                                final shake = _isAnswered && !_isCorrect ? _shakeAnimation.value : 0.0;
                                return Transform.translate(
                                  offset: Offset(shake, 0),
                                  child: AnimatedScale(
                                    scale: _isAnswered && _isCorrect ? 1.03 : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                                  boxShadow: [
                                    BoxShadow(color: Colors.green.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 6)),
                                  ],
                                  border: _isAnswered
                                      ? Border.all(
                                          color: _isCorrect ? Colors.green.shade400 : Colors.red.shade400,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                padding: EdgeInsets.all(isTablet ? 28 * s : 20 * s),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(isTablet ? 12 : 8 * s),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Q${_currentQuestionIndex + 1}',
                                            style: TextStyle(
                                              fontSize: isTablet ? 22 : 16 * s.clamp(0.85, 1.15),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: isTablet ? 16 : 12 * s),
                                        Expanded(
                                          child: Text(
                                            question.question,
                                            style: TextStyle(
                                              fontSize: isTablet ? 24 : 18 * s.clamp(0.85, 1.15),
                                              fontWeight: FontWeight.w600,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: isTablet ? 28 : 20 * s),
                            if (_isAnswered && _isCorrect)
                              AnimatedBuilder(
                                animation: _bounceAnimation,
                                builder: (_, child) => Transform.scale(
                                  scale: 0.8 + _bounceAnimation.value * 0.2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24 * s, vertical: isTablet ? 16 : 12 * s),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.green.shade400, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('🎉', style: TextStyle(fontSize: isTablet ? 36 : 28 * s.clamp(0.85, 1.15))),
                                        SizedBox(width: isTablet ? 12 : 8 * s),
                                        Text(
                                          _streak >= 3 ? 'Hebat! $_streak berturut-turut! 🔥' : 'Betul! +1 mata',
                                          style: TextStyle(
                                            fontSize: isTablet ? 26 : 20 * s.clamp(0.85, 1.15),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (_isAnswered && !_isCorrect)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24 * s, vertical: isTablet ? 16 : 12 * s),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.red.shade300, width: 2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('😅', style: TextStyle(fontSize: isTablet ? 36 : 28 * s.clamp(0.85, 1.15))),
                                    SizedBox(width: isTablet ? 12 : 8 * s),
                                    Expanded(
                                      child: Text(
                                        'Jawapan: ${_getCorrectAnswerText(question)}',
                                        style: TextStyle(
                                          fontSize: isTablet ? 22 : 16 * s.clamp(0.85, 1.15),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: isTablet ? 24 : 16 * s),
                            if (isImageOptions)
                              _buildImageOptions(question, isTablet, s)
                            else
                              _buildTextOptions(question, isTablet, s),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isAnswered)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 18 * s),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isTablet ? 24 : 20)),
                          elevation: 6,
                          shadowColor: Colors.orange.withValues(alpha: 0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentQuestionIndex + 1 < _questions.length ? 'Soalan Seterusnya' : 'Lihat Keputusan',
                              style: TextStyle(fontSize: isTablet ? 26 : 20 * s.clamp(0.85, 1.15), fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: isTablet ? 12 : 8 * s),
                            Icon(Icons.arrow_forward, size: isTablet ? 28 : 24),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_confettiParticles.isNotEmpty) _buildConfettiOverlay(),
          ..._popups.map((p) => _buildPopup(p)),
        ],
      ),
    );
  }

  Widget _buildPopup(_FloatingPopup popup) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (_, value, __) {
        return Positioned(
          top: 120 - value * 80,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 1 - value,
            child: IgnorePointer(
              child: Text(
                popup.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32 + (1 - value) * 8,
                  fontWeight: FontWeight.bold,
                  color: popup.text.contains('❌') ? Colors.red : Colors.green,
                  shadows: [
                    Shadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionDots(bool isTablet, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 6 * s),
      color: Colors.white.withValues(alpha: 0.7),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_questions.length, (i) {
            final isCurrent = i == _currentQuestionIndex;
            final isPast = i < _currentQuestionIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isCurrent ? (isTablet ? 28 : 20 * s) : (isTablet ? 12 : 8 * s),
              height: isTablet ? 12 : 8 * s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isCurrent
                    ? Colors.green
                    : isPast
                        ? Colors.green.shade300
                        : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopBar(double progress, bool isTablet, double s) {
    final timerColor = _timeRemaining > 10 ? Colors.green : (_timeRemaining > 5 ? Colors.orange : Colors.red);

    return Container(
      padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 8 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.grey, size: isTablet ? 28 : 24),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Soalan ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 16 * s.clamp(0.85, 1.15),
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 6 * s),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: isTablet ? 14 : 10 * s,
                              backgroundColor: Colors.green.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 12 : 8 * s),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 14 : 10 * s,
                            vertical: isTablet ? 8 : 4 * s,
                          ),
                          decoration: BoxDecoration(
                            color: timerColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: timerColor, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _timeRemaining > 10 ? Icons.timer : Icons.timer_off,
                                color: timerColor,
                                size: isTablet ? 22 : 16 * s.clamp(0.85, 1.15),
                              ),
                              SizedBox(width: isTablet ? 6 : 4 * s),
                              Text(
                                '$_timeRemaining',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: timerColor,
                                  fontSize: isTablet ? 22 : 15 * s.clamp(0.85, 1.15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8 * s),
              if (_streak >= 2)
                Container(
                  margin: EdgeInsets.only(right: isTablet ? 8 : 4 * s),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 14 : 8 * s,
                    vertical: isTablet ? 8 : 4 * s,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔥', style: TextStyle(fontSize: (14 + min(_streak.toDouble(), 5) * 2) * s.clamp(0.85, 1.15))),
                      SizedBox(width: isTablet ? 6 : 2 * s),
                      Text(
                        '$_streak',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                          fontSize: isTablet ? 22 : 16 * s.clamp(0.85, 1.15),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 14 * s,
                  vertical: isTablet ? 10 : 8 * s,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade400, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_getScoreEmoji(), style: TextStyle(fontSize: isTablet ? 26 : 18 * s.clamp(0.85, 1.15))),
                    SizedBox(width: isTablet ? 8 : 4 * s),
                    Text(
                      '$_score',
                      style: TextStyle(
                        fontSize: isTablet ? 26 : 18 * s.clamp(0.85, 1.15),
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.green;
    if (progress < 0.6) return Colors.lightGreen;
    if (progress < 0.8) return Colors.amber;
    return Colors.orange;
  }

  String _getCorrectAnswerText(QuizQuestion question) {
    if (question.options != null) {
      return question.options![question.correctOptionIndex];
    }
    return 'Lihat gambar yang betul';
  }

  Widget _buildImageOptions(QuizQuestion question, bool isTablet, double s) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        childAspectRatio: isTablet ? 1.2 : 1.0,
        crossAxisSpacing: isTablet ? 20 : 15 * s,
        mainAxisSpacing: isTablet ? 20 : 15 * s,
      ),
      itemCount: question.optionImagePaths!.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedOption == index;
        final isCorrect = index == question.correctOptionIndex;
        Color borderColor = Colors.white;
        double elevation = 4;
        if (_isAnswered) {
          if (isCorrect) { borderColor = Colors.green; elevation = 8; }
          else if (isSelected && !isCorrect) { borderColor = Colors.red; elevation = 8; }
        }
        return GestureDetector(
          onTap: _isAnswered ? null : () => _checkAnswer(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: (isSelected && !_isAnswered) ? Matrix4.translationValues(0, -8, 0) : Matrix4.identity(),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: isTablet ? 5 : 4),
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: borderColor == Colors.white ? Colors.grey.withValues(alpha: 0.2) : borderColor.withValues(alpha: 0.3),
                  blurRadius: elevation * 2, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 12 : 8 * s),
                      child: Image.asset(question.optionImagePaths![index], fit: BoxFit.contain),
                    ),
                  ),
                  if (_isAnswered && isCorrect)
                    Positioned(top: 4, right: 4, child: Container(
                      padding: EdgeInsets.all(isTablet ? 8 : 4 * s),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: Icon(Icons.check, color: Colors.white, size: isTablet ? 28 : 20 * s.clamp(0.85, 1.15)),
                    )),
                  if (_isAnswered && isSelected && !isCorrect)
                    Positioned(top: 4, right: 4, child: Container(
                      padding: EdgeInsets.all(isTablet ? 8 : 4 * s),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Icon(Icons.close, color: Colors.white, size: isTablet ? 28 : 20 * s.clamp(0.85, 1.15)),
                    )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextOptions(QuizQuestion question, bool isTablet, double s) {
    final labels = ['A', 'B', 'C', 'D'];
    final is2Col = isTablet || question.options!.length > 2;

    if (is2Col) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          childAspectRatio: isTablet ? 2.8 : 1.6,
          crossAxisSpacing: isTablet ? 16 : 10,
          mainAxisSpacing: isTablet ? 16 : 10,
        ),
        itemCount: question.options!.length,
        itemBuilder: (context, index) => _buildOptionCard(question, index, labels, isTablet, s),
      );
    }

    return Column(
      children: List.generate(question.options!.length, (index) => Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: _buildOptionCard(question, index, labels, isTablet, s),
      )),
    );
  }

  Widget _buildOptionCard(QuizQuestion question, int index, List<String> labels, bool isTablet, double s) {
    final isCorrect = index == question.correctOptionIndex;
    final isSelected = _selectedOption == index;

    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color labelColor = Colors.grey.shade600;
    if (_isAnswered) {
      if (isCorrect) { bgColor = Colors.green.shade100; borderColor = Colors.green; labelColor = Colors.green; }
      else if (isSelected && !isCorrect) { bgColor = Colors.red.shade50; borderColor = Colors.red; labelColor = Colors.red; }
    } else if (isSelected) { bgColor = Colors.blue.shade50; borderColor = Colors.blue; labelColor = Colors.blue; }

    return GestureDetector(
      onTap: _isAnswered ? null : () => _checkAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: (isSelected && !_isAnswered) ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          border: Border.all(color: borderColor, width: isTablet ? 3 : 2),
          boxShadow: [BoxShadow(color: borderColor.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: isTablet ? 14 : 12),
          child: Row(
            children: [
              Container(
                width: isTablet ? 44 : 32,
                height: isTablet ? 44 : 32,
                decoration: BoxDecoration(
                  color: _isAnswered && (isCorrect || (isSelected && !isCorrect)) ? borderColor : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _isAnswered && isCorrect
                      ? Icon(Icons.check, color: Colors.white, size: isTablet ? 24 : 18)
                      : _isAnswered && isSelected && !isCorrect
                          ? Icon(Icons.close, color: Colors.white, size: isTablet ? 24 : 18)
                          : Text(labels[index], style: TextStyle(fontWeight: FontWeight.bold, color: labelColor, fontSize: isTablet ? 20 : 14)),
                ),
              ),
              SizedBox(width: isTablet ? 14 : 10),
              Expanded(
                child: Text(
                  question.options![index],
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? labelColor : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfettiOverlay() {
    return IgnorePointer(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _ConfettiPainter(_confettiParticles, _confettiController.value),
      ),
    );
  }
}

class _FloatingPopup {
  final String text;
  final int id;
  _FloatingPopup({required this.text, required this.id});
}

class _ConfettiParticle {
  double x, y, speedX, speedY, rotation, rotationSpeed, size;
  Color color;
  _ConfettiParticle({required this.x, required this.y, required this.speedX, required this.speedY, required this.rotation, required this.rotationSpeed, required this.size, required this.color});
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = (p.x + p.speedX * progress) * size.width;
      final y = (p.y + p.speedY * progress + 300 * progress * progress) * size.height;
      final rotation = p.rotation + p.rotationSpeed * progress;
      if (y < 0 || y > size.height) continue;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      final paint = Paint()..color = p.color.withValues(alpha: (1 - progress) * 0.9);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
