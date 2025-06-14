import 'package:flutter/material.dart';
import '../constants/headerConstants.dart';
import '../controllers/header_controller.dart';
import '../profile_screen.dart'; // استيراد ملف شاشة الملف الشخصي
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

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
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // تحديد حجم الشاشة
    final bool isSmallScreen = screenWidth < 360;
    final bool isMediumScreen = screenWidth >= 360 && screenWidth < 400;
    final bool isLargeScreen = screenWidth >= 400;

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
      return _buildLoadingWidget(screenSize);
    }

    // تعديل أحجام النصوص والأيقونات بناءً على حجم الشاشة - أحجام متوازنة
    final double nameSize =
        isSmallScreen ? 22.0 : (isMediumScreen ? 24.0 : 26.0);

    final double majorSize =
        isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);

    final double badgeTextSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);

    final double iconSize = AppDimensions.getIconSize(
      context,
      size: isSmallScreen ? IconSize.small : IconSize.regular,
      small: isSmallScreen,
    );

    final double editIconSize = AppDimensions.getIconSize(
      context,
      size: isSmallScreen ? IconSize.small : IconSize.regular,
      small: isSmallScreen,
    );

    // تعديل المسافات لتكون ديناميكية مع حجم الشاشة
    final double verticalSpacingSmall =
        AppDimensions.getSpacing(context, size: SpacingSize.small);
    final double verticalSpacingMedium =
        AppDimensions.getSpacing(context, size: SpacingSize.medium);
    final double horizontalSpacingSmall =
        AppDimensions.getSpacing(context, size: SpacingSize.small);
    final double horizontalSpacingMedium =
        AppDimensions.getSpacing(context, size: SpacingSize.medium);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنصر قابل للضغط لتعديل الملف الشخصي
        GestureDetector(
          onTap: _navigateToProfileScreen, // استخدام دالة التنقل الجديدة
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الاسم
              Expanded(
                child: Text(
                  _getMorningOrEveningGreeting(userName),
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.bold,
                    color:
                        context.colorPrimaryDark, // استخدام اللون من AppColors
                    letterSpacing: 0.3,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2, // تحسين المسافة بين السطور
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: horizontalSpacingSmall),
              // أيقونة تعديل الملف الشخصي
              Container(
                padding: EdgeInsets.all(screenWidth * 0.015),
                decoration: BoxDecoration(
                  color:
                      context.colorSurfaceLight, // استخدام اللون من AppColors
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius),
                  border: Border.all(
                      color: context.colorBorder), // استخدام اللون من AppColors
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: context.colorPrimaryDark, // استخدام اللون من AppColors
                  size: editIconSize,
                ),
              ),
            ],
          ),
        ),

        // التخصص
        Padding(
          padding: EdgeInsets.only(
            top: verticalSpacingSmall,
            bottom: verticalSpacingMedium,
          ),
          child: Text(
            userMajor,
            style: TextStyle(
              fontSize: majorSize,
              letterSpacing: 0.5,
              color: context.colorTextHint, // استخدام اللون من AppColors
              fontWeight: FontWeight.w500,
              fontFamily: 'SYMBIOAR+LT',
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // خط فاصل
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colorDivider, // استخدام اللون من AppColors
                context.colorDivider.withOpacity(0.5),
                context.colorDivider,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        SizedBox(height: verticalSpacingMedium),

        // الرسالة والتاريخ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // الرسالة الترحيبية
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalSpacingMedium,
                vertical: verticalSpacingSmall * 0.8,
              ),
              decoration: BoxDecoration(
                color: (isEvening
                        ? context
                            .colorPrimaryLight // استخدام اللون من AppColors
                        : context.colorAccent) // استخدام اللون من AppColors
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
                border: Border.all(
                  color: (isEvening
                          ? context
                              .colorPrimaryLight // استخدام اللون من AppColors
                          : context.colorAccent) // استخدام اللون من AppColors
                      .withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  // أيقونة الشمس أو الهلال
                  isEvening
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14)..rotateZ(-0.4),
                          child: Icon(
                            Icons.nightlight_round,
                            color: context
                                .colorPrimaryLight, // استخدام اللون من AppColors
                            size: iconSize,
                          ),
                        )
                      : Icon(
                          Icons.wb_sunny_outlined,
                          color:
                              context.colorAccent, // استخدام اللون من AppColors
                          size: iconSize,
                        ),
                  SizedBox(width: horizontalSpacingSmall * 0.8),
                  Text(
                    HeaderConstants.wishText,
                    style: TextStyle(
                      fontSize: badgeTextSize,
                      fontWeight: FontWeight.w600,
                      color: isEvening
                          ? context
                              .colorPrimaryLight // استخدام اللون من AppColors
                          : context.colorAccent, // استخدام اللون من AppColors
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // التاريخ
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalSpacingMedium,
                vertical: verticalSpacingSmall * 0.8,
              ),
              decoration: BoxDecoration(
                color: context.colorPrimaryDark
                    .withOpacity(0.08), // استخدام اللون من AppColors
                borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
                border: Border.all(
                    color: context.colorPrimaryDark
                        .withOpacity(0.15)), // استخدام اللون من AppColors
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: iconSize - 2,
                    color:
                        context.colorPrimaryDark, // استخدام اللون من AppColors
                  ),
                  SizedBox(width: horizontalSpacingSmall * 0.8),
                  Text(
                    currentDate,
                    style: TextStyle(
                      fontSize: badgeTextSize,
                      fontWeight: FontWeight.w600,
                      color: context
                          .colorPrimaryDark, // استخدام اللون من AppColors
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.2,
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
  Widget _buildLoadingWidget(Size screenSize) {
    final double width = screenSize.width;
    final double height = screenSize.height;
    final double verticalSpacing =
        AppDimensions.getSpacing(context, size: SpacingSize.small);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنصر تحميل للاسم
        _ShimmerLoadingText(
          width: width * 0.55,
          height: height * 0.035,
        ),
        SizedBox(height: verticalSpacing),

        // عنصر تحميل للتخصص
        _ShimmerLoadingText(
          width: width * 0.4,
          height: height * 0.025,
        ),
        SizedBox(height: verticalSpacing),

        // خط فاصل
        Container(
          height: 1,
          color: context.colorDivider, // استخدام اللون من AppColors
        ),
        SizedBox(height: verticalSpacing),

        // عناصر التحميل للتاريخ والرسالة
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ShimmerLoadingText(
              width: width * 0.32,
              height: height * 0.035,
            ),
            _ShimmerLoadingText(
              width: width * 0.32,
              height: height * 0.035,
            ),
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
        color: context.colorShimmerBase, // استخدام اللون من AppColors
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
      ),
    );
  }
}
