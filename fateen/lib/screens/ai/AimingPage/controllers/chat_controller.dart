import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import '../models/chat_message.dart';

class ChatController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLoading = false;
  bool _isListening = false;
  bool _isPlayingAudio = false;
  String _errorMessage = '';

  // للتعرف على الصوت
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;

  // معرف المستخدم
  final String _userId = const Uuid().v4();

  // الوصول للمتغيرات
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isPlayingAudio => _isPlayingAudio;
  String get errorMessage => _errorMessage;
  String get userId => _userId;
  bool get speechEnabled => _speechEnabled;

  ChatController() {
    _initSpeech();
    _addBotMessage('مرحباً بك! كيف يمكنني مساعدتك اليوم؟');
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // تهيئة خدمة التعرف على الصوت
  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speech.initialize();
      notifyListeners();
    } catch (e) {
      print("خطأ في تهيئة خدمة التعرف على الصوت: $e");
    }
  }

  // بدء الاستماع للصوت
  void startListening() {
    if (!_speechEnabled) return;

    _isListening = true;
    notifyListeners();

    _speech.listen(
      onResult: (result) {
        textController.text = result.recognizedWords;
        notifyListeners();
      },
      localeId: 'ar-SA', // للغة العربية
    );
  }

  // إيقاف الاستماع
  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  // إضافة رسالة المستخدم
  void _addUserMessage(String text) {
    _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
    notifyListeners();
    _scrollToBottom();
  }

  // إضافة رسالة البوت
  void _addBotMessage(String text) {
    _messages.add(ChatMessage(text: text, isUser: false, time: DateTime.now()));
    notifyListeners();
    _scrollToBottom();
  }

  // التمرير إلى أسفل عند إضافة رسائل جديدة
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // إرسال الرسالة إلى البوت
  Future<void> sendMessage(String serverIp, String serverPort) async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // إضافة رسالة المستخدم
    _addUserMessage(text);
    textController.clear();

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final botReply =
          await ApiService.sendChatMessage(text, _userId, serverIp, serverPort);

      _addBotMessage(botReply);
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال بالخادم: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحويل رسالة البوت إلى صوت
  Future<void> speakBotMessage(
      String text, String serverIp, String serverPort) async {
    if (_isPlayingAudio) {
      _audioPlayer.stop();
      _isPlayingAudio = false;
      notifyListeners();
      return;
    }

    _isPlayingAudio = true;
    notifyListeners();

    try {
      final audioBytes =
          await ApiService.textToSpeech(text, serverIp, serverPort, 'ar');

      // حفظ الملف الصوتي مؤقتا لتشغيله
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_chat_audio.mp3');
      await file.writeAsBytes(audioBytes);

      // تشغيل الملف الصوتي
      await _audioPlayer.play(DeviceFileSource(file.path));

      _audioPlayer.onPlayerComplete.listen((event) {
        _isPlayingAudio = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'خطأ: $e';
      _isPlayingAudio = false;
      notifyListeners();
    }
  }
}
