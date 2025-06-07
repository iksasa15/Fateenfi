import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'package:fateen/screens/authentication/login/screens/login_screen.dart';
import 'package:fateen/screens/authentication/signup/screens/signup_screen.dart';
import 'package:fateen/screens/authentication/reset_password/screens/reset_password_screen.dart';
import 'package:fateen/screens/home/home_screen/home_screen.dart';
import 'package:fateen/screens/home/home_screen/home_constants.dart';

// مزود للثيم لدعم الوضع الليلي في التطبيق
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // تهيئة الحالة من التخزين المحلي
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // تغيير الوضع وحفظ الإعداد
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // الحصول على ثيم بناءً على الإعداد
  ThemeData getTheme() {
    return _isDarkMode ? _getDarkTheme() : _getLightTheme();
  }

  // تعريف ثيم الوضع الداكن
  ThemeData _getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: const Color(0xFF6C63FF),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFFFF71CD),
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF6C63FF)),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
      cardColor: const Color(0xFF1E1E1E),
      dialogBackgroundColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.grey[800],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6C63FF),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF6C63FF),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey[900],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6C63FF),
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[600]),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        prefixIconColor: const Color(0xFF6C63FF),
      ),
      fontFamily: 'SYMBIOAR+LT',
    );
  }

  // تعريف ثيم الوضع الفاتح
  ThemeData _getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFF),
      primaryColor: const Color(0xFF221291),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF221291),
        secondary: Color(0xFF6C63FF),
        background: Color(0xFFFAFAFF),
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF221291)),
        titleTextStyle: TextStyle(
          color: Color(0xFF221291),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
      cardColor: Colors.white,
      dialogBackgroundColor: Colors.white,
      dividerColor: Colors.grey[300],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF221291),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF221291),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF221291),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFFF6F4FF),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6C63FF),
            width: 1.5,
          ),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle:
            TextStyle(color: Colors.grey[600], fontFamily: 'SYMBIOAR+LT'),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        prefixIconColor: const Color(0xFF221291),
      ),
      fontFamily: 'SYMBIOAR+LT',
    );
  }
}

/// الدالة الرئيسية لتشغيل التطبيق
/// مهيّأة للعمل مع Firebase
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // تعيين لغة Firebase
    FirebaseAuth.instance.setLanguageCode('ar');

    // تهيئة App Check لحل مشكلة التحذيرات
    await FirebaseAppCheck.instance.activate(
      // للتطوير
      androidProvider: AndroidProvider.debug,
      // للإنتاج
      // androidProvider: AndroidProvider.playIntegrity,
      // iosProvider: IOSProvider.appAttest,
    );

    // تعيين إعدادات Firestore للأداء الأفضل
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('خطأ في تهيئة Firebase: $e');
    // محاولة إعادة تهيئة Firebase عبر القناة المخصصة (اختياري)
    try {
      const MethodChannel methodChannel = MethodChannel('app.channel/firebase');
      await methodChannel.invokeMethod('reinitializeFirebase');
    } catch (channelError) {
      debugPrint('فشل إعادة تهيئة Firebase عبر القناة: $channelError');
    }
  }

  // تهيئة مزود الثيم
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  /// تشغيل التطبيق مع إضافة مزود الثيم
  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

/// StatelessWidget رئيسي للتطبيق
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام Consumer للاستماع للتغييرات في الثيم
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          /// إخفاء شريط DEBUG
          debugShowCheckedModeBanner: false,

          /// تفعيل اللغة العربية والاتجاه RTL
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', ''), // إضافة اللغة العربية كلغة معتمدة
          ],
          locale: const Locale('ar', ''), // جعل العربية اللغة الافتراضية

          /// استخدام الثيم المناسب حسب وضع الثيم (فاتح/داكن)
          theme: themeProvider.getTheme(),

          /// عرض شاشة التحقق من حالة الدخول مباشرة
          home: const AuthChecker(),

          /// تعريف المسارات المختلفة في التطبيق
          routes: {
            '/home': (context) => const AuthChecker(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),
          },

          // معالجة المسارات غير المعروفة - تم تعديل هذا الجزء للحصول على انتقالات بدون تأثيرات
          onGenerateRoute: (settings) {
            debugPrint('محاولة الوصول إلى مسار: ${settings.name}');
            switch (settings.name) {
              case '/login':
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, _, __) => const LoginScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                );
              case '/signup':
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, _, __) => const SignUpScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                );
              case '/reset-password':
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, _, __) => const ResetPasswordScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                );
              case '/home':
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, _, __) => const AuthChecker(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                );
              default:
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, _, __) => const LoginScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                );
            }
          },
        );
      },
    );
  }
}

/// Widget يتحقق مما إذا كان المستخدم مسجّل دخوله أم لا
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  /// دالة تسجيل الخروج المتكاملة - تستخدم في جميع أنحاء التطبيق
  static Future<void> signOut(BuildContext context) async {
    try {
      debugPrint('بدء عملية تسجيل الخروج...');

      // 1. تسجيل الخروج من Firebase Auth
      await FirebaseAuth.instance.signOut();

      // 2. مسح بيانات الاعتماد وبيانات المستخدم من التخزين المحلي
      final prefs = await SharedPreferences.getInstance();

      // تعيين علامة تسجيل الخروج الصريح
      await prefs.setBool('explicit_logout', true);

      // مسح بيانات تسجيل الدخول التلقائي
      await prefs.remove('user_email');
      await prefs.remove('user_password');

      // مسح وقت آخر محاولات التحقق من الحساب
      await prefs.remove('last_auto_login_attempt');
      await prefs.remove('last_login_attempt');
      await prefs.remove('last_signin_attempt');
      await prefs.remove('last_email_check');
      await prefs.remove('last_resend_attempt');

      // مسح بيانات المستخدم المحلية
      await prefs.remove(TabsConstants.prefUserNameKey);
      await prefs.remove(TabsConstants.prefUserMajorKey);
      await prefs.remove(TabsConstants.prefUserIdKey);

      // تسجيل نجاح العملية
      debugPrint('تم تسجيل الخروج ومسح البيانات المحلية بنجاح');

      // 3. التوجيه إلى شاشة تسجيل الدخول
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint('خطأ في تسجيل الخروج: $e');

      // إظهار رسالة خطأ للمستخدم
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الخروج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة تسجيل الدخول مع دعم الدخول التلقائي
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, autoLoginSnapshot) {
        if (autoLoginSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // إذا نجح تسجيل الدخول التلقائي
        if (autoLoginSnapshot.data == true) {
          final userId = FirebaseAuth.instance.currentUser!.uid;

          // استخدام FutureBuilder لجلب بيانات المستخدم
          return FutureBuilder<Map<String, dynamic>>(
            future: _getUserDataCombined(userId),
            builder: (context, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final data =
                  dataSnapshot.data ?? {'name': 'مستخدم', 'major': 'غير محدد'};
              final userName = data['name'] as String;
              final userMajor = data['major'] as String;

              debugPrint('تم استرجاع اسم المستخدم: $userName');
              debugPrint('تم استرجاع تخصص المستخدم: $userMajor');

              return HomeScreen(
                userName: userName,
                userMajor: userMajor,
              );
            },
          );
        }

        // إذا فشل تسجيل الدخول التلقائي، الاستماع لتغيرات حالة المستخدم
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (userSnapshot.hasData && userSnapshot.data != null) {
              final userId = userSnapshot.data!.uid;

              return FutureBuilder<Map<String, dynamic>>(
                future: _getUserDataCombined(userId),
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final data = dataSnapshot.data ??
                      {'name': 'مستخدم', 'major': 'غير محدد'};
                  final userName = data['name'] as String;
                  final userMajor = data['major'] as String;

                  debugPrint('تم استرجاع اسم المستخدم: $userName');
                  debugPrint('تم استرجاع تخصص المستخدم: $userMajor');

                  return HomeScreen(
                    userName: userName,
                    userMajor: userMajor,
                  );
                },
              );
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    );
  }

  /// التحقق مما إذا كان المستخدم مسجل الدخول بالفعل
  Future<bool> _isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // التحقق مما إذا كان المستخدم قد سجل الخروج صراحة
      final explicitLogout = prefs.getBool('explicit_logout') ?? false;
      if (explicitLogout) {
        // إعادة تعيين العلامة لجلسة جديدة محتملة
        await prefs.setBool('explicit_logout', false);
        debugPrint(
            'تم اكتشاف تسجيل خروج صريح، تخطي محاولة تسجيل الدخول التلقائي');
        return false;
      }

      // التحقق من FirebaseAuth أولاً
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        debugPrint('Firebase Auth: المستخدم مسجل الدخول بالفعل (${user.uid})');
        return true;
      }

      // تقييد محاولات تسجيل الدخول التلقائي
      final lastAutoLogin = prefs.getInt('last_auto_login_attempt');
      final now = DateTime.now().millisecondsSinceEpoch;

      // عدم محاولة تسجيل الدخول التلقائي أكثر من مرة كل 1 دقيقة
      if (lastAutoLogin != null && now - lastAutoLogin < 60000) {
        debugPrint('تجاوز محاولة تسجيل الدخول التلقائي لتجنب تجاوز الحصة');
        return false;
      }

      await prefs.setInt('last_auto_login_attempt', now);

      // إذا لم يكن هناك مستخدم حالي، التحقق من التخزين المحلي
      final email = prefs.getString('user_email');
      final password = prefs.getString('user_password');

      // إذا كانت معلومات تسجيل الدخول مخزنة محليًا، نحاول تسجيل الدخول تلقائياً
      if (email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        debugPrint('محاولة تسجيل الدخول التلقائي للبريد: $email');

        try {
          // محاولة تسجيل الدخول باستخدام البيانات المخزنة
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          debugPrint('تم تسجيل الدخول التلقائي بنجاح');
          return true;
        } catch (e) {
          debugPrint('فشل تسجيل الدخول التلقائي: $e');

          // إذا كان السبب هو تجاوز الحصة، لا تمسح بيانات الاعتماد
          if (e.toString().contains('too-many-requests') ||
              e.toString().contains('quota')) {
            debugPrint(
                'تم تجاوز حصة محاولات تسجيل الدخول - لن يتم مسح بيانات الاعتماد');
            return false;
          }

          // إزالة البيانات المخزنة إذا فشل تسجيل الدخول التلقائي لسبب آخر
          await prefs.remove('user_email');
          await prefs.remove('user_password');
          // مسح بيانات المستخدم المحلية أيضًا
          await prefs.remove(TabsConstants.prefUserNameKey);
          await prefs.remove(TabsConstants.prefUserMajorKey);
          await prefs.remove(TabsConstants.prefUserIdKey);
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('خطأ في التحقق من حالة تسجيل الدخول: $e');
      return false;
    }
  }

  // استرجاع بيانات المستخدم من كلا SharedPreferences وFirestore
  Future<Map<String, dynamic>> _getUserDataCombined(String userId) async {
    try {
      debugPrint('بدء جلب بيانات المستخدم لـ ID: $userId');

      // الأولوية لبيانات Firestore، لذلك نبدأ بها أولاً
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (docSnapshot.exists) {
          final userData = docSnapshot.data() as Map<String, dynamic>;
          String name = userData['name']?.toString() ?? 'مستخدم';
          String major = userData['major']?.toString() ?? 'غير محدد';

          // تحديث التخزين المحلي بالبيانات من Firestore
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(TabsConstants.prefUserNameKey, name);
          await prefs.setString(TabsConstants.prefUserMajorKey, major);
          await prefs.setString(TabsConstants.prefUserIdKey, userId);

          debugPrint('تم جلب البيانات من Firestore: name=$name, major=$major');
          return {
            'name': name,
            'major': major,
          };
        }
      } catch (firestoreError) {
        debugPrint('خطأ في جلب بيانات Firestore: $firestoreError');
        // سنستمر وننتقل للخطوة التالية
      }

      // إذا لم نتمكن من الوصول لبيانات Firestore، استخدم التخزين المحلي
      final prefs = await SharedPreferences.getInstance();
      String? cachedName = prefs.getString(TabsConstants.prefUserNameKey);
      String? cachedMajor = prefs.getString(TabsConstants.prefUserMajorKey);
      final cachedUserId = prefs.getString(TabsConstants.prefUserIdKey);

      // تحقق من أن البيانات المخزنة تخص نفس المستخدم الحالي
      if (cachedUserId == userId && cachedName != null && cachedMajor != null) {
        debugPrint(
            'استخدام البيانات المخزنة محليًا: name=$cachedName, major=$cachedMajor');
        return {
          'name': cachedName,
          'major': cachedMajor,
        };
      }

      // إذا وصلنا هنا، فإما لا توجد بيانات أو البيانات لا تخص المستخدم الحالي
      // قم بإنشاء بيانات افتراضية وتخزينها
      debugPrint('إنشاء بيانات افتراضية للمستخدم: $userId');
      await _createUserDocument(
          userId, FirebaseAuth.instance.currentUser!, null);

      return {
        'name': 'مستخدم',
        'major': 'غير محدد',
      };
    } catch (e) {
      debugPrint('خطأ في استرجاع بيانات المستخدم: $e');
      return {
        'name': 'مستخدم',
        'major': 'غير محدد',
      };
    }
  }

  // إنشاء وثيقة المستخدم في Firestore
  Future<void> _createUserDocument(
      String userId, User user, Map<String, String>? cachedData) async {
    try {
      debugPrint('جاري إنشاء وثيقة مستخدم جديدة لـ $userId');

      // التحقق أولاً إذا كانت الوثيقة موجودة بالفعل
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // إذا لم تكن الوثيقة موجودة، نقوم بإنشائها
      if (!docSnapshot.exists) {
        // استخدام بيانات المستخدم المخزنة محلياً إذا كانت متاحة
        String name = 'مستخدم';
        String major = 'غير محدد';

        if (cachedData != null) {
          name = cachedData['name'] ?? name;
          major = cachedData['major'] ?? major;
          debugPrint(
              'استخدام البيانات المخزنة محلياً لإنشاء وثيقة: اسم=$name، تخصص=$major');
        } else if (user.displayName != null && user.displayName!.isNotEmpty) {
          name = user.displayName!;
          debugPrint('استخدام اسم العرض من حساب المستخدم: $name');
        }

        // إنشاء وثيقة المستخدم بالبيانات المتاحة
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': name,
          'major': major,
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'uid': userId,
        });

        debugPrint('تم إنشاء وثيقة مستخدم جديدة بنجاح');

        // تخزين البيانات محلياً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(TabsConstants.prefUserNameKey, name);
        await prefs.setString(TabsConstants.prefUserMajorKey, major);
        await prefs.setString(TabsConstants.prefUserIdKey, userId);
      } else {
        debugPrint('وثيقة المستخدم موجودة بالفعل');
      }
    } catch (e) {
      debugPrint('خطأ في إنشاء وثيقة المستخدم: $e');
    }
  }
}
