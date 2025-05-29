import 'package:flutter/material.dart';
import '../constants/signup_colors.dart';
import '../constants/signup_strings.dart';
import '../constants/signup_dimensions.dart';

class MajorPickerComponent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // تحقق من حجم الشاشة
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isTablet = screenSize.width > 600;

    // تحسب ارتفاع الشريط العلوي
    final headerHeight = isTablet ? 70.0 : (isSmallScreen ? 56.0 : 64.0);

    // تحسب ارتفاع القائمة
    final listHeight = screenSize.height * 0.4;

    return Container(
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
          // شريط العنوان
          Container(
            height: headerHeight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: SignupColors.hintColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  'اختر التخصص',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: SignupColors.darkPurple,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),

                // زر الموافقة
                TextButton(
                  onPressed: onDone,
                  style: TextButton.styleFrom(
                    foregroundColor: SignupColors.mediumPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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

          // القائمة
          Container(
            height: listHeight,
            color: Colors.white,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: majorsList.length,
              itemBuilder: (context, index) {
                final major = majorsList[index];
                final isSelected = major == selectedMajor;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onMajorSelected(major),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: isTablet ? 16 : 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SignupColors.mediumPurple.withOpacity(0.1)
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
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: SignupColors.mediumPurple,
                              size: isTablet ? 24 : 20,
                            )
                          else
                            Icon(
                              Icons.circle_outlined,
                              color: SignupColors.hintColor,
                              size: isTablet ? 24 : 20,
                            ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Expanded(
                            child: Text(
                              major,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
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
    );
  }
}
