import 'package:flutter/material.dart';

/// ثوابت الملف الشخصي
class ProfileConstants {
  // ألوان التطبيق الموحدة - متطابقة مع صفحة التسجيل
  static const Color primaryColor = Color(0xFF4A25AA);
  static const Color secondaryColor = Color(0xFF42A5F5);
  static const Color accentColor = Color(0xFFFFA726);
  static const Color dangerColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);

  // ألوان إضافية متطابقة مع تصميم الصفحة القديمة
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColorPink = Color(0xFFEC4899);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);
  static const Color kShadowColor = Color(0x0D221291);
  static const Color kTextColor = Color(0xFF374151);
  static const Color kHintColor = Color(0xFF9CA3AF);

  // ثوابت التباعد والأحجام
  static const double defaultPadding = 20.0;
  static const double smallPadding = 5.0;
  static const double mediumPadding = 15.0;
  static const double largePadding = 30.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 52.0;

  // أحجام الخطوط
  static const double titleFontSize = 24.0;
  static const double subtitleFontSize = 14.0;
  static const double inputTextFontSize = 15.0;
  static const double buttonTextFontSize = 16.0;
  static const double errorTextFontSize = 12.0;

  // النصوص
  static const String defaultUserName = 'مستخدم';
  static const String defaultUserMajor = 'غير محدد';
  static const String profileTitle = 'الملف الشخصي';
  static const String editProfileTitle = 'تعديل الملف الشخصي';
  static const String editProfileSubtitle = 'يمكنك تحديث بياناتك الشخصية';
  static const String changePasswordTitle = 'تغيير كلمة المرور';
  static const String deleteAccountTitle = 'حذف الحساب';

  // المفاتيح المستخدمة في التخزين المحلي
  static const String prefUserNameKey = 'user_name';
  static const String prefUserMajorKey = 'user_major';
  static const String prefUserIdKey = 'logged_user_id';

  // رسائل
  static const String updateSuccessMessage = 'تم تحديث الملف الشخصي بنجاح';
  static const String updateFailMessage = 'فشل في تحديث الملف الشخصي';
  static const String passwordChangeSuccessMessage =
      'تم تغيير كلمة المرور بنجاح';
  static const String passwordChangeFailMessage = 'فشل في تغيير كلمة المرور';
  static const String deleteAccountSuccessMessage = 'تم حذف الحساب بنجاح';
  static const String deleteAccountFailMessage = 'فشل في حذف الحساب';
  static const String invalidCurrentPasswordMessage =
      'كلمة المرور الحالية غير صحيحة';
  static const String errorPrefix = 'خطأ: ';
  static const String formValidationError = 'لم يتم التحقق من صحة النموذج';
  static const String successMessage = 'تم التحديث بنجاح!';

  // رسائل الحقول الفارغة
  static const String emptyNameError = 'الرجاء إدخال الاسم';
  static const String emptyMajorError = 'الرجاء إدخال التخصص';
  static const String emptyCurrentPasswordError =
      'الرجاء إدخال كلمة المرور الحالية';
  static const String emptyNewPasswordError =
      'الرجاء إدخال كلمة المرور الجديدة';
  static const String emptyConfirmPasswordError =
      'الرجاء تأكيد كلمة المرور الجديدة';
  static const String passwordMismatchError = 'كلمات المرور غير متطابقة';
  static const String passwordLengthError =
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  // عناوين الحقول
  static const String nameFieldTitle = 'الاسم الكامل';
  static const String majorFieldTitle = 'التخصص';
  static const String emailFieldTitle = 'البريد الإلكتروني';

  // تعليمات حقول الإدخال
  static const String nameHint = 'أدخل اسمك الكامل';
  static const String majorHint = 'أدخل تخصصك الدراسي';
  static const String emailHint = 'أدخل بريدك الإلكتروني';
  static const String currentPasswordHint = 'أدخل كلمة المرور الحالية';
  static const String newPasswordHint = 'أدخل كلمة المرور الجديدة';
  static const String confirmPasswordHint = 'أكد كلمة المرور الجديدة';

  // رسائل الخطأ للتحقق
  static const String nameErrorMessage = 'اسم غير صحيح';
  static const String majorErrorMessage = 'تخصص غير صحيح';
  static const String emailErrorMessage = 'بريد إلكتروني غير صحيح';

  // نصوص الأزرار
  static const String saveButtonText = 'حفظ التغييرات';
  static const String cancelText = 'إلغاء';
  static const String backButtonTooltip = 'رجوع';
  static const String saveText = 'حفظ';
  static const String deleteText = 'حذف';
  static const String confirmText = 'تأكيد';
  static const String changePasswordButtonText = 'تغيير';

  // عناوين الأقسام
  static const String personalSettingsTitle = 'الإعدادات الشخصية';
  static const String securitySettingsTitle = 'الخصوصية والأمان';

  // أوصاف الإعدادات
  static const String editProfileSubtext =
      'تغيير الاسم، التخصص، والبيانات الشخصية';
  static const String changePasswordSubtitle = 'تحديث كلمة المرور الخاصة بك';
  static const String deleteAccountSubtitle = 'حذف حسابك وجميع بياناتك نهائياً';

  // تأكيد حذف الحساب
  static const String deleteAccountConfirmationTitle = 'تأكيد حذف الحساب';
  static const String deleteAccountConfirmationMessage =
      'هل أنت متأكد من رغبتك في حذف الحساب؟ هذا الإجراء لا يمكن التراجع عنه.';
  static const String confirmPasswordTitle = 'تأكيد كلمة المرور';
  static const String confirmPasswordForDeleteMessage =
      'الرجاء إدخال كلمة المرور الحالية لتأكيد حذف الحساب';

  // أخطاء عامة
  static const String generalErrorMessage = 'حدث خطأ غير متوقع';
  static const String loadingErrorMessage =
      'حدث خطأ أثناء تحميل بيانات الملف الشخصي';
  static const String deleteAccountErrorPrefix = 'حدث خطأ أثناء حذف الحساب: ';
  static const String networkErrorMessage = 'يرجى التحقق من اتصالك بالإنترنت';

  // نص التحميل
  static const String loadingDataText = 'جاري تحميل البيانات...';
}
