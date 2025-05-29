import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // تهيئة مشغل الصوت
  Future<void> preloadSound() async {
    try {
      // يمكن استخدام صوت محلي في مجلد assets أو URL للصوت
      // مثال لصوت محلي (تأكد من إضافته في pubspec.yaml):
      // await _audioPlayer.setSource(AssetSource('sounds/alert.mp3'));

      // أو يمكن استخدام URL للصوت:
      // await _audioPlayer.setSourceUrl('https://example.com/sounds/alert.mp3');

      debugPrint('تم تحميل ملف الصوت بنجاح');
    } catch (e) {
      debugPrint('خطأ في تحميل ملف الصوت: $e');
    }
  }

  // تشغيل صوت التنبيه
  Future<void> playAlertSound() async {
    try {
      // مسار صوت افتراضي (قم بتغييره للصوت المناسب)
      await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
      debugPrint('تم تشغيل صوت التنبيه');
    } catch (e) {
      debugPrint('خطأ في تشغيل الصوت: $e');
    }
  }

  // التخلص من المشغل
  void dispose() {
    _audioPlayer.dispose();
  }
}
