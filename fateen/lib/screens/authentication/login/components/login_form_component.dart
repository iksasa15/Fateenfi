import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/constants/auth_colors.dart';
import '../constants/login_strings.dart';
import '../controllers/login_controller.dart';
import '../constants/login_dimensions.dart';
import '../components/login_button_component.dart';
import '../../reset_password/screens/reset_password_screen.dart';

class LoginFormComponent extends StatefulWidget {
  final LoginController controller;
  final VoidCallback onLogin;

  const LoginFormComponent({
    Key? key,
    required this.controller,
    required this.onLogin,
  }) : super(key: key);

  @override
  State<LoginFormComponent> createState() => _LoginFormComponentState();
}

class _LoginFormComponentState extends State<LoginFormComponent> {
  // إنشاء FocusNode للحقول
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // مفاتيح للنماذج
  final GlobalKey<FormFieldState> _emailFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _passwordFieldKey =
      GlobalKey<FormFieldState>();

  // متغير لتتبع نوع خطأ المصادقة
  String? _authErrorType;

  @override
  void initState() {
    super.initState();
    // الاستماع للتغييرات في رسائل الخطأ
    widget.controller.addListener(_handleErrorMessages);
  }

  void _handleErrorMessages() {
    if (widget.controller.errorMessage.isNotEmpty) {
      final error = widget.controller.errorMessage.toLowerCase();
      setState(() {
        if (error.contains('كلمة المرور') || error.contains('password')) {
          _authErrorType = 'password';
        } else if (error.contains('بريد') ||
            error.contains('اسم المستخدم') ||
            error.contains('email') ||
            error.contains('username')) {
          _authErrorType = 'email';
        } else {
          _authErrorType = 'other';
        }
      });

      // إضافة تأثير اهتزاز للحقل المناسب
      if (_authErrorType == 'password') {
        _shakeField(_passwordFieldKey);
      } else if (_authErrorType == 'email') {
        _shakeField(_emailFieldKey);
      }
    } else {
      setState(() {
        _authErrorType = null;
      });
    }
  }

  // دالة لإضافة تأثير اهتزاز للحقل
  void _shakeField(GlobalKey<FormFieldState> fieldKey) {
    if (fieldKey.currentContext != null) {
      HapticFeedback.heavyImpact();
      // تنفيذ الاهتزاز من خلال تحريك الحقل بطريقة معينة
      // هذا يمكن تنفيذه لاحقًا باستخدام انيميشن
    }
  }

  @override
  void dispose() {
    // التخلص من المستمعين
    widget.controller.removeListener(_handleErrorMessages);
    // التخلص من FocusNode عند إنهاء الشاشة
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return Column(
            children: [
              // حقل البريد الإلكتروني أو اسم المستخدم
              _buildEnhancedInputField(
                context: context,
                title: LoginStrings.emailOrUsernameLabel,
                hintText: LoginStrings.emailOrUsernameHint,
                controller: widget.controller.emailController,
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: widget.controller.validateEmail,
                textInputAction: TextInputAction.next,
                enabled: !widget.controller.isLoggingIn,
                focusNode: _emailFocusNode,
                formFieldKey: _emailFieldKey,
                isError: _authErrorType == 'email',
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
              ),

              // رسالة خطأ اسم المستخدم
              if (_authErrorType == 'email')
                _buildErrorMessage(widget.controller.errorMessage),

              // حقل كلمة المرور
              _buildEnhancedInputField(
                context: context,
                title: LoginStrings.passwordLabel,
                hintText: LoginStrings.passwordHint,
                controller: widget.controller.passwordController,
                icon: Icons.lock_outline_rounded,
                obscureText: !widget.controller.passwordVisible,
                suffixIcon: _buildPasswordToggleButton(context),
                validator: widget.controller.validatePassword,
                textInputAction: TextInputAction.done,
                enabled: !widget.controller.isLoggingIn,
                focusNode: _passwordFocusNode,
                formFieldKey: _passwordFieldKey,
                isError: _authErrorType == 'password',
                onFieldSubmitted: (_) {
                  // عند الضغط على زر "تم" على لوحة المفاتيح
                  if (widget.controller.isFormValid &&
                      !widget.controller.isLoggingIn) {
                    final formKey = Form.of(context);
                    if (formKey.currentState?.validate() == true) {
                      widget.onLogin();
                    }
                  }
                },
              ),

              // رسالة خطأ كلمة المرور
              if (_authErrorType == 'password')
                _buildErrorMessage(widget.controller.errorMessage),

              // رسالة خطأ عامة
              if (_authErrorType == 'other')
                _buildErrorMessage(widget.controller.errorMessage),

              // رابط نسيت كلمة المرور
              _buildForgotPasswordLink(context),

              // زر تسجيل الدخول - تمرير حالة التحميل من المتحكم
              LoginButtonComponent(
                isLoading: widget.controller.isLoggingIn,
                onPressed:
                    widget.controller.isLoggingIn ? null : widget.onLogin,
              ),
            ],
          );
        });
  }

  // إضافة ويدجت لعرض رسالة الخطأ بشكل جمالي
  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: EdgeInsets.only(
        right: LoginDimensions.getSpacing(context, size: SpacingSize.large),
        left: LoginDimensions.getSpacing(context, size: SpacingSize.large),
        bottom: LoginDimensions.getSpacing(context, size: SpacingSize.small),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AuthColors.accentColor,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AuthColors.accentColor,
                fontSize: 13,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // إضافة دالة لبناء رابط نسيت كلمة المرور بشكل مباشر
  Widget _buildForgotPasswordLink(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.fromLTRB(
          LoginDimensions.getSpacing(context, size: SpacingSize.large),
          0,
          LoginDimensions.getSpacing(context, size: SpacingSize.large),
          LoginDimensions.getSpacing(context, size: SpacingSize.large) - 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
            onTap: () {
              HapticFeedback.selectionClick();

              // الانتقال إلى شاشة استعادة كلمة المرور
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordScreen(),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: LoginDimensions.getSpacing(context,
                    size: SpacingSize.small),
                vertical: LoginDimensions.getSpacing(context,
                        size: SpacingSize.small) /
                    2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LoginStrings.forgotPasswordText,
                    style: TextStyle(
                      color: AuthColors.darkPurple,
                      fontSize: LoginDimensions.getBodyFontSize(context,
                          small: isSmallScreen),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  SizedBox(
                      width: LoginDimensions.getSpacing(context,
                              size: SpacingSize.small) /
                          2),
                  Icon(
                    Icons.lock_reset_rounded,
                    color: AuthColors.darkPurple,
                    size: LoginDimensions.getBodyFontSize(context,
                            small: isSmallScreen) +
                        2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // زر إظهار/إخفاء كلمة المرور المحسّن
  Widget _buildPasswordToggleButton(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final iconSize = LoginDimensions.getIconSize(context, small: isSmallScreen);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
        onTap: widget.controller.isLoggingIn
            ? null
            : () {
                widget.controller.togglePasswordVisibility();
                // تطبيق تأثير حسي عند الضغط
                HapticFeedback.selectionClick();
              },
        child: Padding(
          padding: EdgeInsets.all(
              LoginDimensions.getSpacing(context, size: SpacingSize.small)),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              widget.controller.passwordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              key: ValueKey<bool>(widget.controller.passwordVisible),
              color: widget.controller.isLoggingIn
                  ? AuthColors.hintColor.withOpacity(0.5)
                  : (widget.controller.passwordVisible
                      ? AuthColors.mediumPurple
                      : AuthColors.hintColor),
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  // حقل إدخال محسن مع إزالة فورية للخطأ عند الكتابة
  Widget _buildEnhancedInputField({
    required BuildContext context,
    required String title,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    required FocusNode focusNode,
    required GlobalKey<FormFieldState> formFieldKey,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    bool enabled = true,
    bool isError = false,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // استخدام دوال الأبعاد الجديدة
    final fontSize =
        LoginDimensions.getBodyFontSize(context, small: isSmallScreen);
    final labelSize =
        LoginDimensions.getLabelFontSize(context, small: isSmallScreen);
    final iconSize = LoginDimensions.getIconSize(context, small: isSmallScreen);

    // استخدام النسب المئوية لضبط الهوامش بناءً على عرض الشاشة
    final horizontalPadding =
        LoginDimensions.getSpacing(context, size: SpacingSize.large);

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical:
              LoginDimensions.getSpacing(context, size: SpacingSize.small) + 2,
          horizontal: horizontalPadding),
      child: TextFormField(
        key: formFieldKey,
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textAlign: TextAlign.right,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        enabled: enabled,
        onTap: () {
          if (enabled) {
            // تطبيق تأثير حسي عند الضغط
            HapticFeedback.selectionClick();
            // مسح رسائل الخطأ عند التركيز على الحقل
            widget.controller.clearError();
          }
        },
        onChanged: (value) {
          // عند تغيير النص، قم بإعادة التحقق من الحقل وإزالة رسالة الخطأ إذا كان النص صحيحاً
          if (formFieldKey.currentState != null &&
              formFieldKey.currentState!.hasError) {
            // إعادة التحقق فقط إذا كان هناك خطأ
            if (validator(value) == null) {
              formFieldKey.currentState!.validate();
            }
          }

          // مسح رسالة الخطأ عند الكتابة
          if (widget.controller.errorMessage.isNotEmpty) {
            widget.controller.clearError();
          }
        },
        style: TextStyle(
          color: enabled
              ? AuthColors.textColor
              : AuthColors.textColor.withOpacity(0.6),
          fontSize: fontSize,
          fontFamily: 'SYMBIOAR+LT',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: title,
          labelStyle: TextStyle(
            color: !enabled
                ? AuthColors.textColor.withOpacity(0.4)
                : isError
                    ? AuthColors.accentColor
                    : (focusNode.hasFocus
                        ? AuthColors.mediumPurple
                        : AuthColors.textColor.withOpacity(0.7)),
            fontSize: labelSize,
            fontFamily: 'SYMBIOAR+LT',
          ),
          hintStyle: TextStyle(
            color: AuthColors.hintColor.withOpacity(enabled ? 1.0 : 0.5),
            fontSize: labelSize,
            fontFamily: 'SYMBIOAR+LT',
          ),
          prefixIcon: Icon(
            icon,
            color: !enabled
                ? AuthColors.hintColor.withOpacity(0.5)
                : isError
                    ? AuthColors.accentColor
                    : (focusNode.hasFocus || controller.text.isNotEmpty
                        ? AuthColors.mediumPurple
                        : AuthColors.hintColor),
            size: iconSize,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.white.withOpacity(0.9),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: isError ? AuthColors.accentColor : Colors.grey.shade200,
              width: isError ? 1.5 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: isError ? AuthColors.accentColor : AuthColors.mediumPurple,
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: AuthColors.accentColor,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: AuthColors.accentColor,
              width: 1.5,
            ),
          ),
          errorStyle: TextStyle(
            color: AuthColors.accentColor,
            fontSize: isSmallScreen ? 10 : 12,
            fontFamily: 'SYMBIOAR+LT',
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: LoginDimensions.getInputFieldPadding(context,
                small: isSmallScreen),
            horizontal: 20,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

extension on FormState {
  get currentState => null;
}
