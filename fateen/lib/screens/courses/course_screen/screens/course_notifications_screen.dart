// course_notifications_screen.dart - مطابق لتصميم إضافة المقرر

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../models/course.dart';
import '../components/course_add_components.dart';
import '../constants/course_notifications_constants.dart';
import '../controllers/course_notifications_controller.dart';

class CourseNotificationsScreen extends StatefulWidget {
  final Course course;
  final Function? onNotificationsUpdated;

  const CourseNotificationsScreen({
    Key? key,
    required this.course,
    this.onNotificationsUpdated,
  }) : super(key: key);

  @override
  _CourseNotificationsScreenState createState() =>
      _CourseNotificationsScreenState();
}

class _CourseNotificationsScreenState extends State<CourseNotificationsScreen> {
  late CourseNotificationsController _controller;
  bool _isLoading = false;
  final List<String> _reminderOptions = [
    'وقت المحاضرة',
    'قبل 5 دقائق',
    'قبل 10 دقائق',
    'قبل 15 دقيقة',
    'قبل 30 دقيقة',
    'قبل ساعة',
  ];

  final Map<String, int> _optionsMinutes = {
    'وقت المحاضرة': 0,
    'قبل 5 دقائق': 5,
    'قبل 10 دقائق': 10,
    'قبل 15 دقيقة': 15,
    'قبل 30 دقيقة': 30,
    'قبل ساعة': 60,
  };

  final List<String> _selectedOptions = [
    'وقت المحاضرة'
  ]; // دائمًا نحدد خيار "وقت المحاضرة"

  @override
  void initState() {
    super.initState();
    // إنشاء متحكم الإشعارات
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    _controller = CourseNotificationsController(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
  }

  // معالجة تغيير حالة التذكير المحدد
  void _toggleReminderOption(String option, bool isSelected) {
    setState(() {
      if (option == 'وقت المحاضرة') {
        // لا يمكن إلغاء تحديد خيار وقت المحاضرة
        return;
      }

      if (isSelected) {
        _selectedOptions.add(option);
      } else {
        _selectedOptions.remove(option);
      }
    });
  }

  // معالجة تبديل الإشعارات
  void _handleToggleNotifications() {
    _controller.toggleNotifications().then((_) {
      setState(() {});
    });
  }

  // حفظ إعدادات الإشعارات
  void _saveNotificationSettings() {
    if (!_controller.notificationsEnabled ||
        widget.course.lectureTime == null ||
        widget.course.lectureTime!.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _processSaveNotifications().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // عرض رسالة الخطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "حدث خطأ: $error",
              style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  // دالة مساعدة لمعالجة الحفظ
  Future<void> _processSaveNotifications() async {
    try {
      int successCount = 0;

      // إرسال تذكير في وقت المحاضرة
      final success =
          await _controller.scheduleLectureNotification(widget.course);
      if (success) successCount++;

      // إرسال تذكيرات قبل المحاضرة حسب الخيارات المحددة
      for (var option in _selectedOptions) {
        if (option != 'وقت المحاضرة') {
          final minutes = _optionsMinutes[option] ?? 0;
          final success =
              await _controller.scheduleBeforeTime(widget.course, minutes);
          if (success) successCount++;
        }
      }

      if (mounted && successCount > 0) {
        // عرض رسالة النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CourseNotificationsConstants.reminderSetSuccessMessage
                  .replaceAll("%d", successCount.toString()),
              style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // إغلاق النافذة
        Navigator.of(context).pop();

        // استدعاء دالة التحديث إن وجدت
        if (widget.onNotificationsUpdated != null) {
          widget.onNotificationsUpdated!();
        }
      } else if (mounted) {
        // عرض رسالة عدم النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "لم يتم جدولة أي تذكير، حاول مرة أخرى لاحقاً",
              style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('خطأ في حفظ الإشعارات: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 20), // تقليل الهوامش
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.45, // تقليل الارتفاع الأقصى من 0.8 إلى 0.6
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // علامة السحب
            Padding(
              padding: const EdgeInsets.only(top: 8), // تقليل المساحة
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            const SizedBox(height: 8), // تقليل المساحة

            // المحتوى القابل للتمرير
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14), // تقليل الهوامش
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شريط العنوان
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // زر الإغلاق
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 32, // تصغير حجم الزر
                              height: 32, // تصغير حجم الزر
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFF4338CA),
                                size: 16, // تصغير حجم الأيقونة
                              ),
                            ),
                          ),

                          // العنوان
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6), // تقليل المساحة
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.0,
                              ),
                            ),
                            child: const Text(
                              "خيارات الإشعارات",
                              style: TextStyle(
                                fontSize: 14, // تصغير حجم الخط
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4338CA),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),

                          // مساحة فارغة للمحاذاة
                          const SizedBox(width: 32),
                        ],
                      ),

                      const SizedBox(height: 10), // تقليل المساحة

                      // قسم التعليمات
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8), // تقليل المساحة
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4338CA).withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF4338CA),
                              size: 16, // تصغير حجم الأيقونة
                            ),
                            const SizedBox(width: 6), // تقليل المساحة
                            Expanded(
                              child: Text(
                                "قم بإدخال بيانات المقرر الدراسي بشكل كامل",
                                style: TextStyle(
                                  fontSize: 12, // تصغير حجم الخط
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12), // تقليل المساحة

                      // قسم إعدادات الإشعارات
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // عنوان القسم
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 4, right: 4), // تقليل المساحة
                            child: Text(
                              "إعدادات الإشعارات",
                              style: const TextStyle(
                                fontSize: 13, // تصغير حجم الخط
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),

                          // تبديل الإشعارات
                          Container(
                            height: 45, // تقليل الارتفاع
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4338CA).withOpacity(0.2),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // أيقونة الإشعارات
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8), // تقليل المساحة
                                  width: 28, // تصغير حجم الحاوية
                                  height: 28, // تصغير حجم الحاوية
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF4338CA)
                                          .withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Icon(
                                    _controller.notificationsEnabled
                                        ? Icons.notifications_active
                                        : Icons.notifications_off,
                                    color: _controller.notificationsEnabled
                                        ? const Color(0xFF4338CA)
                                        : Colors.grey,
                                    size: 14, // تصغير حجم الأيقونة
                                  ),
                                ),

                                // نص حالة الإشعارات
                                Expanded(
                                  child: Text(
                                    _controller.notificationsEnabled
                                        ? "الإشعارات مفعّلة"
                                        : "الإشعارات معطّلة",
                                    style: TextStyle(
                                      fontSize: 13, // تصغير حجم الخط
                                      color: _controller.notificationsEnabled
                                          ? Colors.green
                                          : Colors.grey.shade600,
                                      fontFamily: 'SYMBIOAR+LT',
                                    ),
                                  ),
                                ),

                                // زر التبديل
                                Transform.scale(
                                  scale: 0.9, // تصغير حجم زر التبديل
                                  child: Switch(
                                    value: _controller.notificationsEnabled,
                                    activeColor: const Color(0xFF4338CA),
                                    onChanged: (value) =>
                                        _handleToggleNotifications(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12), // تقليل المساحة

                      // قسم وقت المحاضرة
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // عنوان القسم
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 4, right: 4), // تقليل المساحة
                            child: Text(
                              "وقت المحاضرة",
                              style: const TextStyle(
                                fontSize: 13, // تصغير حجم الخط
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),

                          // عرض وقت المحاضرة
                          Container(
                            height: 45, // تقليل الارتفاع
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4338CA).withOpacity(0.2),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // أيقونة الوقت
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8), // تقليل المساحة
                                  width: 28, // تصغير حجم الحاوية
                                  height: 28, // تصغير حجم الحاوية
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF4338CA)
                                          .withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    color: Color(0xFF4338CA),
                                    size: 14, // تصغير حجم الأيقونة
                                  ),
                                ),

                                // نص وقت المحاضرة
                                Expanded(
                                  child: Text(
                                    widget.course.lectureTime ?? "غير محدد",
                                    style: const TextStyle(
                                      fontSize: 13, // تصغير حجم الخط
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF374151),
                                      fontFamily: 'SYMBIOAR+LT',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12), // تقليل المساحة

                      // قسم خيارات التذكير
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // عنوان القسم
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 4, right: 4), // تقليل المساحة
                            child: Text(
                              "إرسال التذكير",
                              style: const TextStyle(
                                fontSize: 13, // تصغير حجم الخط
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),

                          // قائمة الخيارات
                          Container(
                            height: 50, // تقليل الارتفاع
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4338CA).withOpacity(0.2),
                                width: 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6), // تقليل المساحة
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: _reminderOptions.map((option) {
                                  final isSelected =
                                      _selectedOptions.contains(option);
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4), // تقليل المساحة
                                    child: Transform.scale(
                                      scale: 0.9, // تصغير حجم الخيارات
                                      child:
                                          CourseAddComponents.buildChoiceChip(
                                        label: option,
                                        isSelected: isSelected,
                                        onSelected: (selected) =>
                                            _toggleReminderOption(
                                                option, selected),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16), // تقليل المساحة

                      // زر حفظ الإعدادات
                      SizedBox(
                        height: 42, // تقليل ارتفاع الزر
                        child: CourseAddComponents.buildPrimaryButton(
                          text: "إرسال التذكير",
                          onPressed: _saveNotificationSettings,
                          isLoading: _isLoading,
                        ),
                      ),

                      // مساحة إضافية لضمان عدم تجاوز المحتوى
                      const SizedBox(height: 16), // تقليل المساحة
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
