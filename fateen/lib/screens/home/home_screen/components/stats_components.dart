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

        // ضبط ارتفاع البطاقة
        final double cardHeight = height ??
            (isSmallScreen
                ? screenSize.height *
                    0.14 // 14% من ارتفاع الشاشة للأجهزة الصغيرة
                : screenSize.height *
                    0.15); // 15% من ارتفاع الشاشة للأجهزة العادية

        // ضبط أحجام النصوص والأيقونات
        final double iconSize = isSmallScreen ? 14.0 : 16.0;
        final double titleSize = isSmallScreen ? 11.0 : 12.0;
        final double valueSize = isSmallScreen ? 13.0 : 14.0;
        final double messageSize = isSmallScreen ? 10.0 : 11.0;

        return Container(
          width: cardWidth,
          padding: EdgeInsets.all(screenSize.width * 0.04), // 4% من عرض الشاشة
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
                        horizontal:
                            screenSize.width * 0.025, // 2.5% من عرض الشاشة
                        vertical:
                            screenSize.height * 0.01, // 1% من ارتفاع الشاشة
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
                          SizedBox(
                              width:
                                  screenSize.width * 0.02), // 2% من عرض الشاشة
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
                                  ),
                                ),
                                SizedBox(
                                    height: screenSize.height *
                                        0.0025), // 0.25% من ارتفاع الشاشة
                                Text(
                                  "خطواتك اليوم تصنع نجاحك غداً",
                                  style: TextStyle(
                                    fontSize: messageSize,
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

                    SizedBox(
                        height: screenSize.height *
                            0.0175), // 1.75% من ارتفاع الشاشة

                    // نص تحفيزي إضافي بتصميم أنيق
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.02, // 2% من عرض الشاشة
                        vertical: screenSize.height *
                            0.0075, // 0.75% من ارتفاع الشاشة
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
                          SizedBox(
                              width: screenSize.width *
                                  0.015), // 1.5% من عرض الشاشة
                          // رسالة تحفيزية
                          Expanded(
                            child: Text(
                              "استمر، أنت قادر على تحقيق طموحاتك!",
                              style: TextStyle(
                                fontSize: messageSize,
                                color: const Color(0xFF555555),
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
                margin: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04, // 4% من عرض الشاشة
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
                          horizontal:
                              screenSize.width * 0.02, // 2% من عرض الشاشة
                          vertical: screenSize.height *
                              0.0075, // 0.75% من ارتفاع الشاشة
                        ),
                        child: Row(
                          children: [
                            // أيقونة المهام
                            Container(
                              width:
                                  screenSize.width * 0.08, // 8% من عرض الشاشة
                              height:
                                  screenSize.width * 0.08, // 8% من عرض الشاشة
                              decoration: BoxDecoration(
                                color: kTaskColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.assignment_outlined,
                                  color: kTaskColor,
                                  size: iconSize +
                                      2, // أكبر قليلاً من الأيقونات الأخرى
                                ),
                              ),
                            ),

                            SizedBox(
                                width: screenSize.width *
                                    0.025), // 2.5% من عرض الشاشة

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
                                  ),
                                ),
                                Text(
                                  "$tasksCount مهمة",
                                  style: TextStyle(
                                    fontSize: valueSize,
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
                      margin: EdgeInsets.symmetric(
                        vertical:
                            screenSize.height * 0.005, // 0.5% من ارتفاع الشاشة
                      ),
                    ),

                    // قسم الكورسات - الأسفل
                    InkWell(
                      onTap: onCoursesTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              screenSize.width * 0.02, // 2% من عرض الشاشة
                          vertical: screenSize.height *
                              0.0075, // 0.75% من ارتفاع الشاشة
                        ),
                        child: Row(
                          children: [
                            // أيقونة الكورسات
                            Container(
                              width:
                                  screenSize.width * 0.08, // 8% من عرض الشاشة
                              height:
                                  screenSize.width * 0.08, // 8% من عرض الشاشة
                              decoration: BoxDecoration(
                                color: kMaterialsColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.menu_book_outlined,
                                  color: kMaterialsColor,
                                  size: iconSize +
                                      2, // أكبر قليلاً من الأيقونات الأخرى
                                ),
                              ),
                            ),

                            SizedBox(
                                width: screenSize.width *
                                    0.025), // 2.5% من عرض الشاشة

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
                                  ),
                                ),
                                Text(
                                  "$coursesCount مادة",
                                  style: TextStyle(
                                    fontSize: valueSize,
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
            vertical: MediaQuery.of(context).size.height *
                0.01, // 1% من ارتفاع الشاشة
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

        // تعديل اللون بناء على نوع البطاقة
        final cardColor = isTaskCard ? kTaskColor : kMaterialsColor;

        // ضبط أحجام تعتمد على الشاشة
        final double cardHeight =
            height ?? (screenSize.height * 0.12); // 12% من ارتفاع الشاشة
        final double iconSize = isSmallScreen ? 14.0 : 16.0;
        final double titleSize = isSmallScreen ? 10.0 : 11.0;
        final double valueSize = isSmallScreen ? 16.0 : 18.0;
        final double subtitleSize = isSmallScreen ? 9.0 : 10.0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cardWidth,
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.025, // 2.5% من عرض الشاشة
              vertical: screenSize.height * 0.0125, // 1.25% من ارتفاع الشاشة
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
                  width: screenSize.width * 0.07, // 7% من عرض الشاشة
                  height: screenSize.width * 0.07, // 7% من عرض الشاشة
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

                SizedBox(width: screenSize.width * 0.025), // 2.5% من عرض الشاشة

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
                        ),
                      ),

                      // السطر الثالث: النص الفرعي
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              screenSize.width * 0.015, // 1.5% من عرض الشاشة
                          vertical: screenSize.height *
                              0.0025, // 0.25% من ارتفاع الشاشة
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

  // باقي الدوال
  static Widget buildSectionTitle(String title, {Widget? trailing}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final double fontSize = isSmallScreen ? 15.0 : 16.0;

        return Padding(
          padding: EdgeInsets.only(
            bottom: screenSize.height * 0.01, // 1% من ارتفاع الشاشة
            top: screenSize.height * 0.02, // 2% من ارتفاع الشاشة
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
                    ),
                  ),
                  SizedBox(
                      height:
                          screenSize.height * 0.004), // 0.4% من ارتفاع الشاشة
                  Container(
                    width: screenSize.width * 0.06, // 6% من عرض الشاشة
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
          padding: padding ??
              EdgeInsets.all(screenSize.width * 0.03), // 3% من عرض الشاشة
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
        final double iconSize = isSmallScreen ? 35.0 : 40.0;
        final double fontSize = isSmallScreen ? 13.0 : 14.0;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.025, // 2.5% من ارتفاع الشاشة
            horizontal: screenSize.width * 0.04, // 4% من عرض الشاشة
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
              SizedBox(
                  height: screenSize.height * 0.015), // 1.5% من ارتفاع الشاشة
              Text(
                message,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
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
