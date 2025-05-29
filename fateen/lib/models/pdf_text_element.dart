import 'dart:ui';

class PdfTextElement {
  final String text;
  final Rect bounds;
  final int pageIndex;
  final double fontSize;
  final String fontFamily;
  final bool isBold;
  final bool isItalic;

  PdfTextElement({
    required this.text,
    required this.bounds,
    required this.pageIndex,
    required this.fontSize,
    required this.fontFamily,
    this.isBold = false,
    this.isItalic = false,
  });

  /// إنشاء عنصر جديد بناءً على عنصر موجود مع تغيير النص
  factory PdfTextElement.fromElement(PdfTextElement element,
      {required String newText}) {
    return PdfTextElement(
      text: newText,
      bounds: element.bounds,
      pageIndex: element.pageIndex,
      fontSize: element.fontSize,
      fontFamily: element.fontFamily,
      isBold: element.isBold,
      isItalic: element.isItalic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'bounds': {
        'left': bounds.left,
        'top': bounds.top,
        'right': bounds.right,
        'bottom': bounds.bottom,
      },
      'pageIndex': pageIndex,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'isBold': isBold,
      'isItalic': isItalic,
    };
  }

  factory PdfTextElement.fromJson(Map<String, dynamic> json) {
    return PdfTextElement(
      text: json['text'],
      bounds: Rect.fromLTRB(
        json['bounds']['left'],
        json['bounds']['top'],
        json['bounds']['right'],
        json['bounds']['bottom'],
      ),
      pageIndex: json['pageIndex'],
      fontSize: json['fontSize'],
      fontFamily: json['fontFamily'],
      isBold: json['isBold'],
      isItalic: json['isItalic'],
    );
  }
}
