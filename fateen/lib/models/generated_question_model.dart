class GeneratedQuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;
  int? userAnswerIndex;

  GeneratedQuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.userAnswerIndex,
  });

  // Helper methods
  bool get isAnswered => userAnswerIndex != null;
  bool get isCorrect => userAnswerIndex == correctIndex;

  // Factory method to create from API response
  factory GeneratedQuestionModel.fromJson(Map<String, dynamic> json) {
    List<String> options = [];
    int correctIndex = 0;

    // تعامل مع مختلف الأشكال الممكنة للخيارات في الاستجابة
    if (json.containsKey('options')) {
      if (json['options'] is List) {
        // إذا كانت الخيارات قائمة، تحقق من النموذج المستخدم
        var optionsJson = json['options'];

        // نموذج 1: قائمة بعناصر تحتوي على 'text' و 'is_correct'
        if (optionsJson.isNotEmpty &&
            optionsJson[0] is Map &&
            optionsJson[0].containsKey('text')) {
          for (int i = 0; i < optionsJson.length; i++) {
            options.add(optionsJson[i]['text']?.toString() ?? "خيار فارغ");
            if (optionsJson[i]['is_correct'] == true) {
              correctIndex = i;
            }
          }
        }
        // نموذج 2: قائمة نصية بسيطة
        else {
          options = List<String>.from(optionsJson.map((o) => o.toString()));

          // استخدم correctIndex إذا كان محدداً في JSON
          if (json.containsKey('correct_index') ||
              json.containsKey('correctIndex')) {
            correctIndex = json['correct_index'] ?? json['correctIndex'] ?? 0;
          }
        }
      }
    }

    // تأكد من وجود 4 خيارات على الأقل
    while (options.length < 4) {
      options.add("خيار ${options.length + 1}");
    }

    // استخدم الاسم الصحيح لحقل السؤال
    String questionText = "";
    if (json.containsKey('question_text')) {
      questionText = json['question_text']?.toString() ?? "";
    } else if (json.containsKey('questionText')) {
      questionText = json['questionText']?.toString() ?? "";
    } else if (json.containsKey('question')) {
      questionText = json['question']?.toString() ?? "";
    }

    return GeneratedQuestionModel(
      question: questionText,
      options: options,
      correctIndex: correctIndex < options.length ? correctIndex : 0,
    );
  }

  // للتحويل إلى JSON (قد تكون مفيدة للحفظ المحلي)
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> optionsJson = [];

    for (int i = 0; i < options.length; i++) {
      optionsJson.add({
        'text': options[i],
        'is_correct': i == correctIndex,
      });
    }

    return {
      'question_text': question,
      'options': optionsJson,
      'user_answer': userAnswerIndex,
    };
  }

  // نسخة من النموذج مع إجابة المستخدم (مفيدة للتحديثات)
  GeneratedQuestionModel copyWith({int? newUserAnswer}) {
    return GeneratedQuestionModel(
      question: question,
      options: options,
      correctIndex: correctIndex,
      userAnswerIndex: newUserAnswer ?? userAnswerIndex,
    );
  }
}
