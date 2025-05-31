class SignupStrings {
  // عناوين الصفحة
  static const String signupTitle = "إنشاء حساب جديد";
  static const String formInfoText = "أدخل بياناتك لإنشاء حساب";

  // حقول النموذج
  static const String fullNameLabel = "الاسم الكامل";
  static const String fullNameHint = "أدخل اسمك الكامل";

  // حقول النموذج الجديدة
  static const String usernameLabel = "اسم المستخدم";
  static const String usernameHint = "أدخل اسم المستخدم الخاص بك";

  static const String universityNameLabel = "الجامعة";
  static const String universityNameHint = "اختر الجامعة";
  static const String universityRequiredError = "الرجاء اختيار الجامعة";
  static const String universityPickerTitle = "اختر الجامعة";

  static const String emailLabel = "البريد الإلكتروني";
  static const String emailHint = "أدخل بريدك الإلكتروني";

  static const String passwordLabel = "كلمة المرور";
  static const String passwordHint = "أدخل كلمة المرور";

  static const String majorLabel = "التخصص";
  static const String majorHint = "اختر تخصصك";
  static const String majorRequiredError = "الرجاء اختيار التخصص";
  static const String majorPickerTitle = "اختر التخصص";

  // أزرار
  static const String signupButtonText = "إنشاء حساب";
  static const String backButtonText = "رجوع";
  static const String cancelButtonText = "إلغاء";
  static const String doneButtonText = "تم";

  // النصوص المساعدة
  static const String orLoginWith = "أو سجل باستخدام";
  static const String termsAgreementText = "بالتسجيل، أنت توافق على ";
  static const String termsText = "الشروط والأحكام";

  // رسائل الخطأ
  static const String commonErrorMessage = "حدث خطأ، يرجى المحاولة مرة أخرى";
  static const String usernameExistsError =
      "اسم المستخدم مستخدم بالفعل، الرجاء اختيار اسم آخر";

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

  // قائمة الجامعات السعودية
  static const List<String> universities = [
    'جامعة الملك سعود',
    'جامعة الملك عبدالعزيز',
    'جامعة الملك فهد للبترول والمعادن',
    'جامعة الملك خالد',
    'جامعة الملك فيصل',
    'جامعة أم القرى',
    'جامعة الإمام محمد بن سعود الإسلامية',
    'جامعة القصيم',
    'جامعة طيبة',
    'جامعة الطائف',
    'جامعة حائل',
    'جامعة جازان',
    'جامعة الجوف',
    'جامعة الباحة',
    'جامعة تبوك',
    'جامعة نجران',
    'جامعة الحدود الشمالية',
    'جامعة الأميرة نورة بنت عبدالرحمن',
    'جامعة الملك سعود بن عبدالعزيز للعلوم الصحية',
    'الجامعة السعودية الإلكترونية',
    'جامعة الأمير سطام بن عبدالعزيز',
    'جامعة شقراء',
    'جامعة المجمعة',
    'جامعة جدة',
    'جامعة بيشة',
    'جامعة حفر الباطن',
    'جامعة الملك عبدالله للعلوم والتقنية (كاوست)',
    'أخرى'
  ];
}
