import 'package:flutter/material.dart';
import '../controllers/task_categories_controller.dart';
import '../constants/task_categories_constants.dart';
import '../constants/tasks_constants.dart';
import '../controllers/tasks_controller.dart';
import 'package:fateen/models/task.dart';

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
    // الحصول على أبعاد الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;
    final double fontSize =
        isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF4338CA),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Text(
              TaskCategoriesConstants.sectionTitle,
              style: TextStyle(
                fontFamily: TaskCategoriesConstants.fontFamily,
                fontSize: fontSize + 1,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // بطاقة فئات المهام الموحدة
            _buildCategoriesCard(fontSize),

            const SizedBox(height: 16),

            // عنوان قسم المهام العاجلة
            Row(
              children: [
                Expanded(
                  child: Text(
                    TasksConstants.tasksNeedAttentionTitle,
                    style: TextStyle(
                      fontFamily: TaskCategoriesConstants.fontFamily,
                      fontSize: fontSize + 1,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                  child: Text('تحديث'),
                ),
              ],
            ),

            const SizedBox(height: 12),

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${category.count}',
                    style: TextStyle(
                      fontFamily: TaskCategoriesConstants.fontFamily,
                      fontSize: fontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.title,
                    style: TextStyle(
                      fontFamily: TaskCategoriesConstants.fontFamily,
                      fontSize: fontSize - 2,
                      color: Colors.grey[600],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                          color: TasksConstants.kOverdueTaskColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "مهمة متأخرة",
                        style: TextStyle(
                          fontFamily: TaskCategoriesConstants.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: TasksConstants.kOverdueTaskColor,
                        ),
                      ),
                      const Spacer(),
                      // زر إكمال المهمة
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.green),
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
                                const SnackBar(
                                  content: Text('تم إكمال المهمة بنجاح'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في إكمال المهمة: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // بطاقة المهمة
                  GestureDetector(
                    onTap: widget.onTaskTap,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              TasksConstants.kOverdueTaskColor.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tasksController.overdueTask!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _tasksController.overdueTask!.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: TasksConstants.kOverdueTaskColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _tasksController.overdueTask!.dueDateFormatted,
                                style: TextStyle(
                                  color: TasksConstants.kOverdueTaskColor,
                                  fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
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
                          color: TasksConstants.kTodayTaskColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "مهمة اليوم",
                        style: TextStyle(
                          fontFamily: TaskCategoriesConstants.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: TasksConstants.kTodayTaskColor,
                        ),
                      ),
                      const Spacer(),
                      // زر إكمال المهمة
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.green),
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
                                const SnackBar(
                                  content: Text('تم إكمال المهمة بنجاح'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في إكمال المهمة: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // بطاقة المهمة
                  GestureDetector(
                    onTap: widget.onTaskTap,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              TasksConstants.kTodayTaskColor.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tasksController.todayTask!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _tasksController.todayTask!.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: TasksConstants.kTodayTaskColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _tasksController.todayTask!.dueDateFormatted,
                                style: TextStyle(
                                  color: TasksConstants.kTodayTaskColor,
                                  fontWeight: FontWeight.bold,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4338CA),
        ),
      ),
    );
  }

  // حالة تحميل المهام
  Widget _buildTasksLoadingState() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4338CA),
        ),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(TaskCategoriesConstants.cardBorderRadius),
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
                    color: Colors.red,
                    fontFamily: TaskCategoriesConstants.fontFamily,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontFamily: TaskCategoriesConstants.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => widget.controller.refresh(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // حالة خطأ المهام
  Widget _buildTasksErrorState(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
                  'حدث خطأ في تحميل المهام',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontFamily: TaskCategoriesConstants.fontFamily,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontFamily: TaskCategoriesConstants.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await _tasksController.refresh();
              setState(() {});
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // حالة عدم وجود فئات
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.task_alt,
              color: Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد فئات مهام',
              style: TextStyle(
                fontFamily: TaskCategoriesConstants.fontFamily,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد مهام تحتاج اهتمامك حالياً',
              style: TextStyle(
                fontFamily: TaskCategoriesConstants.fontFamily,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
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
        title: Text('معلومات التشخيص'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('مهمة اليوم: ${hasTodayTask ? "موجودة" : "غير موجودة"}'),
              if (hasTodayTask)
                Text('اسم مهمة اليوم: ${_tasksController.todayTask!.name}'),
              SizedBox(height: 8),
              Text('مهمة متأخرة: ${hasOverdueTask ? "موجودة" : "غير موجودة"}'),
              if (hasOverdueTask)
                Text(
                    'اسم المهمة المتأخرة: ${_tasksController.overdueTask!.name}'),
              SizedBox(height: 16),
              Text('إحصائيات المهام:'),
              Text('إجمالي المهام: ${stats['total']}'),
              Text('المهام المكتملة: ${stats['completed']}'),
              Text('المهام المتأخرة: ${stats['overdue']}'),
              Text('مهام اليوم: ${stats['today']}'),
              Text('المهام القادمة: ${stats['upcoming']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
