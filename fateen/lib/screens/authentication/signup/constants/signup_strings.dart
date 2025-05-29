class SignupStrings {
  // عناوين الصفحة
  static const String signupTitle = "إنشاء حساب جديد";
  static const String formInfoText = "أدخل بياناتك لإنشاء حساب";

  // حقول النموذج
  static const String fullNameLabel = "الاسم الكامل";
  static const String fullNameHint = "أدخل اسمك الكامل";

  static const String emailLabel = "البريد الإلكتروني";
  static const String emailHint = "أدخل بريدك الإلكتروني";

  static const String passwordLabel = "كلمة المرور";
  static const String passwordHint = "أدخل كلمة المرور";

  static const String majorLabel = "التخصص";
  static const String majorHint = "اختر تخصصك";
  static const String majorRequiredError = "الرجاء اختيار التخصص";

  // أزرار
  static const String signupButtonText = "إنشاء حساب";
  static const String backButtonText = "رجوع";

  // النصوص المساعدة
  static const String orLoginWith = "أو سجل باستخدام";
  static const String termsAgreementText = "بالتسجيل، أنت توافق على ";
  static const String termsText = "الشروط والأحكام";

  // رسائل الخطأ
  static const String commonErrorMessage = "حدث خطأ، يرجى المحاولة مرة أخرى";

  // قائمة التخصصات
  static const List<String> majors = [
    'هندسة برمجيات',
    'علوم الحاسب',
    'نظم المعلومات',
    'تقنية المعلومات',
    'ذكاء اصطناعي',
    'أمن سيبراني',
    'أخرى'
  ];
}
