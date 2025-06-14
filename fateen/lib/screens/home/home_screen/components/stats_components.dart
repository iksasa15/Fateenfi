import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

/// مكونات بطاقات الإحصائيات
class StatsComponents {
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
        // استخدام أبعاد التطبيق المتجاوبة
        final double cardHeight = height ??
            AppDimensions.getButtonHeight(context,
                    size: ButtonSize.regular, small: false) *
                2.5;

        final double iconSize = AppDimensions.getIconSize(context,
            size: IconSize.regular, small: false);

        final double titleSize = AppDimensions.getLabelFontSize(context);
        final double valueSize = AppDimensions.getBodyFontSize(context);
        final double messageSize =
            AppDimensions.getLabelFontSize(context, small: true);

        return Container(
          width: cardWidth,
          padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
            boxShadow: [
              BoxShadow(
                color: context.colorShadow,
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
                        horizontal: AppDimensions.getSpacing(context,
                            size: SpacingSize.small),
                        vertical: AppDimensions.getSpacing(context,
                            size: SpacingSize.small),
                      ),
                      decoration: BoxDecoration(
                        gradient: context.gradientPrimary,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                      ),
                      child: Row(
                        children: [
                          // أيقونة صاروخ للتحفيز
                          Container(
                            padding: EdgeInsets.all(AppDimensions.getSpacing(
                                    context,
                                    size: SpacingSize.small) /
                                2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                              size: iconSize - 2,
                            ),
                          ),
                          SizedBox(
                              width: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small)),
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
                                SizedBox(
                                    height: AppDimensions.getSpacing(context,
                                            size: SpacingSize.small) /
                                        3),
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

                    SizedBox(
                        height: AppDimensions.getSpacing(context,
                            size: SpacingSize.small)),

                    // نص تحفيزي إضافي بتصميم أنيق
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.getSpacing(context,
                            size: SpacingSize.small),
                        vertical: AppDimensions.getSpacing(context,
                                size: SpacingSize.small) /
                            2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorSurfaceLight,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                        border: Border.all(color: context.colorBorder),
                      ),
                      child: Row(
                        children: [
                          // أيقونة النجمة للتميز
                          Icon(
                            Icons.emoji_events_outlined,
                            color: context.colorAccent,
                            size: iconSize - 2,
                          ),
                          SizedBox(
                              width: AppDimensions.getSpacing(context,
                                      size: SpacingSize.small) /
                                  2),
                          // رسالة تحفيزية
                          Expanded(
                            child: Text(
                              "استمر، أنت قادر على تحقيق طموحاتك!",
                              style: TextStyle(
                                fontSize: messageSize,
                                color: context.colorTextSecondary,
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
                color: context.colorDivider,
                margin: EdgeInsets.symmetric(
                  horizontal: AppDimensions.getSpacing(context),
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
                      borderRadius:
                          BorderRadius.circular(AppDimensions.smallRadius),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.getSpacing(context,
                              size: SpacingSize.small),
                          vertical: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2,
                        ),
                        child: Row(
                          children: [
                            // أيقونة المهام
                            Container(
                              width: AppDimensions.getIconSize(context,
                                      size: IconSize.large, small: true) /
                                  2,
                              height: AppDimensions.getIconSize(context,
                                      size: IconSize.large, small: true) /
                                  2,
                              decoration: BoxDecoration(
                                color:
                                    context.colorMediumPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.smallRadius),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.assignment_outlined,
                                  color: context.colorMediumPurple,
                                  size: iconSize,
                                ),
                              ),
                            ),

                            SizedBox(
                                width: AppDimensions.getSpacing(context,
                                    size: SpacingSize.small)),

                            // عدد المهام والنص
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "المهام",
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w500,
                                    color: context.colorTextSecondary,
                                    fontFamily: 'SYMBIOAR+LT',
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  "$tasksCount مهمة",
                                  style: TextStyle(
                                    fontSize: valueSize,
                                    fontWeight: FontWeight.bold,
                                    color: context.colorMediumPurple,
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
                      color: context.colorDivider,
                      margin: EdgeInsets.symmetric(
                        vertical: AppDimensions.getSpacing(context,
                                size: SpacingSize.small) /
                            2,
                      ),
                    ),

                    // قسم الكورسات - الأسفل
                    InkWell(
                      onTap: onCoursesTap,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.smallRadius),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.getSpacing(context,
                              size: SpacingSize.small),
                          vertical: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2,
                        ),
                        child: Row(
                          children: [
                            // أيقونة الكورسات
                            Container(
                              width: AppDimensions.getIconSize(context,
                                      size: IconSize.large, small: true) /
                                  2,
                              height: AppDimensions.getIconSize(context,
                                      size: IconSize.large, small: true) /
                                  2,
                              decoration: BoxDecoration(
                                color: context.colorInfo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.smallRadius),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.menu_book_outlined,
                                  color: context.colorInfo,
                                  size: iconSize,
                                ),
                              ),
                            ),

                            SizedBox(
                                width: AppDimensions.getSpacing(context,
                                    size: SpacingSize.small)),

                            // عدد الكورسات والنص
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "المواد",
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w500,
                                    color: context.colorTextSecondary,
                                    fontFamily: 'SYMBIOAR+LT',
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  "$coursesCount مادة",
                                  style: TextStyle(
                                    fontSize: valueSize,
                                    fontWeight: FontWeight.bold,
                                    color: context.colorInfo,
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
            vertical:
                AppDimensions.getSpacing(context, size: SpacingSize.small),
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
        // استخدام أبعاد التطبيق المتجاوبة
        final double cardHeight = height ??
            AppDimensions.getButtonHeight(context,
                    size: ButtonSize.regular, small: false) *
                1.8;
        final double iconSize = AppDimensions.getIconSize(context,
            size: IconSize.small, small: false);
        final double titleSize =
            AppDimensions.getLabelFontSize(context, small: true);
        final double valueSize = AppDimensions.getSubtitleFontSize(context);
        final double subtitleSize =
            AppDimensions.getLabelFontSize(context, small: true);

        // تعديل اللون بناء على نوع البطاقة
        final cardColor =
            isTaskCard ? context.colorMediumPurple : context.colorInfo;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cardWidth,
            padding: EdgeInsets.symmetric(
              horizontal:
                  AppDimensions.getSpacing(context, size: SpacingSize.small),
              vertical:
                  AppDimensions.getSpacing(context, size: SpacingSize.small),
            ),
            height: cardHeight,
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
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
                  width: AppDimensions.getIconSize(context,
                          size: IconSize.large, small: true) /
                      2,
                  height: AppDimensions.getIconSize(context,
                          size: IconSize.large, small: true) /
                      2,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: iconSize,
                    ),
                  ),
                ),

                SizedBox(
                    width: AppDimensions.getSpacing(context,
                        size: SpacingSize.small)),

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
                          color: context.colorTextSecondary,
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
                          horizontal: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2,
                          vertical: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              4,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.smallRadius / 2),
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
        final double fontSize = AppDimensions.getSubtitleFontSize(context);

        return Padding(
          padding: EdgeInsets.only(
            bottom: AppDimensions.getSpacing(context, size: SpacingSize.small),
            top: AppDimensions.getSpacing(context, size: SpacingSize.medium),
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
                      color: context.colorPrimaryDark,
                      letterSpacing: 0.3,
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.2,
                    ),
                  ),
                  SizedBox(
                      height: AppDimensions.getSpacing(context,
                              size: SpacingSize.small) /
                          4),
                  Container(
                    width: AppDimensions.getWidth(context, percentage: 0.06),
                    height: 2.5, // زيادة سمك الخط
                    decoration: BoxDecoration(
                      color: context.colorPrimary,
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
        return Container(
          padding: padding ??
              EdgeInsets.all(
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
            boxShadow: [
              BoxShadow(
                color: context.colorShadow,
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
        final double iconSize = AppDimensions.getIconSize(context,
            size: IconSize.large, small: false);
        final double fontSize = AppDimensions.getBodyFontSize(context);

        return Container(
          padding: EdgeInsets.symmetric(
            vertical:
                AppDimensions.getSpacing(context, size: SpacingSize.medium),
            horizontal: AppDimensions.getSpacing(context),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: context.colorBorder,
              ),
              SizedBox(
                  height: AppDimensions.getSpacing(context,
                      size: SpacingSize.small)),
              Text(
                message,
                style: TextStyle(
                  fontSize: fontSize,
                  color: context.colorTextSecondary,
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
