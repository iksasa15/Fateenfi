import 'package:flutter/material.dart';
import '../constants/schedule_header_constants.dart';
import '../controllers/schedule_view_controller.dart';
import '../components/schedule_header_component.dart';

/// واجهة متكاملة للهيدر الخاص بالجدول الدراسي
class ScheduleHeaderWidget extends StatelessWidget {
  // وحدة التحكم بعرض الجدول
  final ScheduleViewController controller;

  // دالة تنفذ عند تغيير نوع العرض
  final Function(bool)? onViewModeChanged;

  // دالة تنفذ عند طلب تحديث البيانات
  final VoidCallback? onRefresh;

  const ScheduleHeaderWidget({
    Key? key,
    required this.controller,
    this.onViewModeChanged,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // هيدر الجدول الدراسي - نرسل null بدلاً من دالة التحديث
        ScheduleHeaderComponent.buildHeader(context, controller, null),

        // خط فاصل أنيق
        Container(
          height: 1,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ),

        // نضيف مستمع للتغييرات في نوع العرض
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            // استدعاء الدالة الخارجية إذا كانت موجودة
            if (onViewModeChanged != null) {
              onViewModeChanged!(controller.showCalendarView);
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// طريقة استخدام الواجهة كاملة مع الاستماع للتغييرات
  static Widget withController({
    required BuildContext context,
    required Function(bool) onViewModeChanged,
    VoidCallback? onRefresh,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        final controller = ScheduleViewController();

        // إضافة مستمع للتغييرات في وحدة التحكم
        controller.addListener(() {
          onViewModeChanged(controller.showCalendarView);
        });

        return ScheduleHeaderWidget(
          controller: controller,
          onRefresh: onRefresh,
        );
      },
    );
  }
}
