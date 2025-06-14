import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/tasks_controller.dart';
import '../constants/tasks_constants.dart';
import 'package:fateen/models/task.dart';
import 'package:fateen/models/course.dart';
import 'package:fateen/screens/tasks/services/tasks_firebase_service.dart';
import 'task_card.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        _buildSectionTitle(' المهام'),

        // حالة التحميل
        if (_isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
              child:
                  CircularProgressIndicator(color: context.colorPrimaryLight),
            ),
          )

        // حالة الخطأ
        else if (_errorMessage != null)
          _buildErrorMessage(_errorMessage!)

        // عرض البطاقات والمهام
        else
          Column(
            children: [
              // بطاقة الإحصائيات
              _buildTasksStatsCard(),

              // قائمة المهام
              if (_overdueTasks.isNotEmpty)
                _buildTasksSection(
                  "المهام المتأخرة",
                  _overdueTasks,
                  context.colorError,
                  Icons.warning_rounded,
                ),

              if (_todayTasks.isNotEmpty)
                _buildTasksSection(
                  "مهام اليوم",
                  _todayTasks,
                  context.colorPrimaryLight,
                  Icons.today_rounded,
                ),

              if (_upcomingTasks.isNotEmpty)
                _buildTasksSection(
                  "المهام القادمة",
                  _upcomingTasks,
                  context.colorSuccess,
                  Icons.upcoming_rounded,
                ),

              // حالة عدم وجود مهام
              if (_overdueTasks.isEmpty &&
                  _todayTasks.isEmpty &&
                  _upcomingTasks.isEmpty)
                _buildEmptyState(),
            ],
          ),
      ],
    );
  }

  // بناء عنوان القسم
  Widget _buildSectionTitle(String title) {
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
                  fontSize: AppDimensions.getSubtitleFontSize(context),
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
                width:
                    AppDimensions.getSpacing(context, size: SpacingSize.medium),
                height: 2.5,
                decoration: BoxDecoration(
                  color: context.colorPrimaryLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius / 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء بطاقة إحصائيات المهام
  Widget _buildTasksStatsCard() {
    // حالة عدم وجود مهام
    if (_overdueTasks.isEmpty &&
        _todayTasks.isEmpty &&
        _upcomingTasks.isEmpty) {
      return Container(); // لا نعرض البطاقة إذا لم تكن هناك مهام
    }

    // حساب العدد الإجمالي للمهام
    final int totalTasks =
        _overdueTasks.length + _todayTasks.length + _upcomingTasks.length;

    // حساب أحجام العناصر
    final double iconSize =
        AppDimensions.getIconSize(context, size: IconSize.small, small: false);
    final double fontSize = AppDimensions.getBodyFontSize(context);
    final double statItemSize =
        AppDimensions.getIconSize(context, size: IconSize.large, small: true) *
            0.8;

    return FadeTransition(
      opacity: widget.animation,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: AppDimensions.getSpacing(context, size: SpacingSize.small),
        ),
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
                    color: context.colorError,
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
                    color: context.colorPrimaryLight,
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
                    color: context.colorSuccess,
                    size: statItemSize,
                    fontSize: fontSize,
                    iconSize: iconSize,
                  ),
              ],
            ),

            // خط فاصل
            Padding(
              padding: EdgeInsets.symmetric(
                vertical:
                    AppDimensions.getSpacing(context, size: SpacingSize.small),
              ),
              child: Divider(
                height: 1,
                thickness: 1,
                color: context.colorDivider,
              ),
            ),

            // الرسالة التحفيزية
            Row(
              children: [
                // أيقونة الوقت
                Icon(
                  Icons.schedule,
                  color: context.colorPrimaryLight,
                  size: iconSize,
                ),
                SizedBox(
                    width: AppDimensions.getSpacing(context,
                        size: SpacingSize.small)),

                // رسالة تحفيزية
                Expanded(
                  child: Text(
                    "لديك $totalTasks مهام تنتظر إنجازك!",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: context.colorTextSecondary,
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
                      horizontal: AppDimensions.getSpacing(context,
                          size: SpacingSize.small),
                      vertical: AppDimensions.getSpacing(context,
                              size: SpacingSize.small) /
                          2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'عرض الكل',
                        style: TextStyle(
                          color: context.colorPrimaryLight,
                          fontSize: fontSize - 1,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      SizedBox(
                          width: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: iconSize - 8,
                        color: context.colorPrimaryLight,
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
            borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
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

        SizedBox(
            height:
                AppDimensions.getSpacing(context, size: SpacingSize.small) / 2),

        // عنوان الإحصائية
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize - 1,
            fontWeight: FontWeight.w500,
            color: context.colorTextSecondary,
            fontFamily: 'SYMBIOAR+LT',
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // بناء قسم المهام (عنوان + قائمة بالمهام)
  Widget _buildTasksSection(
    String title,
    List<Task> tasks,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppDimensions.getSpacing(context, size: SpacingSize.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: EdgeInsets.only(
              bottom:
                  AppDimensions.getSpacing(context, size: SpacingSize.small),
              right:
                  AppDimensions.getSpacing(context, size: SpacingSize.small) /
                      2,
              left: AppDimensions.getSpacing(context, size: SpacingSize.small) /
                  2,
            ),
            child: Row(
              children: [
                Container(
                  width: AppDimensions.getIconSize(context,
                      size: IconSize.small, small: false),
                  height: AppDimensions.getIconSize(context,
                      size: IconSize.small, small: false),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius / 2),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: AppDimensions.getIconSize(context,
                          size: IconSize.small, small: true),
                    ),
                  ),
                ),
                SizedBox(
                    width: AppDimensions.getSpacing(context,
                        size: SpacingSize.small)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppDimensions.getBodyFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                ),
                SizedBox(
                    width: AppDimensions.getSpacing(context,
                            size: SpacingSize.small) /
                        2),
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
                    color: color.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius),
                  ),
                  child: Text(
                    "${tasks.length}",
                    style: TextStyle(
                      fontSize:
                          AppDimensions.getLabelFontSize(context, small: true),
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
                  bottom: AppDimensions.getSpacing(context,
                      size: SpacingSize.small),
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
                AppDimensions.getSpacing(context, size: SpacingSize.small),
                0,
                AppDimensions.getSpacing(context, size: SpacingSize.small),
                AppDimensions.getSpacing(context, size: SpacingSize.small),
              ),
              child: InkWell(
                onTap: widget.onTaskTap,
                borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.getSpacing(context,
                        size: SpacingSize.small),
                    horizontal: AppDimensions.getSpacing(context,
                        size: SpacingSize.small),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius),
                    border: Border.all(color: color.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'عرض المزيد',
                        style: TextStyle(
                          fontSize: AppDimensions.getLabelFontSize(context),
                          color: color.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SYMBIOAR+LT',
                          height: 1.2,
                        ),
                      ),
                      SizedBox(
                          width: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2),
                      Icon(
                        Icons.arrow_forward,
                        size: AppDimensions.getIconSize(context,
                            size: IconSize.small, small: true),
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
  Widget _buildErrorMessage(String message) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppDimensions.getSpacing(context, size: SpacingSize.small),
      ),
      padding: EdgeInsets.all(
          AppDimensions.getSpacing(context, size: SpacingSize.small)),
      decoration: BoxDecoration(
        color: context.colorErrorLight,
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        border: Border.all(color: context.colorError.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline,
                  color: context.colorError,
                  size: AppDimensions.getIconSize(context,
                      size: IconSize.small, small: false)),
              SizedBox(
                  width: AppDimensions.getSpacing(context,
                          size: SpacingSize.small) /
                      2),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.getBodyFontSize(context),
                    color: context.colorError,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small) /
                      2),
          Text(
            message,
            style: TextStyle(
              fontSize: AppDimensions.getLabelFontSize(context),
              fontFamily: 'SYMBIOAR+LT',
              color: context.colorTextPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loadTasks,
              icon: Icon(Icons.refresh,
                  size: AppDimensions.getIconSize(context,
                      size: IconSize.small, small: true)),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getLabelFontSize(context),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: context.colorError,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.getSpacing(context,
                      size: SpacingSize.small),
                  vertical: AppDimensions.getSpacing(context,
                          size: SpacingSize.small) /
                      2,
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
  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppDimensions.getSpacing(context, size: SpacingSize.medium),
      ),
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        border: Border.all(color: context.colorBorder),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
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
              width: AppDimensions.getIconSize(context,
                  size: IconSize.large, small: false),
              height: AppDimensions.getIconSize(context,
                  size: IconSize.large, small: false),
              decoration: BoxDecoration(
                color: context.colorPrimaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                color: context.colorPrimaryLight,
                size: AppDimensions.getIconSize(context,
                        size: IconSize.large, small: false) *
                    0.5,
              ),
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            Text(
              'لا توجد مهام حاليًا',
              style: TextStyle(
                fontSize: AppDimensions.getSubtitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: 'SYMBIOAR+LT',
                height: 1.2,
              ),
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small) /
                        2),
            Text(
              'عند إضافة مهام جديدة، ستظهر هنا',
              style: TextStyle(
                fontSize: AppDimensions.getBodyFontSize(context),
                color: context.colorTextSecondary,
                fontFamily: 'SYMBIOAR+LT',
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            // زر إضافة مهمة جديدة
            ElevatedButton.icon(
              onPressed: widget.onTaskTap,
              icon: Icon(Icons.add_circle_outline,
                  size: AppDimensions.getIconSize(context,
                      size: IconSize.small, small: false)),
              label: Text(
                'إضافة مهمة جديدة',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getButtonFontSize(context),
                  height: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorPrimaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.getSpacing(context,
                      size: SpacingSize.small),
                  vertical: AppDimensions.getSpacing(context,
                          size: SpacingSize.small) /
                      2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  get colorErrorLight => null;
}
