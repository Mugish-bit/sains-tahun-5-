import '../models/quiz_question.dart';

class QuizService {
  // ---------- TUMBUHAN (20 soalan dari worksheet) ----------
  static List<QuizQuestion> getPlantQuestions() {
    return [
      // Q1 - Image options - Which plant uses thorns?
      QuizQuestion(
        question: 'Antara berikut tumbuhan manakah yang menggunakan duri untuk melindungi diri daripada bahaya.',
        optionImagePaths: [
          'assets/images/q1a(T).jpg',
          'assets/images/q1b(T).jpg',
          'assets/images/q1c(T).jpg',
          'assets/images/q1d(T).jpg',
        ],
        correctOptionIndex: 0,
        imagePath: null,
      ),
      // Q2 - Rafflesia - stinky smell
      QuizQuestion(
        question: 'Bagaimanakah tumbuhan ini melindungi diri daripada musuhnya.',
        options: ['Berbulu halus', 'Berduri tajam', 'Menghasilkan gas beracun', 'Mengeluarkan bau busuk yang kuat.'],
        correctOptionIndex: 3,
        imagePath: 'assets/images/q2(T).jpg',
      ),
      // Q3 - Rubber tree drops leaves
      QuizQuestion(
        question: 'Tumbuhan seperti pokok getah akan menggugurkan daunnya semasa musim kemarau. Apakah INFERENS yang sesuai yang boleh dibuat?',
        options: [
          'Kerana dapat menarik haiwan untuk menyebarkan biji benihnya.',
          'kerana untuk menyamarkan diri mereka kepada persekitaran.',
          'Kerana untuk membolehkan cabangnya mendapatkan lebih banyak cahaya.',
          'kerana untuk mengelakkan kehilangan air daripada tumbuhan itu.',
        ],
        correctOptionIndex: 3,
        imagePath: null,
      ),
      // Q4 - Aloe Vera leaf protection
      QuizQuestion(
        question: 'Apakah kelebihan daun pada pokok ini untuk melindungi dirinya daripada bahaya?',
        options: ['Bulu halus dipermukannya menyebabkan kegatalan.', 'Membebaskan bau busuk.', 'Menyebabkan kesakitan atau luka', 'Mengeluarkan racun'],
        correctOptionIndex: 2,
        imagePath: 'assets/images/q4(T).jpg',
      ),
      // Q5 - Coconut split leaves
      QuizQuestion(
        question: 'Apakah kelebihan daun kelapa yang berpecah-pecah itu?',
        options: ['Untuk menghasilkan angin kuat.', 'Untuk menghasilkan bunyi.', 'Untuk mengurangkan rintangan angin.', 'Untuk membuat penyapu lidi.'],
        correctOptionIndex: 2,
        imagePath: 'assets/images/q5(T).jpg',
      ),
      // Q6 - Papaya protection
      QuizQuestion(
        question: 'Nyatakan ciri khas tumbuhan ini untuk melindungi diri.',
        options: ['Berduri tajam', 'Berbulu halus', 'Bergetah', 'Beracun'],
        correctOptionIndex: 2,
        imagePath: 'assets/images/q6(T).jpg',
      ),
      // Q7 - Cactus watering
      QuizQuestion(
        question: 'Aishah menanam banyak kaktus di halaman rumahnya. Adakah pokok ini perlu disiram dengan air yang banyak?',
        options: ['Ya', 'Tidak'],
        correctOptionIndex: 1,
        imagePath: 'assets/images/q7(T).jpg',
      ),
      // Q8 - Cactus water storage
      QuizQuestion(
        question: 'Mengapakah tumbuhan ini tidak memerlukan air yang banyak?',
        options: ['Kerana tidak berbuah', 'Kerana mempunyai batang yang berwarna hijau', 'Kerana mempunyai batang yang boleh menyimpan air.'],
        correctOptionIndex: 2,
        imagePath: 'assets/images/q8(T).jpg',
      ),
      // Q9 - Rambutan seed dispersal
      QuizQuestion(
        question: 'Nyatakan agen pencaran biji benih dalam gambar',
        options: ['melalui air', 'melalui angin', 'melalui mekanisma letupan', 'melalui manusia dan haiwan'],
        correctOptionIndex: 3,
        imagePath: 'assets/images/q9(T).jpg',
      ),
      // Q10 - Image options - winged seed dispersal by wind
      QuizQuestion(
        question: 'Saya mempunyai biji benih yang mempunyai struktur bersayap dan boleh diterbangkan jauh melalui angin. Saya juga dipencarkan oleh angin. Siapakah saya?',
        optionImagePaths: [
          'assets/images/q10a(T).jpg',
          'assets/images/q10b(T).jpg',
          'assets/images/q10c(T).jpg',
          'assets/images/q10d(T).jpg',
        ],
        correctOptionIndex: 2,
        imagePath: null,
      ),
      // Q11 - Dispersed by animals
      QuizQuestion(
        question: 'Antara berikut yang manakah dipencarkan melalui haiwan?',
        options: ['kemuncup', 'keembung', 'kelapa', 'pong-pong'],
        correctOptionIndex: 0,
        imagePath: null,
      ),
      // Q12 - Keembung seed dispersal (explosive mechanism)
      QuizQuestion(
        question: 'Biji benih pokok keembung dipencarkan melalui',
        options: ['Air', 'Angin', 'Mekanisme letupan', 'Haiwan dan manusia'],
        correctOptionIndex: 2,
        imagePath: null,
      ),
      // Q13 - Dispersed by water
      QuizQuestion(
        question: 'Biji benih tumbuhan yang manakah dipencarkan oleh air?',
        options: ['Kelapa', 'Labu', 'Bendi', 'Meranti'],
        correctOptionIndex: 0,
        imagePath: null,
      ),
      // Q14 - Rubber tree seed dispersal (explosive mechanism)
      QuizQuestion(
        question: 'Nyatakan agen pencaran bagi biji benih pokok getah.',
        options: ['Mekanisme letupan', 'Angin', 'Air', 'Haiwan dan manusia'],
        correctOptionIndex: 0,
        imagePath: null,
      ),
      // Q15 - NOT a seed dispersal agent
      QuizQuestion(
        question: 'Berikut merupakan agen pencaran biji benih KECUALI',
        options: ['Mekanisme letupan', 'Air', 'Angin', 'Hujan'],
        correctOptionIndex: 3,
        imagePath: null,
      ),
      // Q16 - Mango seed dispersal
      QuizQuestion(
        question: 'Nyatakan agen pencaran bagi biji benih pokok mangga.',
        options: ['Air', 'Hujan', 'Haiwan dan manusia', 'Angin'],
        correctOptionIndex: 2,
        imagePath: null,
      ),
      // Q17 - Dry fruit explodes
      QuizQuestion(
        question: "'Apabila matang buahnya akan kering dan merekah' Nyatakan agen pencaran bagi penyataan ini",
        options: ['Mekanisme letupan', 'Air', 'Angin', 'Haiwan dan manusia'],
        correctOptionIndex: 0,
        imagePath: null,
      ),
      // Q18 - Plants with fine hairs
      QuizQuestion(
        question: 'Apakah tumbuhan yag melindungi diri daripada musuh dengan mempunyai bulu halus?',
        options: ['Buluh, tebu, lalang', 'Pokok semalu, kaktus', 'nangka, keladi', 'Pong-pong, sesetengah cendawan'],
        correctOptionIndex: 0,
        imagePath: null,
      ),
      // Q19 - Kemuncup seed hooks
      QuizQuestion(
        question: 'Apakah ciri-ciri yang terdapat pada biji benih kemuncup yang membolehkannya dipencarkan melalui manusia dan haiwan?',
        options: ['Sabut berongga, kulit kalis air', 'Berbulu halus, kecil, ringan', 'struktur bersayap seperti helikopter', 'mempunyai cangkuk yang melekat pada bulu haiwan dan manusia'],
        correctOptionIndex: 3,
        imagePath: null,
      ),
      // Q20 - Winged seed diagram
      QuizQuestion(
        question: 'Rajah menunjukkan sejenis biji benih. Antara ciri berikut, yang manakah dapat membantu biji benih itu dipencarkan melalui angin?',
        options: ['Bulu yang halus', 'Struktur berbentuk sayap', 'Tidak telap air', 'Warna yang cerah'],
        correctOptionIndex: 1,
        imagePath: 'assets/images/q20(T).jpg',
      ),
    ];
  }

  // ---------- SISTEM RANGKA MANUSIA (10 soalan dari worksheet) ----------
  static List<QuizQuestion> getSkeletonQuestions() {
    return [
      // Q1
      QuizQuestion(
        question: 'Apakah fungsi sendi pada tulang bahu, tulang tangan dan tulang belakang?',
        options: [
          'Membolehkan pergerakan tangan',
          'Membolehkan pergerakan kepala secara pusingan atau putaran',
          'Membolehkan kaki dibengkokkan dan diluruskan',
          'Membolehkan pergerakan bahagian atas tubuh'
        ],
        correctOptionIndex: 3,
        imagePath: null,
      ),
      // Q2
      QuizQuestion(
        question: 'Apakah fungsi sendi?',
        options: ['Melindungi organ dalaman', 'Menyokong tubuh', 'Membolehkan pergerakan dan kebolehlenturan tubuh', 'Melindungi otak'],
        correctOptionIndex: 2,
        imagePath: null,
      ),
      // Q3 - Diagram with arrow P pointing to spine
      QuizQuestion(
        question: 'Apakah nama bagi rangka utama yang bertanda P?',
        options: ['Tulang belakang', 'Tulang rusuk', 'Tulang kaki', 'Tengkorak'],
        correctOptionIndex: 0,
        imagePath: 'assets/images/q3manusia.jpg',
      ),
      // Q4
      QuizQuestion(
        question: 'Apakah fungsi tulang tangan dan kaki?',
        options: ['Sebagai sokongan dan pergerakan', 'Melindungi otak', 'Melindungi organ dalaman', 'Menyokong tubuh'],
        correctOptionIndex: 0,
        imagePath: null,
      ),
      // Q5
      QuizQuestion(
        question: 'Sendi merupakan',
        options: [
          'Tempat pertemuan antara organ dengan organ',
          'Tempat pertemuan antara otot dengan otot',
          'Tempat pertemuan antara otak dengan tengkorak',
          'Tempat pertemuan antara tulang dengan tulang'
        ],
        correctOptionIndex: 3,
        imagePath: null,
      ),
      // Q6
      QuizQuestion(
        question: 'Apakah fungsi sendi pada tulang leher?',
        options: [
          'Membolehkan pergerakan kepala secara pusingan atau putaran',
          'Membolehkan pergerakan bahagian atas tubuh',
          'Membolehkan pergerakan tangan',
          'Membolehkan kaki dibengkokkan dan diluruskan'
        ],
        correctOptionIndex: 0,
        imagePath: null,
      ),
      // Q7 - Image options - which is ribs?
      QuizQuestion(
        question: 'Antara berikut, yang manakah ialah tulang rusuk?',
        optionImagePaths: [
          'assets/images/q7a(manusia).jpg',
          'assets/images/q7b(manusia).jpg',
          'assets/images/q7c(manusia).jpg',
          'assets/images/q7d(manusia).jpg',
        ],
        correctOptionIndex: 1,
        imagePath: null,
      ),
      // Q8
      QuizQuestion(
        question: 'Antara berikut yang manakah BUKAN kepentingan sistem rangka manusia?',
        options: [
          'Menjadi asas kepada bentuk tubuh',
          'Mengangkut oksigen, nutrien dan air ke dalam tubuh',
          'Melindungi organ dalaman daripada tercedera',
          'Sebagai sokongan kepada tubuh'
        ],
        correctOptionIndex: 1,
        imagePath: null,
      ),
      // Q9
      QuizQuestion(
        question: 'Sistem rangka manusia yang manakah melindungi otak?',
        options: ['Tulang tangan dan kaki', 'Tengkorak', 'Tulang belakang', 'Tulang rusuk'],
        correctOptionIndex: 1,
        imagePath: null,
      ),
      // Q10
      QuizQuestion(
        question: 'Apakah fungsi sendi pada tulang lutut, tulang pinggul?',
        options: [
          'Membolehkan pergerakan kepala secara pusingan atau putaran',
          'Membolehkan pergerakan tangan',
          'Membolehkan kaki dibengkokkan dan diluruskan',
          'Membolehkan pergerakan bahagian atas tubuh'
        ],
        correctOptionIndex: 2,
        imagePath: null,
      ),
    ];
  }

  // Combined list (30 questions)
  static List<QuizQuestion> getAllQuestions() {
    return [...getPlantQuestions(), ...getSkeletonQuestions()];
  }

  // Get random questions (if needed)
  static List<QuizQuestion> getRandomQuestions({int count = 10}) {
    final all = getAllQuestions();
    return all.take(count).toList();
  }
}
