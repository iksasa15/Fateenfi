import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'controllers/ai_explainer_controller.dart';
import 'components/ai_explainer_chat_component.dart';
import 'components/ai_explainer_input_component.dart';
import 'components/ai_explainer_loading_component.dart';
import 'constants/ai_explainer_colors.dart';
import 'constants/ai_explainer_strings.dart';
import 'constants/ai_explainer_dimensions.dart';
import 'services/ai_explainer_api_service.dart';
import '../../../models/chat_message_model.dart';
import '../../../models/chat_session_model.dart';

class AiConceptExplainerPage extends StatefulWidget {
  final String? userId; // معرف المستخدم لتخزين المحادثات في فاير بيس

  const AiConceptExplainerPage({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<AiConceptExplainerPage> createState() => _AiConceptExplainerPageState();
}

class _AiConceptExplainerPageState extends State<AiConceptExplainerPage>
    with TickerProviderStateMixin {
  late AiExplainerController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AiExplainerController(
      vsync: this,
      userId: widget.userId ??
          "anonymous_user", // استخدم معرف افتراضي إذا كان فارغاً
      onNewMessage: _scrollToBottom,
    );
    _controller.initializeAnimations();

    // تحميل المحادثات السابقة في بداية تشغيل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadPreviousSessions().then((_) {
        // إضافة رسالة ترحيبية فقط إذا كانت المحادثة جديدة
        if (_controller.currentSession.messages.isEmpty) {
          _controller.addBotMessage(AiExplainerStrings.welcomeMessage);
        }
        // تمرير للأسفل لعرض آخر الرسائل
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    // التمرير إلى أسفل عند إضافة رسالة جديدة
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // حفظ المحادثة الحالية قبل الخروج من الصفحة
    _controller.saveCurrentSession();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFF),
        body: SafeArea(
          child: Column(
            children: [
              // هيدر الصفحة
              _buildHeader(),

              // شريط المعلومات يظهر عند تحميل ملف
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return _controller.selectedFileName.isNotEmpty
                      ? _buildFileInfoBar()
                      : const SizedBox.shrink();
                },
              ),

              // منطقة المحادثة
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return _controller.isLoading && _controller.messages.isEmpty
                        ? AiExplainerLoadingComponent(
                            controller: _controller,
                            loadingController: _controller.loadingController,
                          )
                        : AiExplainerChatComponent(
                            controller: _controller,
                            scrollController: _scrollController,
                            fadeAnimation: _controller.fadeAnimation,
                            slideAnimation: _controller.slideAnimation,
                          );
                  },
                ),
              ),

              // حقل الإدخال والأزرار
              AiExplainerInputComponent(
                controller: _controller,
                isLoading: _controller.isLoading,
                onSendPressed: () => _handleSendMessage(context),
                onAttachPressed: () => _showAttachmentOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final buttonSize = 45.0;
    final padding = 20.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // زر الرجوع في الجهة اليمنى
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4338CA),
                      size: 20,
                    ),
                  ),
                ),
              ),

              // عنوان الصفحة (في المنتصف تماماً)
              Text(
                AiExplainerStrings.pageTitle,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),

              // أزرار إضافية على اليسار
              Positioned(
                left: 0,
                child: Row(
                  children: [
                    // زر التحقق من الاتصال
                    GestureDetector(
                      onTap: () => _testApiConnection(context),
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.cloud_sync,
                          color: Color(0xFF4338CA),
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // زر المحادثة الجديدة
                    GestureDetector(
                      onTap: () => _showNewChatConfirmDialog(context),
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.add_comment,
                          color: Color(0xFF4338CA),
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // زر سجل المحادثات
                    GestureDetector(
                      onTap: () => _showSessionsHistoryDialog(context),
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Color(0xFF4338CA),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // خط فاصل
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.grey.shade200,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildFileInfoBar() {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: const Color(0xFFF5F3FF),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF4338CA).withOpacity(0.1),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.insert_drive_file,
                color: Color(0xFF6366F1),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${AiExplainerStrings.currentFileText}: ${_controller.selectedFileName}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Color(0xFF4338CA),
                size: 18,
              ),
              onPressed: _controller.clearSelectedFile,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendMessage(BuildContext context) async {
    if (_controller.userMessageController.text.trim().isEmpty) {
      // عدم إرسال رسائل فارغة
      return;
    }

    final message = _controller.userMessageController.text.trim();
    _controller.userMessageController.clear();

    try {
      await _controller.sendMessage(message);
    } catch (e) {
      _showErrorSnackBar(context, "حدث خطأ أثناء إرسال الرسالة: $e");
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AiExplainerStrings.attachmentOptionsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 20),
            _buildAttachmentOption(
              icon: Icons.upload_file,
              title: AiExplainerStrings.uploadFileOption,
              onTap: () {
                Navigator.pop(ctx);
                _controller.pickFileAndReadContent(context);
              },
            ),
            _buildAttachmentOption(
              icon: Icons.link,
              title: AiExplainerStrings.addLinkOption,
              onTap: () {
                Navigator.pop(ctx);
                _showAddLinkDialog(context);
              },
            ),
            _buildAttachmentOption(
              icon: Icons.photo,
              title: AiExplainerStrings.uploadImageOption,
              onTap: () {
                Navigator.pop(ctx);
                _controller.pickImage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF4338CA), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'SYMBIOAR+LT',
          color: Color(0xFF374151),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _showAddLinkDialog(BuildContext context) {
    final TextEditingController linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          AiExplainerStrings.addLinkDialogTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'SYMBIOAR+LT',
            color: Color(0xFF374151),
          ),
        ),
        content: TextField(
          controller: linkController,
          decoration: InputDecoration(
            hintText: AiExplainerStrings.linkHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4338CA),
                width: 1.5,
              ),
            ),
            hintStyle: const TextStyle(
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          style: const TextStyle(
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AiExplainerStrings.cancelText,
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final link = linkController.text.trim();
              if (link.isNotEmpty) {
                Navigator.pop(ctx);
                _controller.processWebLink(link, context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AiExplainerStrings.addText,
              style: const TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewChatConfirmDialog(BuildContext context) {
    if (_controller.messages.isEmpty) {
      // إذا لم تكن هناك رسائل، ابدأ محادثة جديدة مباشرة
      _controller.startNewSession();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          AiExplainerStrings.newChatDialogTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'SYMBIOAR+LT',
            color: Color(0xFF374151),
          ),
        ),
        content: const Text(
          AiExplainerStrings.newChatDialogContent,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'SYMBIOAR+LT',
            color: Color(0xFF374151),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AiExplainerStrings.cancelText,
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _controller.startNewSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AiExplainerStrings.confirmText,
              style: const TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // اختبار الاتصال بخادم API
  Future<void> _testApiConnection(BuildContext context) async {
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
            ),
            const SizedBox(height: 20),
            const Text(
              "جاري التحقق من الاتصال...",
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );

    // اختبار الاتصال
    bool isConnected = await AiExplainerApiService.testConnection();

    // إغلاق مؤشر التحميل
    Navigator.of(context, rootNavigator: true).pop();

    // عرض نتيجة الاختبار
    _showConnectionResult(context, isConnected);
  }

  void _showConnectionResult(BuildContext context, bool isConnected) {
    final serverInfo = AiExplainerApiService.serverInfo;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error_outline,
              color: isConnected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53935),
            ),
            const SizedBox(width: 10),
            Text(
              isConnected ? "تم الاتصال بنجاح" : "فشل الاتصال",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isConnected
                  ? "تم الاتصال بخادم API بنجاح"
                  : "تعذر الاتصال بخادم API. تأكد من تشغيل الخادم ووجود اتصال صحيح.",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "عنوان الخادم: $serverInfo",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
        actions: [
          if (!isConnected)
            TextButton(
              onPressed: () => _showServerConfigDialog(context),
              child: const Text(
                "تغيير عنوان الخادم",
                style: TextStyle(
                  color: Color(0xFF4338CA),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "حسناً",
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showServerConfigDialog(BuildContext context) {
    final serverInfo = AiExplainerApiService.serverInfo.split(':');
    final ipController = TextEditingController(text: serverInfo[0]);
    final portController = TextEditingController(
        text: serverInfo.length > 1 ? serverInfo[1] : '8000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.settings_ethernet, color: Color(0xFF4338CA)),
            SizedBox(width: 10),
            Text(
              "إعدادات الخادم",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ipController,
              style: const TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
              decoration: InputDecoration(
                labelText: "عنوان IP",
                hintText: "مثال: 127.0.0.1",
                labelStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                ),
                hintStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4338CA),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
              decoration: InputDecoration(
                labelText: "المنفذ",
                hintText: "مثال: 8000",
                labelStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                ),
                hintStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4338CA),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "إلغاء",
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final ip = ipController.text.trim();
              final port = int.tryParse(portController.text.trim()) ?? 8000;

              if (ip.isNotEmpty) {
                AiExplainerApiService.setServerAddress(ip, port);
                Navigator.pop(ctx);

                // إعادة اختبار الاتصال بعد تغيير الإعدادات
                _testApiConnection(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "حفظ وإعادة الاختبار",
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionsHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          AiExplainerStrings.chatHistoryTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'SYMBIOAR+LT',
            color: Color(0xFF374151),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.5,
          child: StreamBuilder<QuerySnapshot>(
            stream: _controller.getSessionsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "خطأ: ${snapshot.error}",
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      color: Color(0xFFE53935),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    AiExplainerStrings.noHistoryText,
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      color: Color(0xFF374151),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  ChatSessionModel session = ChatSessionModel.fromJson(data);
                  session.id = doc.id;

                  DateTime sessionDate =
                      DateTime.fromMillisecondsSinceEpoch(session.timestamp);
                  String dateText =
                      "${sessionDate.day}/${sessionDate.month}/${sessionDate.year} ${sessionDate.hour}:${sessionDate.minute}";

                  // اظهار الرسالة الأولى في كل محادثة
                  String previewText = "";
                  if (session.messages.isNotEmpty) {
                    // البحث عن أول رسالة من المستخدم
                    for (var message in session.messages) {
                      if (message.isUser) {
                        previewText = message.text;
                        break;
                      }
                    }

                    // إذا لم نجد رسالة من المستخدم، استخدم الرسالة الترحيبية
                    if (previewText.isEmpty) {
                      previewText = "محادثة جديدة";
                    }
                  }

                  if (previewText.length > 40) {
                    previewText = "${previewText.substring(0, 40)}...";
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE3E0F8),
                        width: 1.0,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        session.title.isNotEmpty
                            ? session.title
                            : "محادثة $dateText",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      subtitle: Text(
                        previewText,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4338CA).withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          // تأكيد الحذف
                          _showDeleteConfirmDialog(context, session.id!);
                        },
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _controller.loadSession(session);
                        // تمرير للأسفل لعرض آخر الرسائل
                        _scrollToBottom();
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AiExplainerStrings.closeText,
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // إضافة مربع حوار لتأكيد حذف محادثة
  void _showDeleteConfirmDialog(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "تأكيد الحذف",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'SYMBIOAR+LT',
            color: Color(0xFF374151),
          ),
        ),
        content: const Text(
          "هل أنت متأكد من رغبتك في حذف هذه المحادثة؟ لا يمكن التراجع عن هذا الإجراء.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'SYMBIOAR+LT',
            color: Color(0xFF374151),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "إلغاء",
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _controller.deleteSession(sessionId);

              // إظهار رسالة تأكيد الحذف
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "تم حذف المحادثة بنجاح",
                    style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
                  ),
                  backgroundColor: const Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "حذف",
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
