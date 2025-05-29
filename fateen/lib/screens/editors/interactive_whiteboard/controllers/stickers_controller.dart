import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/sticker_model.dart';
import '../constants/whiteboard_values.dart';
import '../utils/file_utils.dart';

class StickersController extends ChangeNotifier {
  /// قائمة الملصقات الموجودة على السبورة
  List<Sticker> _stickers = [];
  List<Sticker> get stickers => _stickers;

  /// قائمة الملصقات المزالة (للتراجع)
  List<Sticker> _removedStickers = [];
  List<Sticker> get removedStickers => _removedStickers;

  /// الملصق المحدد حاليًا (إذا وجد)
  int? _selectedStickerIndex;
  int? get selectedStickerIndex => _selectedStickerIndex;

  /// هل قائمة الملصقات مفتوحة؟
  bool _isStickerPanelOpen = false;
  bool get isStickerPanelOpen => _isStickerPanelOpen;

  // تعيين قائمة الملصقات
  void setStickers(List<Sticker> stickers) {
    _stickers = stickers;
    notifyListeners();
  }

  // تعيين قائمة الملصقات المزالة
  void setRemovedStickers(List<Sticker> stickers) {
    _removedStickers = stickers;
    notifyListeners();
  }

  /// تبديل حالة قائمة الملصقات
  void toggleStickerPanel() {
    _isStickerPanelOpen = !_isStickerPanelOpen;
    notifyListeners();
  }

  /// إضافة ملصق جديد
  void addSticker(String stickerPath, Size boardSize) {
    final size = boardSize;
    final boardWidth = size.width - 40; // هامش 20 من كل جانب
    final boardHeight = size.height * 0.7; // تقريبًا

    // إنشاء موقع عشوائي داخل منطقة الرسم
    final randomX = 40 + (boardWidth - 100) * math.Random().nextDouble();
    final randomY = 100 + (boardHeight - 100) * math.Random().nextDouble();

    // إنشاء ملصق جديد
    final newSticker = Sticker(
      id: FileUtils.generateUniqueId(),
      imagePath: stickerPath,
      offset: Offset(randomX, randomY),
      scale: WhiteboardValues.defaultStickerScale,
      rotation: 0.0,
    );

    _stickers.add(newSticker);
    _selectedStickerIndex = _stickers.length - 1;
    _removedStickers
        .clear(); // مسح قائمة الملصقات التي تم التراجع عنها لأن المستخدم أضاف ملصقًا جديدًا

    notifyListeners();
  }

  /// تحديد ملصق
  void selectSticker(int? index) {
    if (_selectedStickerIndex == index) {
      _selectedStickerIndex =
          null; // إلغاء التحديد إذا كان الملصق محددًا بالفعل
    } else {
      _selectedStickerIndex = index;
    }
    notifyListeners();
  }

  /// حذف الملصق المحدد
  bool deleteSelectedSticker() {
    if (_selectedStickerIndex == null) return false;

    final removedSticker = _stickers.removeAt(_selectedStickerIndex!);
    _removedStickers.add(removedSticker);
    _selectedStickerIndex = null;

    notifyListeners();
    return true;
  }

  /// تحريك الملصق المحدد
  void moveSelectedSticker(Offset delta) {
    if (_selectedStickerIndex == null) return;

    _stickers[_selectedStickerIndex!] =
        _stickers[_selectedStickerIndex!].copyWith(
      offset: _stickers[_selectedStickerIndex!].offset + delta,
    );

    notifyListeners();
  }

  /// تغيير حجم الملصق المحدد
  void scaleSelectedSticker(double scaleFactor) {
    if (_selectedStickerIndex == null) return;

    final currentScale = _stickers[_selectedStickerIndex!].scale;
    final newScale = (currentScale * scaleFactor).clamp(
        WhiteboardValues.minStickerScale, WhiteboardValues.maxStickerScale);

    _stickers[_selectedStickerIndex!] =
        _stickers[_selectedStickerIndex!].copyWith(
      scale: newScale,
    );

    notifyListeners();
  }

  /// تدوير الملصق المحدد
  void rotateSelectedSticker(double angle) {
    if (_selectedStickerIndex == null) return;

    final currentRotation = _stickers[_selectedStickerIndex!].rotation;

    _stickers[_selectedStickerIndex!] =
        _stickers[_selectedStickerIndex!].copyWith(
      rotation: currentRotation + angle,
    );

    notifyListeners();
  }

  /// مسح كل الملصقات
  void clearAllStickers() {
    _stickers.clear();
    _removedStickers.clear();
    _selectedStickerIndex = null;
    notifyListeners();
  }

  /// استعادة آخر ملصق تم حذفه
  bool redoLastRemovedSticker() {
    if (_removedStickers.isEmpty) return false;

    final lastRemovedSticker = _removedStickers.removeLast();
    _stickers.add(lastRemovedSticker);

    notifyListeners();
    return true;
  }

  /// حذف آخر ملصق تم إضافته
  bool undoLastAddedSticker() {
    if (_stickers.isEmpty) return false;

    final lastSticker = _stickers.removeLast();
    _removedStickers.add(lastSticker);
    _selectedStickerIndex = null;

    notifyListeners();
    return true;
  }
}
