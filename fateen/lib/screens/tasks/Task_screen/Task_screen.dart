// lib/screens/tasks/screens/tasks_screen.dart

import 'package:flutter/material.dart';
import '../controllers/tasks_controller.dart';
import '../../../models/task.dart';
import '../components/task_header.dart';
import '../components/task_list.dart';
import '../components/task_grid.dart';
import '../components/empty_tasks_state.dart';
import '../components/task_filter.dart';
import '../components/task_editor.dart';
import '../components/task_options_menu.dart';
import '../constants/tasks_colors.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_icons.dart';
import '../services/notifications_service.dart';
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';

class TasksScreen extends StatefulWidget {
  final String? selectedCourseName;

  const TasksScreen({
    Key? key,
    this.selectedCourseName,
  }) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with WidgetsBindingObserver {
  late TasksController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = TasksController();
    _controller.init(widget.selectedCourseName);

    // الاستماع للتغييرات في البيانات
    _controller.tasksChanged.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.tasksChanged.removeListener(_onDataChanged);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.loadTasks();
    }
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  // فتح محرر المهام
  void _openTaskEditor({Task? task}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskEditor(
        task: task,
        categories: [],
        selectedCourse: _controller.getSelectedCourse(),
        onSaveComplete: (success) {
          if (success) {
            _controller.loadTasks();
          }
        },
      ),
    );

    if (result == true) {
      _controller.loadTasks();
    }
  }

  // إظهار خيارات المهمة
  void _showTaskOptions(Task task) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.largeRadius + 4)),
      ),
      builder: (context) {
        return TaskOptionsMenu(
          task: task,
          onEdit: () {
            Navigator.pop(context);
            _openTaskEditor(task: task);
          },
          onToggleComplete: () {
            Navigator.pop(context);
            _controller.toggleTaskCompletion(task);
          },
          onDuplicate: () {
            Navigator.pop(context);
            _controller.duplicateTask(task);
          },
          onDelete: () {
            Navigator.pop(context);
            _confirmDeleteTask(task);
          },
        );
      },
    );
  }

  // تأكيد حذف المهمة
  Future<void> _confirmDeleteTask(Task task) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.sectionPadding,
            vertical: AppDimensions.defaultSpacing + 8),
        child: Container(
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
            boxShadow: [
              BoxShadow(
                color: context.colorShadowColor,
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(AppDimensions.sectionPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.colorAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: context.colorAccent,
                  size: 30,
                ),
              ),
              SizedBox(height: AppDimensions.defaultSpacing),
              Text(
                TasksStrings.deleteTask,
                style: TextStyle(
                  fontSize: AppDimensions.subtitleFontSize + 2,
                  fontWeight: FontWeight.bold,
                  color: context.colorTextPrimary,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.smallSpacing),
              Text(
                TasksStrings.deleteConfirmation,
                style: TextStyle(
                  fontSize: AppDimensions.smallButtonFontSize - 1,
                  color: context.colorTextSecondary,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.defaultSpacing + 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.smallSpacing + 4),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.mediumRadius),
                        ),
                        side: BorderSide(
                          color: context.colorDivider,
                        ),
                      ),
                      child: Text(
                        TasksStrings.cancel,
                        style: TextStyle(
                          color: context.colorTextSecondary,
                          fontFamily: 'SYMBIOAR+LT',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.smallSpacing + 4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.smallSpacing + 4),
                        backgroundColor: context.colorAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.mediumRadius),
                        ),
                      ),
                      child: const Text(
                        TasksStrings.deleteTask,
                        style: TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmDelete == true) {
      try {
        await _controller.deleteTask(task);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                TasksStrings.deleteSuccess,
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius)),
              backgroundColor: context.colorSuccess,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                TasksStrings.deleteError,
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius)),
              backgroundColor: context.colorError,
            ),
          );
        }
      }
    }
  }

  // عرض مربع حوار الفلاتر
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
              horizontal: AppDimensions.sectionPadding,
              vertical: AppDimensions.defaultSpacing + 8),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
              boxShadow: [
                BoxShadow(
                  color: context.colorShadowColor,
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // مقبض السحب
                  Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.only(
                        top: AppDimensions.smallSpacing + 4,
                        bottom: AppDimensions.smallSpacing + 2),
                    decoration: BoxDecoration(
                      color: context.colorDivider,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  // شريط العنوان
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.defaultSpacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الإغلاق
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: context.colorSurface,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.smallRadius + 2),
                              border: Border.all(
                                color: context.colorDivider,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              color: context.colorPrimaryDark,
                              size: 18,
                            ),
                          ),
                        ),

                        // العنوان
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.defaultSpacing - 2,
                              vertical: AppDimensions.smallSpacing - 1),
                          decoration: BoxDecoration(
                            color: context.colorSurface,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.smallRadius + 2),
                            border: Border.all(
                              color: context.colorDivider,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            TasksStrings.chooseFilter,
                            style: TextStyle(
                              fontSize: AppDimensions.smallBodyFontSize + 1,
                              fontWeight: FontWeight.bold,
                              color: context.colorPrimaryDark,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),

                        // مساحة فارغة للمحاذاة
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.smallSpacing + 4),

                  // وصف مع أيقونة
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.defaultSpacing),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.smallSpacing + 4,
                          vertical: AppDimensions.smallSpacing + 2),
                      decoration: BoxDecoration(
                        color: context.colorSurface,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.smallRadius + 2),
                        border: Border.all(
                          color: context.colorPrimaryDark.withOpacity(0.1),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: context.colorPrimaryDark,
                            size: 18,
                          ),
                          SizedBox(width: AppDimensions.smallSpacing),
                          Expanded(
                            child: Text(
                              "اختر تصفية المهام حسب الحالة أو الموعد",
                              style: TextStyle(
                                fontSize: AppDimensions.smallLabelFontSize,
                                fontWeight: FontWeight.w500,
                                color: context.colorTextPrimary,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppDimensions.smallSpacing + 4),

                  Divider(
                      height: 1,
                      thickness: 1,
                      color: context.colorPrimaryExtraLight),

                  // قائمة الفلاتر
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _controller.filters.length,
                      itemBuilder: (context, index) {
                        final filter = _controller.filters[index];
                        final count = _controller.getTaskCountByFilter(filter);
                        final filterColor = _controller.getFilterColor(filter);

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: filterColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.smallRadius + 2),
                              border: Border.all(
                                color:
                                    context.colorPrimaryDark.withOpacity(0.1),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              _controller.getFilterIcon(filter),
                              color: filterColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            filter,
                            style: TextStyle(
                              fontWeight: filter == _controller.selectedFilter
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: context.colorPrimaryDark,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          subtitle: Text(
                            '$count${TasksStrings.taskCountSuffix}',
                            style: TextStyle(
                              fontSize: AppDimensions.smallLabelFontSize - 1,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          trailing: filter == _controller.selectedFilter
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.colorPrimaryLight,
                                  ),
                                  child: Icon(
                                    TasksIcons.check,
                                    color: context.colorSurface,
                                    size: 16,
                                  ),
                                )
                              : null,
                          onTap: () {
                            _controller.setSelectedFilter(filter);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _controller.getFilteredTasks();
    final isFiltering = _controller.searchText.isNotEmpty ||
        (_controller.selectedFilter != TasksStrings.allTasks);

    return Scaffold(
      backgroundColor: context.colorBackground,
      // إعادة زر العائم
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskEditor(),
        backgroundColor: context.colorPrimaryDark,
        foregroundColor: context.colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        ),
        child: const Icon(TasksIcons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // هيدر الصفحة
            TaskHeader(courseName: widget.selectedCourseName),

            // شريط البحث
            if (_controller.isSearching)
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.smallSpacing + 4,
                    vertical: AppDimensions.smallSpacing),
                margin: EdgeInsets.symmetric(
                    horizontal: AppDimensions.defaultSpacing,
                    vertical: AppDimensions.smallSpacing),
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.mediumRadius),
                  border: Border.all(
                    color: context.colorPrimaryExtraLight,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.colorSurface,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.smallRadius + 2),
                        border: Border.all(
                          color: context.colorPrimaryDark.withOpacity(0.1),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        Icons.search,
                        color: context.colorPrimaryLight,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: AppDimensions.smallSpacing),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: TasksStrings.searchHint,
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: context.colorTextHint,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                        style: TextStyle(
                          color: context.colorPrimaryDark,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        onChanged: _controller.setSearchText,
                        autofocus: true,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: context.colorPrimaryLight,
                        size: 20,
                      ),
                      onPressed: () {
                        _controller.toggleSearch();
                        _searchController.clear();
                      },
                      constraints:
                          const BoxConstraints(maxWidth: 40, maxHeight: 40),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

            // شريط الفلتر
            if (_controller.selectedFilter != TasksStrings.allTasks &&
                !_controller.isSearching)
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.defaultSpacing),
                child: TaskFilter(
                  selectedFilter: _controller.selectedFilter,
                  filterColor:
                      _controller.getFilterColor(_controller.selectedFilter),
                  onFilterCleared: () {
                    _controller.setSelectedFilter(TasksStrings.allTasks);
                  },
                ),
              ),

            // عدد المهام والنتائج
            if (_controller.searchText.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(AppDimensions.defaultSpacing),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.smallSpacing + 2,
                      vertical: AppDimensions.smallSpacing - 2),
                  decoration: BoxDecoration(
                    color: context.colorPrimaryPale,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius),
                    border: Border.all(
                      color: context.colorPrimaryExtraLight,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${TasksStrings.searchResults}${filteredTasks.length}${TasksStrings.taskCountSuffix}',
                    style: TextStyle(
                      fontSize: AppDimensions.smallButtonFontSize - 1,
                      fontWeight: FontWeight.bold,
                      color: context.colorPrimaryDark,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ),

            // شريط التحكم - تم تحديثه ليتوافق مع تصميم صفحة المقررات
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.defaultSpacing,
                  vertical: AppDimensions.smallSpacing + 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // إضافة عنوان على اليمين
                  Text(
                    "عرض المهام",
                    style: TextStyle(
                      fontSize: AppDimensions.bodyFontSize + 1,
                      fontWeight: FontWeight.bold,
                      color: context.colorPrimaryDark,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),

                  // أزرار التحكم على اليسار
                  Row(
                    children: [
                      // زر الفلترة
                      if (!_controller.isSearching)
                        GestureDetector(
                          onTap: _showFilterDialog,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: context.colorPrimaryPale,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.mediumRadius),
                              border: Border.all(
                                color: context.colorPrimaryExtraLight,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.filter_list_rounded,
                                color: context.colorPrimaryDark,
                                size: 22,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(width: AppDimensions.smallSpacing),

                      // زر تبديل العرض (قائمة/شبكة)
                      GestureDetector(
                        onTap: _controller.toggleViewMode,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: context.colorPrimaryPale,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.mediumRadius),
                            border: Border.all(
                              color: context.colorPrimaryExtraLight,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _controller.isGridView
                                  ? Icons.view_list_rounded
                                  : Icons.grid_view_rounded,
                              color: context.colorPrimaryDark,
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: AppDimensions.smallSpacing),

                      // زر البحث
                      if (!_controller.isSearching)
                        GestureDetector(
                          onTap: _controller.toggleSearch,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: context.colorPrimaryPale,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.mediumRadius),
                              border: Border.all(
                                color: context.colorPrimaryExtraLight,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.search_rounded,
                                color: context.colorPrimaryDark,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // عرض المهام
            Expanded(
              child: _controller.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: context.colorPrimaryLight),
                    )
                  : filteredTasks.isEmpty
                      ? EmptyTasksState(
                          isFiltering: isFiltering,
                          courseName: widget.selectedCourseName,
                          onAddTask: () => _openTaskEditor(),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.defaultSpacing),
                          child: _controller.isGridView
                              ? TaskGrid(
                                  tasks: filteredTasks,
                                  isSearching: _controller.isSearching,
                                  onTaskTap: (task) =>
                                      _openTaskEditor(task: task),
                                  onTaskLongPress: _showTaskOptions,
                                  onTaskComplete:
                                      _controller.toggleTaskCompletion,
                                )
                              : TaskList(
                                  tasks: filteredTasks,
                                  isSearching: _controller.isSearching,
                                  onTaskTap: (task) =>
                                      _openTaskEditor(task: task),
                                  onTaskLongPress: _showTaskOptions,
                                  onTaskComplete:
                                      _controller.toggleTaskCompletion,
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
