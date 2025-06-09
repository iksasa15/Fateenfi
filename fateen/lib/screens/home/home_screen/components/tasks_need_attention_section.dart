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
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360; // للأجهزة الصغيرة

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        _buildSectionTitle(isSmallScreen),

        // محتوى القسم - مهام تحتاج اهتمام
        _buildSectionContent(screenSize),
      ],
    );
  }

  // بناء عنوان القسم
  Widget _buildSectionTitle(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).size.height * 0.01, // 1% من ارتفاع الشاشة
        top: MediaQuery.of(context).size.height * 0.02, // 2% من ارتفاع الشاشة
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // العنوان مع خط تزييني تحته
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TasksConstants.tasksNeedAttentionTitle,
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? 16.0
                      : 18.0, // تعديل الحجم للشاشات الصغيرة
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4338CA),
                  letterSpacing: 0.3,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: MediaQuery.of(context).size.width *
                    0.07, // 7% من عرض الشاشة
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
  Widget _buildSectionContent(Size screenSize) {
    // حالة التحميل
    if (_controller.isLoading) {
      return _buildLoadingState(screenSize);
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
      return _buildEmptyState(screenSize);
    }

    // تباعد بين البطاقات يعتمد على حجم الشاشة
    final cardSpacing = screenSize.height * 0.02; // 2% من ارتفاع الشاشة

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
          SizedBox(height: cardSpacing),
        ],

        // مهمة متأخرة
        if (hasOverdueTask) ...[
          TaskCard(
            task: _controller.overdueTask!,
            isOverdue: true,
            animation: _animation,
            onTap: widget.onTaskTap,
          ),
          SizedBox(height: cardSpacing),
        ],
      ],
    );
  }

  // حالة التحميل
  Widget _buildLoadingState(Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.12, // 12% من ارتفاع الشاشة
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.04), // 4% من عرض الشاشة
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
              SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.02), // 2% من عرض الشاشة
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
          SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.01), // 1% من ارتفاع الشاشة
          Text(
            _controller.errorMessage,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.015), // 1.5% من ارتفاع الشاشة
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
  Widget _buildEmptyState(Size screenSize) {
    // تعديل أحجام العناصر حسب حجم الشاشة
    final bool isSmallScreen = screenSize.width < 360;
    final double iconSize = isSmallScreen
        ? screenSize.width * 0.14 // للشاشات الصغيرة
        : screenSize.width * 0.16; // للشاشات العادية

    return Padding(
      padding: EdgeInsets.only(
          bottom: screenSize.height * 0.02), // 2% من ارتفاع الشاشة
      child: Container(
        padding: EdgeInsets.all(screenSize.width * 0.05), // 5% من عرض الشاشة
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
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  TasksConstants.emptyTasksIcon,
                  color: Colors.grey[400],
                  size: iconSize * 0.5, // 50% من حجم الحاوية
                ),
              ),
              SizedBox(height: screenSize.height * 0.02), // 2% من ارتفاع الشاشة
              Text(
                TasksConstants.noTasksTitle,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16.0 : 18.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4338CA),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              SizedBox(height: screenSize.height * 0.01), // 1% من ارتفاع الشاشة
              Text(
                TasksConstants.noTasksMessage,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12.0 : 14.0,
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
