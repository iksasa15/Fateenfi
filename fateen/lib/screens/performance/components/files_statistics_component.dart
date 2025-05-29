import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/performance_colors.dart';
import '../controllers/files_statistics_controller.dart';

/// مكون عرض إحصائيات الملفات الدراسية
/// يعرض إجمالي عدد الملفات الدراسية
class FilesStatisticsComponent extends StatelessWidget {
  const FilesStatisticsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FilesStatisticsController>(
      builder: (context, filesController, _) {
        // الحصول على إجمالي الملفات من الكنترولر
        final totalFiles = filesController.totalFiles;

        // بناء بطاقة الإحصائيات
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان البطاقة
                _buildCardTitle(),
                const SizedBox(height: 16),

                // محتوى البطاقة (إما رسالة فارغة أو عدد الملفات)
                _buildCardContent(totalFiles),
              ],
            ),
          ),
        );
      },
    );
  }

  //
  // ============ دوال بناء مكونات واجهة المستخدم ============
  //

  /// بناء عنوان البطاقة
  Widget _buildCardTitle() {
    return Row(
      children: [
        Icon(
          Icons.folder,
          color: PerformanceColors.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'إحصائيات الملفات الدراسية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: PerformanceColors.textPrimary,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  /// بناء محتوى البطاقة (يختلف حسب وجود ملفات أم لا)
  Widget _buildCardContent(int totalFiles) {
    // عرض رسالة إذا لم تكن هناك ملفات
    if (totalFiles == 0) {
      return _buildEmptyFilesMessage();
    }

    // عرض عدد الملفات
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          // أيقونة الملفات
          Icon(
            Icons.insert_drive_file,
            color: PerformanceColors.primary,
            size: 48,
          ),
          const SizedBox(height: 16),

          // عدد الملفات
          Text(
            '$totalFiles',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: PerformanceColors.primary,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 8),

          // نص وصفي
          Text(
            totalFiles == 1 ? 'ملف دراسي' : 'ملفات دراسية',
            style: TextStyle(
              fontSize: 16,
              color: PerformanceColors.textSecondary,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 16),

          // بطاقة إجمالي الملفات
          _buildTotalFilesCounter(totalFiles),
        ],
      ),
    );
  }

  /// بناء عداد إجمالي الملفات
  Widget _buildTotalFilesCounter(int totalFiles) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PerformanceColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.analytics,
            color: PerformanceColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'إجمالي الملفات: $totalFiles ${totalFiles == 1 ? 'ملف' : 'ملفات'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: PerformanceColors.primary,
              fontSize: 16,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ],
      ),
    );
  }

  /// بناء رسالة "لا توجد ملفات"
  Widget _buildEmptyFilesMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد ملفات دراسية متاحة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'قم بإضافة الملفات الدراسية في صفحة المقررات',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
