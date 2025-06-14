import 'package:flutter/material.dart';
import '../controllers/tasks_controller.dart';
import '../constants/tasks_constants.dart';
import '../components/task_card.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

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
            backgroundColor: context.colorError,
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
      padding: EdgeInsets.only(
        bottom: AppDimensions.getSpacing(context, size: SpacingSize.small),
        top: AppDimensions.getSpacing(context, size: SpacingSize.medium),
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

    // تباعد بين البطاقات
    final cardSpacing =
        AppDimensions.getSpacing(context, size: SpacingSize.medium);

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
  Widget _buildLoadingState() {
    return SizedBox(
      height: AppDimensions.cardHeightMedium, // استخدم قيمة ثابتة أو طريقة موجودة
      child: Center(
        child: CircularProgressIndicator(
          color: context.colorPrimaryLight,
        ),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      decoration: BoxDecoration(
        color: context.colorError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        border: Border.all(color: context.colorError.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: context.colorError,
                size: AppDimensions.getIconSize(context, size: IconSize.small, small: true),
              ),
              SizedBox(
                  width: AppDimensions.getSpacing(context,
                      size: SpacingSize.small)),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        AppDimensions.getBodyFontSize(context),
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
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          Text(
            _controller.errorMessage,
            style: TextStyle(
              fontSize: AppDimensions.getBodyFontSize(context),
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
              onPressed: _loadData,
              icon: Icon(
                Icons.refresh,
                size: AppDimensions.getIconSize(context,
                    size: IconSize.small, small: true),
              ),
              label: Text(
                TasksConstants.retryButtonText,
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: context.colorError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // حالة فارغة
  Widget _buildEmptyState() {
    final double iconSize =
        AppDimensions.getIconSize(context, size: IconSize.large, small: false);

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppDimensions.getSpacing(context, size: SpacingSize.medium),
      ),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
        decoration: BoxDecoration(
          color: context.colorSurfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          border: Border.all(color: context.colorBorder),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  TasksConstants.emptyTasksIcon,
                  color: context.colorTextHint,
                  size: iconSize * 0.5,
                ),
              ),
              SizedBox(
                  height: AppDimensions.getSpacing(context,
                      size: SpacingSize.medium)),
              Text(
                TasksConstants.noTasksTitle,
                style: TextStyle(
                  fontSize: AppDimensions.getSubtitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: context.colorPrimaryDark,
                  fontFamily: 'SYMBIOAR+LT',
                  height: 1.2,
                ),
              ),
              SizedBox(
                  height: AppDimensions.getSpacing(context,
                      size: SpacingSize.small)),
              Text(
                TasksConstants.noTasksMessage,
                style: TextStyle(
                  fontSize: AppDimensions.getBodyFontSize(context),
                  color: context.colorTextSecondary,
                  fontFamily: 'SYMBIOAR+LT',
                  height: 1.2,
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
