import 'package:flutter/material.dart';
import '../../../models/course.dart';
import '../../../models/app_file.dart';
import '../controllers/course_card_controller.dart';
import 'package:provider/provider.dart';

/// مكون بطاقة المقرر الدراسي
/// يعرض معلومات المقرر والدرجات والتذكيرات والملفات
class CourseCardComponent extends StatelessWidget {
  /// بيانات المقرر الدراسي
  final Course course;

  /// دالة تُستدعى عند اختيار ملف من ملفات المقرر
  final Function(AppFile)? onFileSelected;

  /// الدرجة القصوى للمقرر (افتراضياً 100)
  final double maxGrade;

  const CourseCardComponent({
    Key? key,
    required this.course,
    this.onFileSelected,
    this.maxGrade = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseCardController(
        course: course,
        maxGrade: maxGrade,
      ),
      child: _CourseCardContent(onFileSelected: onFileSelected),
    );
  }
}

class _CourseCardContent extends StatelessWidget {
  /// دالة تُستدعى عند اختيار ملف من ملفات المقرر
  final Function(AppFile)? onFileSelected;

  const _CourseCardContent({this.onFileSelected});

  /// الألوان المستخدمة في المكون - متوافقة مع ألوان الصفحات الأخرى
  final Color bgColor = const Color(0xFFF5F3FF); // kLightPurple
  final Color accentColor = const Color(0xFF6366F1); // kMediumPurple
  final Color darkPurple = const Color.fromARGB(255, 20, 14, 93); // kDarkPurple
  final Color textColor = const Color(0xFF374151); // kTextColor
  final Color hintColor = const Color(0xFF9CA3AF); // kHintColor

  // ألوان الدرجات محددة مباشرة في المكون
  final Color excellentColor = const Color(0xFF4CAF50); // ممتاز
  final Color goodColor = const Color(0xFF2196F3); // جيد
  final Color averageColor = const Color(0xFFFFA000); // متوسط
  final Color weakColor = const Color(0xFFF44336); // ضعيف

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // القسم الأساسي من البطاقة (دائماً مرئي)
            _buildCardHeader(context),

            // القسم القابل للتوسيع من البطاقة
            if (controller.isExpanded) _buildExpandedSection(context),
          ],
        ),
      ),
    );
  }

  /// بناء رأس البطاقة (الجزء الدائم الظهور)
  Widget _buildCardHeader(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return InkWell(
      borderRadius: controller.isExpanded
          ? const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            )
          : BorderRadius.circular(16),
      onTap: () => controller.toggleExpansion(),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم المقرر وعدد الساعات
            _buildCourseTitleRow(context),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),

            // تفاصيل المقرر (الأيام والوقت)
            _buildCourseDetailsRow(context),

            const SizedBox(height: 8),

            // تفاصيل القاعة والدرجات
            _buildClassroomAndGradeRow(context),

            // زر عرض المزيد (يظهر فقط إذا كانت البطاقة مطوية وهناك محتوى إضافي)
            _buildShowMoreButton(context),
          ],
        ),
      ),
    );
  }

  /// بناء صف عنوان المقرر وعدد الساعات
  Widget _buildCourseTitleRow(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            controller.course.courseName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkPurple,
              fontFamily: 'SYMBIOAR+LT',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.book_outlined,
                size: 14,
                color: accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                "${controller.course.creditHours ?? ''} ساعات",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء صف تفاصيل المقرر (الأيام والوقت)
  Widget _buildCourseDetailsRow(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return Row(
      children: [
        // الأيام
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconContainer(Icons.calendar_today_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الأيام",
                      style: TextStyle(
                        fontSize: 10,
                        color: hintColor,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                    Text(
                      controller.daysString.isEmpty
                          ? "غير محدد"
                          : controller.daysString,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textColor,
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
        ),

        const SizedBox(width: 12),

        // الوقت
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconContainer(Icons.access_time_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الوقت",
                      style: TextStyle(
                        fontSize: 10,
                        color: hintColor,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                    Text(
                      controller.course.lectureTime ?? "غير محدد",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textColor,
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
        ),
      ],
    );
  }

  /// بناء صف القاعة ومتوسط الدرجات
  Widget _buildClassroomAndGradeRow(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return Row(
      children: [
        _buildIconContainer(Icons.location_on_outlined),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "القاعة",
                style: TextStyle(
                  fontSize: 10,
                  color: hintColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              Text(
                controller.course.classroom.isEmpty
                    ? "غير محددة"
                    : controller.course.classroom,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // متوسط الدرجات (يظهر فقط إذا كان هناك درجات)
        if (controller.courseAverage > 0) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getGradeColor(controller.courseAverage).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    _getGradeColor(controller.courseAverage).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              // عرض المتوسط الفعلي للدرجات
              '${controller.courseActualAverage.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getGradeColor(controller.courseAverage),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// بناء زر عرض المزيد
  Widget _buildShowMoreButton(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    // يظهر فقط إذا كانت البطاقة مطوية وهناك محتوى إضافي
    if (!controller.isExpanded && controller.hasExpandableContent) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                "عرض المزيد",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// بناء حاوية أيقونة موحدة
  Widget _buildIconContainer(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color: accentColor,
      ),
    );
  }

  /// بناء القسم الموسع من البطاقة
  Widget _buildExpandedSection(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24, thickness: 1),

          // الدرجات
          if (controller.hasGrades) ...[
            _buildSectionHeader("الدرجات", Icons.grade_outlined),
            const SizedBox(height: 12),
            ..._buildGradesSection(context),
            const SizedBox(height: 16),
          ],

          // التذكيرات
          if (controller.hasReminders) ...[
            _buildSectionHeader("التذكيرات", Icons.notifications_outlined),
            const SizedBox(height: 12),
            ..._buildRemindersSection(context),
            const SizedBox(height: 16),
          ],

          // الملفات
          if (controller.hasFiles) ...[
            _buildSectionHeader(
                "ملفات المقرر", Icons.insert_drive_file_outlined),
            const SizedBox(height: 12),
            ..._buildFilesSection(context),
            const SizedBox(height: 16),
          ],

          // زر طي المحتوى
          const SizedBox(height: 12),
          _buildCollapseButton(context),
        ],
      ),
    );
  }

  /// بناء عنوان قسم (الدرجات، التذكيرات، الملفات)
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: accentColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkPurple,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  /// بناء قسم الدرجات
  List<Widget> _buildGradesSection(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return controller.course.grades.entries
        .map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  // اسم الاختبار أو المهمة
                  SizedBox(
                    width: 90,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),

                  // شريط التقدم
                  Expanded(
                    child: Stack(
                      children: [
                        // خلفية الشريط
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        // الشريط الملون حسب الدرجة
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: 8,
                              width: constraints.maxWidth * (entry.value / 100),
                              decoration: BoxDecoration(
                                color: _getGradeColor(entry.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // عرض الدرجة الفعلية
                  Container(
                    width: 45,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      // تحويل النسبة المئوية إلى درجة فعلية
                      '${controller.percentageToActualGrade(entry.value).toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: accentColor,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  /// بناء قسم التذكيرات
  List<Widget> _buildRemindersSection(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return controller.course.reminders
        .map((reminder) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reminder,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  /// بناء قسم الملفات
  List<Widget> _buildFilesSection(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return controller.course.files
        .map((file) => InkWell(
              onTap: () {
                if (onFileSelected != null) {
                  onFileSelected!(file);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _getFileIcon(file.fileType),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.fileName,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  /// الحصول على أيقونة مناسبة لنوع الملف
  Widget _getFileIcon(String fileType) {
    IconData iconData;

    fileType = fileType.toLowerCase();

    if (fileType.contains('pdf')) {
      iconData = Icons.picture_as_pdf;
    } else if (fileType.contains('doc') || fileType.contains('word')) {
      iconData = Icons.description;
    } else if (fileType.contains('xls') || fileType.contains('excel')) {
      iconData = Icons.table_chart;
    } else if (fileType.contains('ppt') || fileType.contains('presentation')) {
      iconData = Icons.slideshow;
    } else if (fileType.contains('jpg') ||
        fileType.contains('jpeg') ||
        fileType.contains('png') ||
        fileType.contains('image')) {
      iconData = Icons.image;
    } else {
      iconData = Icons.insert_drive_file;
    }

    return Icon(
      iconData,
      size: 16,
      color: accentColor,
    );
  }

  /// بناء زر طي المحتوى
  Widget _buildCollapseButton(BuildContext context) {
    final controller = Provider.of<CourseCardController>(context);

    return Center(
      child: InkWell(
        onTap: () => controller.collapse(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_up,
                size: 16,
                color: accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                "عرض أقل",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// تحديد لون الدرجة بناءً على النسبة المئوية
  Color _getGradeColor(double percentage) {
    // استخدام الألوان المحددة مباشرة في المكون
    if (percentage >= 90) {
      return excellentColor; // ممتاز
    } else if (percentage >= 70) {
      return goodColor; // جيد
    } else if (percentage >= 50) {
      return averageColor; // متوسط
    } else if (percentage > 0) {
      return weakColor; // ضعيف
    } else {
      return Colors.grey; // لا توجد درجات
    }
  }
}
