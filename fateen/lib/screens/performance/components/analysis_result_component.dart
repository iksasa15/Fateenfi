import 'package:flutter/material.dart';
import '../../../models/student_performance_model.dart';
import '../constants/performance_colors.dart';
import 'learning_resources_component.dart';

/// مكون عرض نتائج تحليل أداء الطالب
/// يعرض نقاط القوة والضعف والعلاقات المكتشفة وخطة الدراسة والموارد التعليمية المقترحة
class AnalysisResultComponent extends StatelessWidget {
  // الخصائص الأساسية للمكون
  final PerformanceAnalysis analysis;
  final VoidCallback onRequestMoreResources;

  const AnalysisResultComponent({
    Key? key,
    required this.analysis,
    required this.onRequestMoreResources,
  }) : super(key: key);

  // ألوان المكون - متوافقة مع بطاقة المقررات
  final Color bgColor = const Color(0xFFF5F3FF); // kLightPurple
  final Color accentColor = const Color(0xFF6366F1); // kMediumPurple
  final Color darkPurple = const Color(0xFF4338CA); // kDarkPurple
  final Color textColor = const Color(0xFF374151); // kTextColor
  final Color hintColor = const Color(0xFF9CA3AF); // kHintColor

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // بطاقة التحليل الرئيسية
        _buildAnalysisCard(),

        const SizedBox(height: 16),

        // خطة الدراسة
        _buildStudyPlanCard(analysis.studyPlan),

        const SizedBox(height: 16),

        // الموارد المقترحة - استخدام المكون المحسن
        if (analysis.resources.isNotEmpty)
          LearningResourcesComponent(
            resources: analysis.resources,
            onRequestMoreResources: onRequestMoreResources,
          ),
      ],
    );
  }

  //
  // ============ بطاقة التحليل الرئيسية ============
  //

  /// بناء بطاقة التحليل الرئيسية التي تعرض نقاط القوة والضعف والعلاقات المكتشفة
  Widget _buildAnalysisCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          _buildCardHeader('تحليل الأداء والتوصيات', Icons.insights, 'تحليل'),

          const Divider(height: 1, thickness: 1),

          // محتوى التحليل
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // نقاط القوة
                _buildAnalysisSection(
                  'نقاط القوة',
                  Icons.emoji_events_outlined,
                  Colors.green,
                  _filterOutGpaItems(analysis.strengths),
                ),

                const SizedBox(height: 20),

                // نقاط الضعف
                _buildAnalysisSection(
                  'نقاط تحتاج إلى تحسين',
                  Icons.build_outlined,
                  Colors.orange,
                  _filterOutGpaItems(analysis.weaknesses),
                ),

                if (analysis.correlations.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  // علاقات مكتشفة
                  _buildAnalysisSection(
                    'علاقات مكتشفة',
                    Icons.hub_outlined,
                    accentColor,
                    _filterOutGpaItems(analysis.correlations),
                  ),
                ],

                if (analysis.studyPatterns.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  // أنماط الدراسة
                  _buildAnalysisSection(
                    'أنماط الدراسة',
                    Icons.auto_graph_outlined,
                    Colors.purple,
                    _filterOutGpaItems(analysis.studyPatterns),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء قسم من أقسام التحليل (نقاط القوة، نقاط الضعف، إلخ)
  Widget _buildAnalysisSection(
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    // تنظيف النصوص من أي إشارات غير مطلوبة
    items = items.map((item) {
      if (item.startsWith('(تحليل الذكاء الاصطناعي)')) {
        return item.replaceFirst('(تحليل الذكاء الاصطناعي)', '').trim();
      }
      return item;
    }).toList();

    // حذف العناصر التي تحتوي على "تحليل الأداء غير متاح" أو "تعذر تحليل نقاط الضعف"
    items = items
        .where((item) =>
            !item.contains("تحليل الأداء غير متاح") &&
            !item.contains("تعذر تحليل نقاط الضعف"))
        .toList();

    // إذا لم تكن هناك عناصر بعد التصفية، أضف رسالة افتراضية
    if (items.isEmpty) {
      if (title == 'نقاط القوة') {
        items = [
          'لم يتم تحديد نقاط قوة واضحة بناءً على البيانات المتوفرة حالياً.'
        ];
      } else if (title == 'نقاط تحتاج إلى تحسين') {
        items = [
          'لم يتم تحديد نقاط ضعف واضحة بناءً على البيانات المتوفرة حالياً.'
        ];
      } else if (title == 'علاقات مكتشفة') {
        items = ['لم يتم اكتشاف علاقات واضحة بين أدائك وعاداتك الدراسية.'];
      } else if (title == 'أنماط الدراسة') {
        items = ['لم يتم تحديد أنماط دراسة واضحة بناءً على البيانات المتوفرة.'];
      } else {
        items = ['لا توجد معلومات متاحة حالياً.'];
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor,
                        height: 1.4,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// فلترة العناصر المتعلقة بالمعدل التراكمي (GPA)
  List<String> _filterOutGpaItems(List<String> items) {
    final gpaKeywords = [
      'معدل',
      'المعدل',
      'التراكمي',
      'GPA',
      'امتياز',
      'جيد جداً',
      'جيد',
      'مقبول',
      'راسب',
    ];

    return items.where((item) {
      // If item contains any GPA keyword, filter it out
      return !gpaKeywords.any((keyword) => item.contains(keyword));
    }).toList();
  }

  //
  // ============ بطاقة خطة الدراسة ============
  //

  /// بناء بطاقة خطة الدراسة مع الجدول الدراسي والنصائح
  Widget _buildStudyPlanCard(StudyPlan plan) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          _buildCardHeader(plan.title, Icons.schedule_outlined, "خطة دراسية"),

          const Divider(height: 1, thickness: 1),

          // المحتوى
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // وصف الخطة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          plan.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor,
                            height: 1.4,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // جدول الدراسة
                _buildStudySessionsSection(plan),

                const SizedBox(height: 20),

                // نصائح للدراسة
                _buildStudyTipsSection(plan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء قسم جلسات الدراسة الأسبوعية
  Widget _buildStudySessionsSection(StudyPlan plan) {
    if (plan.sessions.isNotEmpty) {
      return _buildStudyHabitItem(
        icon: Icons.calendar_today_outlined,
        title: "جدول الدراسة الأسبوعي",
        child: SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: plan.sessions.length,
            itemBuilder: (context, index) {
              final session = plan.sessions[index];
              return _buildStudySessionCard(session);
            },
          ),
        ),
      );
    } else {
      // رسالة إذا لم تكن هناك جلسات
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "لا توجد جلسات دراسية محددة بعد. قم بتوليد خطة جديدة.",
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// بناء بطاقة جلسة دراسية واحدة
  Widget _buildStudySessionCard(StudySession session) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الجلسة الدراسية
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.today,
                  size: 14,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  session.day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: darkPurple,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                const Spacer(),
                Text(
                  session.timeSlot,
                  style: TextStyle(
                    fontSize: 11,
                    color: accentColor,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),

          // محتوى الجلسة
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getSubjectIcon(session.subject),
                        size: 14,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.subject,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  session.focus,
                  style: TextStyle(
                    fontSize: 12,
                    color: hintColor,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${session.durationMinutes} دقيقة',
                      style: TextStyle(
                        fontSize: 11,
                        color: hintColor,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء قسم نصائح الدراسة
  Widget _buildStudyTipsSection(StudyPlan plan) {
    if (plan.tips.isNotEmpty) {
      return _buildStudyHabitItem(
        icon: Icons.lightbulb_outline,
        title: "نصائح للدراسة الفعالة",
        child: Column(
          children: plan.tips
              .map((tip) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor,
                              height: 1.4,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
    } else {
      // رسالة إذا لم تكن هناك نصائح
      return _buildStudyHabitItem(
        icon: Icons.lightbulb_outline,
        title: "نصائح للدراسة الفعالة",
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              "قم بتوليد خطة جديدة للحصول على نصائح مخصصة للدراسة الفعالة.",
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontFamily: 'SYMBIOAR+LT',
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }

  //
  // ============ مكونات واجهة المستخدم المشتركة ============
  //

  /// بناء رأس بطاقة موحد للمكونات
  Widget _buildCardHeader(String title, IconData icon, String tag) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
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
                  icon,
                  size: 14,
                  color: accentColor,
                ),
                const SizedBox(width: 4),
                Text(
                  tag,
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
      ),
    );
  }

  /// بناء عنصر من عناصر خطة الدراسة (عنوان وويدجت)
  Widget _buildStudyHabitItem({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
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
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  /// اختيار أيقونة مناسبة للمادة الدراسية
  IconData _getSubjectIcon(String subject) {
    final List<IconData> icons = [
      Icons.calculate_outlined,
      Icons.menu_book_outlined,
      Icons.science_outlined,
      Icons.translate_outlined,
      Icons.public_outlined,
      Icons.computer_outlined,
      Icons.history_edu_outlined,
      Icons.psychology_outlined,
    ];

    // توليد أيقونة ثابتة لكل مقرر بناءً على اسمه
    int hashCode = subject.hashCode.abs();
    return icons[hashCode % icons.length];
  }
}
