import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/appColor.dart'; // Updated import
import '../components/verification_header_component.dart';
import '../components/verification_icon_component.dart';
import '../components/verification_status_component.dart';
import '../components/verification_description_component.dart';
import '../components/resend_section_component.dart';
import '../components/verification_login_button_component.dart';
import '../components/verification_footer_component.dart';
import '../controllers/verification_controller.dart';
import '../constants/verification_strings.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String password;

  const VerificationScreen({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late VerificationController _controller;
  bool _hasShownVerificationSuccess = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _verifyingManually = false;

  // مرجع للتمرير
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _hasShownVerificationSuccess = false;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    ));

    _controller = VerificationController(
      email: widget.email,
      password: widget.password,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(context);
      _controller.addListener(_onControllerUpdate);
      _animationController.forward();
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});

      if (_controller.isVerified && !_hasShownVerificationSuccess) {
        _showSuccessNotification();
        _hasShownVerificationSuccess = true;
      }
    }
  }

  // التحقق اليدوي من البريد مع إعادة تحميل بيانات المستخدم
  Future<void> _checkVerificationManually() async {
    setState(() {
      _verifyingManually = true;
    });

    try {
      // استخدام طريقة التحقق المعززة في وحدة التحكم
      final verified = await _controller.forceCheckEmailVerification();

      if (verified) {
        // تم التحقق بنجاح
        _showSuccessNotification();
        _hasShownVerificationSuccess = true;
      } else {
        // لم يتم التحقق بعد
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لم نتمكن من تأكيد البريد الإلكتروني. تأكد من النقر على رابط التفعيل في بريدك.',
              style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // حدث خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء التحقق: $e',
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _verifyingManually = false;
      });
    }
  }

  void _showSuccessNotification() {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              VerificationStrings.verificationComplete,
              style: const TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.primaryDark, // Updated
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
      action: SnackBarAction(
        label: 'تم',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Updated
      resizeToAvoidBottomInset: true,
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return _buildScreenContent();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScreenContent() {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isTablet = screenSize.width >= 600;
    final padding = mediaQuery.padding;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: padding.top > 0 ? 0 : 8),
          child: Form(
            key: _formKey,
            child: _buildScrollableContent(isTablet),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent(bool isTablet) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: Column(
          key: ValueKey<String>(
              _controller.isVerified ? 'verified' : 'unverified'),
          children: [
            // الهيدر - يبقى كما هو بدون توسيط
            const RepaintBoundary(
              child: VerificationHeaderComponent(topPadding: 40),
            ),

            // أيقونة التحقق - توسيط
            Center(
              child: RepaintBoundary(
                child: VerificationIconComponent(
                  isVerified: _controller.isVerified,
                ),
              ),
            ),

            // عنوان الحالة - توسيط
            Center(
              child: RepaintBoundary(
                child: VerificationStatusComponent(
                  isVerified: _controller.isVerified,
                ),
              ),
            ),

            // وصف الحالة - توسيط
            Center(
              child: RepaintBoundary(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 24.0,
                    vertical: 16.0,
                  ),
                  child: VerificationDescriptionComponent(
                    isVerified: _controller.isVerified,
                    email: widget.email,
                  ),
                ),
              ),
            ),

            // زر التحقق اليدوي - توسيط
            if (!_controller.isVerified)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 24.0,
                    vertical: 8.0,
                  ),
                  child: _buildVerificationButton(isTablet),
                ),
              ),

            // قسم إعادة الإرسال أو تسجيل الدخول - توسيط
            Center(
              child: RepaintBoundary(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 24.0,
                    vertical: 16.0,
                  ),
                  child: _controller.isVerified
                      ? VerificationLoginButtonComponent(
                          isLoading: _controller.isLoading,
                          onPressed: () async {
                            try {
                              final result = await _controller
                                  .signInAutomatically(context);

                              if (result.success) {
                                // عرض رسالة نجاح
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم تسجيل الدخول بنجاح!',
                                      style:
                                          TextStyle(fontFamily: 'SYMBIOAR+LT'),
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor:
                                        AppColors.success, // Updated
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                // انتظار قصير قبل الانتقال
                                await Future.delayed(
                                    const Duration(milliseconds: 500));

                                // الانتقال للصفحة الرئيسية
                                if (mounted) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/home', (route) => false);
                                }
                              } else if (result.errorMessage != null) {
                                // عرض رسالة الخطأ
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result.errorMessage!,
                                      style: const TextStyle(
                                          fontFamily: 'SYMBIOAR+LT'),
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor:
                                        AppColors.accent, // Updated
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            } catch (e) {
                              // في حالة حدوث خطأ غير متوقع
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'حدث خطأ غير متوقع: $e',
                                    style: const TextStyle(
                                        fontFamily: 'SYMBIOAR+LT'),
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: AppColors.accent, // Updated
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        )
                      : ResendSectionComponent(
                          countdown: _controller.countdown,
                          resendingEmail: _controller.resendingEmail,
                          onResend: _controller.resendVerificationEmail,
                        ),
                ),
              ),
            ),

            // زر العودة للشاشة السابقة - توسيط
            if (!_controller.isVerified)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: VerificationFooterComponent(
                    onLoginPress: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ),
              ),

            // مساحة إضافية في الأسفل
            SizedBox(height: isTablet ? 100 : 80),
          ],
        ),
      ),
    );
  }

  // زر التحقق اليدوي
  Widget _buildVerificationButton(bool isTablet) {
    final buttonHeight = isTablet ? 56.0 : 50.0;
    final fontSize = isTablet ? 16.0 : 15.0;

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.2), // Updated
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _verifyingManually ? null : _checkVerificationManually,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryLight, // Updated
                width: 1.5,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _verifyingManually
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryLight, // Updated
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "التحقق من تأكيد البريد",
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight, // Updated
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.refresh_rounded,
                            color: AppColors.primaryLight, // Updated
                            size: isTablet ? 22.0 : 20.0,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
