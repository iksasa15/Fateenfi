import 'package:flutter/material.dart';
import '../controllers/task_categories_controller.dart';
import '../constants/task_categories_constants.dart';
import 'task_category_card_widget.dart';

class TaskCategoriesWidget extends StatelessWidget {
  final TaskCategoriesController controller;
  final VoidCallback? onTaskTap;

  const TaskCategoriesWidget({
    Key? key,
    required this.controller,
    this.onTaskTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة التحميل
    if (controller.isLoading) {
      return _buildLoadingState();
    }

    // عرض رسالة الخطأ إذا وجدت
    if (controller.errorMessage != null) {
      return _buildErrorState(controller.errorMessage!);
    }

    // الحصول على فئات المهام
    final categories = controller.categories;

    // التحقق من وجود فئات
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Text(
          TaskCategoriesConstants.sectionTitle,
          style: TextStyle(
            fontFamily: TaskCategoriesConstants.fontFamily,
            fontSize: TaskCategoriesConstants.titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: TaskCategoriesConstants.gridSpacing),
        // شبكة فئات المهام
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: TaskCategoriesConstants.gridColumnCount,
          mainAxisSpacing: TaskCategoriesConstants.gridSpacing,
          crossAxisSpacing: TaskCategoriesConstants.gridSpacing,
          childAspectRatio: TaskCategoriesConstants.gridChildAspectRatio,
          children: categories.map((category) {
            return TaskCategoryCardWidget(
              title: category.title,
              icon: category.icon,
              color: category.color,
              count: category.count,
              onTap: () {
                // استخدام الدالة المخصصة إذا تم تمريرها
                if (onTaskTap != null) {
                  onTaskTap!();
                } else {
                  // استخدام دالة المتحكم
                  controller.handleCategoryTap(category.id);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // حالة التحميل
  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState(String errorMessage) {
    return Container(
      padding: EdgeInsets.all(16),
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
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
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
          SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontFamily: TaskCategoriesConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  // حالة عدم وجود فئات
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(TaskCategoriesConstants.cardBorderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              color: Colors.grey,
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              'لا توجد فئات مهام',
              style: TextStyle(
                fontFamily: TaskCategoriesConstants.fontFamily,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
