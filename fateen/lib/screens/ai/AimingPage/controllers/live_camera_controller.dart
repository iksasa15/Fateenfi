import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';

class LiveCameraController extends ChangeNotifier {
  CameraController? cameraController;
  bool _isInitialized = false;
  bool _isAnalyzing = false;
  bool _isSingleAnalyzing = false;
  String _analysisResult = '';
  String _errorMessage = '';
  Timer? _analysisTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;
  bool _autoSpeak = false; // إضافة متغير للتحكم في التحدث التلقائي

  // وقت الانتظار بين التحليلات (بالثواني)
  final int _analyzeIntervalSeconds = 5;

  // الوصول للمتغيرات
  bool get isInitialized => _isInitialized;
  bool get isAnalyzing => _isAnalyzing;
  bool get isSingleAnalyzing => _isSingleAnalyzing;
  bool get isPlayingAudio => _isPlayingAudio;
  bool get autoSpeak => _autoSpeak;
  String get analysisResult => _analysisResult;
  String get errorMessage => _errorMessage;

  @override
  void dispose() {
    _stopAnalysisTimer();
    cameraController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // تهيئة الكاميرا
  Future<void> initCamera(List<CameraDescription> cameras) async {
    if (cameras.isEmpty) {
      _errorMessage = 'لم يتم العثور على كاميرات متاحة';
      notifyListeners();
      return;
    }

    // استخدام الكاميرا الخلفية كافتراضي
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController!.initialize();
      _isInitialized = true;
      notifyListeners();
    } on CameraException catch (e) {
      _errorMessage = 'خطأ في تهيئة الكاميرا: ${e.description}';
      notifyListeners();
    }
  }

  // تبديل حالة التحليل المستمر
  void toggleAnalysisTimer() {
    if (_analysisTimer != null && _analysisTimer!.isActive) {
      _stopAnalysisTimer();
    } else {
      _isAnalyzing = true;
      notifyListeners();

      // ابدأ بالتحليل فورًا ثم على فترات منتظمة
      _captureAndAnalyze();
      _analysisTimer = Timer.periodic(
        Duration(seconds: _analyzeIntervalSeconds),
        (timer) => _captureAndAnalyze(),
      );
    }
  }

  // إيقاف التحليل المستمر
  void _stopAnalysisTimer() {
    _analysisTimer?.cancel();
    _isAnalyzing = false;
    notifyListeners();
  }

  // التقاط وتحليل الصورة بشكل مستمر
  Future<void> _captureAndAnalyze() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      // التقاط الصورة
      final XFile image = await cameraController!.takePicture();
      // تحليل الصورة
      await _analyzeImage(File(image.path), isQuickAnalysis: true);
    } catch (e) {
      _errorMessage = 'خطأ أثناء التقاط أو تحليل الصورة: $e';
      notifyListeners();
    }
  }

  // التقاط وتحليل صورة واحدة
  Future<void> captureAndAnalyzeOnce() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    _isSingleAnalyzing = true;
    _errorMessage = '';
    _analysisResult = 'جاري تحليل الصورة...';
    notifyListeners();

    try {
      // التقاط الصورة
      final XFile image = await cameraController!.takePicture();
      // تحليل الصورة
      await _analyzeImage(File(image.path), isQuickAnalysis: false);
    } catch (e) {
      _errorMessage = 'خطأ أثناء التقاط أو تحليل الصورة: $e';
      _analysisResult = '';
      _isSingleAnalyzing = false;
      notifyListeners();
    }
  }

  // تحليل الصورة
  Future<void> _analyzeImage(
    File imageFile, {
    bool isQuickAnalysis = false,
  }) async {
    try {
      // تحديد نوع التحليل (سريع للتحليل المستمر أو عميق للتحليل الفردي)
      final endpoint = isQuickAnalysis ? 'analyze_live_image' : 'analyze_image';

      // تحليل الصورة عبر الخدمة
      String result;
      if (isQuickAnalysis) {
        result = await ApiService.analyzeLiveImage(
            imageFile, _serverIp!, _serverPort!);
      } else {
        result =
            await ApiService.analyzeImage(imageFile, _serverIp!, _serverPort!);
      }

      _analysisResult = result;
      _errorMessage = '';
      _isSingleAnalyzing = false;
      notifyListeners();

      // التحدث تلقائياً إذا كانت الميزة مفعلة
      if (_autoSpeak || !isQuickAnalysis) {
        await convertTextToSpeech(result);
      }
    } catch (e) {
      _errorMessage = 'خطأ في الاتصال بخدمة تحليل الصورة: $e';
      _isSingleAnalyzing = false;
      notifyListeners();
    }
  }

  // تحويل النص إلى صوت
  Future<void> convertTextToSpeech(String text) async {
    if (text.isEmpty) {
      return;
    }

    _isPlayingAudio = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final audioBytes =
          await ApiService.textToSpeech(text, _serverIp!, _serverPort!, 'ar');

      // حفظ الملف الصوتي مؤقتا لتشغيله
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_live_audio.mp3');
      await file.writeAsBytes(audioBytes);

      // تشغيل الملف الصوتي
      await _audioPlayer.play(DeviceFileSource(file.path));

      _audioPlayer.onPlayerComplete.listen((event) {
        _isPlayingAudio = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'خطأ في خدمة تحويل النص إلى صوت: $e';
      _isPlayingAudio = false;
      notifyListeners();
    }
  }

  // تبديل حالة الشرح الصوتي التلقائي
  void toggleAutoSpeak() {
    _autoSpeak = !_autoSpeak;
    notifyListeners();
  }

  // إيقاف الصوت
  void stopAudio() {
    _audioPlayer.stop();
    _isPlayingAudio = false;
    notifyListeners();
  }

  // الإعدادات
  String? _serverIp;
  String? _serverPort;

  void updateServerSettings(String serverIp, String serverPort) {
    _serverIp = serverIp;
    _serverPort = serverPort;
  }
}
