import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../constants/ai_explainer_colors.dart';
import '../controllers/ai_explainer_controller.dart';
import '../../../../models/chat_message_model.dart';

class AiExplainerChatComponent extends StatelessWidget {
  final AiExplainerController controller;
  final ScrollController scrollController;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const AiExplainerChatComponent({
    Key? key,
    required this.controller,
    required this.scrollController,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messages = controller.messages;

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Color(0xFF4338CA),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ابدأ محادثة جديدة بكتابة سؤال أو تحميل ملف',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageBubble(context, message, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, ChatMessageModel message, int index) {
    final bool isUser = message.isUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.8;

    // تنسيق التاريخ
    final timestamp = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final timeString = DateFormat('HH:mm').format(timestamp);

    // التحقق من ما إذا كانت هذه أول رسالة في اليوم
    bool showDateHeader = false;
    if (index == 0) {
      showDateHeader = true;
    } else {
      final prevTimestamp = DateTime.fromMillisecondsSinceEpoch(
          controller.messages[index - 1].timestamp);
      showDateHeader = !_isSameDay(prevTimestamp, timestamp);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // رأس التاريخ
        if (showDateHeader) _buildDateHeader(timestamp),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة البوت (تظهر فقط لرسائل البوت)
              if (!isUser)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE3E0F8),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.smart_toy,
                      color: Color(0xFF4338CA),
                      size: 18,
                    ),
                  ),
                ),

              // فقاعة الرسالة
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF4338CA) : Colors.white,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: !isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                    ),
                    border: !isUser
                        ? Border.all(
                            color: const Color(0xFFE3E0F8),
                            width: 1,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // محتوى الرسالة (نص)
                      SelectableText(
                        message.text,
                        style: TextStyle(
                          color:
                              isUser ? Colors.white : const Color(0xFF374151),
                          fontSize: 15,
                          fontFamily: 'SYMBIOAR+LT',
                          height: 1.5,
                        ),
                      ),

                      // إذا كان هناك مرفق ملف
                      if (message.fileAttachment != null &&
                          message.fileType == 'text')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildFileAttachment(message.fileAttachment!),
                        ),

                      // إذا كان هناك مرفق رابط
                      if (message.fileAttachment != null &&
                          message.fileType == 'link')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildLinkAttachment(message.fileAttachment!),
                        ),

                      // إذا كان هناك مرفق صورة
                      if (message.imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildImageAttachment(message.imageUrl!),
                        ),

                      // وقت الرسالة
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            timeString,
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white.withOpacity(0.7)
                                  : const Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // أزرار إضافية للرسائل من البوت
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Column(
                    children: [
                      // زر نسخ النص
                      _buildActionButton(
                        icon: Icons.copy,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'تم نسخ النص',
                                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFF4338CA),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 14),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: const Color(0xFF4338CA),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final String dateStr = _formatDateHeader(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE3E0F8),
              width: 1,
            ),
          ),
          child: Text(
            dateStr,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileAttachment(String fileName) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E0F8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file,
              size: 16, color: Color(0xFF4338CA)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'SYMBIOAR+LT',
                color: Color(0xFF374151),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkAttachment(String url) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E0F8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 16, color: Color(0xFF4338CA)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              url,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4338CA),
                fontFamily: 'SYMBIOAR+LT',
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAttachment(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 150,
            height: 100,
            color: const Color(0xFFF5F3FF),
            child: const Center(
              child: Icon(Icons.error, color: Color(0xFFE53935)),
            ),
          );
        },
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'اليوم';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'الأمس';
    } else {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
