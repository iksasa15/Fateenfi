library web_helper;

// هذا ملف بديل لاستخدامه عند تشغيل التطبيق على منصات غير الويب
// يعمل كبديل لـ dart:html عندما لا يكون متاحًا
class html {
  static dynamic window;
  static dynamic document;
  static dynamic navigator;
  static dynamic localStorage;
  static dynamic sessionStorage;
  static dynamic history;
  static dynamic location;
}
