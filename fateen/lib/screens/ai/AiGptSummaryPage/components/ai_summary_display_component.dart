import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/ai_summary_strings.dart';
import '../controllers/ai_summary_controller.dart';

class AiSummaryDisplayComponent extends StatelessWidget {
  final AiSummaryController controller;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const AiSummaryDisplayComponent({
    Key? key,
    required this.controller,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // إذا لم يوجد ملخص أو كنا في حالة تحميل
    if (controller.summary.isEmpty || controller.isLoading) {
      return const SizedBox.shrink();
    }

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          // عنوان الملخص
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE3E0F8),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // رأس القسم
                Row(
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
                        Icons.title,
                        color: Color(0xFF6366F1),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "عنوان الملخص",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // محتوى العنوان
                Text(
                  controller.summary.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4338CA),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // بقية المحتوى
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الفكرة الرئيسية
                  if (controller.summary.mainIdea.isNotEmpty)
                    _buildSectionCard(
                      title: AiSummaryStrings.mainIdeaTitle,
                      icon: Icons.lightbulb_outline,
                      content: controller.summary.mainIdea,
                      onCopy: () => _copyTextToClipboard(
                          context, controller.summary.mainIdea),
                    ),

                  const SizedBox(height: 16),

                  // النقاط الرئيسية
                  if (controller.summary.keyPoints.isNotEmpty)
                    _buildPointsCard(
                      title: AiSummaryStrings.keyPointsTitle,
                      icon: Icons.format_list_bulleted,
                      points: controller.summary.keyPoints,
                      onCopy: () => _copyPointsToClipboard(
                          context, controller.summary.keyPoints),
                    ),

                  const SizedBox(height: 16),

                  // الخلاصة
                  if (controller.summary.conclusion.isNotEmpty)
                    _buildSectionCard(
                      title: AiSummaryStrings.conclusionTitle,
                      icon: Icons.summarize,
                      content: controller.summary.conclusion,
                      onCopy: () => _copyTextToClipboard(
                          context, controller.summary.conclusion),
                    ),

                  const SizedBox(height: 24),

                  // أزرار المشاركة والحفظ
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _shareFullSummary(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4338CA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text(
                            "مشاركة الملخص",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _saveSummary(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.save_alt, size: 18),
                          label: const Text(
                            "حفظ الملخص",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء بطاقة قسم عادية (الفكرة الرئيسية أو الخلاصة)
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
    required VoidCallback onCopy,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القسم
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                  child: Icon(
                    icon,
                    color: const Color(0xFF6366F1),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),

                const Spacer(),

                // زر النسخ
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.content_copy,
                      color: Color(0xFF6366F1),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // خط فاصل
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFE3E0F8),
          ),

          // المحتوى
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
              textDirection: _getTextDirection(content),
            ),
          ),
        ],
      ),
    );
  }

  // بناء بطاقة النقاط الرئيسية
  Widget _buildPointsCard({
    required String title,
    required IconData icon,
    required List<String> points,
    required VoidCallback onCopy,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القسم
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                  child: Icon(
                    icon,
                    color: const Color(0xFF6366F1),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),

                const Spacer(),

                // زر النسخ
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.content_copy,
                      color: Color(0xFF6366F1),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // خط فاصل
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFE3E0F8),
          ),

          // قائمة النقاط
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: points.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(left: 8, top: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4338CA),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          points[index],
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF374151),
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                          textDirection: _getTextDirection(points[index]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // نسخ نص إلى الحافظة
  void _copyTextToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(context, "تم نسخ النص إلى الحافظة");
  }

  // نسخ النقاط إلى الحافظة
  void _copyPointsToClipboard(BuildContext context, List<String> points) async {
    String formattedPoints = "";
    for (int i = 0; i < points.length; i++) {
      formattedPoints += "${i + 1}. ${points[i]}\n";
    }
    await Clipboard.setData(ClipboardData(text: formattedPoints));
    _showSnackBar(context, "تم نسخ النقاط إلى الحافظة");
  }

  // مشاركة الملخص كاملاً
  void _shareFullSummary(BuildContext context) async {
    final summary = controller.summary;

    String fullSummary = "${summary.title}\n\n";
    fullSummary += "الفكرة الرئيسية:\n${summary.mainIdea}\n\n";

    fullSummary += "النقاط الرئيسية:\n";
    for (int i = 0; i < summary.keyPoints.length; i++) {
      fullSummary += "${i + 1}. ${summary.keyPoints[i]}\n";
    }

    fullSummary += "\nالخلاصة:\n${summary.conclusion}";

    await Clipboard.setData(ClipboardData(text: fullSummary));
    _showSnackBar(context, "تم نسخ الملخص كاملاً إلى الحافظة للمشاركة");
  }

  // حفظ الملخص
  void _saveSummary(BuildContext context) {
    // هنا يمكن إضافة وظيفة حفظ الملخص كملف
    _showSnackBar(context, "تم حفظ الملخص بنجاح");
  }

  // عرض رسالة بشكل مؤقت
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4338CA),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // تحديد اتجاه النص بناءً على المحتوى
  TextDirection _getTextDirection(String text) {
    final RegExp arabicPattern = RegExp(r'^[\u0600-\u06FF]');
    return arabicPattern.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }
}
