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
    return LayoutBuilder(
      builder: (context, constraints) {
        // استخدام MediaQuery للحصول على أبعاد الشاشة
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        // ضبط ارتفاع البطاقة
        final double cardHeight = height ??
            (isSmallScreen
                ? screenSize.height * 0.14
                : screenSize.height * 0.15);

        // ضبط أحجام النصوص والأيقونات - تحسين الأحجام
        final double iconSize =
            isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
        final double titleSize =
            isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
        final double valueSize =
            isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
        final double messageSize =
            isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0);

        return Container(
          width: cardWidth,
          padding: EdgeInsets.all(screenSize.width * 0.04),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.025,
                        vertical: screenSize.height * 0.01,
                      ),
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
                            child: Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                              size: iconSize,
                            ),
                          ),
                          SizedBox(width: screenSize.width * 0.02),
                          // نص تحفيزي
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "نحو التميز",
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'SYMBIOAR+LT',
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.0025),
                                Text(
                                  "خطواتك اليوم تصنع نجاحك غداً",
                                  style: TextStyle(
                                    fontSize: messageSize,
                                    color: Colors.white,
                                    fontFamily: 'SYMBIOAR+LT',
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.0175),

                    // نص تحفيزي إضافي بتصميم أنيق
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.02,
                        vertical: screenSize.height * 0.0075,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          // أيقونة النجمة للتميز
                          Icon(
                            Icons.emoji_events_outlined,
                            color: kAccentPink,
                            size: iconSize,
                          ),
                          SizedBox(width: screenSize.width * 0.015),
                          // رسالة تحفيزية
                          Expanded(
                            child: Text(
                              "استمر، أنت قادر على تحقيق طموحاتك!",
                              style: TextStyle(
                                fontSize: messageSize,
                                color: const Color(0xFF555555),
                                fontFamily: 'SYMBIOAR+LT',
                                height: 1.2,
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
                margin: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.02,
                          vertical: screenSize.height * 0.0075,
                        ),
                        child: Row(
                          children: [
                            // أيقونة المهام
                            Container(
                              width: screenSize.width * 0.08,
                              height: screenSize.width * 0.08,
                              decoration: BoxDecoration(
                                color: kTaskColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.assignment_outlined,
                                  color: kTaskColor,
                                  size: iconSize + 2,
                                ),
                              ),
                            ),

                            SizedBox(width: screenSize.width * 0.025),

                            // عدد المهام والنص
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "المهام",
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF555555),
                                    fontFamily: 'SYMBIOAR+LT',
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  "$tasksCount مهمة",
                                  style: TextStyle(
                                    fontSize: valueSize,
                                    fontWeight: FontWeight.bold,
                                    color: kTaskColor,
                                    fontFamily: 'SYMBIOAR+LT',
                                    height: 1.2,
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
                      margin: EdgeInsets.symmetric(
                        vertical: screenSize.height * 0.005,
                      ),
                    ),

                    // قسم الكورسات - الأسفل
                    InkWell(
                      onTap: onCoursesTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.02,
                          vertical: screenSize.height * 0.0075,
                        ),
                        child: Row(
                          children: [
                            // أيقونة الكورسات
                            Container(
                              width: screenSize.width * 0.08,
                              height: screenSize.width * 0.08,
                              decoration: BoxDecoration(
                                color: kMaterialsColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.menu_book_outlined,
                                  color: kMaterialsColor,
                                  size: iconSize + 2,
                                ),
                              ),
                            ),

                            SizedBox(width: screenSize.width * 0.025),

                            // عدد الكورسات والنص
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "المواد",
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF555555),
                                    fontFamily: 'SYMBIOAR+LT',
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  "$coursesCount مادة",
                                  style: TextStyle(
                                    fontSize: valueSize,
                                    fontWeight: FontWeight.bold,
                                    color: kMaterialsColor,
                                    fontFamily: 'SYMBIOAR+LT',
                                    height: 1.2,
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
      },
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
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // استخدام MediaQuery للحصول على أبعاد الشاشة
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        // تعديل اللون بناء على نوع البطاقة
        final cardColor = isTaskCard ? kTaskColor : kMaterialsColor;

        // ضبط أحجام تعتمد على الشاشة
        final double cardHeight = height ?? (screenSize.height * 0.12);
        final double iconSize =
            isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);
        final double titleSize =
            isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0);
        final double valueSize =
            isSmallScreen ? 17.0 : (isMediumScreen ? 18.0 : 19.0);
        final double subtitleSize =
            isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cardWidth,
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.025,
              vertical: screenSize.height * 0.0125,
            ),
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
                  width: screenSize.width * 0.07,
                  height: screenSize.width * 0.07,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: iconSize,
                    ),
                  ),
                ),

                SizedBox(width: screenSize.width * 0.025),

                // المحتوى: ثلاثة أسطر (العنوان، القيمة، الحالة)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // السطر الأول: عنوان البطاقة
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF555555),
                          fontFamily: 'SYMBIOAR+LT',
                          height: 1.2,
                        ),
                      ),

                      // السطر الثاني: القيمة
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: valueSize,
                          fontWeight: FontWeight.bold,
                          color: cardColor,
                          fontFamily: 'SYMBIOAR+LT',
                          height: 1.2,
                        ),
                      ),

                      // السطر الثالث: النص الفرعي
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.015,
                          vertical: screenSize.height * 0.0025,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: cardColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SYMBIOAR+LT',
                            height: 1.2,
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
      },
    );
  }

  // بناء صف من بطاقات الإحصائيات (للتوافق الخلفي)
  static Widget buildStatsRow({
    required List<Map<String, dynamic>> statsCards,
    required double totalWidth,
    int completedTasks = 0,
    int totalTasks = 0,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
      },
    );
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

  // بناء عنوان القسم
  static Widget buildSectionTitle(String title, {Widget? trailing}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        final double fontSize =
            isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);

        return Padding(
          padding: EdgeInsets.only(
            bottom: screenSize.height * 0.01,
            top: screenSize.height * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: kDarkPurple,
                      letterSpacing: 0.3,
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.004),
                  Container(
                    width: screenSize.width * 0.06,
                    height: 2.5, // زيادة سمك الخط
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
      },
    );
  }

  static Widget buildStatsContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screenSize = MediaQuery.of(context).size;

        return Container(
          padding: padding ?? EdgeInsets.all(screenSize.width * 0.03),
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
      },
    );
  }

  static Widget buildEmptyStats({
    required String message,
    IconData icon = Icons.bar_chart_outlined,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        final double iconSize =
            isSmallScreen ? 38.0 : (isMediumScreen ? 42.0 : 45.0);
        final double fontSize =
            isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.025,
            horizontal: screenSize.width * 0.04,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Colors.grey[300],
              ),
              SizedBox(height: screenSize.height * 0.015),
              Text(
                message,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
