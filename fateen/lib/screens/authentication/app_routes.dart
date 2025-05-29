/// ملف مسارات التطبيق - يحتوي على جميع مسارات التنقل المستخدمة في التطبيق
class AppRoutes {
  // مسارات المصادقة
  static const String login = '/login';
  static const String signup = '/signup';
  static const String resetPassword = '/reset-password';
  static const String verification = '/verification';

  // المسارات الرئيسية
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // مسارات أخرى قد تضاف لاحقاً
  static const String notifications = '/notifications';
  static const String search = '/search';
}
