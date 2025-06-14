// lib/features/step_form/components/step_form_container.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/appColor.dart';
import '../../signup_controller/controllers/signup_controller.dart';
import '../social_terms/terms_agreement_component.dart';
import 'progress_indicator_component.dart';
import 'step_title_component.dart';
import 'final_step_view_component.dart';
import 'navigation_buttons_component.dart';
import '../../../../../core/components/Field/EnhancedPickerComponent.dart';
import '../../../../../core/components/Field/enhanced_selection_field.dart';
import '../../../../../core/components/Field/EnhancedPickerComponent.dart';
import '../../../../../core/components/Field/enhanced_input_field.dart';
import '../../constants/signup_strings.dart';

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

  // إضافة GlobalKeys للحقول
  final GlobalKey<FormFieldState> _nameFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _usernameFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _emailFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _passwordFieldKey =
      GlobalKey<FormFieldState>();

  // متغيرات لتتبع محاولات التحقق
  bool _hasAttemptedUniversityValidation = false;
  bool _hasAttemptedMajorValidation = false;

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
    // إعادة تعيين متغير محاولة التحقق عند تغيير الخطوة
    setState(() {
      _hasAttemptedUniversityValidation = false;
    });

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
    // إعادة تعيين متغير محاولة التحقق عند تغيير الخطوة
    setState(() {
      _hasAttemptedMajorValidation = false;
    });

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

  // دالة مخصصة للانتقال إلى الخطوة التالية مع تحقق إضافي - تم تحويلها إلى async
  Future<void> _navigateToNextStep() async {
    if (_isVerificationInProgress()) {
      _showVerificationSnackbar();
      return;
    }

    if (widget.controller.currentStep == SignupStep.username) {
      // تحديث واجهة المستخدم لإظهار أننا نتحقق
      setState(() {
        widget.controller.setCheckingUsername(true);
      });

      // استخدام await بدلاً من then للانتظار حتى اكتمال التحقق
      final isValid = await widget.controller.validateUsernameExists();

      // تحديث الواجهة بعد اكتمال التحقق
      setState(() {
        widget.controller.setCheckingUsername(false);
      });

      // إذا كان اسم المستخدم صالحاً، انتقل للخطوة التالية
      if (isValid) {
        widget.onNextPressed();
      }
    } else if (widget.controller.currentStep == SignupStep.email) {
      // تحديث واجهة المستخدم لإظهار أننا نتحقق
      setState(() {
        widget.controller.setCheckingEmail(true);
      });

      // استخدام await بدلاً من then للانتظار حتى اكتمال التحقق
      final isValid = await widget.controller.validateEmailExists();

      // تحديث الواجهة بعد اكتمال التحقق
      setState(() {
        widget.controller.setCheckingEmail(false);
      });

      // إذا كان البريد الإلكتروني صالحاً، انتقل للخطوة التالية
      if (isValid) {
        widget.onNextPressed();
      }
    } else if (widget.controller.currentStep == SignupStep.university) {
      // تحديث متغير محاولة التحقق من الجامعة
      setState(() {
        _hasAttemptedUniversityValidation = true;
      });

      // للخطوات الأخرى، التأكد من صحة البيانات
      if (widget.controller.validateCurrentStep()) {
        widget.onNextPressed();
      }
    } else if (widget.controller.currentStep == SignupStep.major) {
      // تحديث متغير محاولة التحقق من التخصص
      setState(() {
        _hasAttemptedMajorValidation = true;
      });

      // للخطوات الأخرى، التأكد من صحة البيانات
      if (widget.controller.validateCurrentStep()) {
        widget.onNextPressed();
      }
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
        backgroundColor: context.colorPrimaryLight, // استخدام Extension
      ),
    );
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

  // حقل الاسم باستخدام المكون الموحد
  Widget _buildNameField() {
    return EnhancedInputField(
      title: 'الاسم الكامل',
      hintText: 'أدخل اسمك الكامل',
      controller: widget.controller.nameController,
      icon: Icons.person_outline,
      validator: widget.controller.validateName,
      focusNode: _nameFocusNode,
      formFieldKey: _nameFieldKey,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _attemptNextStep(),
      onChanged: (_) {},
    );
  }

  // حقل اسم المستخدم باستخدام المكون الموحد
  Widget _buildUsernameField() {
    final bool hasUsernameError = widget.controller.usernameError != null;
    final bool isLoginSuggestion = hasUsernameError &&
        widget.controller.usernameError!.contains("مستخدم بالفعل");

    return Column(
      children: [
        EnhancedInputField(
          title: 'اسم المستخدم',
          hintText: 'أدخل اسم المستخدم',
          controller: widget.controller.usernameController,
          icon: Icons.account_circle_outlined,
          validator: _customUsernameValidator,
          focusNode: _usernameFocusNode,
          formFieldKey: _usernameFieldKey,
          textInputAction: TextInputAction.next,
          isError: hasUsernameError,
          suffixIcon: widget.controller.isCheckingUsername
              ? Container(
                  margin: const EdgeInsets.all(14),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        context.colorPrimaryLight), // استخدام Extension
                  ),
                )
              : null,
          onFieldSubmitted: (_) => _attemptNextStep(),
          onChanged: _handleUsernameChange,
        ),

        // زر الانتقال إلى تسجيل الدخول إذا كان اسم المستخدم مستخدم بالفعل
        if (isLoginSuggestion && widget.onLoginPressed != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: widget.onLoginPressed,
              icon: Icon(Icons.login,
                  color: context.colorPrimaryLight), // استخدام Extension
              label: Text(
                'انتقل إلى تسجيل الدخول',
                style: TextStyle(
                  color: context.colorPrimaryLight, // استخدام Extension
                  fontFamily: 'SYMBIOAR+LT',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // حقل البريد الإلكتروني باستخدام المكون الموحد
  Widget _buildEmailField() {
    final bool hasEmailError = widget.controller.emailError != null;
    final bool isLoginSuggestion = hasEmailError &&
        widget.controller.emailError!.contains("مستخدم بالفعل");

    return Column(
      children: [
        EnhancedInputField(
          title: 'البريد الإلكتروني',
          hintText: 'أدخل بريدك الإلكتروني',
          controller: widget.controller.emailController,
          icon: Icons.email_outlined,
          validator: _customEmailValidator,
          focusNode: _emailFocusNode,
          formFieldKey: _emailFieldKey,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          isError: hasEmailError,
          suffixIcon: widget.controller.isCheckingEmail
              ? Container(
                  margin: const EdgeInsets.all(14),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        context.colorPrimaryLight), // استخدام Extension
                  ),
                )
              : null,
          onFieldSubmitted: (_) => _attemptNextStep(),
          onChanged: _handleEmailChange,
        ),

        // زر الانتقال إلى تسجيل الدخول إذا كان البريد الإلكتروني مستخدم بالفعل
        if (isLoginSuggestion && widget.onLoginPressed != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: widget.onLoginPressed,
              icon: Icon(Icons.login,
                  color: context.colorPrimaryLight), // استخدام Extension
              label: Text(
                'انتقل إلى تسجيل الدخول',
                style: TextStyle(
                  color: context.colorPrimaryLight, // استخدام Extension
                  fontFamily: 'SYMBIOAR+LT',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // حقل كلمة المرور باستخدام المكون الموحد
  Widget _buildPasswordField() {
    final passwordStrength = widget.controller.calculatePasswordStrength(
      widget.controller.passwordController.text,
    );

    return Column(
      children: [
        EnhancedInputField(
          title: 'كلمة المرور',
          hintText: 'أدخل كلمة المرور',
          controller: widget.controller.passwordController,
          icon: Icons.lock_outline,
          validator: widget.controller.validatePassword,
          focusNode: _passwordFocusNode,
          formFieldKey: _passwordFieldKey,
          obscureText: !widget.controller.passwordVisible,
          textInputAction: TextInputAction.done,
          suffixIcon: _buildPasswordToggleButton(),
          onFieldSubmitted: (_) => _attemptNextStep(),
          onChanged: (value) {
            // تحديث واجهة المستخدم عند تغيير كلمة المرور لعرض قوة كلمة المرور
            setState(() {});
          },
        ),

        // مؤشر قوة كلمة المرور
        if (widget.controller.passwordController.text.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // شريط قوة كلمة المرور
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: passwordStrength / 100,
                    minHeight: 6,
                    backgroundColor: context.colorSurface
                        .withOpacity(0.3), // استخدام Extension
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStrengthColor(passwordStrength),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // نص قوة كلمة المرور
                Text(
                  widget.controller
                      .getPasswordStrengthText(passwordStrength as String),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: _getStrengthColor(passwordStrength),
                    fontSize: 12,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // زر إظهار/إخفاء كلمة المرور
  Widget _buildPasswordToggleButton() {
    return IconButton(
      icon: Icon(
        widget.controller.passwordVisible
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        color: context.colorPrimaryLight, // استخدام Extension
      ),
      onPressed: () {
        HapticFeedback.selectionClick();
        setState(() {
          widget.controller.togglePasswordVisibility();
        });
      },
    );
  }

  // لون قوة كلمة المرور
  Color _getStrengthColor(double strength) {
    if (strength < 30) return Colors.red;
    if (strength < 60) return Colors.orange;
    if (strength < 80) return Colors.yellow.shade700;
    return Colors.green;
  }

  // 1. حقل الجامعة باستخدام المكون الموحد
  Widget _buildUniversityField() {
    return EnhancedSelectionField(
      title: SignupStrings.universityNameLabel,
      hintText: SignupStrings.universityNameHint,
      controller: widget.controller.universityNameController,
      icon: Icons.account_balance_outlined,
      onTap: () => _showUniversityPicker(context),
      errorText: (_hasAttemptedUniversityValidation &&
              !widget.controller.validateUniversity())
          ? 'الرجاء اختيار الجامعة'
          : null,
      isEditable: widget.controller.isOtherUniversity,
      focusNode: widget.controller.universityFocusNode,
    );
  }

  // 2. حقل التخصص باستخدام المكون الموحد
  Widget _buildMajorField() {
    return EnhancedSelectionField(
      title: "التخصص",
      hintText: SignupStrings.majorHint,
      controller: widget.controller.majorController,
      icon: Icons.school_outlined,
      onTap: () => _showMajorPicker(context),
      errorText:
          (_hasAttemptedMajorValidation && !widget.controller.validateMajor())
              ? 'الرجاء اختيار التخصص'
              : null,
      isEditable: widget.controller.isOtherMajor,
      focusNode: widget.controller.majorFocusNode,
    );
  }

  // 3. منتقي الجامعة باستخدام المكون الموحد
  void _showUniversityPicker(BuildContext context) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedPickerComponent(
        itemsList: widget.controller.getUniversitiesList,
        selectedItem: widget.controller.selectedUniversity,
        onItemSelected: (university) {
          widget.controller.selectUniversity(university);
        },
        onCancel: () {
          Navigator.pop(context);
        },
        onDone: () {
          Navigator.pop(context);
        },
        title: SignupStrings.universityPickerTitle,
      ),
    );
  }

  // 4. منتقي التخصص باستخدام المكون الموحد
  void _showMajorPicker(BuildContext context) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedPickerComponent(
        itemsList: widget.controller.getMajorsList,
        selectedItem: widget.controller.selectedMajor,
        onItemSelected: (major) {
          widget.controller.selectMajor(major);
        },
        onCancel: () {
          Navigator.pop(context);
        },
        onDone: () {
          Navigator.pop(context);
        },
        title: 'اختر التخصص',
      ),
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

  // تحديث هذه الدالة لتصبح async لتتوافق مع _navigateToNextStep
  Future<void> _attemptNextStep() async {
    if (widget.controller.validateCurrentStep()) {
      await _navigateToNextStep();
    }
  }

  // عرض الشروط والأحكام
  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colorSurface, // استخدام Extension
        title: Text(
          'الشروط والأحكام',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontWeight: FontWeight.bold,
            color: context.colorTextPrimary, // استخدام Extension
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'بالتسجيل في التطبيق، أنت توافق على شروط الاستخدام وسياسة الخصوصية. نلتزم بحماية بياناتك الشخصية واستخدامها فقط للأغراض المذكورة في سياسة الخصوصية.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              color: context.colorTextPrimary, // استخدام Extension
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: context.colorPrimaryLight, // استخدام Extension
            ),
            child: Text(
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
}
