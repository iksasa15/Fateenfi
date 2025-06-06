// lib/features/step_form/components/step_form_container.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/signup_colors.dart';
import '../../signup_controller/controllers/signup_controller.dart';
import '../university_major/signup_major_field.dart';
import '../university_major/signup_university_field.dart';
import '../social_terms/terms_agreement_component.dart';
import '../university_major/major_picker_component.dart';
import '../university_major/university_picker_component.dart';
import 'progress_indicator_component.dart';
import 'step_title_component.dart';
import 'input_fields/name_field_component.dart';
import 'input_fields/username_field_component.dart';
import 'input_fields/email_field_component.dart';
import 'input_fields/password_field_component.dart';
import 'final_step_view_component.dart';
import 'navigation_buttons_component.dart';

class StepFormContainer extends StatefulWidget {
  final SignupController controller;
  final VoidCallback onNextPressed;
  final VoidCallback onPrevPressed;
  final VoidCallback onSubmitPressed;
  final VoidCallback?
      onLoginPressed; // إضافة جديدة: دالة للانتقال إلى شاشة تسجيل الدخول

  const StepFormContainer({
    Key? key,
    required this.controller,
    required this.onNextPressed,
    required this.onPrevPressed,
    required this.onSubmitPressed,
    this.onLoginPressed, // إضافة جديدة (اختيارية)
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
    _setupAnimations();
    _animationController.forward();

    // تعيين التركيز المناسب عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setFocusBasedOnCurrentStep();
    });
  }

  void _setupAnimations() {
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

    // تأخير بسيط لضمان اكتمال الانتقال بين الخطوات
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
          _handleUniversityStep();
          break;
        case SignupStep.major:
          _handleMajorStep();
          break;
        default:
          // لا حاجة للتركيز في الخطوة الأخيرة
          break;
      }
    });
  }

  void _handleUniversityStep() {
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
  }

  void _handleMajorStep() {
    // إظهار منتقي التخصص تلقائياً إذا كان الحقل فارغاً
    if (widget.controller.majorController.text.isEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _showMajorPicker(context);
        }
      });
    } else {
      FocusScope.of(context).requestFocus(widget.controller.majorFocusNode);
    }
  }

  // دالة مخصصة للانتقال إلى الخطوة التالية مع تحقق إضافي
  void _navigateToNextStep() {
    if (_isVerificationInProgress()) {
      _showVerificationSnackbar();
      return;
    }

    if (widget.controller.currentStep == SignupStep.username) {
      _handleUsernameVerification();
    } else if (widget.controller.currentStep == SignupStep.email) {
      _handleEmailVerification();
    } else {
      // للخطوات الأخرى، التأكد من صحة البيانات
      if (widget.controller.validateCurrentStep()) {
        widget.onNextPressed();
      }
    }
  }

  bool _isVerificationInProgress() {
    return (widget.controller.currentStep == SignupStep.username &&
            widget.controller.isCheckingUsername) ||
        (widget.controller.currentStep == SignupStep.email &&
            widget.controller.isCheckingEmail);
  }

  void _showVerificationSnackbar() {
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
  }

  void _handleUsernameVerification() {
    widget.controller.validateUsernameExists().then((isValid) {
      if (isValid) {
        widget.onNextPressed();
      }
    });
  }

  void _handleEmailVerification() {
    widget.controller.validateEmailExists().then((isValid) {
      if (isValid) {
        widget.onNextPressed();
      }
    });
  }

  // دالة تعامل مع تغيير اسم المستخدم مع دعم debounce
  void _handleUsernameChange(String value) {
    // إعادة تعيين رسالة الخطأ عند تغيير اسم المستخدم
    if (widget.controller.usernameError != null) {
      widget.controller.setUsernameError(null);
    }

    // تحقق فوري من صحة اسم المستخدم باستخدام debounce
    if (value.length >= 3 &&
        widget.controller.validateUsername(value) == null) {
      // استخدام دالة debounce المعرفة في الكونترولر
      widget.controller.debounceCheckUsername(value);
    }
  }

  // دالة تعامل مع تغيير البريد الإلكتروني مع دعم debounce
  void _handleEmailChange(String value) {
    // إعادة تعيين رسالة الخطأ عند تغيير البريد الإلكتروني
    if (widget.controller.emailError != null) {
      widget.controller.setEmailError(null);
    }

    // تحقق فوري من صحة البريد الإلكتروني باستخدام debounce
    if (value.contains('@') &&
        value.split('@').length == 2 &&
        widget.controller.validateEmail(value) == null) {
      // استخدام دالة debounce المعرفة في الكونترولر
      widget.controller.debounceCheckEmail(value);
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
    return Column(
      children: [
        // مؤشر التقدم محسن
        StepProgressIndicator(
          controller: widget.controller,
          currentStepNumber: _getCurrentStepNumber(),
        ),

        // عنوان الخطوة محسن
        StepTitleComponent(
          controller: widget.controller,
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
        ),

        // محتوى الخطوة الحالية
        _buildAnimatedStepContent(),

        // أزرار التنقل محسنة
        NavigationButtonsComponent(
          controller: widget.controller,
          onPrevPressed: widget.onPrevPressed,
          onNextPressed: _navigateToNextStep,
          onSubmitPressed: widget.onSubmitPressed,
        ),
      ],
    );
  }

  Widget _buildAnimatedStepContent() {
    return ScaleTransition(
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

  Widget _buildCurrentStepContent() {
    final step = widget.controller.currentStep;
    Widget content;

    switch (step) {
      case SignupStep.name:
        content = NameFieldComponent(
          controller: widget.controller.nameController,
          focusNode: _nameFocusNode,
          validator: widget.controller.validateName,
          onSubmitted: (_) => _attemptNextStep(),
        );
        break;
      case SignupStep.username:
        content = UsernameFieldComponent(
          controller: widget.controller.usernameController,
          focusNode: _usernameFocusNode,
          validator: _customUsernameValidator,
          onSubmitted: (_) => _attemptNextStep(),
          isCheckingUsername: widget.controller.isCheckingUsername,
          usernameError: widget.controller.usernameError,
          onChanged: _handleUsernameChange,
          onLoginPressed: widget.onLoginPressed,
        );
        break;
      case SignupStep.email:
        content = EmailFieldComponent(
          controller: widget.controller.emailController,
          focusNode: _emailFocusNode,
          validator: _customEmailValidator,
          onSubmitted: (_) => _attemptNextStep(),
          isCheckingEmail: widget.controller.isCheckingEmail,
          emailError: widget.controller.emailError,
          onChanged: _handleEmailChange,
          onLoginPressed: widget.onLoginPressed,
        );
        break;
      case SignupStep.password:
        content = PasswordFieldComponent(
          controller: widget.controller.passwordController,
          focusNode: _passwordFocusNode,
          validator: widget.controller.validatePassword,
          passwordVisible: widget.controller.passwordVisible,
          togglePasswordVisibility: widget.controller.togglePasswordVisibility,
          onSubmitted: (_) => _attemptNextStep(),
          calculatePasswordStrength:
              widget.controller.calculatePasswordStrength,
          getPasswordStrengthText: widget.controller.getPasswordStrengthText,
        );
        break;
      case SignupStep.university:
        content = _buildUniversityField();
        break;
      case SignupStep.major:
        content = _buildMajorField();
        break;
      case SignupStep.terms:
        content = FinalStepViewComponent(
          controller: widget.controller,
          onShowTerms: () => _showTermsAndConditions(context),
        );
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

  // دالة مخصصة للتحقق من اسم المستخدم مع إضافة خيار تسجيل الدخول
  String? _customUsernameValidator(String? value) {
    final originalError = widget.controller.validateUsername(value);

    // إذا كان اسم المستخدم موجودًا بالفعل
    if (widget.controller.usernameError != null &&
        widget.controller.usernameError!.contains("مستخدم بالفعل")) {
      return "اسم المستخدم مستخدم بالفعل. تسجيل الدخول؟";
    }

    return originalError;
  }

  // دالة مخصصة للتحقق من البريد الإلكتروني مع إضافة خيار تسجيل الدخول
  String? _customEmailValidator(String? value) {
    final originalError = widget.controller.validateEmail(value);

    // إذا كان البريد الإلكتروني موجودًا بالفعل
    if (widget.controller.emailError != null &&
        widget.controller.emailError!.contains("مستخدم بالفعل")) {
      return "البريد الإلكتروني موجود بالفعل. تسجيل الدخول؟";
    }

    return originalError;
  }

  void _attemptNextStep() {
    if (widget.controller.validateCurrentStep()) {
      _navigateToNextStep();
    }
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

  // عرض منتقي التخصص
  void _showMajorPicker(BuildContext context) {
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
