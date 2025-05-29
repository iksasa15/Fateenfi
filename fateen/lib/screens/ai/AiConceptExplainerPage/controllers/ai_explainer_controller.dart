import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/ai_explainer_api_service.dart';
import '../services/ai_explainer_file_service.dart';
import '../constants/ai_explainer_strings.dart';
import '../../../../models/chat_message_model.dart';
import '../../../../models/chat_session_model.dart';

class AiExplainerController extends ChangeNotifier {
  // Animation controllers
  final TickerProvider vsync;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late AnimationController loadingController;

  // Text controller
  final TextEditingController userMessageController = TextEditingController();

  // Firebase refs
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Callback for new messages
  final Function? onNewMessage;

  // State variables
  bool _isLoading = false;
  String? _fileContent;
  String _selectedFileName = "";
  String? _userId;
  String _currentTopic = "general";
  ChatSessionModel _currentSession = ChatSessionModel.createNew();
  bool _isProcessingFile = false;

  // Getters
  bool get isLoading => _isLoading;
  String get selectedFileName => _selectedFileName;
  String get currentTopic => _currentTopic;
  List<ChatMessageModel> get messages => _currentSession.messages;
  ChatSessionModel get currentSession => _currentSession;
  bool get isProcessingFile => _isProcessingFile;

  // Constructor
  AiExplainerController({
    required this.vsync,
    String? userId,
    this.onNewMessage,
  }) {
    _userId = userId;
  }

  // Initialize animations
  void initializeAnimations() {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 350),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    loadingController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    );

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    loadingController.dispose();
    userMessageController.dispose();
    super.dispose();
  }

  // إضافة رسالة من المستخدم
  void addUserMessage(String message,
      {String? fileAttachment, String? fileType, String? imageUrl}) {
    final newMessage = ChatMessageModel(
      text: message,
      isUser: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      fileAttachment: fileAttachment,
      fileType: fileType,
      imageUrl: imageUrl,
    );

    _currentSession.messages.add(newMessage);
    saveCurrentSession(); // حفظ المحادثة بعد إضافة رسالة
    notifyListeners();

    if (onNewMessage != null) {
      onNewMessage!();
    }
  }

  // إضافة رسالة من الروبوت
  void addBotMessage(String message,
      {String? fileAttachment, String? fileType, String? imageUrl}) {
    final newMessage = ChatMessageModel(
      text: message,
      isUser: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      fileAttachment: fileAttachment,
      fileType: fileType,
      imageUrl: imageUrl,
    );

    _currentSession.messages.add(newMessage);
    saveCurrentSession(); // حفظ المحادثة بعد إضافة رسالة
    notifyListeners();

    if (onNewMessage != null) {
      onNewMessage!();
    }
  }

  // إرسال رسالة
  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    // Add user message to chat
    addUserMessage(message);

    // Prepare for response
    _isLoading = true;
    notifyListeners();

    loadingController.repeat();

    try {
      String botResponse;

      // إذا كان هناك ملف مُختار، أرسل محتواه مع الرسالة
      if (_fileContent != null && _fileContent!.isNotEmpty) {
        botResponse = await AiExplainerApiService.getResponseWithContext(
          message: message,
          context: _fileContent!,
          topic: _currentTopic,
        );
      } else {
        botResponse = await AiExplainerApiService.getResponse(
          message: message,
          conversation: _getConversationHistory(),
          topic: _currentTopic,
        );
      }

      // إضافة رد البوت
      addBotMessage(botResponse);

      // إذا كانت هذه أول رسالة، ابحث عن عنوان مناسب للمحادثة
      if (_currentSession.title.isEmpty &&
          _currentSession.messages.length > 1) {
        await _generateSessionTitle();
      }

      // حفظ المحادثة بعد الرد
      await saveCurrentSession();
    } catch (e) {
      debugPrint("Error sending message: $e");
      addBotMessage(AiExplainerStrings.errorResponseMessage);
    } finally {
      loadingController.stop();
      _isLoading = false;
      notifyListeners();
    }
  }

  // التقاط ملف وقراءته
  Future<void> pickFileAndReadContent(BuildContext context) async {
    try {
      _isProcessingFile = true;
      notifyListeners();

      final result = await AiExplainerFileService.pickAndReadFile();

      if (result['success']) {
        _selectedFileName = result['fileName'];
        _fileContent = result['content'];

        if (_fileContent == null || _fileContent!.trim().isEmpty) {
          _showSnackBar(context, AiExplainerStrings.emptyFileError,
              isError: true);
          _fileContent = null;
          _selectedFileName = "";
        } else {
          // إضافة رسالة تفيد بتحميل الملف
          addUserMessage(
            AiExplainerStrings.fileUploadedMessage
                .replaceFirst('%s', _selectedFileName),
            fileAttachment: _selectedFileName,
            fileType: 'text',
          );

          // طلب تحليل الملف
          await sendMessage(AiExplainerStrings.analyzeFileRequest);
        }
      } else {
        _showSnackBar(
            context, result['error'] ?? AiExplainerStrings.fileReadError,
            isError: true);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      _showSnackBar(context, "${AiExplainerStrings.filePickError}$e",
          isError: true);
    } finally {
      _isProcessingFile = false;
      notifyListeners();
    }
  }

  // اختيار صورة
  Future<void> pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      _isProcessingFile = true;
      notifyListeners();

      // رفع الصورة إلى Firebase Storage إذا كان هناك معرف مستخدم
      String? imageUrl;
      if (_userId != null) {
        final File imageFile = File(image.path);
        final String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final Reference storageRef =
            _storage.ref().child('images/$_userId/$fileName');

        final UploadTask uploadTask = storageRef.putFile(imageFile);
        final TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // إضافة رسالة بالصورة
      addUserMessage(
        AiExplainerStrings.imageUploadedMessage,
        imageUrl: imageUrl ?? image.path,
        fileType: 'image',
      );

      // طلب تحليل الصورة أو المساعدة
      await sendMessage(AiExplainerStrings.analyzeImageRequest);
    } catch (e) {
      debugPrint("Error picking image: $e");
      _showSnackBar(context, "${AiExplainerStrings.imagePickError}$e",
          isError: true);
    } finally {
      _isProcessingFile = false;
      notifyListeners();
    }
  }

  // معالجة رابط ويب
  Future<void> processWebLink(String url, BuildContext context) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    try {
      _isProcessingFile = true;
      notifyListeners();

      // إضافة رسالة تفيد بالرابط
      addUserMessage(
        AiExplainerStrings.linkSharedMessage.replaceFirst('%s', url),
        fileAttachment: url,
        fileType: 'link',
      );

      // طلب تحليل الرابط
      await sendMessage(
          AiExplainerStrings.analyzeLinkRequest.replaceFirst('%s', url));
    } catch (e) {
      debugPrint("Error processing web link: $e");
      _showSnackBar(context, "${AiExplainerStrings.linkProcessingError}$e",
          isError: true);
    } finally {
      _isProcessingFile = false;
      notifyListeners();
    }
  }

  // مسح الملف المحدد
  void clearSelectedFile() {
    _selectedFileName = "";
    _fileContent = null;
    notifyListeners();
  }

  // تعيين الموضوع الحالي
  void setCurrentTopic(String topic) {
    _currentTopic = topic;

    // تحديث موضوع المحادثة الحالية
    _currentSession.topic = topic;
    saveCurrentSession();

    notifyListeners();

    // إضافة رسالة إعلامية بتغيير الموضوع
    addBotMessage(AiExplainerStrings.topicChangedMessage
        .replaceFirst('%s', _getTopicNameById(topic)));
  }

  // الحصول على اسم الموضوع حسب المعرف
  String _getTopicNameById(String topicId) {
    switch (topicId) {
      case 'math':
        return AiExplainerStrings.mathTopic;
      case 'science':
        return AiExplainerStrings.scienceTopic;
      case 'history':
        return AiExplainerStrings.historyTopic;
      case 'literature':
        return AiExplainerStrings.literatureTopic;
      case 'computer_science':
        return AiExplainerStrings.computerScienceTopic;
      case 'languages':
        return AiExplainerStrings.languagesTopic;
      default:
        return AiExplainerStrings.generalTopic;
    }
  }

  // إنشاء محادثة جديدة
  void startNewSession() {
    // حفظ المحادثة الحالية قبل إنشاء محادثة جديدة
    saveCurrentSession();

    _currentSession = ChatSessionModel.createNew();
    _currentSession.topic = _currentTopic;
    _currentSession.timestamp = DateTime.now().millisecondsSinceEpoch;
    clearSelectedFile();

    // إضافة رسالة ترحيبية
    addBotMessage(AiExplainerStrings.welcomeMessage);
    notifyListeners();

    debugPrint("تم إنشاء محادثة جديدة");
  }

  // تحميل محادثة سابقة
  void loadSession(ChatSessionModel session) {
    // حفظ المحادثة الحالية قبل تحميل محادثة جديدة
    saveCurrentSession();

    _currentSession = session;
    _currentTopic = session.topic;
    clearSelectedFile();
    notifyListeners();

    debugPrint("تم الانتقال إلى المحادثة: ${session.id}");
  }

  // حذف محادثة
  Future<void> deleteSession(String sessionId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .delete();

      // إذا كانت المحادثة الحالية هي المحادثة المحذوفة، أنشئ محادثة جديدة
      if (_currentSession.id == sessionId) {
        startNewSession();
      }

      debugPrint("تم حذف المحادثة: $sessionId");
    } catch (e) {
      debugPrint("Error deleting session: $e");
    }
  }

  // إنشاء عنوان للمحادثة
  Future<void> _generateSessionTitle() async {
    try {
      // الحصول على الرسائل الأولى لتحديد موضوع المحادثة
      final List<ChatMessageModel> initialMessages =
          _currentSession.messages.take(2).toList();
      final String messageContent =
          initialMessages.map((m) => m.text).join("\n");

      final String title =
          await AiExplainerApiService.generateSessionTitle(messageContent);

      _currentSession.title = title;
      saveCurrentSession();
      notifyListeners();

      debugPrint("تم إنشاء عنوان للمحادثة: $title");
    } catch (e) {
      debugPrint("Error generating session title: $e");
      // استخدام عنوان افتراضي في حالة الفشل
      _currentSession.title =
          "محادثة ${DateTime.now().day}/${DateTime.now().month}";
      saveCurrentSession();
    }
  }

  // الحصول على سجل المحادثة
  String _getConversationHistory() {
    // الحصول على آخر 10 رسائل كسياق
    final lastMessages = _currentSession.messages.length > 10
        ? _currentSession.messages.sublist(_currentSession.messages.length - 10)
        : _currentSession.messages;

    String conversationHistory = "";
    for (var message in lastMessages) {
      conversationHistory += message.isUser
          ? "User: ${message.text}\n"
          : "Assistant: ${message.text}\n";
    }

    return conversationHistory;
  }

  // حفظ المحادثة الحالية
  Future<void> saveCurrentSession() async {
    if (_userId == null ||
        _userId!.isEmpty ||
        _currentSession.messages.isEmpty) {
      // لا نحفظ المحادثات الفارغة أو إذا لم يكن هناك معرف مستخدم
      debugPrint(
          "لم يتم حفظ المحادثة: إما المستخدم غير موجود أو المحادثة فارغة");
      return;
    }

    try {
      // تحديث التاريخ
      _currentSession.timestamp = DateTime.now().millisecondsSinceEpoch;

      final sessionData = _currentSession.toJson();

      if (_currentSession.id == null || _currentSession.id!.isEmpty) {
        // إنشاء محادثة جديدة
        DocumentReference docRef = await _firestore
            .collection('users')
            .doc(_userId)
            .collection('chat_sessions')
            .add(sessionData);

        _currentSession.id = docRef.id;
        debugPrint("تم إنشاء محادثة جديدة بمعرف: ${_currentSession.id}");
      } else {
        // تحديث محادثة موجودة
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('chat_sessions')
            .doc(_currentSession.id)
            .update(sessionData);
        debugPrint("تم تحديث المحادثة: ${_currentSession.id}");
      }
    } catch (e) {
      debugPrint("Error saving session: $e");
    }
  }

  // تحميل المحادثات السابقة
  Future<void> loadPreviousSessions() async {
    if (_userId == null || _userId!.isEmpty) {
      // في حالة عدم وجود معرف مستخدم، لا يمكن تحميل المحادثات
      debugPrint("لا يمكن تحميل المحادثات: معرف المستخدم غير موجود");
      return;
    }

    try {
      // إنشاء مرجع للمستخدم إذا لم يكن موجوداً
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      if (!userDoc.exists) {
        // ننشئ وثيقة جديدة للمستخدم إذا لم تكن موجودة
        await _firestore.collection('users').doc(_userId).set({
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'last_active': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // تحديث آخر وقت نشاط للمستخدم
        await _firestore.collection('users').doc(_userId).update({
          'last_active': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // تحميل آخر محادثة
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('chat_sessions')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        ChatSessionModel session = ChatSessionModel.fromJson(data);
        session.id = doc.id;

        _currentSession = session;
        _currentTopic = session.topic;
        notifyListeners();
        debugPrint("تم تحميل المحادثة: ${session.id}");
      } else {
        // إنشاء محادثة جديدة إذا لم يكن هناك محادثات سابقة
        _currentSession = ChatSessionModel.createNew();
        _currentSession.timestamp = DateTime.now().millisecondsSinceEpoch;
        debugPrint("لا توجد محادثات سابقة، تم إنشاء محادثة جديدة");
      }
    } catch (e) {
      debugPrint("خطأ أثناء تحميل المحادثات السابقة: $e");
      // إنشاء محادثة جديدة في حالة حدوث خطأ
      _currentSession = ChatSessionModel.createNew();
      _currentSession.timestamp = DateTime.now().millisecondsSinceEpoch;
    }
  }

  // الحصول على تدفق المحادثات من Firestore
  Stream<QuerySnapshot> getSessionsStream() {
    if (_userId == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // إظهار رسالة للمستخدم
  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
