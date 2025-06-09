import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fateen/screens/home/home_screen/controllers/header_controller.dart';
import 'package:fateen/screens/tasks/task_screen/task_screen.dart';
import '../home_screen/components/header.dart';

// استيراد ملفات ميزة المحاضرة القادمة
import '../home_screen/controllers/next_lecture_controller.dart';
import '../home_screen/components/next_lecture_card.dart';
import '../home_screen/constants/next_lecture_constants.dart';

// استيراد ملفات ميزة شريط التنقل السفلي
import '../../bottom_nav/index.dart';

// استيراد ملفات ميزة الإحصائيات - سنحتفظ بالاستيراد لكن لن نستخدمه
import '../home_screen/controllers/stats_controller.dart';

// استيراد ملفات ميزة المهام التي تحتاج اهتمام
import '../home_screen/controllers/tasks_controller.dart';

// استيراد قسم فئات المهام الجديد
import '../home_screen/components/task_categories_section.dart';

// استيراد ملفات الصفحات الرئيسية
import 'package:fateen/screens/courses/course_screen/course_screen.dart';
import '../../tasks/Task_screen/Task_screen.dart' hide TasksScreen;
import '../services_screen/services_screen.dart';
import '../settings_screen/settings_screen.dart';

// استيراد MyScheduleScreen
import '../../courses/Schedule_screen/Schedule_screen.dart';

// إنشاء مكون NextLectureCard معدل لإزالة الأنيميشن
class StaticNextLectureCard extends StatelessWidget {
  final String courseName;
  final String classroom;
  final int diffSeconds;

  const StaticNextLectureCard({
    Key? key,
    required this.courseName,
    required this.classroom,
    required this.diffSeconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نسخة مبسطة من NextLectureCard بدون أنيميشن
    String timeText = _formatTime(diffSeconds);
    Color timeColor = _getTimeColor(diffSeconds);
    Color bgColor = _getBgColor(diffSeconds);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // معلومات المحاضرة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    courseName,
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        classroom,
                        style: const TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // مؤشر الوقت المتبقي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                timeText,
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: timeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دوال مساعدة لتنسيق الوقت وألوان العرض
  String _formatTime(int diffSeconds) {
    if (diffSeconds < 0) {
      return "بدأت";
    }
    if (diffSeconds < 60) {
      return "خلال $diffSeconds ثانية";
    }
    int diffMinutes = diffSeconds ~/ 60;
    if (diffMinutes < 60) {
      return "خلال $diffMinutes دقيقة";
    }
    int diffHours = diffMinutes ~/ 60;
    int remainingMinutes = diffMinutes % 60;
    if (remainingMinutes == 0) {
      return "خلال $diffHours ساعة";
    }
    return "خلال $diffHours ساعة و $remainingMinutes دقيقة";
  }

  Color _getTimeColor(int diffSeconds) {
    if (diffSeconds < 900) {
      // أقل من 15 دقيقة
      return Colors.red;
    } else if (diffSeconds < 1800) {
      // أقل من 30 دقيقة
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Color _getBgColor(int diffSeconds) {
    if (diffSeconds < 900) {
      // أقل من 15 دقيقة
      return Colors.red.withOpacity(0.1);
    } else if (diffSeconds < 1800) {
      // أقل من 30 دقيقة
      return Colors.orange.withOpacity(0.1);
    } else {
      return Colors.green.withOpacity(0.1);
    }
  }
}

// إنشاء مكون TaskCategoriesSection معدل لإزالة الأنيميشن
class StaticTaskCategoriesSection extends StatelessWidget {
  final VoidCallback onTaskTap;

  const StaticTaskCategoriesSection({
    Key? key,
    required this.onTaskTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Text(
          'فئات المهام',
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        // بطاقات فئات المهام
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildCategoryCard(
              context,
              title: 'المهام العاجلة',
              icon: Icons.timer,
              color: Colors.red,
              count: 3,
            ),
            _buildCategoryCard(
              context,
              title: 'المهام القادمة',
              icon: Icons.calendar_today,
              color: Colors.blue,
              count: 5,
            ),
            _buildCategoryCard(
              context,
              title: 'المهام المكتملة',
              icon: Icons.check_circle,
              color: Colors.green,
              count: 12,
            ),
            _buildCategoryCard(
              context,
              title: 'كل المهام',
              icon: Icons.list_alt,
              color: Colors.purple,
              count: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required int count,
  }) {
    return InkWell(
      onTap: onTaskTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userMajor;

  const HomeScreen({Key? key, required this.userName, required this.userMajor})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ألوان ثابتة لتوحيد المظهر
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFEEF2FF);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);
  static const Color kAccentColor = Color(0xFF7E22CE);
  static const Color kGreenColor = Color(0xFF10B981);
  static const Color kOrangeColor = Color(0xFFF59E0B);

  final HeaderController _headerController = HeaderController();
  late NextLectureController _nextLectureController;
  late StatsController _statsController;
  late TasksController _tasksController;

  // إضافة وحدة تحكم شريط التنقل
  late BottomNavController _navController;

  // قائمة بالصفحات المتوفرة في التطبيق
  late List<Widget> _pages;

  // حاوية لتخزين حالة الصفحات
  final PageStorageBucket _bucket = PageStorageBucket();

  // مؤشر التحميل الأولي
  bool _isInitialLoading = true;

  // مؤشر لعملية التحديث
  bool _isRefreshing = false;

  // قائمة بالمواعيد القادمة للعرض
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'اختبار نصفي - مقدمة في البرمجة',
      'date': 'الثلاثاء، ١٠ يونيو',
      'icon': Icons.assignment,
      'color': Color(0xFFEF4444),
      'isUrgent': true,
    },
    {
      'title': 'تسليم واجب - هندسة البرمجيات',
      'date': 'الخميس، ١٢ يونيو',
      'icon': Icons.book,
      'color': Color(0xFFF59E0B),
      'isUrgent': false,
    },
    {
      'title': 'محاضرة استثنائية - تصميم قواعد البيانات',
      'date': 'الأحد، ١٥ يونيو',
      'icon': Icons.event_note,
      'color': Color(0xFF3B82F6),
      'isUrgent': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  // استخدام دالة منفصلة لتهيئة وحدات التحكم لتحسين الأداء
  Future<void> _initializeControllers() async {
    setState(() {
      _isInitialLoading = true;
    });

    // تهيئة وحدات التحكم في مجموعات متوازية لتحسين الأداء
    await Future.wait([
      _headerController.initialize(),
      Future(() async {
        _nextLectureController = NextLectureController();
        await _nextLectureController.initialize();
      }),
      Future(() async {
        _statsController = StatsController();
        await _statsController.initialize();
      }),
      Future(() async {
        _tasksController = TasksController();
        await _tasksController.initialize();
      }),
    ]);

    // تهيئة وحدة تحكم شريط التنقل
    _navController = BottomNavController();

    // تهيئة الصفحات
    _initializePages();

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  // تهيئة قائمة الصفحات
  void _initializePages() {
    _pages = [
      _buildHomeContent(), // الصفحة الرئيسية
      const MyScheduleScreen(), // صفحة الجدول - استخدام MyScheduleScreen
      const CourseScreen(), // صفحة المقررات
      const TasksScreen(), // صفحة المهام
      const ServicesScreen(), // صفحة الخدمات
      const SettingsScreen(), // صفحة الإعدادات
    ];
  }

  // معالجة النقر على بطاقة الإحصائيات
  void _handleStatsCardTap(String cardType) {
    // تنفيذ إجراء مناسب حسب نوع البطاقة
    switch (cardType) {
      case 'courses':
        _navController.changeIndex(2); // الانتقال إلى صفحة المقررات
        break;
      case 'tasks':
        _navController.changeIndex(3); // الانتقال إلى صفحة المهام
        break;
      case 'attendance':
        // يمكن إضافة تنقل لصفحة الحضور إذا كانت موجودة
        break;
      case 'exams':
        // يمكن إضافة تنقل لصفحة الاختبارات إذا كانت موجودة
        break;
    }
  }

  // إضافة بطاقة الملف الشخصي
  Widget _buildProfileCard(
      double horizontalPadding, double smallSpacing, double fontSize) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Center(
                    child: Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : "؟",
                      style: TextStyle(
                        fontFamily: 'SYMBIOAR+LT',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kAccentColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: horizontalPadding * 0.8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: TextStyle(
                        fontFamily: 'SYMBIOAR+LT',
                        fontSize: fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "طالب في ${widget.userMajor}",
                      style: TextStyle(
                        fontFamily: 'SYMBIOAR+LT',
                        fontSize: fontSize - 2,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white.withOpacity(0.9),
                ),
                onPressed: () {
                  _navController.changeIndex(5); // الانتقال إلى صفحة الإعدادات
                },
              ),
            ],
          ),
          SizedBox(height: smallSpacing * 1.5),
          // معلومات الطالب
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProfileStat("المستوى", "6", fontSize),
              _buildProfileStat("الساعات", "84", fontSize),
              _buildProfileStat("المعدل", "4.52", fontSize),
            ],
          ),
        ],
      ),
    );
  }

  // بناء إحصائية الملف الشخصي
  Widget _buildProfileStat(String title, String value, double fontSize) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontSize: fontSize + 3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontSize: fontSize - 3,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // بناء بطاقات مؤشرات الأداء
  Widget _buildPerformanceIndicators(
      double horizontalPadding, double smallSpacing, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مؤشرات الأداء',
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: fontSize + 1,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: smallSpacing),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceCard(
                  title: "الحضور",
                  value: "92%",
                  icon: Icons.people,
                  color: kGreenColor,
                  description: "ممتاز",
                  fontSize: fontSize,
                ),
              ),
              SizedBox(width: horizontalPadding * 0.5),
              Expanded(
                child: _buildPerformanceCard(
                  title: "إنجاز المهام",
                  value: "85%",
                  icon: Icons.assignment_turned_in,
                  color: kMediumPurple,
                  description: "جيد جدًا",
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
          SizedBox(height: smallSpacing),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceCard(
                  title: "معدل الدرجات",
                  value: "78%",
                  icon: Icons.grade,
                  color: kOrangeColor,
                  description: "بحاجة لتحسين",
                  fontSize: fontSize,
                ),
              ),
              SizedBox(width: horizontalPadding * 0.5),
              Expanded(
                child: _buildPerformanceCard(
                  title: "الأنشطة",
                  value: "60%",
                  icon: Icons.stars,
                  color: Colors.red.shade400,
                  description: "ضعيف",
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء بطاقة مؤشر أداء
  Widget _buildPerformanceCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String description,
    required double fontSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: fontSize - 2,
                  color: Colors.grey[600],
                ),
              ),
              Icon(
                icon,
                color: color,
                size: 18,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontSize: fontSize - 4,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء شريط تقدم الفصل الدراسي
  Widget _buildSemesterProgressBar(
      double horizontalPadding, double smallSpacing, double fontSize) {
    // بيانات افتراضية لتقدم الفصل الدراسي
    final int totalDays = 105; // إجمالي أيام الفصل الدراسي
    final int passedDays = 65; // الأيام التي مرت
    final double progressPercentage = passedDays / totalDays; // نسبة التقدم

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kDarkPurple.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تقدم الفصل الدراسي',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progressPercentage * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: 'SYMBIOAR+LT',
                    fontSize: fontSize - 3,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: smallSpacing),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.white.withOpacity(0.3),
            color: Colors.white,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: smallSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'بداية الفصل',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: fontSize - 3,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                'نهاية الفصل',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: fontSize - 3,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: smallSpacing * 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '١٥ مارس',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: fontSize - 3,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '٢٨ يونيو',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: fontSize - 3,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // إضافة قسم المواعيد القادمة
  Widget _buildUpcomingEventsSection(
      double horizontalPadding, double smallSpacing, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المواعيد القادمة',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: fontSize + 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // الانتقال إلى صفحة المواعيد
                  _navController.changeIndex(1);
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontFamily: 'SYMBIOAR+LT',
                    fontSize: fontSize - 2,
                    color: kDarkPurple,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: smallSpacing),

          // قائمة المواعيد
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upcomingEvents.length > 3 ? 3 : _upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = _upcomingEvents[index];
              return Container(
                margin: EdgeInsets.only(bottom: smallSpacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (event['color'] as Color).withOpacity(0.2),
                    child: Icon(
                      event['icon'] as IconData,
                      color: event['color'] as Color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    event['title'] as String,
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: fontSize - 1,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    event['date'] as String,
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: fontSize - 3,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: event['isUrgent'] == true
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'عاجل',
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: fontSize - 4,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    // الانتقال إلى صفحة التفاصيل عند النقر
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // بناء محتوى الصفحة الرئيسية
  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // الحصول على أبعاد الشاشة
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        // حساب المسافات والأحجام النسبية
        final double horizontalPadding =
            screenSize.width * 0.04; // 4% من عرض الشاشة
        final double verticalPadding =
            screenSize.height * 0.02; // 2% من ارتفاع الشاشة
        final double sectionSpacing =
            screenSize.height * 0.022; // زيادة المسافة بين الأقسام
        final double smallSpacing =
            screenSize.height * 0.01; // 1% من ارتفاع الشاشة

        // أحجام الخطوط
        final double normalFontSize =
            isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);
        final double smallFontSize =
            isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _nextLectureController),
            ChangeNotifierProvider.value(value: _statsController),
            ChangeNotifierProvider.value(value: _tasksController),
          ],
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: kDarkPurple,
            strokeWidth: 2.5,
            child: Stack(
              children: [
                // المحتوى الرئيسي
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: verticalPadding),

                      // بطاقة الملف الشخصي
                      _buildProfileCard(
                          horizontalPadding, smallSpacing, normalFontSize),

                      SizedBox(height: sectionSpacing),

                      // المحاضرة القادمة
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Consumer<NextLectureController>(
                          builder: (context, controller, child) {
                            // عرض المحاضرة القادمة فقط إذا لم تكن حالة التحميل وكانت المحاضرة متوفرة
                            if (!controller.isLoading &&
                                controller.nextLectureMap != null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // عنوان قسم المحاضرة القادمة
                                  NextLectureComponents.buildSectionTitle(),

                                  SizedBox(height: smallSpacing),

                                  // استخدام المكون البديل بدون أنيميشن
                                  StaticNextLectureCard(
                                    courseName: controller.nextLectureMap![
                                        NextLectureConstants.courseNameField],
                                    classroom: controller.nextLectureMap![
                                        NextLectureConstants.classroomField],
                                    diffSeconds: controller
                                        .nextLectureMap!['diffSeconds'],
                                  ),

                                  SizedBox(height: sectionSpacing),
                                ],
                              );
                            }

                            // في حالة التحميل أو عدم وجود محاضرة، لن نعرض أي شيء
                            return const SizedBox.shrink();
                          },
                        ),
                      ),

                      // شريط تقدم الفصل الدراسي
                      _buildSemesterProgressBar(
                          horizontalPadding, smallSpacing, normalFontSize),

                      SizedBox(height: sectionSpacing),

                      // قسم مؤشرات الأداء
                      _buildPerformanceIndicators(
                          horizontalPadding, smallSpacing, normalFontSize),

                      SizedBox(height: sectionSpacing),

                      // قسم المواعيد القادمة
                      _buildUpcomingEventsSection(
                          horizontalPadding, smallSpacing, normalFontSize),

                      SizedBox(height: sectionSpacing),

                      // قسم "فئات المهام" - استخدام المكون البديل بدون أنيميشن
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: StaticTaskCategoriesSection(
                          onTaskTap: () => _navController
                              .changeIndex(3), // الانتقال إلى صفحة المهام
                        ),
                      ),

                      // مساحة إضافية في الأسفل للسماح بالسحب للأسفل بشكل أفضل
                      SizedBox(
                          height: screenSize.height *
                              0.12), // 12% من ارتفاع الشاشة لإعطاء مساحة للشريط السفلي
                    ],
                  ),
                ),

                // مؤشر التحديث - لا يحتوي على أنيميشن سنتركه كما هو
                if (_isRefreshing)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      height:
                          screenSize.height * 0.055, // 5.5% من ارتفاع الشاشة
                      decoration: BoxDecoration(
                        color: kDarkPurple.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: isSmallScreen ? 14 : 16,
                              height: isSmallScreen ? 14 : 16,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: screenSize.width * 0.02),
                            Text(
                              "جاري التحديث...",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: smallFontSize,
                                fontFamily: 'SYMBIOAR+LT',
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    // أحجام تتناسب مع حجم الشاشة
    final double loadingTextSize =
        isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
    final double indicatorSize =
        isSmallScreen ? 28.0 : (isMediumScreen ? 32.0 : 36.0);

    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: const CircularProgressIndicator(
                  color: kDarkPurple,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: screenSize.height * 0.025),
              Text(
                "جاري تحميل البيانات...",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: loadingTextSize,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _navController,
      child: Consumer<BottomNavController>(
        builder: (context, controller, _) {
          return WillPopScope(
            onWillPop: () async {
              // إذا كنا في صفحة غير الرئيسية، انتقل إلى الرئيسية بدلاً من الخروج
              return !controller.handleBackPress();
            },
            child: Scaffold(
              backgroundColor: kBackgroundColor, // استخدام متغير اللون الثابت
              body: SafeArea(
                // إضافة هامش سفلي إضافي للمحتوى ليتناسب مع شريط التنقل
                bottom: false,
                child: PageStorage(
                  bucket: _bucket,
                  child: IndexedStack(
                    key: ValueKey<int>(controller.selectedIndex),
                    index: controller.selectedIndex,
                    children: _pages,
                  ),
                ),
              ),
              // إضافة شريط التنقل السفلي بدون هوامش إضافية
              bottomNavigationBar: ColorfulNavBar(
                selectedIndex: controller.selectedIndex,
                onItemTapped: (index) => controller.changeIndex(index),
              ),
            ),
          );
        },
      ),
    );
  }

  // دالة لتحديث البيانات عند السحب للأسفل
  Future<void> _refreshData() async {
    if (_isRefreshing) return; // منع التحديث المتزامن المتعدد

    setState(() {
      _isRefreshing = true;
    });

    debugPrint('بدء تحديث البيانات...');

    try {
      // تحديث البيانات بشكل متوازي
      await Future.wait([
        _nextLectureController.refresh(),
        _statsController.refresh(),
        _tasksController.refresh(),
        _headerController.initialize(),
      ]);

      // إعلام واجهة المستخدم بالتحديث
      if (mounted) {
        debugPrint('تم تحديث جميع البيانات');
      }
    } catch (e) {
      debugPrint('حدث خطأ أثناء التحديث: $e');
      // يمكن إضافة عرض رسالة خطأ للمستخدم هنا
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nextLectureController.dispose();
    _statsController.dispose();
    _tasksController.dispose();
    super.dispose();
  }
}
