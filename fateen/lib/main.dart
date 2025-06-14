import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
// إضافة استيراد لإشعارات Firebase
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:fateen/screens/authentication/login/screens/login_screen.dart';
import 'package:fateen/screens/authentication/signup/screens/signup_screen.dart';
import 'package:fateen/screens/authentication/reset_password/screens/reset_password_screen.dart';
import 'package:fateen/screens/home/home_screen/home_screen.dart';
import 'package:fateen/screens/home/home_screen/home_constants.dart';
// استيراد ملف الألوان
import 'core/constants/appColor.dart';

// معالج الإشعارات في الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // تأكد من تهيئة Firebase قبل معالجة الإشعارات في الخلفية
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('تم استلام إشعار في الخلفية: ${message.messageId}');
}

// مزود للثيم لدعم الوضع الليلي في التطبيق
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _followSystem = true; // متغير جديد لتتبع ما إذا كان يتبع إعدادات النظام

  bool get isDarkMode => _isDarkMode;
  bool get followSystem => _followSystem;

  // تهيئة الحالة من التخزين المحلي
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _followSystem = prefs.getBool('followSystemTheme') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // تحديث حالة الثيم بناءً على وضع النظام
  void updateWithPlatformBrightness(Brightness platformBrightness) {
    if (_followSystem) {
      final isDark = platformBrightness == Brightness.dark;
      if (_isDarkMode != isDark) {
        _isDarkMode = isDark;
        notifyListeners();
      }
    }
  }

  // تغيير الوضع وحفظ الإعداد
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _followSystem = false; // عند التبديل يدوياً، نتوقف عن اتباع النظام

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('followSystemTheme', false);

    notifyListeners();
  }

  // تبديل حالة اتباع النظام
  Future<void> toggleFollowSystem() async {
    _followSystem = !_followSystem;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystemTheme', _followSystem);

    // إذا فعّلنا اتباع النظام، نحدث حالة الثيم فوراً
    if (_followSystem) {
      final platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _isDarkMode = platformBrightness == Brightness.dark;
      await prefs.setBool('isDarkMode', _isDarkMode);
    }

    notifyListeners();
  }

  // الحصول على ثيم بناءً على الإعداد
  ThemeData getTheme({Brightness? platformBrightness}) {
    // إذا كان يتبع النظام وتم تمرير platformBrightness، استخدم ذلك لتحديد الوضع
    bool shouldUseDarkMode = _isDarkMode;
    if (_followSystem && platformBrightness != null) {
      shouldUseDarkMode = platformBrightness == Brightness.dark;
    }

    return shouldUseDarkMode ? _getDarkTheme() : _getLightTheme();
  }

  // تعريف ثيم الوضع الداكن
  ThemeData _getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkPrimary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkAccent,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        error: AppColors.darkError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
      cardColor: AppColors.darkSurface,
      dialogBackgroundColor: AppColors.darkSurface,
      dividerColor: AppColors.darkDivider,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.darkSurface,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.darkPrimaryLight,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.darkError,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.darkError,
            width: 1.5,
          ),
        ),
        labelStyle: TextStyle(color: AppColors.darkTextSecondary),
        hintStyle: TextStyle(color: AppColors.darkTextHint),
        errorStyle: TextStyle(color: AppColors.darkError),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        prefixIconColor: AppColors.darkPrimary,
        suffixIconColor: AppColors.darkTextSecondary,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.darkTextPrimary),
        displayMedium: TextStyle(color: AppColors.darkTextPrimary),
        displaySmall: TextStyle(color: AppColors.darkTextPrimary),
        headlineLarge: TextStyle(color: AppColors.darkTextPrimary),
        headlineMedium: TextStyle(color: AppColors.darkTextPrimary),
        headlineSmall: TextStyle(color: AppColors.darkTextPrimary),
        titleLarge: TextStyle(color: AppColors.darkTextPrimary),
        titleMedium: TextStyle(color: AppColors.darkTextPrimary),
        titleSmall: TextStyle(color: AppColors.darkTextPrimary),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
        bodySmall: TextStyle(color: AppColors.darkTextSecondary),
        labelLarge: TextStyle(color: AppColors.darkTextPrimary),
        labelMedium: TextStyle(color: AppColors.darkTextPrimary),
        labelSmall: TextStyle(color: AppColors.darkTextSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.darkPrimary;
          }
          return AppColors.darkTextSecondary;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.darkPrimary;
          }
          return AppColors.darkTextSecondary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.darkPrimary;
          }
          return AppColors.darkTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.darkPrimaryLight.withOpacity(0.5);
          }
          return AppColors.darkDisabledState;
        }),
      ),
      fontFamily: 'SYMBIOAR+LT',
    );
  }

  // تعريف ثيم الوضع الفاتح
  ThemeData _getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
      cardColor: AppColors.surface,
      dialogBackgroundColor: AppColors.surface,
      dividerColor: AppColors.divider,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.surface,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle:
            TextStyle(color: AppColors.textHint, fontFamily: 'SYMBIOAR+LT'),
        errorStyle: TextStyle(color: AppColors.error),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.textSecondary,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary),
        displayMedium: TextStyle(color: AppColors.textPrimary),
        displaySmall: TextStyle(color: AppColors.textPrimary),
        headlineLarge: TextStyle(color: AppColors.textPrimary),
        headlineMedium: TextStyle(color: AppColors.textPrimary),
        headlineSmall: TextStyle(color: AppColors.textPrimary),
        titleLarge: TextStyle(color: AppColors.textPrimary),
        titleMedium: TextStyle(color: AppColors.textPrimary),
        titleSmall: TextStyle(color: AppColors.textPrimary),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
        labelLarge: TextStyle(color: AppColors.textPrimary),
        labelMedium: TextStyle(color: AppColors.textPrimary),
        labelSmall: TextStyle(color: AppColors.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight.withOpacity(0.5);
          }
          return AppColors.disabledState;
        }),
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

    // تسجيل معالج الإشعارات في الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

    // تهيئة إشعارات Firebase
    await _initializeFirebaseMessaging();

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

/// تهيئة إشعارات Firebase
Future<void> _initializeFirebaseMessaging() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // طلب أذونات الإشعارات (مطلوب خاصة في iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  debugPrint('إعدادات أذونات الإشعارات: ${settings.authorizationStatus}');

  // الحصول على رمز الجهاز لإرسال الإشعارات المستهدفة
  String? token = await messaging.getToken();
  debugPrint('رمز الجهاز FCM: $token');

  // تخزين رمز الجهاز في SharedPreferences للاستخدام لاحقًا
  if (token != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);

    // تحديث رمز الجهاز في Firestore عند تسجيل الدخول
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _updateFCMTokenInFirestore(currentUser.uid, token);
    }
  }

  // الاستماع لتحديثات رمز الجهاز (يحدث عندما يتم تجديد الرمز)
  messaging.onTokenRefresh.listen((newToken) async {
    debugPrint('تم تجديد رمز الجهاز FCM: $newToken');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', newToken);

    // تحديث رمز الجهاز في Firestore إذا كان المستخدم مسجل الدخول
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _updateFCMTokenInFirestore(currentUser.uid, newToken);
    }
  });

  // إعداد معالج الإشعارات في الواجهة الأمامية
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('تم استلام إشعار في الواجهة الأمامية:');
    debugPrint('العنوان: ${message.notification?.title}');
    debugPrint('الرسالة: ${message.notification?.body}');
    debugPrint('البيانات: ${message.data}');

    // يمكن هنا عرض الإشعار باستخدام مكتبة مثل flutter_local_notifications
  });
}

/// تحديث رمز الجهاز في Firestore
Future<void> _updateFCMTokenInFirestore(String userId, String token) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcm_tokens': FieldValue.arrayUnion([token]),
      'last_fcm_token': token,
      'last_seen': FieldValue.serverTimestamp(),
    });
    debugPrint('تم تحديث رمز الجهاز FCM في Firestore');
  } catch (e) {
    debugPrint('خطأ في تحديث رمز الجهاز FCM: $e');
  }
}

/// StatelessWidget رئيسي للتطبيق
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام Consumer للاستماع للتغييرات في الثيم
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // استخدام MediaQuery للحصول على وضع الثيم للنظام
        final platformBrightness = MediaQuery.platformBrightnessOf(context);

        // تحديث حالة الثيم بناءً على وضع النظام
        themeProvider.updateWithPlatformBrightness(platformBrightness);

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
          theme: themeProvider.getTheme(platformBrightness: platformBrightness),
          themeMode: themeProvider.followSystem
              ? ThemeMode.system
              : (themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light),

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

              // تحديث رمز FCM بعد تسجيل الدخول
              _updateFCMTokenAfterLogin(userId);

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

              // تحديث رمز FCM بعد تسجيل الدخول
              _updateFCMTokenAfterLogin(userId);

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

  /// تحديث رمز FCM بعد تسجيل الدخول
  Future<void> _updateFCMTokenAfterLogin(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');

      if (token != null) {
        await _updateFCMTokenInFirestore(userId, token);
      } else {
        // محاولة الحصول على رمز جديد إذا لم يكن متوفراً
        final newToken = await FirebaseMessaging.instance.getToken();
        if (newToken != null) {
          await prefs.setString('fcm_token', newToken);
          await _updateFCMTokenInFirestore(userId, newToken);
        }
      }
    } catch (e) {
      debugPrint('خطأ في تحديث رمز FCM بعد تسجيل الدخول: $e');
    }
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

        // الحصول على رمز FCM الحالي
        final prefs = await SharedPreferences.getInstance();
        final fcmToken = prefs.getString('fcm_token');

        // إنشاء وثيقة المستخدم بالبيانات المتاحة
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': name,
          'major': major,
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'uid': userId,
          'fcm_tokens': fcmToken != null ? [fcmToken] : [],
          'last_fcm_token': fcmToken,
          'last_seen': FieldValue.serverTimestamp(),
        });

        debugPrint('تم إنشاء وثيقة مستخدم جديدة بنجاح');

        // تخزين البيانات محلياً
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
