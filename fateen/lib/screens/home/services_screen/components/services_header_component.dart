import 'package:flutter/material.dart';
import '../constants/services_constants.dart';

class ServicesHeaderComponent extends StatelessWidget {
  const ServicesHeaderComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : ServicesConstants.kDarkPurple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان الكبير
        Text(
          ServicesConstants.servicesTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        const SizedBox(height: 8),

        // وصف صغير
        Text(
          ServicesConstants.servicesDescription,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }
}
