import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/signup_colors.dart';
import '../constants/signup_strings.dart';
import '../constants/signup_dimensions.dart';

class MajorPickerComponent extends StatefulWidget {
  final List<String> majorsList;
  final String? selectedMajor;
  final Function(String) onMajorSelected;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const MajorPickerComponent({
    Key? key,
    required this.majorsList,
    required this.selectedMajor,
    required this.onMajorSelected,
    required this.onCancel,
    required this.onDone,
  }) : super(key: key);

  @override
  State<MajorPickerComponent> createState() => _MajorPickerComponentState();
}

class _MajorPickerComponentState extends State<MajorPickerComponent>
    with SingleTickerProviderStateMixin {
  String? _currentSelection;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // تعيين القيمة الأولية من الخارج
    _currentSelection = widget.selectedMajor;

    // إعداد الرسوم المتحركة
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام LayoutBuilder للحصول على قيود الحاوية
    return LayoutBuilder(
      builder: (context, constraints) {
        // الحصول على أبعاد الشاشة
        final size = MediaQuery.of(context).size;
        final screenWidth = size.width;
        final screenHeight = size.height;

        final isSmallScreen = screenWidth < 360;
        final isTablet = screenWidth > 600;

        // تحسب ارتفاع الشريط العلوي بنسبة من ارتفاع الشاشة
        final headerHeight = isTablet
            ? screenHeight * 0.08
            : (isSmallScreen ? screenHeight * 0.07 : screenHeight * 0.075);

        // تحسب ارتفاع القائمة بنسبة من ارتفاع الشاشة
        final listHeight = screenHeight * 0.4;

        return AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, screenHeight * _slideAnimation.value),
                child: Container(
                  height: headerHeight + listHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // مؤشر السحب في الأعلى
                      Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.01),
                        width: screenWidth * 0.1,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // شريط العنوان
                      Container(
                        height: headerHeight,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // زر الإلغاء
                            TextButton(
                              onPressed: () {
                                // تشغيل رسوم متحركة للخروج
                                _animationController.reverse().then((_) {
                                  widget.onCancel();
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: SignupColors.hintColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03),
                              ),
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontSize: isTablet
                                      ? screenWidth * 0.025
                                      : (isSmallScreen
                                          ? screenWidth * 0.035
                                          : screenWidth * 0.032),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ),

                            // العنوان
                            Text(
                              'اختر التخصص',
                              style: TextStyle(
                                fontSize: isTablet
                                    ? screenWidth * 0.028
                                    : (isSmallScreen
                                        ? screenWidth * 0.04
                                        : screenWidth * 0.035),
                                fontWeight: FontWeight.bold,
                                color: SignupColors.darkPurple,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),

                            // زر الموافقة
                            TextButton(
                              onPressed: () {
                                // تأكيد الاختيار إذا كان محدداً
                                if (_currentSelection != null) {
                                  widget.onMajorSelected(_currentSelection!);
                                }

                                // تشغيل رسوم متحركة للخروج
                                _animationController.reverse().then((_) {
                                  widget.onDone();
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: SignupColors.mediumPurple,
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03),
                              ),
                              child: Text(
                                'تم',
                                style: TextStyle(
                                  fontSize: isTablet
                                      ? screenWidth * 0.025
                                      : (isSmallScreen
                                          ? screenWidth * 0.035
                                          : screenWidth * 0.032),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // القائمة
                      Container(
                        height: listHeight,
                        color: Colors.white,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.majorsList.length,
                          itemBuilder: (context, index) {
                            final major = widget.majorsList[index];
                            final isSelected = major == _currentSelection;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // استخدام تأثير صوتي عند النقر (اختياري)
                                  HapticFeedback.lightImpact();

                                  // تحديث الاختيار مباشرة وإعادة بناء القائمة
                                  setState(() {
                                    _currentSelection = major;
                                  });
                                  // تحديث القيمة في وحدة التحكم مباشرة
                                  widget.onMajorSelected(major);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.06,
                                    vertical: isTablet
                                        ? screenHeight * 0.018
                                        : (isSmallScreen
                                            ? screenHeight * 0.014
                                            : screenHeight * 0.016),
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? SignupColors.mediumPurple
                                            .withOpacity(0.1)
                                        : Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // أيقونة الاختيار مع تأثير ظهور وإخفاء سلس
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        transitionBuilder: (Widget child,
                                            Animation<double> animation) {
                                          return ScaleTransition(
                                              scale: animation, child: child);
                                        },
                                        child: isSelected
                                            ? Icon(
                                                Icons.check_circle,
                                                key: const ValueKey('selected'),
                                                color:
                                                    SignupColors.mediumPurple,
                                                size: isTablet
                                                    ? screenWidth * 0.04
                                                    : (isSmallScreen
                                                        ? screenWidth * 0.055
                                                        : screenWidth * 0.05),
                                              )
                                            : Icon(
                                                Icons.circle_outlined,
                                                key: const ValueKey(
                                                    'unselected'),
                                                color: SignupColors.hintColor,
                                                size: isTablet
                                                    ? screenWidth * 0.04
                                                    : (isSmallScreen
                                                        ? screenWidth * 0.055
                                                        : screenWidth * 0.05),
                                              ),
                                      ),

                                      SizedBox(width: screenWidth * 0.03),

                                      Expanded(
                                        child: Text(
                                          major,
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? screenWidth * 0.025
                                                : (isSmallScreen
                                                    ? screenWidth * 0.035
                                                    : screenWidth * 0.032),
                                            color: isSelected
                                                ? SignupColors.darkPurple
                                                : SignupColors.textColor,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontFamily: 'SYMBIOAR+LT',
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}
