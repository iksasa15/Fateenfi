import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/deepl_translation_service.dart';
import '../constants/api_constants.dart';

class ApiKeyController extends ChangeNotifier {
  // الخدمات
  final DeeplTranslationService _deeplService = DeeplTranslationService();

  // حالة المفتاح
  String? _apiKey;
  bool _isLoading = false;

  // وصول للحالة
  String? get apiKey => _apiKey;
  bool get isLoading => _isLoading;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  // متحكم حقل إدخال المفتاح
  final TextEditingController textController = TextEditingController();

  // تهيئة المتحكم وتحميل المفتاح المحفوظ
  ApiKeyController() {
    _loadApiKey();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // تحميل مفتاح API
  Future<void> _loadApiKey() async {
    _isLoading = true;
    notifyListeners();

    try {
      _apiKey = await _deeplService.getApiKey();
      if (_apiKey != null) {
        textController.text = _apiKey!;
      }
    } catch (e) {
      debugPrint('خطأ في تحميل مفتاح API: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // حفظ مفتاح API
  Future<bool> saveApiKey(String apiKey) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool result = await _deeplService.saveApiKey(apiKey);
      if (result) {
        _apiKey = apiKey;
      }
      return result;
    } catch (e) {
      debugPrint('خطأ في حفظ مفتاح API: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
