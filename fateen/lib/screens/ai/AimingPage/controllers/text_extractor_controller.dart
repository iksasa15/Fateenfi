import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';

class TextExtractorController extends ChangeNotifier {
  // حالة الصفحة
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _extractedText = '';
  String _analyzedText = '';
  String _imageAnalysis = '';
  bool _isLoading = false;
  bool _isAnalyzing = false;
  bool _isAnalyzingImage = false;
  bool _isPlayingAudio = false;
  String _errorMessage = '';

  // للصوتيات
  final AudioPlayer _audioPlayer = AudioPlayer();
  Uint8List? _audioData;

  // الوصول للمتغيرات
  File? get image => _image;
  String get extractedText => _extractedText;
  String get analyzedText => _analyzedText;
  String get imageAnalysis => _imageAnalysis;
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  bool get isAnalyzingImage => _isAnalyzingImage;
  bool get isPlayingAudio => _isPlayingAudio;
  String get errorMessage => _errorMessage;

  // تنظيف الموارد
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // اختيار صورة من المعرض
  Future<void> getImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _extractedText = '';
      _analyzedText = '';
      _imageAnalysis = '';
      _errorMessage = '';
      _audioData = null;
      notifyListeners();
    }
  }

  // التقاط صورة من الكاميرا
  Future<void> takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _extractedText = '';
      _analyzedText = '';
      _imageAnalysis = '';
      _errorMessage = '';
      _audioData = null;
      notifyListeners();
    }
  }

  // استخراج النص من الصورة
  Future<void> extractText(String serverIp, String serverPort) async {
    if (_image == null) {
      _errorMessage = 'يرجى اختيار صورة أولاً';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    _analyzedText = '';
    _imageAnalysis = '';
    _audioData = null;
    notifyListeners();

    try {
      final result =
          await ApiService.extractTextFromImage(_image!, serverIp, serverPort);
      _extractedText = result;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال بالخادم: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحليل النص المستخرج
  Future<void> analyzeText(String serverIp, String serverPort) async {
    if (_extractedText.isEmpty) {
      _errorMessage = 'يجب استخراج النص أولاً قبل تحليله';
      notifyListeners();
      return;
    }

    _isAnalyzing = true;
    _errorMessage = '';
    _audioData = null;
    notifyListeners();

    try {
      final result =
          await ApiService.analyzeText(_extractedText, serverIp, serverPort);
      _analyzedText = result;
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال بخدمة التحليل: $e';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  // تحليل الصورة مباشرة
  Future<void> analyzeImage(String serverIp, String serverPort) async {
    if (_image == null) {
      _errorMessage = 'يرجى اختيار صورة أولاً';
      notifyListeners();
      return;
    }

    _isAnalyzingImage = true;
    _errorMessage = '';
    _imageAnalysis = '';
    _audioData = null;
    notifyListeners();

    try {
      final result =
          await ApiService.analyzeImage(_image!, serverIp, serverPort);
      _imageAnalysis = result;
      _isAnalyzingImage = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال بخدمة تحليل الصورة: $e';
      _isAnalyzingImage = false;
      notifyListeners();
    }
  }

  // تحويل النص إلى صوت
  Future<void> convertTextToSpeech(
      String text, String serverIp, String serverPort) async {
    if (text.isEmpty) {
      _errorMessage = 'لا يوجد نص للتحويل إلى صوت';
      notifyListeners();
      return;
    }

    _isPlayingAudio = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final audioBytes =
          await ApiService.textToSpeech(text, serverIp, serverPort, 'ar');
      _audioData = audioBytes;

      // حفظ الملف الصوتي مؤقتا لتشغيله
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_audio.mp3');
      await file.writeAsBytes(_audioData!);

      // تشغيل الملف الصوتي
      await _audioPlayer.play(DeviceFileSource(file.path));

      _audioPlayer.onPlayerComplete.listen((event) {
        _isPlayingAudio = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال بخدمة تحويل النص إلى صوت: $e';
      _isPlayingAudio = false;
      notifyListeners();
    }
  }

  // إيقاف تشغيل الصوت
  void stopAudio() {
    _audioPlayer.stop();
    _isPlayingAudio = false;
    notifyListeners();
  }

  // مسح البيانات
  void clear() {
    _image = null;
    _extractedText = '';
    _analyzedText = '';
    _imageAnalysis = '';
    _errorMessage = '';
    _audioData = null;
    notifyListeners();
  }
}
