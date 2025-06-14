import 'package:flutter/material.dart';
import '../controllers/task_categories_controller.dart';
import '../controllers/tasks_controller.dart';
import 'package:fateen/models/task.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

class TaskCategoriesWidget extends StatefulWidget {
  final TaskCategoriesController controller;
  final VoidCallback? onTaskTap;

  const TaskCategoriesWidget({
    Key? key,
    required this.controller,
    this.onTaskTap,
  }) : super(key: key);

  @override
  State<TaskCategoriesWidget> createState() => _TaskCategoriesWidgetState();
}

class _TaskCategoriesWidgetState extends State<TaskCategoriesWidget> {
  // المتحكم الخاص بالمهام
  final TasksController _tasksController = TasksController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasksData();
  }

  Future<void> _loadTasksData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // تهيئة متحكم المهام
      await _tasksController.initialize();

      // إضافة مستمع لتحديث واجهة المستخدم عند تغيير المهام
      _tasksController.addListener(() {
        if (mounted) {
          setState(() {
            print('تم تحديث حالة TasksController - تحديث واجهة المستخدم');
            // تحديث فئات المهام عندما تتغير المهام
            widget.controller.refresh();
          });
        }
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('خطأ في تحميل بيانات المهام: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _tasksController.refresh(),
        widget.controller.refresh(),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('خطأ في تحديث البيانات: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tasksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام أبعاد التطبيق المتجاوبة
    final double fontSize = AppDimensions.getBodyFontSize(context);

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: context.colorPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Text(
              "فئات المهام",
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontSize: fontSize + 1,
                fontWeight: FontWeight.bold,
                color: context.colorTextPrimary,
              ),
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),

            // بطاقة فئات المهام الموحدة
            _buildCategoriesCard(fontSize),

            SizedBox(
                height: AppDimensions.getSpacing(context,
                    size: SpacingSize.medium)),

            // عنوان قسم المهام العاجلة
            Row(
              children: [
                Expanded(
                  child: Text(
                    "مهام تحتاج اهتمامك",
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: fontSize + 1,
                      fontWeight: FontWeight.bold,
                      color: context.colorTextPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await _tasksController.refresh();
                    setState(() {
                      _isLoading = false;
                    });
                    // عرض نافذة منبثقة تظهر حالة المهام
                    _showTasksDebugInfo(context);
                  },
                  child: Text(
                    'تحديث',
                    style: TextStyle(
                      color: context.colorPrimary,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),

            // عرض المهام المتأخرة ومهام اليوم
            _buildTasksSection(),
          ],
        ),
      ),
    );
  }

  // بناء بطاقة فئات المهام
  Widget _buildCategoriesCard(double fontSize) {
    if (_isLoading || widget.controller.isLoading) {
      return _buildLoadingState();
    }

    if (widget.controller.errorMessage != null) {
      return _buildErrorState(widget.controller.errorMessage!);
    }

    final categories = widget.controller.categories;
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: context.colorBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((category) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                // استخدام الدالة المخصصة إذا تم تمريرها
                if (widget.onTaskTap != null) {
                  widget.onTaskTap!();
                } else {
                  // استخدام دالة المتحكم
                  widget.controller.handleCategoryTap(category.id);
                }
              },
              child: Column(
                children: [
                  Container(
                    width: AppDimensions.getIconSize(context,
                        size: IconSize.medium, small: false),
                    height: AppDimensions.getIconSize(context,
                        size: IconSize.medium, small: false),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: AppDimensions.getIconSize(context,
                          size: IconSize.small, small: false),
                    ),
                  ),
                  SizedBox(
                      height: AppDimensions.getSpacing(context,
                          size: SpacingSize.small)),
                  Text(
                    '${category.count}',
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: fontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: context.colorTextPrimary,
                    ),
                  ),
                  SizedBox(
                      height: AppDimensions.getSpacing(context,
                              size: SpacingSize.small) /
                          2),
                  Text(
                    category.title,
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: fontSize - 2,
                      color: context.colorTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // بناء قسم المهام - تعديل طريقة العرض
  Widget _buildTasksSection() {
    if (_isLoading || _tasksController.isLoading) {
      return _buildTasksLoadingState();
    }

    if (_tasksController.hasError) {
      return _buildTasksErrorState(_tasksController.errorMessage);
    }

    // المهام
    final hasTodayTask = _tasksController.todayTask != null;
    final hasOverdueTask = _tasksController.overdueTask != null;

    debugPrint(
        "حالة المهام في واجهة المستخدم - مهمة اليوم: $hasTodayTask، مهمة متأخرة: $hasOverdueTask");

    if (!hasTodayTask && !hasOverdueTask) {
      return _buildNoTasksState();
    }

    // بطاقة موحدة للمهام
    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: context.colorBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // المهام المتأخرة (أعلى أولوية)
            if (hasOverdueTask) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: context.colorError,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(
                          width: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2),
                      Text(
                        "مهمة متأخرة",
                        style: TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                          fontSize: AppDimensions.getLabelFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: context.colorError,
                        ),
                      ),
                      const Spacer(),
                      // زر إكمال المهمة
                      IconButton(
                        icon: Icon(
                          Icons.check_circle_outline,
                          color: context.colorSuccess,
                        ),
                        onPressed: () async {
                          try {
                            // إظهار مؤشر تحميل
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('جاري إكمال المهمة...'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            await _tasksController
                                .completeTask(_tasksController.overdueTask!.id);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('تم إكمال المهمة بنجاح'),
                                  backgroundColor: context.colorSuccess,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في إكمال المهمة: $e'),
                                  backgroundColor: context.colorError,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                      height: AppDimensions.getSpacing(context,
                          size: SpacingSize.small)),

                  // بطاقة المهمة
                  GestureDetector(
                    onTap: widget.onTaskTap,
                    child: Container(
                      padding: EdgeInsets.all(AppDimensions.getSpacing(context,
                          size: SpacingSize.medium)),
                      decoration: BoxDecoration(
                        color: context.colorSurface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                        border: Border.all(
                          color: context.colorError.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tasksController.overdueTask!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  AppDimensions.getSubtitleFontSize(context),
                              color: context.colorTextPrimary,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          SizedBox(
                              height: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small)),
                          Text(
                            _tasksController.overdueTask!.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppDimensions.getBodyFontSize(context),
                              color: context.colorTextSecondary,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          SizedBox(
                              height: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small)),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: AppDimensions.getIconSize(context,
                                    size: IconSize.small, small: true),
                                color: context.colorError,
                              ),
                              SizedBox(
                                  width: AppDimensions.getSpacing(context,
                                          size: SpacingSize.small) /
                                      2),
                              Text(
                                _tasksController.overdueTask!.dueDateFormatted,
                                style: TextStyle(
                                  color: context.colorError,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      AppDimensions.getLabelFontSize(context),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // فاصل بين المهام إذا وجدت كلاهما
            if (hasOverdueTask && hasTodayTask)
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.getSpacing(context,
                        size: SpacingSize.small)),
                child: Divider(height: 1, color: context.colorDivider),
              ),

            // مهام اليوم
            if (hasTodayTask) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: context.colorPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(
                          width: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2),
                      Text(
                        "مهمة اليوم",
                        style: TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                          fontSize: AppDimensions.getLabelFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: context.colorPrimary,
                        ),
                      ),
                      const Spacer(),
                      // زر إكمال المهمة
                      IconButton(
                        icon: Icon(
                          Icons.check_circle_outline,
                          color: context.colorSuccess,
                        ),
                        onPressed: () async {
                          try {
                            // إظهار مؤشر تحميل
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('جاري إكمال المهمة...'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            await _tasksController
                                .completeTask(_tasksController.todayTask!.id);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('تم إكمال المهمة بنجاح'),
                                  backgroundColor: context.colorSuccess,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في إكمال المهمة: $e'),
                                  backgroundColor: context.colorError,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                      height: AppDimensions.getSpacing(context,
                          size: SpacingSize.small)),

                  // بطاقة المهمة
                  GestureDetector(
                    onTap: widget.onTaskTap,
                    child: Container(
                      padding: EdgeInsets.all(AppDimensions.getSpacing(context,
                          size: SpacingSize.medium)),
                      decoration: BoxDecoration(
                        color: context.colorSurface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                        border: Border.all(
                          color: context.colorPrimary.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tasksController.todayTask!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  AppDimensions.getSubtitleFontSize(context),
                              color: context.colorTextPrimary,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          SizedBox(
                              height: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small)),
                          Text(
                            _tasksController.todayTask!.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppDimensions.getBodyFontSize(context),
                              color: context.colorTextSecondary,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          SizedBox(
                              height: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small)),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: AppDimensions.getIconSize(context,
                                    size: IconSize.small, small: true),
                                color: context.colorPrimary,
                              ),
                              SizedBox(
                                  width: AppDimensions.getSpacing(context,
                                          size: SpacingSize.small) /
                                      2),
                              Text(
                                _tasksController.todayTask!.dueDateFormatted,
                                style: TextStyle(
                                  color: context.colorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      AppDimensions.getLabelFontSize(context),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // حالة التحميل
  Widget _buildLoadingState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        border: Border.all(
          color: context.colorBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: context.colorPrimary,
        ),
      ),
    );
  }

  // حالة تحميل المهام
  Widget _buildTasksLoadingState() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        border: Border.all(
          color: context.colorBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: context.colorPrimary,
        ),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState(String errorMessage) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      decoration: BoxDecoration(
        color: context.colorErrorLight,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
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
                size: AppDimensions.getIconSize(context,
                    size: IconSize.small, small: false),
              ),
              SizedBox(
                  width: AppDimensions.getSpacing(context,
                      size: SpacingSize.small)),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorError,
                    fontFamily: 'SYMBIOAR+LT',
                    fontSize: AppDimensions.getSubtitleFontSize(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          Text(
            errorMessage,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: AppDimensions.getBodyFontSize(context),
              color: context.colorTextPrimary,
            ),
          ),
          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          TextButton(
            onPressed: () => widget.controller.refresh(),
            style: TextButton.styleFrom(
              foregroundColor: context.colorError,
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // حالة خطأ المهام
  Widget _buildTasksErrorState(String errorMessage) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      decoration: BoxDecoration(
        color: context.colorErrorLight,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
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
                size: AppDimensions.getIconSize(context,
                    size: IconSize.small, small: false),
              ),
              SizedBox(
                  width: AppDimensions.getSpacing(context,
                      size: SpacingSize.small)),
              Expanded(
                child: Text(
                  'حدث خطأ في تحميل المهام',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorError,
                    fontFamily: 'SYMBIOAR+LT',
                    fontSize: AppDimensions.getSubtitleFontSize(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          Text(
            errorMessage,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: AppDimensions.getBodyFontSize(context),
              color: context.colorTextPrimary,
            ),
          ),
          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          TextButton(
            onPressed: () async {
              await _tasksController.refresh();
              setState(() {});
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colorError,
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // حالة عدم وجود فئات
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      decoration: BoxDecoration(
        color: context.colorSurfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        border: Border.all(color: context.colorBorder),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.task_alt,
              color: context.colorTextHint,
              size: AppDimensions.getIconSize(context,
                  size: IconSize.medium, small: false),
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            Text(
              'لا توجد فئات مهام',
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                color: context.colorTextSecondary,
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.getBodyFontSize(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // حالة عدم وجود مهام
  Widget _buildNoTasksState() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: context.colorBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: context.colorSuccess,
              size: AppDimensions.getIconSize(context,
                  size: IconSize.medium, small: false),
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            Text(
              'لا توجد مهام تحتاج اهتمامك حالياً',
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                color: context.colorTextSecondary,
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.getBodyFontSize(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // أضف هذه الدالة الجديدة للتشخيص
  void _showTasksDebugInfo(BuildContext context) {
    final hasTodayTask = _tasksController.todayTask != null;
    final hasOverdueTask = _tasksController.overdueTask != null;
    final stats = _tasksController.tasksStats;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'معلومات التشخيص',
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            color: context.colorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مهمة اليوم: ${hasTodayTask ? "موجودة" : "غير موجودة"}',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                ),
              ),
              if (hasTodayTask)
                Text(
                  'اسم مهمة اليوم: ${_tasksController.todayTask!.name}',
                  style: TextStyle(
                    fontFamily: 'SYMBIOAR+LT',
                    fontSize: AppDimensions.getBodyFontSize(context),
                  ),
                ),
              SizedBox(
                  height: AppDimensions.getSpacing(context,
                      size: SpacingSize.small)),
              Text(
                'مهمة متأخرة: ${hasOverdueTask ? "موجودة" : "غير موجودة"}',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                ),
              ),
              if (hasOverdueTask)
                Text(
                  'اسم المهمة المتأخرة: ${_tasksController.overdueTask!.name}',
                  style: TextStyle(
                    fontFamily: 'SYMBIOAR+LT',
                    fontSize: AppDimensions.getBodyFontSize(context),
                  ),
                ),
              SizedBox(
                  height: AppDimensions.getSpacing(context,
                      size: SpacingSize.medium)),
              Text(
                'إحصائيات المهام:',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'إجمالي المهام: ${stats['total']}',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                ),
              ),
              Text(
                'المهام المكتملة: ${stats['completed']}',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                ),
              ),
              Text(
                'المهام المتأخرة: ${stats['overdue']}',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                ),
              ),
              Text(
                'مهام اليوم: ${stats['today']}',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                ),
              ),
              Text(
                'المهام القادمة: ${stats['upcoming']}',
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إغلاق',
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                color: context.colorPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  get colorErrorLight => null;
}
