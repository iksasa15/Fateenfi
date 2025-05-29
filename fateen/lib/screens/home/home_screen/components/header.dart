import 'package:flutter/material.dart';
import '../constants/headerConstants.dart';
import '../controllers/header_controller.dart';
import '../profile_screen.dart'; // استيراد ملف شاشة الملف الشخصي

/// مكون الهيدر لعرض معلومات المستخدم والتخصص مع زر التعديل
class HeaderComponent extends StatefulWidget {
  final HeaderController controller;
  final VoidCallback? onEditPressed;

  const HeaderComponent({
    Key? key,
    required this.controller,
    this.onEditPressed,
  }) : super(key: key);

  @override
  State<HeaderComponent> createState() => _HeaderComponentState();
}

class _HeaderComponentState extends State<HeaderComponent> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    await widget.controller.initialize();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // فتح صفحة الملف الشخصي
  void _navigateToProfileScreen() async {
    if (widget.onEditPressed != null) {
      // استخدام الدالة المخصصة المقدمة من الخارج إذا كانت موجودة
      widget.onEditPressed!();
    } else {
      // فتح صفحة الملف الشخصي افتراضياً إذا لم يتم تقديم دالة مخصصة
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );

      // إذا تم تحديث الملف الشخصي، قم بتحديث بيانات الهيدر
      if (result == true && mounted) {
        await widget.controller.syncWithFirebase();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد أيقونة النهار/الليل حسب الوقت الحالي
    final currentHour = DateTime.now().hour;
    final isEvening = currentHour >= 17 ||
        currentHour < 6; // بعد الساعة 5 مساءً أو قبل 6 صباحاً

    // الحصول على البيانات من المتحكم
    final String userName = widget.controller.userName;
    final String userMajor = widget.controller.userMajor;
    final String currentDate = widget.controller.getFormattedDate();
    final bool isControllerLoading = widget.controller.isLoading;

    // إظهار مؤشر التحميل إذا كان التطبيق أو المتحكم في حالة تحميل
    if (_isLoading || isControllerLoading) {
      return _buildLoadingWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنصر قابل للضغط لتعديل الملف الشخصي
        GestureDetector(
          onTap: _navigateToProfileScreen, // استخدام دالة التنقل الجديدة
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الاسم بخط أكبر وأكثر بروزاً
              Expanded(
                child: Text(
                  _getMorningOrEveningGreeting(userName),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(
                        0xFF4338CA), // استخدام لون darkPurple من صفحات التسجيل
                    letterSpacing: 0.3,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // أيقونة تعديل الملف الشخصي
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(
                      12), // استخدام نفس borderRadius من الصفحات الأخرى
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Color(
                      0xFF4338CA), // استخدام لون darkPurple من صفحات التسجيل
                  size: 16,
                ),
              ),
            ],
          ),
        ),

        // التخصص بتباعد أكبر وتنسيق محسن
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 12),
          child: Text(
            userMajor,
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 0.5,
              color: const Color(
                  0xFF9CA3AF), // استخدام لون hintColor من صفحات التسجيل
              fontWeight: FontWeight.w500,
              fontFamily: 'SYMBIOAR+LT',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // خط فاصل بتأثير مظلل
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // الرسالة والتاريخ في صف واحد مع تأثيرات محسنة
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // الرسالة الترحيبية محسنة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isEvening
                        ? const Color(0xFF6366F1) // استخدام mediumPurple لليل
                        : const Color(0xFFEC4899) // استخدام accentColor للنهار
                    )
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(
                    12), // استخدام نفس borderRadius من الصفحات الأخرى
                border: Border.all(
                  color: (isEvening
                          ? const Color(0xFF6366F1) // استخدام mediumPurple لليل
                          : const Color(
                              0xFFEC4899) // استخدام accentColor للنهار
                      )
                      .withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  // أيقونة الشمس أو الهلال محسنة
                  isEvening
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14)..rotateZ(-0.4),
                          child: Icon(
                            Icons.nightlight_round,
                            color: const Color(
                                0xFF6366F1), // استخدام mediumPurple لليل
                            size: 14,
                          ),
                        )
                      : Icon(
                          Icons.wb_sunny_outlined,
                          color: const Color(
                              0xFFEC4899), // استخدام accentColor للنهار
                          size: 14,
                        ),
                  const SizedBox(width: 6),
                  Text(
                    HeaderConstants.wishText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isEvening
                          ? const Color(0xFF6366F1) // استخدام mediumPurple لليل
                          : const Color(
                              0xFFEC4899), // استخدام accentColor للنهار
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
            ),

            // التاريخ بتصميم محسن
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4338CA)
                    .withOpacity(0.08), // استخدام darkPurple
                borderRadius: BorderRadius.circular(
                    12), // استخدام نفس borderRadius من الصفحات الأخرى
                border: Border.all(
                    color: const Color(0xFF4338CA)
                        .withOpacity(0.15)), // استخدام darkPurple
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: Color(0xFF4338CA), // استخدام darkPurple
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4338CA), // استخدام darkPurple
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // بناء واجهة التحميل
  Widget _buildLoadingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنصر تحميل للاسم
        const _ShimmerLoadingText(width: 200, height: 28),
        const SizedBox(height: 8),

        // عنصر تحميل للتخصص
        const _ShimmerLoadingText(width: 150, height: 20),
        const SizedBox(height: 12),

        // خط فاصل
        Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
        const SizedBox(height: 12),

        // عناصر التحميل للتاريخ والرسالة
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _ShimmerLoadingText(width: 120, height: 30),
            _ShimmerLoadingText(width: 120, height: 30),
          ],
        ),
      ],
    );
  }

  // الحصول على تحية الصباح أو المساء
  String _getMorningOrEveningGreeting(String name) {
    final hourNow = DateTime.now().hour;
    final greeting =
        (hourNow >= 5 && hourNow < 18) ? 'صباح الخير' : 'مساء الخير';

    // التحقق من اسم المستخدم وإزالة الحالات الخاصة
    String displayName = name;
    if (name == HeaderConstants.defaultUserName ||
        name.isEmpty ||
        name == 'null') {
      // إذا كان الاسم هو القيمة الافتراضية أو فارغاً، استخدم تحية بدون اسم
      return greeting;
    } else {
      // تأكد من أن الاسم لا يحتوي على كلمة "مستخدم"
      if (name.contains(HeaderConstants.defaultUserName)) {
        displayName =
            name.replaceAll(HeaderConstants.defaultUserName, '').trim();
        if (displayName.isEmpty) {
          return greeting;
        }
      }

      // استخدم تحية مع الاسم
      return '$greeting $displayName';
    }
  }
}

// عنصر لعرض تأثير التحميل
class _ShimmerLoadingText extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerLoadingText({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
