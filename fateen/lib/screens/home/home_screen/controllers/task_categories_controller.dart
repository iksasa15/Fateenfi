import 'package:flutter/material.dart';
import '../constants/task_categories_constants.dart';
import '../services/firebaseServices/task_categories_service.dart';

class TaskCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final int count;

  TaskCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });
}

class TaskCategoriesController extends ChangeNotifier {
  final TaskCategoriesService _service = TaskCategoriesService();
  bool _isLoading = true;
  String? _errorMessage;
  List<TaskCategory> _categories = [];

  // الحصول على القيم
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskCategory> get categories => _categories;

  // تهيئة البيانات
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('بدء تهيئة وحدة تحكم فئات المهام...');

      // جلب بيانات فئات المهام من Firebase
      final data = await _service.getTaskCategories();

      debugPrint('تم استلام بيانات فئات المهام: $data');

      // معالجة البيانات
      _processData(data);

      _errorMessage = null;
    } catch (e) {
      debugPrint('خطأ في تهيئة وحدة تحكم فئات المهام: $e');
      _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
      // ضمان استخدام أصفار في حالة الخطأ
      _categories = _getZeroCategories();
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('اكتملت تهيئة وحدة تحكم فئات المهام');
    }
  }

  // معالجة البيانات القادمة من Firebase
  void _processData(Map<String, dynamic> data) {
    // حتى إذا كانت البيانات فارغة، نقوم بإنشاء الفئات مع قيم صفرية
    _categories = [];

    // المهام العاجلة - التأكد من استخدام 0 كقيمة افتراضية
    _categories.add(
      TaskCategory(
        id: 'urgent',
        title: TaskCategoriesConstants.urgentTasksTitle,
        icon: TaskCategoriesConstants.urgentTasksIcon,
        color: TaskCategoriesConstants.urgentTasksColor,
        count: _parseCountValue(data['urgent']),
      ),
    );

    // المهام القادمة - التأكد من استخدام 0 كقيمة افتراضية
    _categories.add(
      TaskCategory(
        id: 'upcoming',
        title: TaskCategoriesConstants.upcomingTasksTitle,
        icon: TaskCategoriesConstants.upcomingTasksIcon,
        color: TaskCategoriesConstants.upcomingTasksColor,
        count: _parseCountValue(data['upcoming']),
      ),
    );

    // المهام المكتملة - التأكد من استخدام 0 كقيمة افتراضية
    _categories.add(
      TaskCategory(
        id: 'completed',
        title: TaskCategoriesConstants.completedTasksTitle,
        icon: TaskCategoriesConstants.completedTasksIcon,
        color: TaskCategoriesConstants.completedTasksColor,
        count: _parseCountValue(data['completed']),
      ),
    );

    // كل المهام - التأكد من استخدام 0 كقيمة افتراضية
    _categories.add(
      TaskCategory(
        id: 'all',
        title: TaskCategoriesConstants.allTasksTitle,
        icon: TaskCategoriesConstants.allTasksIcon,
        color: TaskCategoriesConstants.allTasksColor,
        count: _parseCountValue(data['all']),
      ),
    );

    debugPrint('تم تجهيز ${_categories.length} فئات مهام');
  }

  // دالة لتحويل القيمة إلى عدد صحيح بقيمة افتراضية 0
  int _parseCountValue(dynamic value) {
    if (value == null) return 0;

    // إذا كانت القيمة عدد صحيح
    if (value is int) {
      return value < 0 ? 0 : value;
    }

    // إذا كانت القيمة نص
    if (value is String) {
      try {
        final parsed = int.parse(value);
        return parsed < 0 ? 0 : parsed;
      } catch (e) {
        return 0;
      }
    }

    // إذا كانت القيمة عدد عشري
    if (value is double) {
      return value.toInt() < 0 ? 0 : value.toInt();
    }

    // أي قيمة أخرى
    return 0;
  }

  // إنشاء فئات مع قيم صفرية
  List<TaskCategory> _getZeroCategories() {
    return [
      TaskCategory(
        id: 'urgent',
        title: TaskCategoriesConstants.urgentTasksTitle,
        icon: TaskCategoriesConstants.urgentTasksIcon,
        color: TaskCategoriesConstants.urgentTasksColor,
        count: 0,
      ),
      TaskCategory(
        id: 'upcoming',
        title: TaskCategoriesConstants.upcomingTasksTitle,
        icon: TaskCategoriesConstants.upcomingTasksIcon,
        color: TaskCategoriesConstants.upcomingTasksColor,
        count: 0,
      ),
      TaskCategory(
        id: 'completed',
        title: TaskCategoriesConstants.completedTasksTitle,
        icon: TaskCategoriesConstants.completedTasksIcon,
        color: TaskCategoriesConstants.completedTasksColor,
        count: 0,
      ),
      TaskCategory(
        id: 'all',
        title: TaskCategoriesConstants.allTasksTitle,
        icon: TaskCategoriesConstants.allTasksIcon,
        color: TaskCategoriesConstants.allTasksColor,
        count: 0,
      ),
    ];
  }

  // معالجة النقر على فئة المهام
  void handleCategoryTap(String categoryId) {
    // يمكن إضافة منطق إضافي هنا إذا لزم الأمر
    debugPrint('تم النقر على فئة المهام: $categoryId');
  }

  // تحديث البيانات
  Future<void> refresh() async {
    debugPrint('بدء تحديث بيانات فئات المهام...');
    await initialize();
    debugPrint('تم تحديث بيانات فئات المهام');
  }

  @override
  void dispose() {
    debugPrint('تحرير موارد وحدة تحكم فئات المهام');
    // تنظيف الموارد إذا لزم الأمر
    super.dispose();
  }
}
