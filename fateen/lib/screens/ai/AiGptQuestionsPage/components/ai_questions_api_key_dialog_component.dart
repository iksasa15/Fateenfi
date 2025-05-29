import 'package:flutter/material.dart';
import '../constants/ai_questions_colors.dart';
import '../constants/ai_questions_strings.dart';

class AiQuestionsApiKeyDialogComponent extends StatefulWidget {
  final TextEditingController apiKeyController;
  final Function(String) onSaveKey;
  final bool isValidatingApiKey;
  final bool isApiKeyValid;
  final Function(String, {bool notify}) onVerifyKey;

  const AiQuestionsApiKeyDialogComponent({
    Key? key,
    required this.apiKeyController,
    required this.onSaveKey,
    this.isValidatingApiKey = false,
    this.isApiKeyValid = false,
    required this.onVerifyKey,
  }) : super(key: key);

  @override
  State<AiQuestionsApiKeyDialogComponent> createState() =>
      _AiQuestionsApiKeyDialogComponentState();
}

class _AiQuestionsApiKeyDialogComponentState
    extends State<AiQuestionsApiKeyDialogComponent> {
  bool _isValidating = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _isValidating = widget.isValidatingApiKey;
    _isValid = widget.isApiKeyValid;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.key, color: AiQuestionsColors.darkPurple),
          SizedBox(width: 10),
          Text(AiQuestionsStrings.apiKeyTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.apiKeyController,
            decoration: InputDecoration(
              hintText: AiQuestionsStrings.apiKeyHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AiQuestionsColors.lightPurple),
              ),
              filled: true,
              fillColor: AiQuestionsColors.lightPurple.withOpacity(0.3),
              // إضافة أيقونة تعرض حالة التحقق
              suffixIcon: _buildKeyStatusIcon(),
            ),
            obscureText: true, // إخفاء المفتاح للأمان
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر التحقق من المفتاح
              ElevatedButton.icon(
                onPressed: _isValidating
                    ? null
                    : () => _verifyKey(widget.apiKeyController.text.trim()),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(_isValidating
                    ? AiQuestionsStrings.validatingText
                    : AiQuestionsStrings.verifyKeyText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AiQuestionsColors.mediumPurple,
                  foregroundColor: Colors.white,
                ),
              ),
              // حالة التحقق
              if (_isValid)
                const Text(
                  AiQuestionsStrings.apiKeyValidSuccess,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AiQuestionsStrings.cancelText,
              style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSaveKey(widget.apiKeyController.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AiQuestionsColors.darkPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(AiQuestionsStrings.saveText),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
    );
  }

  // بناء أيقونة حالة المفتاح
  Widget _buildKeyStatusIcon() {
    if (_isValidating) {
      // مؤشر تحميل أثناء التحقق
      return Container(
        margin: const EdgeInsets.all(8),
        width: 20,
        height: 20,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor:
              AlwaysStoppedAnimation<Color>(AiQuestionsColors.darkPurple),
        ),
      );
    } else if (_isValid) {
      // أيقونة خضراء للمفتاح الصالح
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    } else if (widget.apiKeyController.text.isNotEmpty) {
      // أيقونة حمراء للمفتاح غير الصالح
      return const Icon(
        Icons.error_outline,
        color: Colors.red,
      );
    }

    // لا أيقونة إذا كان الحقل فارغاً
    return const SizedBox.shrink();
  }

  // التحقق من المفتاح المدخل
  Future<void> _verifyKey(String key) async {
    if (key.isEmpty) return;

    setState(() {
      _isValidating = true;
    });

    try {
      _isValid = await widget.onVerifyKey(key, notify: false);
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }
}
