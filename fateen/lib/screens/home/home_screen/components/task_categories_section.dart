import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/tasks_controller.dart';
import '../constants/tasks_constants.dart';
import 'package:fateen/models/task.dart';
import 'package:fateen/models/course.dart';
import 'package:fateen/screens/tasks/services/tasks_firebase_service.dart';
import 'task_card.dart';

/// قسم إحصائيات المهام في الصفحة الرئيسية
/// (المهام المتأخرة، مهام اليوم، المهام القادمة)
class TaskCategoriesSection extends StatefulWidget {
  final Function() onTaskTap;
  final Animation<double> animation;

  const TaskCategoriesSection({
    Key? key,
    required this.onTaskTap,
    required this.animation,
  }) : super(key: key);

  @override
  State<TaskCategoriesSection> createState() => _TaskCategoriesSectionState();
}

class _TaskCategoriesSectionState extends State<TaskCategoriesSection> {
  // ألوان متناسقة مع النظام
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kRed = Color(0xFFE53935); // لون للمهام المتأخرة
  static const Color kGreen = Color(0xFF4CAF50); // لون للمهام القادمة

  // إنشاء مثيل من خدمة Firebase للمهام
  final TasksFirebaseService _tasksService = TasksFirebaseService();

  List<Task> _overdueTasks = [];
  List<Task> _todayTasks = [];
  List<Task> _upcomingTasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // تحميل جميع أنواع المهام - باستخدام TasksFirebaseService
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      try {
        // تحميل جميع المهام مرة واحدة ثم تصنيفها
        List<Task> allTasks = await _getAllTasks();

        // تصنيف المهام
        _categorizeAllTasks(allTasks);
      } catch (e) {
        print('خطأ في تحميل المهام: $e');
        _errorMessage = 'فشل في تحميل المهام: $e';
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // الحصول على جميع المهام
  Future<List<Task>> _getAllTasks() async {
    try {
      // الحصول على جميع المهام من خلال TasksFirebaseService
      final tasksSnapshot = await _tasksService.tasksCollection.get();
      final courses = await _tasksService.getCourses();

      List<Task> allTasks = [];
      for (var doc in tasksSnapshot.docs) {
        try {
          final courseId = doc.data()['courseId'] as String?;
          Course? course;

          if (courseId != null) {
            for (var c in courses) {
              if (c.id == courseId) {
                course = c;
                break;
              }
            }
          }

          allTasks.add(Task.fromFirestore(doc, course: course));
        } catch (e) {
          print('خطأ في تحويل المهمة: $e');
        }
      }
      return allTasks;
    } catch (e) {
      print('خطأ في جلب المهام: $e');
      throw Exception('فشل في الحصول على المهام: $e');
    }
  }

  // تصنيف المهام المستلمة إلى فئات
  void _categorizeAllTasks(List<Task> allTasks) {
    DateTime now = DateTime.now();
    DateTime startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime startOfTomorrow =
        DateTime(now.year, now.month, now.day + 1, 0, 0, 0);

    // تفريغ القوائم السابقة
    _overdueTasks = [];
    _todayTasks = [];
    _upcomingTasks = [];

    // تصنيف كل مهمة
    for (var task in allTasks) {
      // تخطي المهام المكتملة أو الملغاة
      if (task.status == 'مكتملة' || task.status == 'ملغاة') {
        continue;
      }

      if (task.dueDate.isBefore(startOfToday)) {
        // المهام المتأخرة
        _overdueTasks.add(task);
      } else if (task.dueDate.isBefore(startOfTomorrow)) {
        // مهام اليوم
        _todayTasks.add(task);
      } else {
        // المهام القادمة
        _upcomingTasks.add(task);
      }
    }

    // ترتيب المهام حسب تاريخ الاستحقاق
    _overdueTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    _todayTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    _upcomingTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        _buildSectionTitle(' المهام', screenSize, isSmallScreen),

        // حالة التحميل
        if (_isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(screenSize.width * 0.04),
              child: const CircularProgressIndicator(color: kMediumPurple),
            ),
          )

        // حالة الخطأ
        else if (_errorMessage != null)
          _buildErrorMessage(_errorMessage!, screenSize)

        // عرض البطاقات والمهام
        else
          Column(
            children: [
              // بطاقة الإحصائيات
              _buildTasksStatsCard(screenSize, isSmallScreen),

              // قائمة المهام
              if (_overdueTasks.isNotEmpty)
                _buildTasksSection(
                  "المهام المتأخرة",
                  _overdueTasks,
                  kRed,
                  Icons.warning_rounded,
                  screenSize,
                  isSmallScreen,
                ),

              if (_todayTasks.isNotEmpty)
                _buildTasksSection(
                  "مهام اليوم",
                  _todayTasks,
                  kMediumPurple,
                  Icons.today_rounded,
                  screenSize,
                  isSmallScreen,
                ),

              if (_upcomingTasks.isNotEmpty)
                _buildTasksSection(
                  "المهام القادمة",
                  _upcomingTasks,
                  kGreen,
                  Icons.upcoming_rounded,
                  screenSize,
                  isSmallScreen,
                ),

              // حالة عدم وجود مهام
              if (_overdueTasks.isEmpty &&
                  _todayTasks.isEmpty &&
                  _upcomingTasks.isEmpty)
                _buildEmptyState(screenSize),
            ],
          ),
      ],
    );
  }

  // بناء عنوان القسم
  Widget _buildSectionTitle(String title, Size screenSize, bool isSmallScreen) {
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;
    final double titleSize =
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
                  fontSize: titleSize,
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
        ],
      ),
    );
  }

  // بناء بطاقة إحصائيات المهام
  Widget _buildTasksStatsCard(Size screenSize, bool isSmallScreen) {
    // حالة عدم وجود مهام
    if (_overdueTasks.isEmpty &&
        _todayTasks.isEmpty &&
        _upcomingTasks.isEmpty) {
      return Container(); // لا نعرض البطاقة إذا لم تكن هناك مهام
    }

    // حساب العدد الإجمالي للمهام
    final int totalTasks =
        _overdueTasks.length + _todayTasks.length + _upcomingTasks.length;

    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    // حساب أحجام العناصر حسب حجم الشاشة
    final double iconSize =
        isSmallScreen ? 18.0 : (isMediumScreen ? 19.0 : 20.0);
    final double fontSize =
        isSmallScreen ? 13.0 : (isMediumScreen ? 13.5 : 14.0);
    final double statItemSize =
        isSmallScreen ? 52.0 : (isMediumScreen ? 55.0 : 58.0);

    return FadeTransition(
      opacity: widget.animation,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.01,
        ),
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
        child: Column(
          children: [
            // صف الإحصائيات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // المهام المتأخرة
                if (_overdueTasks.isNotEmpty)
                  _buildStatItem(
                    title: 'المتأخرة',
                    count: _overdueTasks.length.toString(),
                    icon: Icons.warning_rounded,
                    color: kRed,
                    size: statItemSize,
                    fontSize: fontSize,
                    iconSize: iconSize,
                  ),

                // مهام اليوم
                if (_todayTasks.isNotEmpty)
                  _buildStatItem(
                    title: 'اليوم',
                    count: _todayTasks.length.toString(),
                    icon: Icons.today_rounded,
                    color: kMediumPurple,
                    size: statItemSize,
                    fontSize: fontSize,
                    iconSize: iconSize,
                  ),

                // المهام القادمة
                if (_upcomingTasks.isNotEmpty)
                  _buildStatItem(
                    title: 'القادمة',
                    count: _upcomingTasks.length.toString(),
                    icon: Icons.upcoming_rounded,
                    color: kGreen,
                    size: statItemSize,
                    fontSize: fontSize,
                    iconSize: iconSize,
                  ),
              ],
            ),

            // خط فاصل
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.015,
              ),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade100,
              ),
            ),

            // الرسالة التحفيزية
            Row(
              children: [
                // أيقونة الوقت
                Icon(
                  Icons.schedule,
                  color: kMediumPurple,
                  size: iconSize,
                ),
                SizedBox(width: screenSize.width * 0.02),
                // رسالة تحفيزية
                Expanded(
                  child: Text(
                    "لديك $totalTasks مهام تنتظر إنجازك!",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF555555),
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.2,
                    ),
                  ),
                ),
                // زر عرض الكل
                TextButton(
                  onPressed: widget.onTaskTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.02,
                      vertical: screenSize.height * 0.005,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'عرض الكل',
                        style: TextStyle(
                          color: kMediumPurple,
                          fontSize: fontSize - 1,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      SizedBox(width: screenSize.width * 0.005),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: iconSize - 8,
                        color: kMediumPurple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بناء عنصر إحصائية فردية
  Widget _buildStatItem({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required double size,
    required double fontSize,
    required double iconSize,
  }) {
    return Column(
      children: [
        // أيقونة الإحصائية في مربع بزوايا ناعمة
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
                const SizedBox(height: 3),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // عنوان الإحصائية
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize - 1,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF555555),
            fontFamily: 'SYMBIOAR+LT',
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // بناء قسم المهام (عنوان + قائمة بالمهام)
  Widget _buildTasksSection(String title, List<Task> tasks, Color color,
      IconData icon, Size screenSize, bool isSmallScreen) {
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;
    final double titleSize =
        isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
    final double iconSize =
        isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
    final double countSize =
        isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0);

    return Padding(
      padding: EdgeInsets.only(
        top: screenSize.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: EdgeInsets.only(
              bottom: screenSize.height * 0.01,
              right: screenSize.width * 0.01,
              left: screenSize.width * 0.01,
            ),
            child: Row(
              children: [
                Container(
                  width: screenSize.width * 0.06,
                  height: screenSize.width * 0.06,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: iconSize,
                    ),
                  ),
                ),
                SizedBox(width: screenSize.width * 0.02),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.015),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.015,
                    vertical: screenSize.height * 0.0025,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${tasks.length}",
                    style: TextStyle(
                      fontSize: countSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // قائمة المهام
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                tasks.length > 3 ? 3 : tasks.length, // عرض 3 مهام كحد أقصى
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isOverdue = task.dueDate.isBefore(DateTime.now());

              return Padding(
                padding: EdgeInsets.only(
                  bottom: screenSize.height * 0.01,
                ),
                child: TaskCard(
                  task: task,
                  isOverdue: isOverdue,
                  onTap: widget.onTaskTap,
                  animation: widget.animation,
                  color: color, // تمرير لون الفئة لبطاقة المهمة
                ),
              );
            },
          ),

          // زر عرض المزيد إذا كان عدد المهام أكثر من 3
          if (tasks.length > 3)
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenSize.width * 0.02,
                0,
                screenSize.width * 0.02,
                screenSize.height * 0.015,
              ),
              child: InkWell(
                onTap: widget.onTaskTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.01,
                    horizontal: screenSize.width * 0.03,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'عرض المزيد',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen ? 12.0 : 13.0, // زيادة حجم النص
                          color: color.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SYMBIOAR+LT',
                          height: 1.2,
                        ),
                      ),
                      SizedBox(width: screenSize.width * 0.01),
                      Icon(
                        Icons.arrow_forward,
                        size: isSmallScreen ? 11.0 : 13.0, // زيادة حجم الأيقونة
                        color: color.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // رسالة خطأ - مُصغّرة
  Widget _buildErrorMessage(String message, Size screenSize) {
    // تعديل الأحجام للشاشات المختلفة
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;
    final double fontSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final double iconSize =
        isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.015,
      ),
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: iconSize),
              SizedBox(width: screenSize.width * 0.015),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize + 1,
                    color: Colors.red[800],
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.0075),
          Text(
            message,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'SYMBIOAR+LT',
              height: 1.2,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loadTasks,
              icon: Icon(Icons.refresh, size: iconSize - 2),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: fontSize,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[800],
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.02,
                  vertical: screenSize.height * 0.005,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // حالة فارغة - مُصغّرة
  Widget _buildEmptyState(Size screenSize) {
    // تعديل الأحجام للشاشات المختلفة
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;
    final double iconSize =
        isSmallScreen ? 55.0 : (isMediumScreen ? 60.0 : 65.0);
    final double titleSize =
        isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
    final double descSize =
        isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);
    final double buttonTextSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.02,
      ),
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: kMediumPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                color: kMediumPurple,
                size: iconSize * 0.5,
              ),
            ),
            SizedBox(height: screenSize.height * 0.015),
            Text(
              'لا توجد مهام حاليًا',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
                height: 1.2,
              ),
            ),
            SizedBox(height: screenSize.height * 0.0075),
            Text(
              'عند إضافة مهام جديدة، ستظهر هنا',
              style: TextStyle(
                fontSize: descSize,
                color: Colors.grey[700],
                fontFamily: 'SYMBIOAR+LT',
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.height * 0.015),
            // زر إضافة مهمة جديدة
            ElevatedButton.icon(
              onPressed: widget.onTaskTap,
              icon:
                  Icon(Icons.add_circle_outline, size: isSmallScreen ? 14 : 16),
              label: Text(
                'إضافة مهمة جديدة',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: buttonTextSize,
                  height: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kMediumPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.03,
                  vertical: screenSize.height * 0.01,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
