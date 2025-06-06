// lib/features/step_form/components/final_step_view_component.dart

import 'package:flutter/material.dart';
import '../../constants/signup_colors.dart';
import '../../signup_controller/controllers/signup_controller.dart';
import '../social_terms/terms_agreement_component.dart';

class FinalStepViewComponent extends StatelessWidget {
  final SignupController controller;
  final VoidCallback onShowTerms;

  const FinalStepViewComponent({
    Key? key,
    required this.controller,
    required this.onShowTerms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          // أيقونة النجاح مع تأثير حركي
          _buildSuccessIcon(screenWidth, screenHeight),

          // عنوان محسن
          _buildTitle(screenWidth, screenHeight),

          SizedBox(height: screenHeight * 0.02),

          // بطاقة معلومات المستخدم محسنة
          _buildUserInfoCard(context, screenWidth, screenHeight),

          SizedBox(height: screenHeight * 0.03),

          // شروط الاستخدام محسنة
          _buildTermsContainer(screenWidth, screenHeight),

          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(
          top: screenHeight * 0.01, bottom: screenHeight * 0.02),
      width: screenWidth * 0.22,
      height: screenWidth * 0.22,
      decoration: BoxDecoration(
        color: SignupColors.lightPurple.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle_outline,
        color: SignupColors.darkPurple,
        size: screenWidth * 0.15,
      ),
    );
  }

  Widget _buildTitle(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.01,
      ),
      child: Column(
        children: [
          Text(
            'أنت على وشك إنشاء حساب جديد',
            style: TextStyle(
              fontSize: screenWidth * 0.052,
              fontWeight: FontWeight.bold,
              color: SignupColors.darkPurple,
              fontFamily: 'SYMBIOAR+LT',
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'تأكد من صحة بياناتك قبل المتابعة',
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              color: SignupColors.hintColor,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(
      BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SignupColors.mediumPurple.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان البطاقة
          Container(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.016,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SignupColors.mediumPurple,
                  SignupColors.darkPurple,
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                'معلومات الحساب',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.042,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
          ),

          // عناصر البيانات
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.045),
            child: Column(
              children: [
                _buildFinalStepInfoItem(
                  context: context,
                  icon: Icons.person,
                  label: 'الاسم',
                  value: controller.nameController.text,
                ),
                _buildDivider(),
                _buildFinalStepInfoItem(
                  context: context,
                  icon: Icons.alternate_email,
                  label: 'اسم المستخدم',
                  value: controller.usernameController.text,
                ),
                _buildDivider(),
                _buildFinalStepInfoItem(
                  context: context,
                  icon: Icons.email_outlined,
                  label: 'البريد الإلكتروني',
                  value: controller.emailController.text,
                ),
                _buildDivider(),
                _buildFinalStepInfoItem(
                  context: context,
                  icon: Icons.school_outlined,
                  label: 'الجامعة',
                  value: controller.universityNameController.text,
                ),
                _buildDivider(),
                _buildFinalStepInfoItem(
                  context: context,
                  icon: Icons.book_outlined,
                  label: 'التخصص',
                  value: controller.majorController.text,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContainer(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        color: SignupColors.lightPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SignupColors.mediumPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TermsAgreementComponent(
        onTap: onShowTerms,
      ),
    );
  }

  // دالة مساعدة لبناء عنصر معلومات في الصفحة النهائية
  Widget _buildFinalStepInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SignupColors.lightPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: SignupColors.darkPurple,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: SignupColors.hintColor,
                  fontSize: screenWidth * 0.032,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: SignupColors.textColor,
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لإنشاء خط فاصل
  Widget _buildDivider() {
    return Divider(
      color: SignupColors.lightPurple.withOpacity(0.3),
      thickness: 1,
      height: 20,
    );
  }
}
