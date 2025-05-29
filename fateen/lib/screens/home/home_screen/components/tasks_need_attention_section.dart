import 'package:flutter/material.dart';
import '../controllers/tasks_controller.dart';
import '../constants/tasks_constants.dart';
import '../components/task_card.dart';

/// قسم "مهام تحتاج اهتمامك" في الصفحة الرئيسية
class TasksNeedAttentionSection extends StatefulWidget {
  final Function() onTaskTap; // دالة تنفذ عند الضغط على مهمة
  final Animation<double> animation;

  const TasksNeedAttentionSection({
    Key? key,
    required this.onTaskTap,
    required this.animation,
  }) : super(key: key);

  @override
  State<TasksNeedAttentionSection> createState() =>
      _TasksNeedAttentionSectionState();
}

class _TasksNeedAttentionSectionState extends State<TasksNeedAttentionSection>
    with SingleTickerProviderStateMixin {
  late TasksController _controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // تهيئة وحدة التحكم
    _controller = TasksController();

    // إعداد الأنيميشن
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    // بدء الأنيميشن
    _animationController.forward();

    // تحميل البيانات
    _loadData();
  }

  // تحميل البيانات
  Future<void> _loadData() async {
    try {
      if (_isFirstLoad) {
        // التهيئة الكاملة في المرة الأولى فقط
        debugPrint('_loadData: التهيئة الأولى للبيانات');
        await _controller.initialize();
        _isFirstLoad = false;
      } else {
        // تحديث البيانات فقط في المرات اللاحقة
        debugPrint('_loadData: تحديث البيانات الموجودة');
        await _controller.refresh();
      }

      // طباعة حالة المهام بعد التحديث
      debugPrint('_loadData: حالة المهام بعد التحديث - ' +
          'مهمة اليوم: ${_controller.todayTask != null ? _controller.todayTask!.name : "غير موجودة"}, ' +
          'مهمة متأخرة: ${_controller.overdueTask != null ? _controller.overdueTask!.name : "غير موجودة"}');

      // نضمن تحديث واجهة المستخدم
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('_loadData: خطأ في تحميل البيانات: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء تحميل البيانات: $e',
              style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        _buildSectionTitle(),

        // محتوى القسم - مهام تحتاج اهتمام
        _buildSectionContent(),
      ],
    );
  }

  // بناء عنوان القسم
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // العنوان مع خط تزييني تحته
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                TasksConstants.tasksNeedAttentionTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4338CA), // استخدام لون مطابق للأقسام الأخرى
                  letterSpacing: 0.3,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 28,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء محتوى القسم
  Widget _buildSectionContent() {
    // حالة التحميل
    if (_controller.isLoading) {
      return _buildLoadingState();
    }

    // حالة الخطأ
    if (_controller.hasError) {
      return _buildErrorState();
    }

    // لنتحقق من وجود مهام
    final hasTodayTask = _controller.todayTask != null;
    final hasOverdueTask = _controller.overdueTask != null;

    debugPrint(
        'في وقت البناء: هل توجد مهمة اليوم؟ $hasTodayTask، هل توجد مهمة متأخرة؟ $hasOverdueTask');

    if (!hasTodayTask && !hasOverdueTask) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // مهمة اليوم
        if (hasTodayTask) ...[
          TaskCard(
            task: _controller.todayTask!,
            isOverdue: false,
            animation: _animation,
            onTap: widget.onTaskTap,
          ),
          const SizedBox(height: 16),
        ],

        // مهمة متأخرة
        if (hasOverdueTask) ...[
          TaskCard(
            task: _controller.overdueTask!,
            isOverdue: true,
            animation: _animation,
            onTap: widget.onTaskTap,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // حالة التحميل
  Widget _buildLoadingState() {
    return const SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _controller.errorMessage,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                TasksConstants.retryButtonText,
                style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // حالة فارغة
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  TasksConstants.emptyTasksIcon,
                  color: Colors.grey[400],
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                TasksConstants.noTasksTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4338CA),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                TasksConstants.noTasksMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
