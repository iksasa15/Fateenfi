import 'package:flutter/material.dart';
import '../constants/stats_constants.dart';

/// مكونات بطاقات الإحصائيات
class StatsComponents {
  // ألوان ثابتة متوافقة مع ثيم التطبيق
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kAccentPink = Color(0xFFEC4899);

  // تغيير لون المهام إلى أرجواني/بنفسجي بدلاً من الوردي
  static const Color kTaskColor = Color(0xFF9C27B0); // لون المهام - أرجواني
  static const Color kMaterialsColor = Color(0xFF2196F3); // لون المواد - أزرق

  // بطاقة إحصائيات متكاملة - المهام والكورسات في بطاقة واحدة
  static Widget buildCombinedStatsCard({
    required String tasksCount,
    required String coursesCount,
    required VoidCallback? onTasksTap,
    required VoidCallback? onCoursesTap,
    double? height,
    required double cardWidth,
    required int completedTasks, // عدد المهام المكتملة
    required int totalTasks, // إجمالي عدد المهام
  }) {
    // ضبط ارتفاع البطاقة
    final double cardHeight = height ?? 120;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // قسم العنوان والمعلومات العامة
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الجزء التحفيزي الجديد المميز
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kDarkPurple, kMediumPurple],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // أيقونة صاروخ للتحفيز
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // نص تحفيزي
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "نحو التميز",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "خطواتك اليوم تصنع نجاحك غداً",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // نص تحفيزي إضافي بتصميم أنيق
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // أيقونة النجمة للتميز
                      const Icon(
                        Icons.emoji_events_outlined,
                        color: kAccentPink,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      // رسالة تحفيزية
                      const Expanded(
                        child: Text(
                          "استمر، أنت قادر على تحقيق طموحاتك!",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF555555),
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // خط فاصل عمودي
          Container(
            height: cardHeight * 0.7,
            width: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // قسم المهام والكورسات
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // قسم المهام - الأعلى
                InkWell(
                  onTap: onTasksTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        // أيقونة المهام
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: kTaskColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.assignment_outlined,
                              color: kTaskColor,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // عدد المهام والنص
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "المهام",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF555555),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                            Text(
                              "$tasksCount مهمة",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kTaskColor,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // خط فاصل أفقي
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),

                // قسم الكورسات - الأسفل
                InkWell(
                  onTap: onCoursesTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        // أيقونة الكورسات
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: kMaterialsColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.menu_book_outlined,
                              color: kMaterialsColor,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // عدد الكورسات والنص
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "المواد",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF555555),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                            Text(
                              "$coursesCount مادة",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kMaterialsColor,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
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
    );
  }

  // عرض البطاقة المدمجة مع LayoutBuilder - دعم النسب الديناميكية
  static Widget buildCombinedStatsCardWithLayoutBuilder({
    required String tasksCount,
    required String coursesCount,
    required VoidCallback? onTasksTap,
    required VoidCallback? onCoursesTap,
    required int completedTasks,
    required int totalTasks,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: buildCombinedStatsCard(
            tasksCount: tasksCount,
            coursesCount: coursesCount,
            onTasksTap: onTasksTap,
            onCoursesTap: onCoursesTap,
            cardWidth: availableWidth,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
          ),
        );
      },
    );
  }

  // حساب نسبة إنجاز المهام بناءً على بيانات المهام
  static double calculateTaskCompletionPercentage({
    required int completedTasks,
    required int totalTasks,
  }) {
    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks) * 100;
  }

  // بطاقة إحصائيات بتصميم منفصل (للتوافق الخلفي)
  static Widget buildStatisticCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    double? height,
    VoidCallback? onTap,
    bool isTaskCard = false,
    required double cardWidth,
  }) {
    // تعديل اللون بناء على نوع البطاقة
    final cardColor = isTaskCard ? kTaskColor : kMaterialsColor;

    // ضبط ارتفاع أصغر للبطاقة
    const double cardHeight = 100;
    const double iconSize = 28;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // الأيقونة على يمين البطاقة
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: cardColor,
                  size: 16,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // المحتوى: ثلاثة أسطر (العنوان، القيمة، الحالة)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // السطر الأول: عنوان البطاقة
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF555555),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),

                  // السطر الثاني: القيمة
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),

                  // السطر الثالث: النص الفرعي
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: cardColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء صف من بطاقات الإحصائيات (للتوافق الخلفي)
  static Widget buildStatsRow({
    required List<Map<String, dynamic>> statsCards,
    required double totalWidth,
    int completedTasks = 0,
    int totalTasks = 0,
  }) {
    // استخدام البطاقة المدمجة الجديدة بدلاً من البطاقات المنفصلة
    if (statsCards.length >= 2) {
      String tasksCount = "0";
      String coursesCount = "0";
      VoidCallback? onTasksTap;
      VoidCallback? onCoursesTap;

      // استخراج البيانات من statsCards
      for (var card in statsCards) {
        if (card['title'] == "المهام") {
          tasksCount = card['value'].toString();
          onTasksTap = card['onTap'];

          // محاولة استخراج المهام المكتملة/الإجمالية من البطاقة
          // إذا كانت البيانات المضمنة متاحة
          if (card.containsKey('completedTasks')) {
            completedTasks = card['completedTasks'];
          }
          if (card.containsKey('totalTasks')) {
            totalTasks = card['totalTasks'];
          }
        } else if (card['title'] == "المواد") {
          coursesCount = card['value'].toString();
          onCoursesTap = card['onTap'];
        }
      }

      // إذا لم يتم تحديد إجمالي المهام، استخدم عدد المهام
      if (totalTasks == 0 && tasksCount != "0") {
        totalTasks = int.tryParse(tasksCount) ?? 0;
      }

      // عرض البطاقة المدمجة
      return buildCombinedStatsCard(
        tasksCount: tasksCount,
        coursesCount: coursesCount,
        onTasksTap: onTasksTap,
        onCoursesTap: onCoursesTap,
        cardWidth: totalWidth,
        completedTasks: completedTasks,
        totalTasks: totalTasks,
      );
    }

    // في حالة عدم وجود بطاقات كافية، عرض رسالة
    return buildEmptyStats(message: "لا توجد إحصائيات متاحة");
  }

  // طريقة استخدام جديدة للصف مع LayoutBuilder (للتوافق الخلفي)
  static Widget buildStatsRowWithLayoutBuilder({
    required List<Map<String, dynamic>> statsCards,
    int completedTasks = 0,
    int totalTasks = 0,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        return buildStatsRow(
          statsCards: statsCards,
          totalWidth: availableWidth,
          completedTasks: completedTasks,
          totalTasks: totalTasks,
        );
      },
    );
  }

  // باقي الدوال
  static Widget buildSectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDarkPurple,
                  letterSpacing: 0.3,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 24,
                height: 2,
                decoration: BoxDecoration(
                  color: kMediumPurple,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  static Widget buildStatsContainer({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12.0),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget buildEmptyStats({
    required String message,
    IconData icon = Icons.bar_chart_outlined,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
