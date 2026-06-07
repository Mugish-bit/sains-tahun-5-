import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';
import 'quiz_screen.dart';

class NotaHomeScreen extends StatelessWidget {
  const NotaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final s = (size.width / 375).clamp(0.8, 1.4);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('Nota'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 48 : 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nota',
                  style: TextStyle(
                    fontSize: isTablet ? 42 : 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                SizedBox(height: isTablet ? 20 : 14.0),
                Text(
                  'Pilih topik nota:',
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 17.0,
                    color: Colors.green.shade600,
                  ),
                ),
                SizedBox(height: isTablet ? 48 : 36.0),
                _buildTopicCard(
                  context: context,
                  emoji: 'Tumbuhan',
                  title: 'Tumbuhan',
                  subtitle: '3 video',
                  color: Colors.green,
                  videos: const [
                    'assets/videos/Tumbuhan/Topic1_Melindungi_diri_daripada_musuh.MOV',
                    'assets/videos/Tumbuhan/Topic2_menyesuaikan_diri_dengan_iklim.MOV',
                    'assets/videos/Tumbuhan/Topic3_pencaran_biji_benih_atau_buah.MOV',
                  ],
                  questions: QuizService.getPlantQuestions(),
                  isTablet: isTablet,
                  s: s,
                ),
                SizedBox(height: isTablet ? 28 : 18.0),
                _buildTopicCard(
                  context: context,
                  emoji: 'Rangka Manusia',
                  title: 'Sistem Rangka Manusia',
                  subtitle: '2 video',
                  color: Colors.blue,
                  videos: const [
                    'assets/videos/Manusia/Topic1_Sistem_Rangka_Manusia.mp4',
                    'assets/videos/Manusia/Topic2_Sistem_Peredaran_Darah.mp4',
                  ],
                  questions: QuizService.getSkeletonQuestions(),
                  isTablet: isTablet,
                  s: s,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTopicCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required List<String> videos,
    required List<QuizQuestion> questions,
    required bool isTablet,
    required double s,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotaVideoScreen(
              title: title,
              videoPaths: videos,
              emoji: emoji,
              color: color,
              questions: questions,
            ),
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
              Icons.play_circle_fill,
              color: Colors.white.withValues(alpha: 0.9),
              size: isTablet ? 60 : 44.0,
            ),
          ],
        ),
      ),
    );
  }
}

class NotaVideoScreen extends StatefulWidget {
  final String title;
  final List<String> videoPaths;
  final String emoji;
  final Color color;
  final List<QuizQuestion> questions;

  const NotaVideoScreen({
    super.key,
    required this.title,
    required this.videoPaths,
    required this.emoji,
    required this.color,
    required this.questions,
  });

  @override
  State<NotaVideoScreen> createState() => _NotaVideoScreenState();
}

class _NotaVideoScreenState extends State<NotaVideoScreen> {
  VideoPlayerController? _controller;
  int _currentVideoIndex = 0;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initVideo(0);
  }

  Future<void> _initVideo(int index) async {
    _controller?.dispose();
    setState(() {
      _currentVideoIndex = index;
      _isInitialized = false;
      _isPlaying = false;
    });

    final controller = VideoPlayerController.asset(widget.videoPaths[index]);
    _controller = controller;
    await controller.initialize();
    controller.addListener(_onVideoUpdate);
    setState(() => _isInitialized = true);
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    setState(() {
      _isPlaying = _controller!.value.isPlaying;
    });
  }

  void _togglePlay() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoTitles = widget.videoPaths.map((p) {
      final name = p.split('/').last.split('.').first;
      return name.replaceAll('_', ' ');
    }).toList();

    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final s = (size.width / 375).clamp(0.8, 1.4);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text('${widget.emoji} ${widget.title}'),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 24 * s : 16 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isInitialized && _controller != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            ),
                            GestureDetector(
                              onTap: _togglePlay,
                              child: Container(
                                color: Colors.transparent,
                                child: _isPlaying
                                    ? const SizedBox()
                                    : Container(
                                        padding: EdgeInsets.all(isTablet ? 28 : 20 * s),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: isTablet ? 64 : 50 * s.clamp(0.8, 1.2),
                                        ),
                                      ),
                              ),
                            ),
                            if (_isPlaying)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: VideoProgressIndicator(
                                  _controller!,
                                  allowScrubbing: true,
                                  colors: VideoProgressColors(
                                    playedColor: widget.color,
                                    bufferedColor: Colors.white24,
                                    backgroundColor: Colors.white12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      height: isTablet ? 300 : 200 * s.clamp(0.8, 1.2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  SizedBox(height: isTablet ? 32 : 24 * s),
                  Text(
                    'Senarai Video',
                    style: TextStyle(
                      fontSize: isTablet ? 26 : 20 * s.clamp(0.85, 1.15),
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12 * s),
                  ...List.generate(widget.videoPaths.length, (i) {
                    final isActive = i == _currentVideoIndex;
                    return GestureDetector(
                      onTap: () => _initVideo(i),
                      child: Container(
                        margin: EdgeInsets.only(bottom: isTablet ? 12 : 8 * s),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 16 * s,
                          vertical: isTablet ? 18 : 14 * s,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? widget.color.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                          border: Border.all(
                            color: isActive
                                ? widget.color
                                : Colors.grey.shade200,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isTablet ? 12 : 8 * s),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? widget.color
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isActive ? Icons.play_arrow : Icons.play_circle_outline,
                                color: isActive ? Colors.white : Colors.grey,
                                size: isTablet ? 32 : 24 * s.clamp(0.85, 1.15),
                              ),
                            ),
                            SizedBox(width: isTablet ? 20 : 14 * s),
                            Expanded(
                              child: Text(
                                videoTitles[i],
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 15 * s.clamp(0.85, 1.15),
                                  fontWeight:
                                      isActive ? FontWeight.bold : FontWeight.w500,
                                  color:
                                      isActive ? widget.color : Colors.black87,
                                ),
                              ),
                            ),
                            if (isActive && _isPlaying)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 14 : 8 * s,
                                  vertical: isTablet ? 8 : 4 * s,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Sedang Main',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 11 * s,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20 * s, 8 * s, 20 * s, 20 * s),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Row(
                      children: [
                        Text('📝', style: TextStyle(fontSize: isTablet ? 32 : 24)),
                        const SizedBox(width: 8),
                        Text('Mulakan Kuiz', style: TextStyle(fontSize: isTablet ? 24 : 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    content: Text(
                      'Anda akan memulakan kuiz ${widget.title.toLowerCase()}. Sedia untuk menjawab soalan?',
                      style: TextStyle(fontSize: isTablet ? 18 : 15),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Batal', style: TextStyle(fontSize: isTablet ? 18 : 15, color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(questions: widget.questions),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 20, vertical: isTablet ? 14 : 10),
                        ),
                        child: Text('Mulakan', style: TextStyle(fontSize: isTablet ? 18 : 15, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.quiz, color: Colors.white, size: isTablet ? 28 : 24),
              label: Text(
                'Mulakan Kuiz',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 20 * s.clamp(0.85, 1.15),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 18 * s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 28 : 20),
                ),
                elevation: 6,
                shadowColor: Colors.orange.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
