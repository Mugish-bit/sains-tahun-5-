import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _scoreKey = 'user_score';

  static Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scoreKey, score);
  }

  static Future<void> addScore(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_scoreKey) ?? 0;
    await prefs.setInt(_scoreKey, current + points);
  }

  static Future<int> getScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scoreKey) ?? 0;
  }

  static Future<void> resetScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoreKey);
  }
}