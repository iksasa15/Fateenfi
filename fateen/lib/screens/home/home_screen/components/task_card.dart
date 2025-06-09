import 'package:flutter/material.dart';
import 'package:fateen/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isOverdue;
  final VoidCallback? onTap;
  final Animation<double>? animation;
  final Color? color; // إضافة خاصية اللون الاختيارية

  const TaskCard({
    Key? key,
    required this.task,
    this.isOverdue = false,
    this.onTap,
    this.animation,
    this.color, // إعلان خاصية اللون
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    // تحديد لون البطاقة بناءً على اللون المخصص أو نوع المهمة
    final cardColor = color ??
        (isOverdue
            ? const Color(0xFFE53935) // لون المهام المتأخرة - أحمر
            : const Color(0xFF6366F1)); // لون المهام العادية - أرجواني متوسط

    // حساب الوقت المتبقي أو المتأخر
    final now = DateTime.now();
    final difference = task.dueDate.difference(now);
    final diffMinutes = difference.inMinutes.abs();

    // تنسيق النص الذي سيظهر في الدائرة
    String timeText;
    if (diffMinutes < 60) {
      timeText = '$diffMinutes د';
    } else {
      int hours = diffMinutes ~/ 60;
      if (hours < 24) {
        timeText = '$hours س';
      } else {
        int days = hours ~/ 24;
        timeText = '$days ي';
      }
    }

    // حساب أحجام العناصر بناءً على حجم الشاشة
    final double cardHeight =
        screenSize.height * 0.085; // 8.5% من ارتفاع الشاشة
    final double iconSize = isSmallScreen ? 9.0 : 10.0;
    final double textSize = isSmallScreen ? 13.0 : 14.0;
    final double smallTextSize = isSmallScreen ? 9.0 : 10.0;
    final double timeCircleSize = screenSize.width * 0.09; // 9% من عرض الشاشة

    Widget cardContent = Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // دائرة زخرفية في الخلفية (أصغر)
            Positioned(
              left: -25,
              top: -15,
              child: Container(
                width: screenSize.width * 0.15, // 15% من عرض الشاشة
                height: screenSize.width * 0.15, // 15% من عرض الشاشة
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // المحتوى الرئيسي
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.03, // 3% من عرض الشاشة
                vertical: screenSize.height * 0.0125, // 1.25% من ارتفاع الشاشة
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // معلومات المهمة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // عنوان المهمة
                        Text(
                          task.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: textSize,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(
                            height: screenSize.height *
                                0.004), // 0.4% من ارتفاع الشاشة

                        // معلومات إضافية (موعد التسليم أو متأخرة منذ)
                        Row(
                          children: [
                            Icon(
                              isOverdue
                                  ? Icons.warning_amber_outlined
                                  : Icons.calendar_today_outlined,
                              color: Colors.white,
                              size: iconSize,
                            ),
                            SizedBox(
                                width: screenSize.width *
                                    0.0075), // 0.75% من عرض الشاشة
                            Text(
                              isOverdue ? 'متأخرة منذ:' : 'موعد التسليم:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: smallTextSize,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                            SizedBox(
                                width: screenSize.width *
                                    0.005), // 0.5% من عرض الشاشة
                            Text(
                              task.dueDateFormatted,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: smallTextSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // مؤشر الوقت
                  Container(
                    width: timeCircleSize,
                    height: timeCircleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isOverdue ? Icons.timer_off : Icons.timer,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          Text(
                            timeText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallTextSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // شريط صغير للأولوية
            if (task.priority == 'عالية')
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: screenSize.width * 0.03, // 3% من عرض الشاشة
                  height: screenSize.height * 0.006, // 0.6% من ارتفاع الشاشة
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    // إذا تم توفير animation، طبق الأنميشن على البطاقة
    if (animation != null) {
      return AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 8 * (1 - animation!.value)),
            child: Opacity(
              opacity: animation!.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    // وإلا أعد البطاقة بدون أنميشن
    return GestureDetector(
      onTap: onTap,
      child: cardContent,
    );
  }
}
