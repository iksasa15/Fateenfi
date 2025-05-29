// learning_resources_component.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/student_performance_model.dart';
import '../constants/performance_colors.dart';
import '../services/student_performance_service.dart';

/// مكون عرض الموارد التعليمية المقترحة
/// يعرض موارد تعليمية متنوعة مثل مقاطع الفيديو والمقالات والاختبارات بناءً على أداء الطالب
class LearningResourcesComponent extends StatelessWidget {
  /// قائمة الموارد التعليمية المقترحة
  final List<LearningResource> resources;

  /// دالة تُستدعى عند طلب موارد تعليمية إضافية
  final VoidCallback onRequestMoreResources;

  const LearningResourcesComponent({
    Key? key,
    required this.resources,
    required this.onRequestMoreResources,
  }) : super(key: key);

  // الألوان الثابتة المستخدمة في المكون
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kTextColor = Color(0xFF1F2937);
  static const Color kTextSecondary = Color(0xFF6B7280);
  static const Color kTextHint = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          _buildHeader(),

          const Divider(height: 1, thickness: 1),

          // المقدمة
          _buildIntroduction(),

          // قائمة الموارد
          _buildResourcesList(context),

          const SizedBox(height: 16),

          // زر طلب المزيد
          _buildMoreResourcesButton(),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  //
  // ============ مكونات واجهة المستخدم الرئيسية ============
  //

  /// بناء رأس بطاقة الموارد التعليمية
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              'الموارد التعليمية المقترحة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kLightPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 14,
                  color: kMediumPurple,
                ),
                SizedBox(width: 4),
                Text(
                  "مقاطع مقترحة",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kMediumPurple,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء مقدمة وصفية للموارد التعليمية
  Widget _buildIntroduction() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'بناءً على تحليل أدائك وأسلوب تعلمك، هذه مقاطع تعليمية مقترحة لتحسين مستواك الدراسي:',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
    );
  }

  /// بناء قائمة الموارد التعليمية أو عرض رسالة في حالة عدم وجود موارد
  Widget _buildResourcesList(BuildContext context) {
    if (resources.isEmpty) {
      return _buildEmptyResourcesView(context);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            // عرض بطاقة فيديو أو بطاقة مورد عادية حسب نوع المورد
            if (resource.type.toLowerCase() == 'video') {
              return _buildVideoResourceCard(context, resource);
            } else {
              return _buildResourceCard(context, resource);
            }
          },
        ),
      );
    }
  }

  /// بناء زر طلب المزيد من الموارد
  Widget _buildMoreResourcesButton() {
    return Center(
      child: TextButton.icon(
        onPressed: onRequestMoreResources,
        icon: const Icon(Icons.refresh),
        label: const Text('عرض المزيد من المقاطع'),
        style: TextButton.styleFrom(
          foregroundColor: kDarkPurple,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  //
  // ============ بطاقات الموارد التعليمية ============
  //

  /// بناء رسالة عندما تكون قائمة الموارد فارغة
  Widget _buildEmptyResourcesView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.video_library_outlined,
              size: 48,
              color: Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 16),
            const Text(
              'لم يتم اقتراح مقاطع تعليمية حالياً',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextSecondary,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'لم تتمكن الخدمة من العثور على مقاطع تعليمية مناسبة بناءً على بيانات المواد والدرجات.',
              style: TextStyle(
                fontSize: 14,
                color: kTextHint,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRequestMoreResources,
              icon: const Icon(Icons.refresh),
              label: const Text('محاولة أخرى'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة مورد فيديو تعليمي
  Widget _buildVideoResourceCard(
      BuildContext context, LearningResource resource) {
    // استخراج معرف الفيديو وصورته المصغرة
    String? videoId =
        StudentPerformanceService.extractYoutubeVideoId(resource.url);
    String thumbnailUrl = _getThumbnailUrl(resource, videoId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openResource(resource),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مقدمة الفيديو (الصورة المصغرة وزر التشغيل)
            _buildVideoThumbnail(thumbnailUrl, resource),

            // معلومات الفيديو
            _buildVideoInfo(resource),
          ],
        ),
      ),
    );
  }

  /// بناء صورة الفيديو المصغرة مع عناصر التحكم
  Widget _buildVideoThumbnail(String thumbnailUrl, LearningResource resource) {
    return Stack(
      children: [
        // الصورة المصغرة
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: Image.network(
            thumbnailUrl,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 140,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),

        // طبقة شفافة للتباين
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),

        // زر التشغيل
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),

        // مؤشر مصدر الفيديو
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 12,
                ),
                SizedBox(width: 3),
                Text(
                  'YouTube',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
        ),

        // مدة الفيديو
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${resource.durationMinutes} دقيقة',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء معلومات الفيديو وأزرار التحكم
  Widget _buildVideoInfo(LearningResource resource) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // المادة الدراسية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: PerformanceColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              resource.subject,
              style: TextStyle(
                fontSize: 11,
                color: PerformanceColors.primary,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          const SizedBox(height: 8),

          // عنوان المقطع
          Text(
            resource.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kTextColor,
              fontFamily: 'SYMBIOAR+LT',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // وصف المقطع
          Text(
            resource.description,
            style: const TextStyle(
              fontSize: 12,
              color: kTextSecondary,
              fontFamily: 'SYMBIOAR+LT',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // أزرار مشاهدة
          _buildVideoActionButtons(resource),
        ],
      ),
    );
  }

  /// بناء أزرار التحكم في الفيديو
  Widget _buildVideoActionButtons(LearningResource resource) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // زر مشاهدة الفيديو
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openResource(resource),
            icon: const Icon(Icons.play_circle_outline, size: 16),
            label: const Text(
              'مشاهدة الفيديو',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // زر مشاهدة المحتوى
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openResource(resource),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text(
              'مشاهدة المحتوى',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء بطاقة مورد تعليمي عادي (غير فيديو)
  Widget _buildResourceCard(BuildContext context, LearningResource resource) {
    // تحديد أيقونة ولون المورد
    final IconData resourceIcon = _getResourceTypeIcon(resource.type);
    final Color resourceColor = _getResourceTypeColor(resource.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _openResource(resource),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة نوع المورد
              _buildResourceTypeIcon(resourceIcon, resourceColor),
              const SizedBox(width: 12),

              // معلومات المورد
              _buildResourceInfo(resource, resourceColor),

              // زر فتح المورد
              IconButton(
                icon: const Icon(
                  Icons.open_in_new,
                  size: 20,
                ),
                color: resourceColor,
                onPressed: () => _openResource(resource),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء أيقونة نوع المورد التعليمي
  Widget _buildResourceTypeIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  /// بناء معلومات المورد التعليمي
  Widget _buildResourceInfo(LearningResource resource, Color resourceColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نوع المورد
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: resourceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getResourceTypeText(resource.type),
              style: TextStyle(
                fontSize: 10,
                color: resourceColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // العنوان
          Text(
            resource.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kTextColor,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),

          const SizedBox(height: 4),

          // الوصف
          Text(
            resource.description,
            style: const TextStyle(
              fontSize: 12,
              color: kTextSecondary,
              fontFamily: 'SYMBIOAR+LT',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // المادة والمدة
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                size: 12,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                resource.subject,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time,
                size: 12,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${resource.durationMinutes} دقيقة',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //
  // ============ دوال المساعدة للموارد التعليمية ============
  //

  /// الحصول على نص نوع المورد بالعربية
  String _getResourceTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return 'فيديو تعليمي';
      case 'article':
        return 'مقال';
      case 'exercise':
        return 'تمارين';
      case 'quiz':
        return 'اختبار';
      case 'book':
        return 'كتاب';
      default:
        return 'مورد تعليمي';
    }
  }

  /// الحصول على أيقونة نوع المورد
  IconData _getResourceTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'article':
        return Icons.article_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'exercise':
        return Icons.fitness_center_outlined;
      case 'book':
        return Icons.book_outlined;
      default:
        return Icons.link;
    }
  }

  /// الحصول على لون نوع المورد
  Color _getResourceTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'article':
        return Colors.blue;
      case 'quiz':
        return Colors.orange;
      case 'exercise':
        return Colors.purple;
      case 'book':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// الحصول على رابط الصورة المصغرة للفيديو
  String _getThumbnailUrl(LearningResource resource, String? videoId) {
    // استخدام الصورة المصغرة المخزنة إذا كانت متوفرة
    if (resource.thumbnailUrl != null && resource.thumbnailUrl!.isNotEmpty) {
      return resource.thumbnailUrl!;
    }

    // استخدام صورة يوتيوب المصغرة إذا كان معرف الفيديو متوفرًا
    if (videoId != null && videoId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
    }

    // صورة افتراضية إذا لم تتوفر الصورة المصغرة
    return 'https://via.placeholder.com/320x180.png?text=Video';
  }

  /// فتح المورد التعليمي (مع معالجة خاصة لروابط يوتيوب)
  Future<void> _openResource(LearningResource resource) async {
    try {
      String url = resource.url.trim();
      if (url.isEmpty) {
        print("URL is empty, can't open resource");
        return;
      }

      // التأكد من أن الرابط يبدأ بـ http/https
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      // التعامل مع روابط يوتيوب بطريقة خاصة
      bool isYoutubeLink = StudentPerformanceService.isValidYoutubeUrl(url);
      Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print("Could not launch URL: $url");
      }
    } catch (e) {
      print("Error opening resource: $e");
    }
  }
}
