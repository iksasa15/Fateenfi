import 'package:flutter/material.dart';
import 'package:fateen/models/task.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

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
    // تحديد لون البطاقة بناءً على اللون المخصص أو نوع المهمة
    final cardColor = color ??
        (isOverdue
            ? context.colorError // لون المهام المتأخرة
            : context.colorPrimaryLight); // لون المهام العادية

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

    // حساب أحجام العناصر
    final double cardHeight = AppDimensions.getButtonHeight(context,
            size: ButtonSize.regular, small: false) *
        1.1;

    // أحجام النصوص والأيقونات
    final double iconSize =
        AppDimensions.getIconSize(context, size: IconSize.small, small: true);
    final double textSize = AppDimensions.getBodyFontSize(context);
    final double smallTextSize = AppDimensions.getLabelFontSize(context);
    final double timeCircleSize =
        AppDimensions.getIconSize(context, size: IconSize.medium, small: false);

    Widget cardContent = Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
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
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        child: Stack(
          children: [
            // دائرة زخرفية في الخلفية
            Positioned(
              left: -25,
              top: -15,
              child: Container(
                width: AppDimensions.getIconSize(context,
                        size: IconSize.large, small: false) *
                    0.6,
                height: AppDimensions.getIconSize(context,
                        size: IconSize.large, small: false) *
                    0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // المحتوى الرئيسي
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    AppDimensions.getSpacing(context, size: SpacingSize.small),
                vertical:
                    AppDimensions.getSpacing(context, size: SpacingSize.small),
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
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(
                            height: AppDimensions.getSpacing(context,
                                    size: SpacingSize.small) /
                                2),

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
                                width: AppDimensions.getSpacing(context,
                                        size: SpacingSize.small) /
                                    2),
                            Text(
                              isOverdue ? 'متأخرة منذ:' : 'موعد التسليم:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: smallTextSize,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'SYMBIOAR+LT',
                                height: 1.2,
                              ),
                            ),
                            SizedBox(
                                width: AppDimensions.getSpacing(context,
                                        size: SpacingSize.small) /
                                    2),
                            Text(
                              task.dueDateFormatted,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: smallTextSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SYMBIOAR+LT',
                                height: 1.2,
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
                          SizedBox(height: 2),
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
                  width: AppDimensions.getSpacing(context,
                      size: SpacingSize.small),
                  height: AppDimensions.getSpacing(context,
                          size: SpacingSize.small) /
                      2,
                  decoration: BoxDecoration(
                    color: context.colorWarning,
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
