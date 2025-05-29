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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: TasksColors.kAccentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: TasksColors.kAccentColor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                TasksStrings.deleteTask,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                TasksStrings.deleteConfirmation,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: const Text(
                        TasksStrings.cancel,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontFamily: 'SYMBIOAR+LT',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: TasksColors.kAccentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(8)),
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
                  borderRadius: BorderRadius.circular(8)),
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
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // مقبض السحب
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  // شريط العنوان
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF4338CA),
                              size: 18,
                            ),
                          ),
                        ),

                        // العنوان
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.0,
                            ),
                          ),
                          child: const Text(
                            TasksStrings.chooseFilter,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4338CA),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),

                        // مساحة فارغة للمحاذاة
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // وصف مع أيقونة
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF4338CA).withOpacity(0.1),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF4338CA),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "اختر تصفية المهام حسب الحالة أو الموعد",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFE3E0F8)),

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
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF4338CA).withOpacity(0.1),
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
                              color: const Color(0xFF4338CA),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          subtitle: Text(
                            '$count${TasksStrings.taskCountSuffix}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          trailing: filter == _controller.selectedFilter
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF6366F1),
                                  ),
                                  child: const Icon(
                                    TasksIcons.check,
                                    color: Colors.white,
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
      backgroundColor: const Color(0xFFFDFDFF),
      // إعادة زر العائم
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskEditor(),
        backgroundColor: const Color(0xFF4338CA),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE3E0F8),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF4338CA).withOpacity(0.1),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Color(0xFF6366F1),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: TasksStrings.searchHint,
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF4338CA),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        onChanged: _controller.setSearchText,
                        autofocus: true,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF6366F1),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE3E0F8),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${TasksStrings.searchResults}${filteredTasks.length}${TasksStrings.taskCountSuffix}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4338CA),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ),

            // شريط التحكم - تم تحديثه ليتوافق مع تصميم صفحة المقررات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // إضافة عنوان على اليمين
                  const Text(
                    "عرض المهام",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4338CA),
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
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE3E0F8),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.filter_list_rounded,
                                color: Color(0xFF4338CA),
                                size: 22,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(width: 8),

                      // زر تبديل العرض (قائمة/شبكة)
                      GestureDetector(
                        onTap: _controller.toggleViewMode,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE3E0F8),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _controller.isGridView
                                  ? Icons.view_list_rounded
                                  : Icons.grid_view_rounded,
                              color: const Color(0xFF4338CA),
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // زر البحث
                      if (!_controller.isSearching)
                        GestureDetector(
                          onTap: _controller.toggleSearch,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE3E0F8),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.search_rounded,
                                color: Color(0xFF4338CA),
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
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF6366F1)),
                    )
                  : filteredTasks.isEmpty
                      ? EmptyTasksState(
                          isFiltering: isFiltering,
                          courseName: widget.selectedCourseName,
                          onAddTask: () => _openTaskEditor(),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
