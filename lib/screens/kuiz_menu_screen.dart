import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';
import 'quiz_screen.dart';

class KuizMenuScreen extends StatelessWidget {
  const KuizMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final s = (size.width / 375).clamp(0.8, 1.4);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Kuiz'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 48 : 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pilih Kuiz',
                style: TextStyle(
                  fontSize: isTablet ? 40 : 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: isTablet ? 48 : 36.0),
              _buildQuizCard(
                context,
                emoji: 'Tumbuhan',
                title: 'Tumbuhan',
                subtitle: '20 soalan',
                color: Colors.green,
                questions: QuizService.getPlantQuestions(),
                isTablet: isTablet,
                s: s,
              ),
              SizedBox(height: isTablet ? 28 : 18.0),
              _buildQuizCard(
                context,
                emoji: 'Rangka Manusia',
                title: 'Sistem Rangka Manusia',
                subtitle: '10 soalan',
                color: Colors.blue,
                questions: QuizService.getSkeletonQuestions(),
                isTablet: isTablet,
                s: s,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required List<QuizQuestion> questions,
    required bool isTablet,
    required double s,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Text(emoji == 'Tumbuhan' ? '🌿' : '🦴', style: TextStyle(fontSize: isTablet ? 32 : 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kuiz $title',
                    style: TextStyle(fontSize: isTablet ? 24 : 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bersedia untuk menguji pengetahuan anda tentang $title?',
                  style: TextStyle(fontSize: isTablet ? 18 : 15),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: isTablet ? 24 : 20),
                      SizedBox(width: isTablet ? 12 : 8),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.orange.shade800, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal', style: TextStyle(fontSize: isTablet ? 18 : 15, color: Colors.grey)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(questions: questions),
                    ),
                  );
                },
                icon: Icon(Icons.play_arrow, color: Colors.white, size: isTablet ? 24 : 20),
                label: Text('Mula!', style: TextStyle(fontSize: isTablet ? 18 : 15, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 20, vertical: isTablet ? 14 : 10),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 40 : 28.0,
          horizontal: isTablet ? 32 : 22.0,
        ),
        child: Row(
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(isTablet ? 20 : 14.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(emoji, style: TextStyle(fontSize: isTablet ? 48 : 36.0)),
                ),
              ),
            ),
            SizedBox(width: isTablet ? 24 : 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 30 : 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isTablet ? 8 : 4.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 15.0,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.quiz,
              color: Colors.white.withValues(alpha: 0.9),
              size: isTablet ? 56 : 40.0,
            ),
          ],
        ),
      ),
    );
  }
}
