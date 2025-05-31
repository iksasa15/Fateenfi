import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/signup_colors.dart';
import '../constants/signup_dimensions.dart';
import '../controllers/signup_controller.dart';
import '../components/signup_major_field.dart';
import '../components/signup_university_field.dart';
import '../components/terms_agreement_component.dart';
import '../components/social_signup_component.dart';
import '../components/major_picker_component.dart';
import '../components/university_picker_component.dart';

class StepFormContainer extends StatefulWidget {
  final SignupController controller;
  final VoidCallback onNextPressed;
  final VoidCallback onPrevPressed;
  final VoidCallback onSubmitPressed;

  const StepFormContainer({
    Key? key,
    required this.controller,
    required this.onNextPressed,
    required this.onPrevPressed,
    required this.onSubmitPressed,
  }) : super(key: key);

  @override
  _StepFormContainerState createState() => _StepFormContainerState();
}

class _StepFormContainerState extends State<StepFormContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // FocusNodes للحقول المختلفة للتحكم بتركيز لوحة المفاتيح
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();

    // تعيين التركيز المناسب عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setFocusBasedOnCurrentStep();
    });
  }

  @override
  void didUpdateWidget(StepFormContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.currentStep != widget.controller.currentStep) {
      // إعادة تشغيل الرسوم المتحركة عند تغيير الخطوة
      _animationController.reset();
      _animationController.forward();

      // تطبيق تأثير اهتزاز خفيف عند الانتقال بين الخطوات
      HapticFeedback.lightImpact();

      // تعيين التركيز المناسب عند تغيير الخطوة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setFocusBasedOnCurrentStep();
      });
    }
  }

  void _setFocusBasedOnCurrentStep() {
    // إزالة التركيز الحالي
    FocusScope.of(context).unfocus();

    // تعيين التركيز الجديد بناءً على الخطوة الحالية
    Future.delayed(const Duration(milliseconds: 150), () {
      switch (widget.controller.currentStep) {
        case SignupStep.name:
          FocusScope.of(context).requestFocus(_nameFocusNode);
          break;
        case SignupStep.username:
          FocusScope.of(context).requestFocus(_usernameFocusNode);
          break;
        case SignupStep.email:
          FocusScope.of(context).requestFocus(_emailFocusNode);
          break;
        case SignupStep.password:
          FocusScope.of(context).requestFocus(_passwordFocusNode);
          break;
        default:
          // لا حاجة للتركيز في باقي الخطوات
          break;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة للاستجابة التلقائية
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Column(
      children: [
        // مؤشر التقدم محسن
        _buildEnhancedProgressIndicator(),

        // عنوان الخطوة محسن
        _buildEnhancedStepTitle(),

        // محتوى الخطوة الحالية
        ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                    clipBehavior: Clip.none,
                  );
                },
                child: _buildCurrentStepContent(),
              ),
            ),
          ),
        ),

        // أزرار التنقل محسنة
        _buildEnhancedNavigationButtons(),
      ],
    );
  }

  Widget _buildEnhancedProgressIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;
    final progressValue = widget.controller.getProgressPercentage();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenWidth * 0.04,
      ),
      child: Column(
        children: [
          // نص لطيف يوضح رقم الخطوة
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'الخطوة ${_getCurrentStepNumber()} من 7',
                style: TextStyle(
                  color: SignupColors.hintColor,
                  fontSize: screenWidth * 0.035,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // مؤشر تقدم محسن
          Stack(
            children: [
              // مؤشر الخلفية
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: SignupColors.lightPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // مؤشر التقدم المتحرك
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                height: 8,
                width: screenWidth * 0.88 * progressValue,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SignupColors.mediumPurple,
                      SignupColors.darkPurple,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: SignupColors.mediumPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // الحصول على رقم الخطوة الحالية
  int _getCurrentStepNumber() {
    switch (widget.controller.currentStep) {
      case SignupStep.name:
        return 1;
      case SignupStep.username:
        return 2;
      case SignupStep.email:
        return 3;
      case SignupStep.password:
        return 4;
      case SignupStep.university:
        return 5;
      case SignupStep.major:
        return 6;
      case SignupStep.terms:
        return 7;
    }
  }

  Widget _buildEnhancedStepTitle() {
    final screenWidth = MediaQuery.of(context).size.width;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenWidth * 0.02,
          ),
          child: Column(
            children: [
              Text(
                widget.controller.getCurrentStepTitle(),
                style: TextStyle(
                  color: SignupColors.darkPurple,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              // سطر صغير تحت العنوان
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.02,
                  horizontal: screenWidth * 0.25,
                ),
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SignupColors.mediumPurple.withOpacity(0.2),
                      SignupColors.mediumPurple,
                      SignupColors.mediumPurple.withOpacity(0.2),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    final step = widget.controller.currentStep;
    Widget content;

    switch (step) {
      case SignupStep.name:
        content = _buildNameField();
        break;
      case SignupStep.username:
        content = _buildUsernameField();
        break;
      case SignupStep.email:
        content = _buildEmailField();
        break;
      case SignupStep.password:
        content = _buildPasswordField();
        break;
      case SignupStep.university:
        content = _buildUniversityField();
        break;
      case SignupStep.major:
        content = _buildMajorField();
        break;
      case SignupStep.terms:
        content = _buildFinalStep();
        break;
    }

    return Container(
      key: ValueKey<SignupStep>(step),
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      child: content,
    );
  }

  Widget _buildNameField() {
    return _buildEnhancedInputField(
      title: 'الاسم الكامل',
      hintText: 'أدخل اسمك الكامل',
      controller: widget.controller.nameController,
      focusNode: _nameFocusNode,
      icon: Icons.person_outline,
      validator: widget.controller.validateName,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) {
        if (widget.controller.validateCurrentStep()) {
          widget.onNextPressed();
        }
      },
      helperText: 'مثال: محمد عبدالله العنزي',
    );
  }

  Widget _buildUsernameField() {
    return _buildEnhancedInputField(
      title: 'اسم المستخدم',
      hintText: 'أدخل اسم المستخدم',
      controller: widget.controller.usernameController,
      focusNode: _usernameFocusNode,
      icon: Icons.alternate_email,
      validator: widget.controller.validateUsername,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) {
        if (widget.controller.validateCurrentStep()) {
          widget.onNextPressed();
        }
      },
      suffixIcon: widget.controller.isCheckingUsername
          ? Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SignupColors.mediumPurple,
              ),
            )
          : null,
      helperText: 'سيظهر للمستخدمين الآخرين، ويستخدم لتسجيل الدخول',
    );
  }

  Widget _buildEmailField() {
    return _buildEnhancedInputField(
      title: 'البريد الإلكتروني',
      hintText: 'أدخل بريدك الإلكتروني',
      controller: widget.controller.emailController,
      focusNode: _emailFocusNode,
      icon: Icons.email_outlined,
      validator: widget.controller.validateEmail,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      onSubmitted: (_) {
        if (widget.controller.validateCurrentStep()) {
          widget.onNextPressed();
        }
      },
      helperText: 'سيتم استخدامه للتحقق من حسابك',
      onChanged: (value) {
        // تحقق فوري من صحة البريد الإلكتروني
        if (value.contains('@') && value.split('@').length == 2) {
          // تأخير بسيط لتجنب الكثير من الطلبات
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == widget.controller.emailController.text) {
              widget.controller.validateEmailExists();
            }
          });
        }
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildEnhancedInputField(
      title: 'كلمة المرور',
      hintText: 'أنشئ كلمة مرور قوية',
      controller: widget.controller.passwordController,
      focusNode: _passwordFocusNode,
      icon: Icons.lock_outline,
      validator: widget.controller.validatePassword,
      textInputAction: TextInputAction.next,
      obscureText: !widget.controller.passwordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          widget.controller.passwordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: widget.controller.passwordVisible
              ? SignupColors.mediumPurple
              : SignupColors.hintColor,
        ),
        onPressed: widget.controller.togglePasswordVisibility,
      ),
      onSubmitted: (_) {
        if (widget.controller.validateCurrentStep()) {
          widget.onNextPressed();
        }
      },
      helperText: 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل',
      // إضافة مؤشر قوة كلمة المرور
      showPasswordStrength: true,
    );
  }

  Widget _buildUniversityField() {
    return SignupUniversityField(
      controller: widget.controller.universityNameController,
      focusNode: widget.controller.universityFocusNode,
      isOtherUniversity: widget.controller.isOtherUniversity,
      onTap: () => _showUniversityPicker(context),
      errorText: !widget.controller.validateUniversity()
          ? 'الرجاء اختيار الجامعة'
          : null,
    );
  }

  Widget _buildMajorField() {
    return SignupMajorField(
      controller: widget.controller.majorController,
      focusNode: widget.controller.majorFocusNode,
      isOtherMajor: widget.controller.isOtherMajor,
      onTap: () => _showMajorPicker(context),
      errorText:
          !widget.controller.validateMajor() ? 'الرجاء اختيار التخصص' : null,
    );
  }

  Widget _buildFinalStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Text(
            'أنت على وشك إنشاء حساب جديد',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: SignupColors.darkPurple,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  _buildEnhancedSummaryItem(
                      'الاسم', widget.controller.nameController.text),
                  _buildEnhancedSummaryItem('اسم المستخدم',
                      widget.controller.usernameController.text),
                  _buildEnhancedSummaryItem('البريد الإلكتروني',
                      widget.controller.emailController.text),
                  _buildEnhancedSummaryItem('الجامعة',
                      widget.controller.universityNameController.text),
                  _buildEnhancedSummaryItem(
                      'التخصص', widget.controller.majorController.text),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        TermsAgreementComponent(
          onTap: () {
            // عرض الشروط والأحكام
            _showTermsAndConditions(context);
          },
        ),
        SizedBox(height: screenHeight * 0.02),
        SocialSignupComponent(),
      ],
    );
  }

  // عرض الشروط والأحكام
  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'الشروط والأحكام',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'بالتسجيل في التطبيق، أنت توافق على شروط الاستخدام وسياسة الخصوصية. نلتزم بحماية بياناتك الشخصية واستخدامها فقط للأغراض المذكورة في سياسة الخصوصية.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'موافق',
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryItem(String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.015),
            decoration: BoxDecoration(
              color: SignupColors.lightPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: SignupColors.darkPurple,
                fontSize: screenWidth * 0.035,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: SignupColors.textColor,
                fontSize: screenWidth * 0.035,
                fontFamily: 'SYMBIOAR+LT',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInputField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    String? helperText,
    void Function(String)? onChanged,
    bool showPasswordStrength = false,
  }) {
    // استخدام قيم نسبية للحجم
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام حسب حجم الشاشة
    final fontSize = screenWidth * 0.04;
    final labelSize = screenWidth * 0.035;
    final iconSize = screenWidth * 0.055;
    final helperTextSize = screenWidth * 0.03;

    // حساب قوة كلمة المرور إذا كان مطلوبًا
    double passwordStrength = 0.0;
    Color passwordStrengthColor = Colors.red;
    String passwordStrengthText = '';

    if (showPasswordStrength && controller.text.isNotEmpty) {
      // حساب قوة كلمة المرور
      passwordStrength = _calculatePasswordStrength(controller.text);

      if (passwordStrength < 0.3) {
        passwordStrengthColor = Colors.red;
        passwordStrengthText = 'ضعيفة';
      } else if (passwordStrength < 0.6) {
        passwordStrengthColor = Colors.orange;
        passwordStrengthText = 'متوسطة';
      } else if (passwordStrength < 0.8) {
        passwordStrengthColor = Colors.blue;
        passwordStrengthText = 'جيدة';
      } else {
        passwordStrengthColor = Colors.green;
        passwordStrengthText = 'قوية';
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: size.height * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // حقل الإدخال المحسن
          Material(
            elevation: 0,
            shadowColor: SignupColors.shadowColor,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: focusNode.hasFocus
                        ? SignupColors.mediumPurple.withOpacity(0.2)
                        : SignupColors.shadowColor.withOpacity(0.1),
                    blurRadius: focusNode.hasFocus ? 8 : 4,
                    spreadRadius: focusNode.hasFocus ? 2 : 1,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: focusNode.hasFocus
                      ? SignupColors.mediumPurple
                      : Colors.grey.shade200,
                  width: focusNode.hasFocus ? 1.5 : 1,
                ),
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                obscureText: obscureText,
                textAlign: TextAlign.right,
                textInputAction: textInputAction,
                onFieldSubmitted: onSubmitted,
                onChanged: onChanged,
                style: TextStyle(
                  color: SignupColors.textColor,
                  fontSize: fontSize,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  labelText: title,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelStyle: TextStyle(
                    color: focusNode.hasFocus
                        ? SignupColors.mediumPurple
                        : SignupColors.textColor.withOpacity(0.7),
                    fontSize: labelSize,
                    fontFamily: 'SYMBIOAR+LT',
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(
                    color: SignupColors.hintColor,
                    fontSize: labelSize,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: focusNode.hasFocus
                        ? SignupColors.mediumPurple
                        : SignupColors.hintColor,
                    size: iconSize,
                  ),
                  suffixIcon: suffixIcon,
                  filled: true,
                  fillColor: focusNode.hasFocus
                      ? SignupColors.focusColor.withOpacity(0.05)
                      : Colors.white,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  errorStyle: TextStyle(
                    color: SignupColors.accentColor,
                    fontSize: helperTextSize,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: size.height * 0.02,
                    horizontal: screenWidth * 0.05,
                  ),
                ),
                validator: validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ),

          // نص المساعدة إذا كان موجودًا
          if (helperText != null)
            Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.01,
                right: screenWidth * 0.03,
              ),
              child: Text(
                helperText,
                style: TextStyle(
                  color: SignupColors.hintColor,
                  fontSize: helperTextSize,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.right,
              ),
            ),

          // مؤشر قوة كلمة المرور إذا كان مطلوبًا
          if (showPasswordStrength && controller.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.015,
                right: screenWidth * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قوة كلمة المرور: $passwordStrengthText',
                        style: TextStyle(
                          color: passwordStrengthColor,
                          fontSize: helperTextSize,
                          fontFamily: 'SYMBIOAR+LT',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: passwordStrength,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(passwordStrengthColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // حساب قوة كلمة المرور
  double _calculatePasswordStrength(String password) {
    double strength = 0.0;

    // طول كلمة المرور
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;

    // تنوع الأحرف
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    // الحد الأقصى هو 1.0
    return strength > 1.0 ? 1.0 : strength;
  }

  Widget _buildEnhancedNavigationButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isFirstStep = widget.controller.currentStep == SignupStep.name;
    final isLastStep = widget.controller.currentStep == SignupStep.terms;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع - مع تأثير متحرك عند الظهور والاختفاء
          AnimatedOpacity(
            opacity: isFirstStep ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isFirstStep ? 0 : screenWidth * 0.25,
              child: isFirstStep
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: widget.onPrevPressed,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: SignupColors.hintColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            size: screenWidth * 0.035,
                            color: SignupColors.hintColor,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            'رجوع',
                            style: TextStyle(
                              color: SignupColors.hintColor,
                              fontFamily: 'SYMBIOAR+LT',
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // زر التالي أو الإنهاء - مع تأثير نبض عندما يكون جاهزًا
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isFirstStep ? screenWidth * 0.88 : screenWidth * 0.6,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              onPressed: widget.controller.canMoveToNextStep
                  ? (isLastStep ? widget.onSubmitPressed : widget.onNextPressed)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SignupColors.mediumPurple,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    SignupColors.mediumPurple.withOpacity(0.5),
                disabledForegroundColor: Colors.white.withOpacity(0.7),
                elevation: widget.controller.canMoveToNextStep ? 4 : 0,
                shadowColor: SignupColors.mediumPurple.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastStep ? 'إنشاء الحساب' : 'التالي',
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Icon(
                    isLastStep
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward_ios,
                    size: screenWidth * 0.04,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // عرض منتقي التخصص
  void _showMajorPicker(BuildContext context) {
    // تطبيق تأثير اهتزاز خفيف
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MajorPickerComponent(
        majorsList: widget.controller.getMajorsList,
        selectedMajor: widget.controller.selectedMajor,
        onMajorSelected: (major) {
          widget.controller.selectMajor(major);
        },
        onCancel: () {
          Navigator.pop(context);
        },
        onDone: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // عرض منتقي الجامعة
  void _showUniversityPicker(BuildContext context) {
    // تطبيق تأثير اهتزاز خفيف
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UniversityPickerComponent(
        universitiesList: widget.controller.getUniversitiesList,
        selectedUniversity: widget.controller.selectedUniversity,
        onUniversitySelected: (university) {
          widget.controller.selectUniversity(university);
        },
        onCancel: () {
          Navigator.pop(context);
        },
        onDone: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
