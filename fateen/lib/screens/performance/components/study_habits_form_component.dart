import 'package:flutter/material.dart';
import '../../../models/student_performance_model.dart';
import '../controllers/study_habits_controller.dart';

/// مكون نموذج إدخال عادات الدراسة
/// يسمح للطالب بإدخال وتعديل معلومات عن عادات الدراسة وأسلوب التعلم
class StudyHabitsFormComponent extends StatefulWidget {
  /// عادات الدراسة الحالية للطالب
  final StudentHabits habits;

  /// دالة تُستدعى عند تقديم النموذج
  final Function(StudentHabits) onSubmit;

  /// كنترولر عادات الدراسة (اختياري)
  final StudyHabitsController? controller;

  const StudyHabitsFormComponent({
    Key? key,
    required this.habits,
    required this.onSubmit,
    this.controller,
  }) : super(key: key);

  @override
  StudyHabitsFormComponentState createState() =>
      StudyHabitsFormComponentState();
}

class StudyHabitsFormComponentState extends State<StudyHabitsFormComponent> {
  // مفتاح النموذج للتحقق والتقديم
  final _formKey = GlobalKey<FormState>();

  // متغيرات حالة النموذج
  late int _sleepHours;
  late int _studyHoursDaily;
  late int _studyHoursWeekly;
  late int _understandingLevel;
  late int _distractionLevel;
  late bool _hasHealthIssues;
  late String _learningStyle;
  late String _additionalNotes;

  // ألوان النموذج
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kTextColor = Color(0xFF374151);
  static const Color kHintColor = Color(0xFF9CA3AF);

  // ثوابت للمقاسات والتباعدات
  static const double kPadding = 16.0;
  static const double kBorderRadius = 16.0;
  static const double kItemSpacing = 16.0;
  static const double kIconSize = 16.0;

  @override
  void initState() {
    super.initState();
    // تهيئة قيم النموذج من حالة الطالب الحالية
    _initializeFormValues();
  }

  @override
  void didUpdateWidget(StudyHabitsFormComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث قيم النموذج إذا تغيرت البيانات من الخارج
    if (widget.habits != oldWidget.habits) {
      _initializeFormValues();
    }
  }

  /// تهيئة القيم الأولية للنموذج من بيانات الطالب
  void _initializeFormValues() {
    _sleepHours = widget.habits.sleepHours;
    _studyHoursDaily = widget.habits.studyHoursDaily;
    _studyHoursWeekly = widget.habits.studyHoursWeekly;
    _understandingLevel = widget.habits.understandingLevel;
    _distractionLevel = widget.habits.distractionLevel;
    _hasHealthIssues = widget.habits.hasHealthIssues;
    _learningStyle = widget.habits.learningStyle;
    _additionalNotes = widget.habits.additionalNotes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
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
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس النموذج
              _buildFormHeader(),

              const Divider(height: 1, thickness: 1),

              // محتوى النموذج
              _buildFormContent(),

              const Divider(height: 1, thickness: 1),

              // زر التقديم
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  //
  // ============ مكونات واجهة المستخدم الرئيسية ============
  //

  /// بناء رأس النموذج
  Widget _buildFormHeader() {
    return Padding(
      padding: const EdgeInsets.all(kPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'عادات الدراسة والتعلم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kLightPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.psychology,
                  size: 14,
                  color: kMediumPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  "تحليل الأداء",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kMediumPurple,
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

  /// بناء محتوى النموذج
  Widget _buildFormContent() {
    return Padding(
      padding: const EdgeInsets.all(kPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ساعات النوم
          _buildSleepHoursSlider(),

          const SizedBox(height: kItemSpacing),

          // ساعات المذاكرة
          _buildStudyHoursSlider(),

          const SizedBox(height: kItemSpacing),

          // مستوى الفهم
          _buildUnderstandingLevelSlider(),

          const SizedBox(height: kItemSpacing),

          // مستوى التشتت
          _buildDistractionLevelSlider(),

          const SizedBox(height: kItemSpacing),

          // المشاكل الصحية
          _buildHealthIssuesSwitch(),

          const SizedBox(height: kItemSpacing),

          // أسلوب التعلم المفضل
          _buildLearningStyleSelector(),

          const SizedBox(height: kItemSpacing),

          // ملاحظات إضافية
          _buildAdditionalNotesField(),
        ],
      ),
    );
  }

  /// بناء زر تقديم النموذج
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(kPadding),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.analytics_outlined,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'تحليل الأداء',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  // ============ مكونات حقول النموذج ============
  //

  /// بناء حقل تحديد ساعات النوم
  Widget _buildSleepHoursSlider() {
    return _buildStudyHabitItem(
      icon: Icons.nightlight_outlined,
      title: "ساعات النوم",
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          activeTrackColor: _getSleepColor(_sleepHours),
          inactiveTrackColor: kLightPurple,
          thumbColor: _getSleepColor(_sleepHours),
          overlayColor: _getSleepColor(_sleepHours).withOpacity(0.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: _sleepHours.toDouble(),
                min: 4,
                max: 12,
                divisions: 8,
                onChanged: (value) {
                  setState(() {
                    _sleepHours = value.round();
                  });
                },
              ),
            ),
            _buildValueLabel(
              value: "$_sleepHours ساعات",
              color: _getSleepColor(_sleepHours),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء حقل تحديد ساعات المذاكرة
  Widget _buildStudyHoursSlider() {
    return _buildStudyHabitItem(
      icon: Icons.access_time_outlined,
      title: "ساعات المذاكرة",
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          activeTrackColor: kMediumPurple,
          inactiveTrackColor: kLightPurple,
          thumbColor: kMediumPurple,
          overlayColor: kMediumPurple.withOpacity(0.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: _studyHoursDaily.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    _studyHoursDaily = value.round();
                  });
                },
              ),
            ),
            _buildValueLabel(
              value: "$_studyHoursDaily ساعات",
              color: kMediumPurple,
              backgroundColor: kLightPurple,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء حقل تحديد مستوى الفهم
  Widget _buildUnderstandingLevelSlider() {
    return _buildStudyHabitItem(
      icon: Icons.psychology_outlined,
      title: "مستوى الفهم",
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          activeTrackColor: _getUnderstandingColor(_understandingLevel),
          inactiveTrackColor: kLightPurple,
          thumbColor: _getUnderstandingColor(_understandingLevel),
          overlayColor:
              _getUnderstandingColor(_understandingLevel).withOpacity(0.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: _understandingLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) {
                  setState(() {
                    _understandingLevel = value.round();
                  });
                },
              ),
            ),
            _buildValueLabel(
              value: _getLevelLabel(_understandingLevel),
              color: _getUnderstandingColor(_understandingLevel),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء حقل تحديد مستوى التشتت
  Widget _buildDistractionLevelSlider() {
    return _buildStudyHabitItem(
      icon: Icons.blur_on_outlined,
      title: "مستوى التشتت",
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          activeTrackColor: _getDistractionColor(_distractionLevel),
          inactiveTrackColor: kLightPurple,
          thumbColor: _getDistractionColor(_distractionLevel),
          overlayColor:
              _getDistractionColor(_distractionLevel).withOpacity(0.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: _distractionLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) {
                  setState(() {
                    _distractionLevel = value.round();
                  });
                },
              ),
            ),
            _buildValueLabel(
              value: _getDistractionLabel(_distractionLevel),
              color: _getDistractionColor(_distractionLevel),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء حقل تحديد المشاكل الصحية
  Widget _buildHealthIssuesSwitch() {
    return _buildStudyHabitItem(
      icon: Icons.healing_outlined,
      title: "المشاكل الصحية",
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: _hasHealthIssues,
              activeColor: kMediumPurple,
              activeTrackColor: kLightPurple,
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[200],
              onChanged: (value) {
                setState(() {
                  _hasHealthIssues = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'توجد مشاكل صحية تؤثر على الدراسة',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _hasHealthIssues ? kMediumPurple : kTextColor,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء حقل اختيار أسلوب التعلم
  Widget _buildLearningStyleSelector() {
    return _buildStudyHabitItem(
      icon: Icons.school_outlined,
      title: "أسلوب التعلم المفضل",
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildLearningStyleChip('visual', 'بصري', Icons.visibility_outlined),
          _buildLearningStyleChip('auditory', 'سمعي', Icons.hearing_outlined),
          _buildLearningStyleChip(
              'kinesthetic', 'حركي', Icons.sports_handball_outlined),
          _buildLearningStyleChip('reading', 'قرائي', Icons.menu_book_outlined),
        ],
      ),
    );
  }

  /// بناء حقل إدخال الملاحظات الإضافية
  Widget _buildAdditionalNotesField() {
    return _buildStudyHabitItem(
      icon: Icons.note_outlined,
      title: "ملاحظات إضافية",
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: TextField(
          controller: TextEditingController(text: _additionalNotes),
          decoration: const InputDecoration(
            hintText: "أضف ملاحظاتك هنا...",
            hintStyle: TextStyle(
              fontSize: 12,
              fontFamily: 'SYMBIOAR+LT',
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: TextStyle(
            fontSize: 12,
            color: kTextColor,
            fontFamily: 'SYMBIOAR+LT',
          ),
          maxLines: 3,
          minLines: 3,
          onChanged: (value) {
            _additionalNotes = value;
          },
        ),
      ),
    );
  }

  //
  // ============ مكونات واجهة المستخدم المساعدة ============
  //

  /// بناء عنصر من عناصر النموذج
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
                color: kLightPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: kIconSize,
                color: kMediumPurple,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kTextColor,
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

  /// بناء تسمية قيمة لعرض القيم المختارة
  Widget _buildValueLabel({
    required String value,
    required Color color,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
    );
  }

  /// بناء شريحة أسلوب التعلم
  Widget _buildLearningStyleChip(String value, String label, IconData icon) {
    final isSelected = _learningStyle == value;

    return InkWell(
      onTap: () {
        setState(() {
          _learningStyle = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kMediumPurple : kLightPurple,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kMediumPurple : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: kIconSize,
              color: isSelected ? Colors.white : kMediumPurple,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : kTextColor,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  // ============ وظائف معالجة النموذج ============
  //

  /// إرسال النموذج وإشعار الأب بالتغييرات
  void _submitForm() {
    final updatedHabits = StudentHabits(
      sleepHours: _sleepHours,
      studyHoursDaily: _studyHoursDaily,
      studyHoursWeekly: _studyHoursWeekly,
      understandingLevel: _understandingLevel,
      distractionLevel: _distractionLevel,
      hasHealthIssues: _hasHealthIssues,
      learningStyle: _learningStyle,
      additionalNotes: _additionalNotes,
    );

    // تحديث الكنترولر إذا كان متوفراً
    if (widget.controller != null) {
      widget.controller!.updateStudyHabitsFromForm(updatedHabits);
    }

    // إشعار الأب بالتغييرات
    widget.onSubmit(updatedHabits);
  }

  //
  // ============ دوال المساعدة ============
  //

  /// تحديد لون مستوى الفهم
  Color _getUnderstandingColor(int level) {
    switch (level) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.amber;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.amber;
    }
  }

  /// تحديد لون مستوى التشتت
  Color _getDistractionColor(int level) {
    switch (level) {
      case 1:
      case 2:
        return Colors.green;
      case 3:
        return Colors.amber;
      case 4:
      case 5:
        return Colors.red;
      default:
        return Colors.amber;
    }
  }

  /// تحديد لون ساعات النوم
  Color _getSleepColor(int hours) {
    if (hours < 6) {
      return Colors.red;
    } else if (hours < 8) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  /// الحصول على نص وصفي لمستوى الفهم
  String _getLevelLabel(int level) {
    switch (level) {
      case 1:
        return 'ضعيف جداً';
      case 2:
        return 'ضعيف';
      case 3:
        return 'متوسط';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return 'متوسط';
    }
  }

  /// الحصول على نص وصفي لمستوى التشتت
  String _getDistractionLabel(int level) {
    switch (level) {
      case 1:
        return 'نادراً';
      case 2:
        return 'قليلاً';
      case 3:
        return 'أحياناً';
      case 4:
        return 'غالباً';
      case 5:
        return 'دائماً';
      default:
        return 'أحياناً';
    }
  }
}
