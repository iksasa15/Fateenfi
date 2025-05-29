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

  // الحصول على جميع المهام (بدون تغيير)
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

  // تصنيف المهام المستلمة إلى فئات (بدون تغيير)
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
        _buildSectionTitle('إحصائيات المهام'),

        // حالة التحميل
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: kMediumPurple),
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
                  kRed,
                  Icons.warning_rounded,
                ),

              if (_todayTasks.isNotEmpty)
                _buildTasksSection(
                  "مهام اليوم",
                  _todayTasks,
                  kMediumPurple, // تم تغيير اللون ليطابق الإحصائيات
                  Icons.today_rounded,
                ),

              if (_upcomingTasks.isNotEmpty)
                _buildTasksSection(
                  "المهام القادمة",
                  _upcomingTasks,
                  kGreen,
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
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDarkPurple,
                  letterSpacing: 0.3,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 24,
                height: 2,
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

    return FadeTransition(
      opacity: widget.animation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
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
                  ),

                // مهام اليوم
                if (_todayTasks.isNotEmpty)
                  _buildStatItem(
                    title: 'اليوم',
                    count: _todayTasks.length.toString(),
                    icon: Icons.today_rounded,
                    color:
                        kMediumPurple, // تغيير لون مهام اليوم ليطابق الإحصائيات
                  ),

                // المهام القادمة
                if (_upcomingTasks.isNotEmpty)
                  _buildStatItem(
                    title: 'القادمة',
                    count: _upcomingTasks.length.toString(),
                    icon: Icons.upcoming_rounded,
                    color: kGreen,
                  ),
              ],
            ),

            // خط فاصل
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
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
                const Icon(
                  Icons.schedule,
                  color: kMediumPurple,
                  size: 18,
                ),
                const SizedBox(width: 8),
                // رسالة تحفيزية
                Expanded(
                  child: Text(
                    "لديك $totalTasks مهام تنتظر إنجازك!",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
                // زر عرض الكل
                TextButton(
                  onPressed: widget.onTaskTap,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'عرض الكل',
                        style: TextStyle(
                          color: kMediumPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
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
  }) {
    return Column(
      children: [
        // أيقونة الإحصائية في مربع بزوايا ناعمة
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(12), // زوايا ناعمة بدلاً من الشكل الدائري
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
                const SizedBox(height: 3),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'SYMBIOAR+LT',
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
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  // بناء قسم المهام (عنوان + قائمة بالمهام)
  Widget _buildTasksSection(
      String title, List<Task> tasks, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 14,
                    ),
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
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${tasks.length}",
                    style: TextStyle(
                      fontSize: 10,
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
                padding: const EdgeInsets.only(bottom: 8),
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
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: InkWell(
                onTap: widget.onTaskTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                          fontSize: 12,
                          color: color.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
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
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
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
              const Icon(Icons.error_outline, color: Colors.red, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.red[800],
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'SYMBIOAR+LT', fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[800],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: kMediumPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                color: kMediumPurple,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'لا توجد مهام حاليًا',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'عند إضافة مهام جديدة، ستظهر هنا',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // زر إضافة مهمة جديدة
            ElevatedButton.icon(
              onPressed: widget.onTaskTap,
              icon: const Icon(Icons.add_circle_outline, size: 14),
              label: const Text(
                'إضافة مهمة جديدة',
                style: TextStyle(fontFamily: 'SYMBIOAR+LT', fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kMediumPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
