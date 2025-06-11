import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SemesterProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // مجموعة البيانات في Firestore
  final String _semesterCollection = 'semester_data';

  // مفاتيح التخزين المحلي
  static const String _localEndDateKey = 'semester_end_date';
  static const String _localStartDateKey = 'semester_start_date';
  static const String _localTotalDaysKey = 'semester_total_days';
  static const String _localPassedDaysKey = 'semester_passed_days';

  // الحصول على بيانات الفصل الدراسي
  Future<Map<String, dynamic>> getSemesterData() async {
    try {
      // التحقق من وجود بيانات محلية أولاً
      final localData = await _getLocalSemesterData();
      if (localData.isNotEmpty) {
        print('استخدام بيانات الفصل الدراسي المحلية');
        return localData;
      }

      // الحصول على المستخدم الحالي
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // الحصول على بيانات الفصل الدراسي المرتبطة بالمستخدم
        final DocumentSnapshot semesterDoc = await _firestore
            .collection(_semesterCollection)
            .doc(currentUser.uid)
            .get();

        if (semesterDoc.exists && semesterDoc.data() != null) {
          final data = semesterDoc.data() as Map<String, dynamic>;

          // تخزين البيانات محلياً للاستخدام المستقبلي
          await _saveLocalSemesterData(data);

          return data;
        }
      }

      // إذا لم يتم العثور على بيانات للمستخدم، نحصل على البيانات العامة
      final DocumentSnapshot defaultSemesterDoc =
          await _firestore.collection(_semesterCollection).doc('default').get();

      if (defaultSemesterDoc.exists && defaultSemesterDoc.data() != null) {
        final data = defaultSemesterDoc.data() as Map<String, dynamic>;

        // تخزين البيانات محلياً للاستخدام المستقبلي
        await _saveLocalSemesterData(data);

        return data;
      }

      // القيم الافتراضية إذا لم يتم العثور على أي بيانات
      final defaultData = {
        'totalDays': 105,
        'passedDays': 65,
        'startDate': '2025-03-15',
        'endDate': '2025-06-28',
      };

      // تخزين البيانات الافتراضية محلياً
      await _saveLocalSemesterData(defaultData);

      return defaultData;
    } catch (e) {
      print('خطأ في الحصول على بيانات الفصل الدراسي: $e');

      // التحقق من وجود بيانات محلية في حالة الخطأ
      final localData = await _getLocalSemesterData();
      if (localData.isNotEmpty) {
        return localData;
      }

      // إرجاع قيم افتراضية في حالة حدوث خطأ وعدم وجود بيانات محلية
      final defaultData = {
        'totalDays': 105,
        'passedDays': 65,
        'startDate': '2025-03-15',
        'endDate': '2025-06-28',
      };

      // تخزين البيانات الافتراضية محلياً
      await _saveLocalSemesterData(defaultData);

      return defaultData;
    }
  }

  // تحديث تاريخ نهاية الفصل الدراسي
  Future<bool> updateSemesterEndDate(DateTime newEndDate) async {
    try {
      // الحصول على المستخدم الحالي
      final User? currentUser = _auth.currentUser;

      // الحصول على البيانات الحالية أولاً
      final Map<String, dynamic> currentData = await getSemesterData();

      // الحصول على تاريخ البداية
      DateTime startDate;
      if (currentData.containsKey('startDate')) {
        startDate = DateTime.parse(currentData['startDate']);
      } else {
        startDate = DateTime.parse('2025-03-15');
      }

      // حساب إجمالي عدد الأيام بين تاريخ البداية وتاريخ النهاية الجديد
      final int totalDays = newEndDate.difference(startDate).inDays + 1;

      // حساب عدد الأيام التي مرت منذ بداية الفصل حتى اليوم
      final int passedDays = DateTime.now().difference(startDate).inDays + 1;

      // تحديث البيانات المحلية أولاً
      final newData = {
        'totalDays': totalDays,
        'passedDays': passedDays,
        'startDate': currentData['startDate'] ?? '2025-03-15',
        'endDate':
            newEndDate.toIso8601String().split('T')[0], // تخزين التاريخ فقط
      };

      // حفظ البيانات المحدثة محلياً
      await _saveLocalSemesterData(newData);

      // محاولة تحديث البيانات في Firestore (قد تفشل بسبب الصلاحيات)
      if (currentUser != null) {
        try {
          await _firestore
              .collection(_semesterCollection)
              .doc(currentUser.uid)
              .set(newData, SetOptions(merge: true));
          print('تم تحديث بيانات الفصل الدراسي في Firebase بنجاح');
        } catch (e) {
          // لا داعي لفشل العملية إذا فشل التحديث في Firebase
          // لأننا قمنا بالفعل بحفظ البيانات محلياً
          print('تعذر تحديث بيانات الفصل الدراسي في Firebase: $e');
          print('تم الاعتماد على التخزين المحلي');
        }
      }

      return true;
    } catch (e) {
      print('خطأ في تحديث تاريخ نهاية الفصل الدراسي: $e');
      return false;
    }
  }

  // حفظ بيانات الفصل الدراسي محلياً
  Future<void> _saveLocalSemesterData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (data.containsKey('endDate')) {
        await prefs.setString(_localEndDateKey, data['endDate']);
      }

      if (data.containsKey('startDate')) {
        await prefs.setString(_localStartDateKey, data['startDate']);
      }

      if (data.containsKey('totalDays')) {
        await prefs.setInt(_localTotalDaysKey, data['totalDays']);
      }

      if (data.containsKey('passedDays')) {
        await prefs.setInt(_localPassedDaysKey, data['passedDays']);
      }
    } catch (e) {
      print('خطأ في حفظ بيانات الفصل الدراسي محلياً: $e');
    }
  }

  // الحصول على بيانات الفصل الدراسي المحلية
  Future<Map<String, dynamic>> _getLocalSemesterData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {};

      if (prefs.containsKey(_localEndDateKey)) {
        data['endDate'] = prefs.getString(_localEndDateKey);
      }

      if (prefs.containsKey(_localStartDateKey)) {
        data['startDate'] = prefs.getString(_localStartDateKey);
      }

      if (prefs.containsKey(_localTotalDaysKey)) {
        data['totalDays'] = prefs.getInt(_localTotalDaysKey);
      }

      if (prefs.containsKey(_localPassedDaysKey)) {
        data['passedDays'] = prefs.getInt(_localPassedDaysKey);
      }

      return data;
    } catch (e) {
      print('خطأ في قراءة بيانات الفصل الدراسي المحلية: $e');
      return {};
    }
  }

  // حذف البيانات المحلية (لإعادة ضبط الإعدادات)
  Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localEndDateKey);
      await prefs.remove(_localStartDateKey);
      await prefs.remove(_localTotalDaysKey);
      await prefs.remove(_localPassedDaysKey);
    } catch (e) {
      print('خطأ في حذف بيانات الفصل الدراسي المحلية: $e');
    }
  }
}
