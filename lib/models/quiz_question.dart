class QuizQuestion {
  final String question;
  final List<String>? options;
  final List<String>? optionImagePaths;
  final int correctOptionIndex;
  final String? imagePath;

  QuizQuestion({
    required this.question,
    this.options,
    this.optionImagePaths,
    required this.correctOptionIndex,
    this.imagePath,
  }) {
    assert(options != null || optionImagePaths != null);
  }
}