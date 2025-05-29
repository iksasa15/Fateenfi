import 'package:flutter/material.dart';
import '../constants/next_lecture_constants.dart';

/// بطاقة المحاضرة القادمة
class NextLectureCard extends StatelessWidget {
  final String courseName;
  final String classroom;
  final int diffSeconds;
  final Animation<double> animation;

  const NextLectureCard({
    Key? key,
    required this.courseName,
    required this.classroom,
    required this.diffSeconds,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الألوان المستخدمة في التطبيق
    const Color kMediumPurple = Color(0xFF6366F1);
    const Color kDarkPurple = Color(0xFF4338CA);

    // حساب الوقت المتبقي بشكل أكثر دقة
    int diffHours = diffSeconds ~/ 3600;
    int diffMinutes = (diffSeconds % 3600) ~/ 60;

    // تنسيق عرض الوقت
    String timeDisplay;
    if (diffHours > 0) {
      timeDisplay = '$diffHours س $diffMinutes د';
    } else {
      timeDisplay = '$diffMinutes د';
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        // تقليل الارتفاع لتجنب التجاوز
        height: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [kMediumPurple, kDarkPurple],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kMediumPurple.withOpacity(0.25),
              blurRadius: 6, // تقليل قيمة الـ blur
              offset: const Offset(0, 2), // تقليل قيمة الإزاحة
              spreadRadius: 0,
            ),
          ],
        ),
        // استخدام ClipRRect لضمان عدم تجاوز أي عنصر داخلي
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // زخارف الخلفية (تم تصغيرها)
              Positioned(
                left: -25,
                top: -10,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),

              // المحتوى الرئيسي - تصميم أفقي وأكثر تركيزًا
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // المعلومات الرئيسية (اسم المقرر + القاعة)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // اسم المقرر
                          Text(
                            courseName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // القاعة
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${NextLectureConstants.classroomPrefix}$classroom',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // دائرة الوقت المتبقي
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timeDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// مكونات إضافية خاصة بالمحاضرة القادمة
class NextLectureComponents {
  /// بناء عنوان قسم المحاضرة القادمة
  static Widget buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // العنوان مع خط تزييني تحته
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                NextLectureConstants.nextLectureTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4338CA),
                  letterSpacing: 0.3,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 28,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// رسالة فارغة عندما لا توجد محاضرات قادمة
  static Widget buildEmptyLectureState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // تقليل الهوامش
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      height: 100, // نفس ارتفاع البطاقة الرئيسية بعد التعديل
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Color(0xFF6366F1),
              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          // النص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  NextLectureConstants.noLecturesMessage,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4338CA),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'يمكنك إضافة محاضراتك من قسم الجدول الدراسي',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
