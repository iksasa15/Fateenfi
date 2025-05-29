import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const IntroScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  bool isLastPage = false;
  int _currentPage = 0;

  // ألوان تطبيق فطين
  final Color kDarkPurple = const Color(0xFF221291); // اللون الأساسي للتطبيق
  final Color kMediumPurple = const Color(0xFF6C63FF); // اللون الثانوي
  final Color kLightPurple = const Color(0xFFF6F4FF); // لون خلفية فاتح
  final Color kAccentColor = const Color(0xFFFF71CD); // لون التمييز
  final Color kBackgroundColor = const Color(0xFFFAFAFF); // لون الخلفية
  final Color kShadowColor = const Color(0x0D221291); // لون الظل

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // روابط الرسوم المتحركة Lottie للشاشات
  final List<String> _lottieUrls = [
    'https://assets4.lottiefiles.com/packages/lf20_6wuscyjj.json', // رسم متحرك للترحيب
    'https://assets10.lottiefiles.com/packages/lf20_bp0fvhmp.json', // رسم متحرك للمهام
    'https://assets3.lottiefiles.com/packages/lf20_0zoi9oom.json', // رسم متحرك للترجمة
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _finishIntro() async {
    // حفظ حالة إكمال شاشة المقدمة
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenIntro', true);

    // استدعاء الدالة لإكمال الإعداد
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF121212) : kBackgroundColor;
    final textColor = isDarkMode ? Colors.white : kDarkPurple;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // صفحات الـ Intro
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  isLastPage = index == 2;
                  _currentPage = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              children: [
                // الصفحة الأولى: مرحباً بك في فطين
                _buildIntroPage(
                  context,
                  title: 'مرحباً بك في فطين',
                  description: 'مساعدك الدراسي الذكي لتحقيق النجاح الأكاديمي',
                  lottieUrl: _lottieUrls[0],
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  cardColor: cardColor,
                  index: 0,
                ),

                // الصفحة الثانية: إدارة المقررات والمهام
                _buildIntroPage(
                  context,
                  title: 'إدارة المقررات والمهام',
                  description:
                      'نظم جدولك الدراسي وتابع مهامك بكل سهولة لتحسين أدائك وإنتاجيتك',
                  lottieUrl: _lottieUrls[1],
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  cardColor: cardColor,
                  index: 1,
                ),

                // الصفحة الثالثة: ترجمة المستندات وأكثر
                _buildIntroPage(
                  context,
                  title: 'ترجمة المستندات وأكثر',
                  description:
                      'استخدم الذكاء الاصطناعي لترجمة ملفاتك وتحسين دراستك بأدوات متقدمة',
                  lottieUrl: _lottieUrls[2],
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  cardColor: cardColor,
                  index: 2,
                ),
              ],
            ),

            // الهيدر: زر التخطي
            Positioned(
              top: 10,
              right: 10,
              child: SafeArea(
                child: FadeIn(
                  duration: const Duration(milliseconds: 500),
                  child: TextButton(
                    onPressed: _finishIntro,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      backgroundColor: isDarkMode
                          ? Colors.grey.shade800.withOpacity(0.7)
                          : kLightPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'تخطي',
                          style: TextStyle(
                            color: isDarkMode ? kMediumPurple : kDarkPurple,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: isDarkMode ? kMediumPurple : kDarkPurple,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // القسم السفلي: المؤشر والأزرار
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      backgroundColor.withOpacity(0),
                      backgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // مؤشر الصفحات
                    SlideInUp(
                      duration: const Duration(milliseconds: 600),
                      from: 30,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: 3,
                          effect: ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 8,
                            activeDotColor:
                                isDarkMode ? kMediumPurple : kDarkPurple,
                            dotColor: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // زر التالي أو البدء
                    SlideInUp(
                      duration: const Duration(milliseconds: 600),
                      from: 60,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: kDarkPurple.withOpacity(0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [kMediumPurple, kDarkPurple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: isLastPage
                                  ? _finishIntro
                                  : () {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLastPage ? 'ابدأ الآن' : 'التالي',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SYMBIOAR+LT',
                                    ),
                                  ),
                                  if (isLastPage) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.login_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage(
    BuildContext context, {
    required String title,
    required String description,
    required String lottieUrl,
    required Color textColor,
    required Color subtitleColor,
    required Color cardColor,
    required int index,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isTablet ? 120 : 100),

          // رسم متحرك من Lottie
          Expanded(
            flex: 4,
            child: SlideInUp(
              duration: const Duration(milliseconds: 800),
              from: 50,
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: kShadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Lottie.network(
                    lottieUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // في حالة فشل تحميل الرسم المتحرك، نعرض أيقونة بديلة
                      return Container(
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(40),
                        child: Icon(
                          index == 0
                              ? Icons.school_rounded
                              : index == 1
                                  ? Icons.task_rounded
                                  : Icons.translate_rounded,
                          size: 100,
                          color: textColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // العنوان
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            from: 30,
            delay: const Duration(milliseconds: 300),
            child: Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 32 : 28,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'SYMBIOAR+LT',
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // الوصف
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            from: 30,
            delay: const Duration(milliseconds: 400),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 8),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: subtitleColor,
                  height: 1.5,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
