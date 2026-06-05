import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import 'quiz_screen.dart';

class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('Pilih Topik'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTopicButton(
              context,
              title: '🌿 Tumbuhan',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(questions: QuizService.getPlantQuestions()),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildTopicButton(
              context,
              title: '🦴 Sistem Rangka Manusia',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(questions: QuizService.getSkeletonQuestions()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicButton(BuildContext context, {required String title, required Color color, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(250, 70),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: Text(title, style: const TextStyle(fontSize: 24)),
    );
  }
}