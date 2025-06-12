// course_screen.dart (التعديلات المطلوبة)

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// استدعاء ملفات المتحكمات
import 'controllers/course_header_controller.dart';
import 'controllers/course_card_controller.dart';
import 'controllers/course_add_controller.dart';

// استدعاء ملفات المكونات
import 'components/course_header_component.dart';
import 'components/course_card_component.dart';
import 'components/course_add_components.dart';

// استدعاء ملفات الثوابت
import 'constants/course_header_constants.dart';
import 'constants/course_card_constants.dart';
import 'constants/course_add_constants.dart';

// استدعاء النماذج
import '../../../../models/course.dart';

// استدعاء شاشة خيارات المقرر الجديدة
import 'screens/course_options_screen.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({Key? key}) : super(key: key);

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  // إنشاء المتحكمات
  late CourseHeaderController _headerController;
  late CourseCardController _courseCardController;
  late CourseAddController _addController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // إنشاء متحكمات النصوص
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  final TextEditingController _classroomController = TextEditingController();

  // متغيرات الاختيار
  List<String> _selectedDays = [];
  String? _selectedTimeString;

  // متغيرات الأخطاء
  String? _nameError;
  String? _creditError;
  String? _classroomError;
  String? _daysError;
  String? _timeError;

  // استدعاء الثوابت
  final courseAddConstants = CourseAddConstants();

  @override
  void initState() {
    super.initState();

    // استدعاء إنشاء كائن الإشعارات
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // استدعاء دالة تهيئة الإشعارات
    _initNotifications();

    // استدعاء إنشاء المتحكمات
    _headerController = CourseHeaderController();
    _courseCardController = CourseCardController();
    _addController = CourseAddController();
  }

  // دالة تهيئة الإشعارات
  Future<void> _initNotifications() async {
    // استدعاء إنشاء إعدادات الإشعارات لأندرويد
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // استدعاء إنشاء إعدادات الإشعارات لـ iOS
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings();

    // استدعاء إنشاء إعدادات الإشعارات العامة
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    // استدعاء تهيئة الإشعارات
    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (details) {
      // معالجة الضغط على الإشعار (غير مستخدم بعد)
    });
  }

  // إعادة تعيين حقول النموذج
  void _resetFormFields() {
    _nameController.text = '';
    _creditController.text = '';
    _classroomController.text = '';
    _selectedDays = [];
    _selectedTimeString = null;
    _nameError = null;
    _creditError = null;
    _classroomError = null;
    _daysError = null;
    _timeError = null;
  }

  // تحديث مقرر
  Future<void> _editCourse(Course course) async {
    // هنا يمكن فتح نافذة تعديل المقرر
    print("تعديل المقرر: ${course.courseName}");
    // سيتم تنفيذ منطق التعديل هنا
  }

  // حذف مقرر
  Future<void> _deleteCourse(Course course) async {
    try {
      // تنفيذ عملية الحذف
      await _courseCardController.removeCourse(course.id);

      // عرض رسالة نجاح
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CourseCardConstants.deleteSuccess,
              style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      // عرض رسالة خطأ
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CourseCardConstants.deleteError,
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
    }
  }

  // عرض نموذج إضافة مقرر جديد
  void _showAddCourseSheet() {
    // استدعاء إعادة تعيين الحقول
    _resetFormFields();

    // استدعاء عرض نافذة حوار
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // استدعاء بناء شريط الأدوات مع العنوان
                        CourseAddComponents.buildToolbar(
                          title: courseAddConstants.addCourseTitle,
                          onBackPressed: () => Navigator.pop(ctx),
                        ),

                        // استدعاء بناء حقول الاسم والساعات
                        CourseAddComponents.buildRowFields(
                          mainController: _nameController,
                          mainLabel: courseAddConstants.courseNameLabel,
                          mainError: _nameError,
                          mainIcon: Icons.book_outlined,
                          secondaryController: _creditController,
                          secondaryLabel: courseAddConstants.creditHoursLabel,
                          secondaryError: _creditError,
                          secondaryKeyboardType: TextInputType.number,
                          secondaryIcon: Icons.timer_outlined,
                        ),

                        // استدعاء بناء حقل القاعة
                        CourseAddComponents.buildTextField(
                          controller: _classroomController,
                          labelText: courseAddConstants.classroomLabel,
                          errorText: _classroomError,
                          icon: Icons.location_on_outlined,
                        ),

                        // استدعاء بناء قسم أيام المحاضرة مع رسالة الخطأ
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // قسم أيام المحاضرة
                            CourseAddComponents.buildDaysSection(
                              selectedDays: _selectedDays,
                              onDaySelected: (day, selected) {
                                setModalState(() {
                                  if (selected) {
                                    _selectedDays.add(day);
                                    _daysError =
                                        null; // إزالة الخطأ عند اختيار يوم
                                  } else {
                                    _selectedDays.remove(day);
                                    // إضافة الخطأ إذا أصبحت القائمة فارغة
                                    if (_selectedDays.isEmpty) {
                                      _daysError =
                                          'يجب اختيار يوم واحد على الأقل للمحاضرة';
                                    }
                                  }
                                });
                              },
                            ),

                            // عرض رسالة خطأ الأيام إذا وجدت
                            if (_daysError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, right: 4, bottom: 8),
                                child: Text(
                                  _daysError!,
                                  style: const TextStyle(
                                    color: Color(0xFFEC4899), // kAccentColor
                                    fontSize: 12,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // استدعاء بناء منتقي الوقت مع رسالة الخطأ
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CourseAddComponents.buildTimePicker(
                              selectedTime: _selectedTimeString,
                              onTap: () async {
                                // استدعاء عرض منتقي الوقت
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF4338CA),
                                          onPrimary: Colors.white,
                                          onSurface: Color(0xFF374151),
                                          surface: Colors.white,
                                        ),
                                        timePickerTheme: TimePickerThemeData(
                                          hourMinuteTextColor: Colors.white,
                                          hourMinuteColor: Color(0xFF4338CA),
                                          dayPeriodTextColor: Color(0xFF374151),
                                          dayPeriodColor: Color(0xFFF5F3FF),
                                          dialBackgroundColor: Colors.white,
                                          dialHandColor: Color(0xFF4338CA),
                                          dialTextColor: Color(0xFF374151),
                                          entryModeIconColor: Color(0xFF4338CA),
                                          cancelButtonStyle: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                              Color(0xFF4338CA),
                                            ),
                                          ),
                                          confirmButtonStyle: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                              Color(0xFF4338CA),
                                            ),
                                          ),
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Color(0xFF4338CA)),
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedTime != null) {
                                  final hour = pickedTime.hour
                                      .toString()
                                      .padLeft(2, '0');
                                  final minute = pickedTime.minute
                                      .toString()
                                      .padLeft(2, '0');
                                  setModalState(() {
                                    _selectedTimeString = '$hour:$minute';
                                    _timeError =
                                        null; // إزالة الخطأ عند اختيار وقت
                                  });
                                }
                              },
                            ),

                            // عرض رسالة خطأ الوقت إذا وجدت
                            if (_timeError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, right: 4, bottom: 8),
                                child: Text(
                                  _timeError!,
                                  style: const TextStyle(
                                    color: Color(0xFFEC4899), // kAccentColor
                                    fontSize: 12,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // استدعاء بناء زر الإضافة
                        CourseAddComponents.buildPrimaryButton(
                          text: courseAddConstants.addButton,
                          icon: Icons.add_circle,
                          isLoading: _addController.isLoading,
                          onPressed: () async {
                            if (_addController.isLoading) {
                              return;
                            }

                            // استدعاء التحقق من صحة البيانات
                            final errors = _addController.validateCourseData(
                                _nameController.text.trim(),
                                _creditController.text.trim(),
                                _selectedDays,
                                _selectedTimeString);

                            setModalState(() {
                              // تعيين جميع رسائل الخطأ
                              _nameError = errors['nameError'];
                              _creditError = errors['creditError'];
                              _daysError = errors['daysError'];
                              _timeError = errors['timeError'];
                            });

                            // إذا كان هناك أخطاء، لا نكمل
                            if (_nameError != null ||
                                _creditError != null ||
                                _daysError != null ||
                                _timeError != null) {
                              return;
                            }

                            // إنشاء مقرر جديد
                            final newName = _nameController.text.trim();
                            final newCreditHours =
                                int.parse(_creditController.text.trim());
                            final classroom = _classroomController.text.trim();

                            // استدعاء إنشاء كائن المقرر
                            final newCourse = Course(
                              id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                              courseName: newName,
                              creditHours: newCreditHours,
                              days: _selectedDays,
                              classroom: classroom,
                              lectureTime: _selectedTimeString,
                              grades: {},
                              files: [],
                            );

                            // تحديث حالة التحميل
                            setModalState(() {
                              _addController.isLoading = true;
                            });

                            // استدعاء إضافة المقرر
                            final success =
                                await _addController.addNewCourse(newCourse);

                            // إيقاف مؤشر التحميل
                            if (context.mounted) {
                              setModalState(() {
                                _addController.isLoading = false;
                              });
                            }

                            if (success) {
                              // استدعاء تحديث قائمة المقررات
                              await _courseCardController
                                  .fetchCoursesFromFirestore();

                              if (context.mounted) {
                                // استدعاء إغلاق النافذة
                                Navigator.pop(context);

                                // استدعاء عرض رسالة نجاح
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      courseAddConstants.addSuccess,
                                      style: const TextStyle(
                                          fontFamily: 'SYMBIOAR+LT'),
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            } else if (context.mounted) {
                              // استدعاء عرض رسالة خطأ
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    courseAddConstants.addError,
                                    style: const TextStyle(
                                        fontFamily: 'SYMBIOAR+LT'),
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // عرض خيارات المقرر - تم تعديلها لاستدعاء الصفحة الجديدة
  void _showCourseOptions(int index) {
    // استدعاء الحصول على مقرر من المصفوفة
    final course = _courseCardController.courses[index];

    // استدعاء عرض صفحة خيارات المقرر
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return CourseOptionsScreen(
          course: course,
          courseIndex: index,
          onCourseDeleted: () async {
            // إعادة تحميل المقررات بعد الحذف
            await _courseCardController.fetchCoursesFromFirestore();
            setState(() {}); // تحديث واجهة المستخدم
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      // استدعاء إنشاء زر عائم
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseSheet,
        backgroundColor: const Color(0xFF4338CA),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // استدعاء بناء هيدر ديناميكي
            AnimatedBuilder(
              animation: _headerController,
              builder: (context, _) {
                return Column(
                  children: [
                    // استدعاء بناء الهيدر
                    CourseHeaderComponent.buildHeader(
                        context, _headerController),
                    // استدعاء بناء الفاصل
                    CourseHeaderComponent.buildDivider(),
                  ],
                );
              },
            ),

            // استدعاء بناء قائمة المقررات
            Expanded(
              child: AnimatedBuilder(
                animation: _courseCardController,
                builder: (context, child) {
                  // استدعاء عرض مؤشر التحميل
                  if (_courseCardController.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4338CA),
                      ),
                    );
                  }

                  // استخدام مكون القائمة المعدل
                  return CourseCardComponent.buildCoursesList(
                    context,
                    _courseCardController.courses,
                    onCourseTap: (course) {
                      // البحث عن مؤشر المقرر في القائمة
                      final index =
                          _courseCardController.courses.indexOf(course);
                      if (index != -1) {
                        _showCourseOptions(index);
                      }
                    },
                    onCourseEdit: _editCourse,
                    onCourseDelete: _deleteCourse,
                    onAddCourse: _showAddCourseSheet,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // استدعاء تنظيف المتحكمات
    _headerController.dispose();
    _courseCardController.dispose();
    _addController.dispose();

    // استدعاء تنظيف متحكمات النصوص
    _nameController.dispose();
    _creditController.dispose();
    _classroomController.dispose();

    // استدعاء دالة dispose الأساسية
    super.dispose();
  }
}
