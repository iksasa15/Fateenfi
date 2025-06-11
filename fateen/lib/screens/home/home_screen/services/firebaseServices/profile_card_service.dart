import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/profile_card_constants.dart';

class ProfileCardService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جمع المستخدمين في Firestore
  final String _usersCollection = 'users';

  // الحصول على بيانات المستخدم الحالي
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final DocumentSnapshot userDoc = await _firestore
            .collection(_usersCollection)
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          return userDoc.data() as Map<String, dynamic>;
        }
      }

      // إرجاع قيم افتراضية إذا لم يتم العثور على البيانات
      return {
        'name': ProfileCardConstants.defaultUserName,
        'major': ProfileCardConstants.defaultUserMajor,
      };
    } catch (e) {
      print('خطأ في الحصول على بيانات المستخدم: $e');

      // إرجاع قيم افتراضية في حالة حدوث خطأ
      return {
        'name': ProfileCardConstants.defaultUserName,
        'major': ProfileCardConstants.defaultUserMajor,
      };
    }
  }

  // تحديث بيانات المستخدم (إذا لزم الأمر)
  Future<bool> updateUserData(String name, String major) async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore
            .collection(_usersCollection)
            .doc(currentUser.uid)
            .update({
          'name': name,
          'major': major,
        });
        return true;
      }
      return false;
    } catch (e) {
      print('خطأ في تحديث بيانات المستخدم: $e');
      return false;
    }
  }
}
