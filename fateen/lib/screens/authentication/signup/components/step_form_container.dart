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
    // تأخير بسيط لضمان اكتمال الانتقال بين الخطوات قبل إظهار لوحة المفاتيح
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

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
        case SignupStep.university:
          // إظهار منتقي الجامعة تلقائياً إذا كان الحقل فارغاً
          if (widget.controller.universityNameController.text.isEmpty) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                _showUniversityPicker(context);
              }
            });
          } else {
            FocusScope.of(context)
                .requestFocus(widget.controller.universityFocusNode);
          }
          break;
        case SignupStep.major:
          // إظهار منتقي التخصص تلقائياً إذا كان الحقل فارغاً
          if (widget.controller.majorController.text.isEmpty) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                _showMajorPicker(context);
              }
            });
          } else {
            FocusScope.of(context)
                .requestFocus(widget.controller.majorFocusNode);
          }
          break;
        default:
          // لا حاجة للتركيز في الخطوة الأخيرة
          break;
      }
    });
  }

  // دالة مخصصة للانتقال إلى الخطوة التالية مع تحقق إضافي
  void _navigateToNextStep() {
    // إذا كان هناك تحقق جارٍ، فلا يتم الانتقال
    if ((widget.controller.currentStep == SignupStep.username &&
            widget.controller.isCheckingUsername) ||
        (widget.controller.currentStep == SignupStep.email &&
            widget.controller.isCheckingEmail)) {
      // عرض تلميح للمستخدم بأن التحقق جارٍ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.currentStep == SignupStep.username
                ? 'جاري التحقق من اسم المستخدم...'
                : 'جاري التحقق من البريد الإلكتروني...',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          duration: Duration(milliseconds: 1500),
          backgroundColor: SignupColors.mediumPurple,
        ),
      );
      return;
    }

    // للخطوات التي تتطلب تحققًا إضافيًا
    if (widget.controller.currentStep == SignupStep.username) {
      // التحقق من فرادة اسم المستخدم قبل الانتقال
      widget.controller.validateUsernameExists().then((isValid) {
        if (isValid) {
          widget.onNextPressed();
        }
      });
    } else if (widget.controller.currentStep == SignupStep.email) {
      // التحقق من فرادة البريد الإلكتروني قبل الانتقال
      widget.controller.validateEmailExists().then((isValid) {
        if (isValid) {
          widget.onNextPressed();
        }
      });
    } else {
      // للخطوات الأخرى، التأكد من صحة البيانات
      if (widget.controller.validateCurrentStep()) {
        widget.onNextPressed();
      }
    }
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
          _navigateToNextStep();
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
          _navigateToNextStep();
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
          : widget.controller.usernameError != null
              ? Icon(
                  Icons.error_outline,
                  color: SignupColors.accentColor,
                  size: 20,
                )
              : null, // إزالة علامة الصح الخضراء
      helperText: 'سيظهر للمستخدمين الآخرين، ويستخدم لتسجيل الدخول',
      onChanged: (value) {
        // إعادة تعيين رسالة الخطأ عند تغيير اسم المستخدم
        if (widget.controller.usernameError != null) {
          widget.controller.setUsernameError(null);
        }

        // تحقق فوري من صحة اسم المستخدم
        if (value.length >= 3 &&
            widget.controller.validateUsername(value) == null) {
          // تأخير بسيط لتجنب الكثير من الطلبات
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == widget.controller.usernameController.text) {
              widget.controller.validateUsernameExists();
            }
          });
        }
      },
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
          _navigateToNextStep();
        }
      },
      helperText: 'سيتم استخدامه للتحقق من حسابك',
      onChanged: (value) {
        // إعادة تعيين رسالة الخطأ عند تغيير البريد الإلكتروني
        if (widget.controller.emailError != null) {
          widget.controller.setEmailError(null);
        }

        // تحقق فوري من صحة البريد الإلكتروني
        if (value.contains('@') &&
            value.split('@').length == 2 &&
            widget.controller.validateEmail(value) == null) {
          // تأخير بسيط لتجنب الكثير من الطلبات
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == widget.controller.emailController.text) {
              widget.controller.validateEmailExists();
            }
          });
        }
      },
      // إضافة أيقونة مناسبة للحالة
      suffixIcon: widget.controller.isCheckingEmail
          ? Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SignupColors.mediumPurple,
              ),
            )
          : widget.controller.emailError != null
              ? Icon(
                  Icons.error_outline,
                  color: SignupColors.accentColor,
                  size: 20,
                )
              : null, // إزالة علامة الصح الخضراء
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
          _navigateToNextStep();
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
    final isSmallScreen = screenWidth < 360;

    return SingleChildScrollView(
      child: Column(
        children: [
          // أيقونة النجاح مع تأثير حركي
          Container(
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
          ),

          // عنوان محسن
          Padding(
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
          ),

          SizedBox(height: screenHeight * 0.02),

          // بطاقة معلومات المستخدم محسنة
          Container(
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
                        icon: Icons.person,
                        label: 'الاسم',
                        value: widget.controller.nameController.text,
                      ),
                      _buildDivider(),
                      _buildFinalStepInfoItem(
                        icon: Icons.alternate_email,
                        label: 'اسم المستخدم',
                        value: widget.controller.usernameController.text,
                      ),
                      _buildDivider(),
                      _buildFinalStepInfoItem(
                        icon: Icons.email_outlined,
                        label: 'البريد الإلكتروني',
                        value: widget.controller.emailController.text,
                      ),
                      _buildDivider(),
                      _buildFinalStepInfoItem(
                        icon: Icons.school_outlined,
                        label: 'الجامعة',
                        value: widget.controller.universityNameController.text,
                      ),
                      _buildDivider(),
                      _buildFinalStepInfoItem(
                        icon: Icons.book_outlined,
                        label: 'التخصص',
                        value: widget.controller.majorController.text,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.03),

          // شروط الاستخدام محسنة
          Container(
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
              onTap: () {
                _showTermsAndConditions(context);
              },
            ),
          ),

          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء عنصر معلومات في الصفحة النهائية
  Widget _buildFinalStepInfoItem({
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
    final fontSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);
    final labelSize = isTablet ? 14.0 : (isSmallScreen ? 12.0 : 13.0);
    final iconSize = isTablet ? 24.0 : (isSmallScreen ? 20.0 : 22.0);
    final helperTextSize = isTablet ? 12.0 : (isSmallScreen ? 10.0 : 11.0);

    // فحص متطلبات كلمة المرور إذا كان showPasswordStrength صحيحًا
    final hasMinLength = controller.text.length >= 8;
    final hasUppercase = controller.text.contains(RegExp(r'[A-Z]'));
    final hasLowercase = controller.text.contains(RegExp(r'[a-z]'));
    final hasDigit = controller.text.contains(RegExp(r'[0-9]'));
    final hasSpecialChar =
        controller.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasNoArabic = !RegExp(r'[\u0600-\u06FF]').hasMatch(controller.text);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: size.height * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // حقل الإدخال المحسن بأسلوب متناسق مع صفحة تسجيل الدخول
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            textAlign: TextAlign.right,
            textInputAction: textInputAction,
            onFieldSubmitted: onSubmitted,
            // تعديل لإظهار لوحة المفاتيح تلقائياً عند الضغط على الحقل
            onTap: () {
              // تضمن فتح لوحة المفاتيح عند الضغط على الحقل
              FocusScope.of(context).requestFocus(focusNode);
            },
            onChanged: (value) {
              if (onChanged != null) {
                onChanged(value);
              }
              // تحديث الحالة عند تغيير كلمة المرور
              if (showPasswordStrength) {
                setState(() {});
              }
            },
            style: TextStyle(
              color: SignupColors.textColor,
              fontSize: fontSize,
              fontFamily: 'SYMBIOAR+LT',
            ),
            decoration: InputDecoration(
              hintText: hintText,
              labelText: title,
              labelStyle: TextStyle(
                color: focusNode.hasFocus
                    ? SignupColors.mediumPurple
                    : SignupColors.textColor.withOpacity(0.7),
                fontSize: labelSize,
                fontFamily: 'SYMBIOAR+LT',
              ),
              hintStyle: TextStyle(
                color: SignupColors.hintColor,
                fontSize: labelSize,
                fontFamily: 'SYMBIOAR+LT',
              ),
              prefixIcon: Icon(
                icon,
                color: focusNode.hasFocus || controller.text.isNotEmpty
                    ? SignupColors.mediumPurple
                    : SignupColors.hintColor,
                size: iconSize,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: SignupColors.mediumPurple,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: SignupColors.accentColor,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: SignupColors.accentColor,
                  width: 1.5,
                ),
              ),
              errorStyle: TextStyle(
                color: SignupColors.accentColor,
                fontSize: isSmallScreen ? 10 : 12,
                fontFamily: 'SYMBIOAR+LT',
              ),
              errorMaxLines: 3, // السماح بعرض الخطأ على عدة أسطر
              contentPadding: EdgeInsets.symmetric(
                vertical: isTablet ? 20.0 : (isSmallScreen ? 16.0 : 18.0),
                horizontal: 20,
              ),
            ),
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          // نص المساعدة إذا كان موجودًا ولم يبدأ المستخدم بكتابة كلمة المرور
          if (helperText != null &&
              (!showPasswordStrength || controller.text.isEmpty))
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

          // متطلبات كلمة المرور والتلميحات إذا كان هذا حقل كلمة المرور وبدأ المستخدم بالكتابة
          if (showPasswordStrength && controller.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.015,
                right: screenWidth * 0.03,
                left: screenWidth * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // مؤشر قوة كلمة المرور
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قوة كلمة المرور: ${_getPasswordStrengthText(controller.text)}',
                        style: TextStyle(
                          color: _getPasswordStrengthColor(controller.text),
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
                      value: _calculatePasswordStrength(controller.text),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _getPasswordStrengthColor(controller.text)),
                      minHeight: 6,
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),

                  // متطلبات كلمة المرور في صفوف منظمة
                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.01),
                    child: Column(
                      children: [
                        // متطلب الطول
                        _buildPasswordRequirement(
                          '٨ أحرف على الأقل',
                          hasMinLength,
                          helperTextSize,
                        ),
                        SizedBox(height: 4),

                        // متطلب الحرف الكبير
                        _buildPasswordRequirement(
                          'حرف كبير (A-Z)',
                          hasUppercase,
                          helperTextSize,
                        ),
                        SizedBox(height: 4),

                        // متطلب الحرف الصغير
                        _buildPasswordRequirement(
                          'حرف صغير (a-z)',
                          hasLowercase,
                          helperTextSize,
                        ),
                        SizedBox(height: 4),

                        // متطلب الرقم
                        _buildPasswordRequirement(
                          'رقم (0-9)',
                          hasDigit,
                          helperTextSize,
                        ),
                        SizedBox(height: 4),

                        // متطلب الرمز الخاص
                        _buildPasswordRequirement(
                          'رمز خاص (!@#\$%^&*)',
                          hasSpecialChar,
                          helperTextSize,
                        ),

                        // إضافة متطلب عدم وجود حروف عربية
                        SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'لا تستخدم حروف عربية',
                          hasNoArabic,
                          helperTextSize,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // دالة لبناء متطلب من متطلبات كلمة المرور
  Widget _buildPasswordRequirement(
      String text, bool isFulfilled, double fontSize) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          isFulfilled ? Icons.check_circle : Icons.circle_outlined,
          color: isFulfilled ? Colors.green : Colors.grey.shade400,
          size: fontSize * 1.2,
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isFulfilled ? Colors.black87 : Colors.grey.shade600,
            fontSize: fontSize,
            fontFamily: 'SYMBIOAR+LT',
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // حساب قوة كلمة المرور - استدعاء من الكنترولر
  double _calculatePasswordStrength(String password) {
    return widget.controller.calculatePasswordStrength(password);
  }

  // دالة للحصول على لون قوة كلمة المرور
  Color _getPasswordStrengthColor(String password) {
    double strength = _calculatePasswordStrength(password);

    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.blue;
    return Colors.green;
  }

  // دالة للحصول على نص قوة كلمة المرور
  String _getPasswordStrengthText(String password) {
    return widget.controller.getPasswordStrengthText(password);
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
                  ? (isLastStep ? widget.onSubmitPressed : _navigateToNextStep)
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
