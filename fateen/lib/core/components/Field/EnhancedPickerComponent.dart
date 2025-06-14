import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/appColor.dart';

class EnhancedPickerComponent extends StatefulWidget {
  final List<String> itemsList;
  final String? selectedItem;
  final Function(String) onItemSelected;
  final VoidCallback onCancel;
  final VoidCallback onDone;
  final String title;

  const EnhancedPickerComponent({
    Key? key,
    required this.itemsList,
    required this.selectedItem,
    required this.onItemSelected,
    required this.onCancel,
    required this.onDone,
    required this.title,
  }) : super(key: key);

  @override
  State<EnhancedPickerComponent> createState() =>
      _EnhancedPickerComponentState();
}

class _EnhancedPickerComponentState extends State<EnhancedPickerComponent>
    with SingleTickerProviderStateMixin {
  String? _currentSelection;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // تعيين القيمة الأولية من الخارج
    _currentSelection = widget.selectedItem;

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
    // تحقق من حجم الشاشة
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تحسب ارتفاع الشريط العلوي
    final headerHeight = isTablet ? 70.0 : (isSmallScreen ? 56.0 : 64.0);

    // تحسب ارتفاع القائمة بنسبة من ارتفاع الشاشة
    final maxAvailableHeight = screenHeight - bottomPadding - 20;
    final listHeight =
        maxAvailableHeight * 0.4 > 150 ? maxAvailableHeight * 0.4 : 150;

    // تأكد من أن الارتفاع الإجمالي لا يتجاوز المساحة المتاحة
    final totalHeight = headerHeight + listHeight > maxAvailableHeight * 0.5
        ? maxAvailableHeight * 0.5
        : headerHeight + listHeight;

    return AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, screenHeight * _slideAnimation.value),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Container(
                height: totalHeight,
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorShadowColor,
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // مؤشر السحب في الأعلى
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      width: screenWidth * 0.1,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // شريط العنوان
                    Container(
                      height: headerHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: context.colorSurface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.colorShadow,
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
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
                              foregroundColor: context.colorTextHint,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),

                          // العنوان
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: context.colorPrimaryDark,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),

                          // زر الموافقة
                          TextButton(
                            onPressed: () {
                              // تأكيد الاختيار إذا كان محدداً
                              if (_currentSelection != null) {
                                widget.onItemSelected(_currentSelection!);
                              }

                              // تشغيل رسوم متحركة للخروج
                              _animationController.reverse().then((_) {
                                widget.onDone();
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: context.colorPrimaryLight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Text(
                              'تم',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // استخدام Expanded لضمان عدم تجاوز المساحة المتاحة
                    Expanded(
                      child: Container(
                        color: context.colorSurface,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.itemsList.length,
                          itemBuilder: (context, index) {
                            final item = widget.itemsList[index];
                            final isSelected = item == _currentSelection;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // استخدام تأثير صوتي عند النقر
                                  HapticFeedback.lightImpact();

                                  // تحديث الاختيار مباشرة وإعادة بناء القائمة
                                  setState(() {
                                    _currentSelection = item;
                                  });
                                  // تحديث القيمة في وحدة التحكم مباشرة
                                  widget.onItemSelected(item);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: isTablet ? 16 : 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? context.colorPrimaryLight
                                            .withOpacity(0.1)
                                        : Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: context.isDarkMode
                                            ? context.colorBorder
                                            : Colors.grey.shade200,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      // أيقونة الاختيار
                                      isSelected
                                          ? Icon(
                                              Icons.check_circle,
                                              color: context.colorPrimaryLight,
                                              size: isTablet ? 24 : 20,
                                            )
                                          : Icon(
                                              Icons.circle_outlined,
                                              color: context.colorTextHint,
                                              size: isTablet ? 24 : 20,
                                            ),

                                      SizedBox(width: isTablet ? 16 : 12),

                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 14,
                                            color: isSelected
                                                ? context.colorPrimaryDark
                                                : context.colorTextPrimary,
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
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
