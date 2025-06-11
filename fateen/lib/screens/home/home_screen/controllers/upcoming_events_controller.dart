import 'package:flutter/material.dart';
import '../services/firebaseServices/upcoming_events_service.dart';

class UpcomingEvent {
  final String id;
  final String title;
  final String date;
  final String type;
  final bool isUrgent;

  UpcomingEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.isUrgent = false,
  });

  factory UpcomingEvent.fromMap(Map<String, dynamic> data, String id) {
    return UpcomingEvent(
      id: id,
      title: data['title'] ?? 'بدون عنوان',
      date: data['date'] ?? 'غير محدد',
      type: data['type'] ?? 'other',
      isUrgent: data['isUrgent'] ?? false,
    );
  }
}

class UpcomingEventsController extends ChangeNotifier {
  final UpcomingEventsService _service = UpcomingEventsService();
  bool _isLoading = true;
  String? _errorMessage;
  List<UpcomingEvent> _events = [];

  // الحصول على القيم
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UpcomingEvent> get events => _events;

  // عدد العناصر للعرض (اختياري)
  int _displayLimit = 3;
  int get displayLimit => _displayLimit;
  set displayLimit(int value) {
    _displayLimit = value;
    notifyListeners();
  }

  // تهيئة البيانات
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // جلب البيانات من Firebase
      final data = await _service.getUpcomingEvents();

      // معالجة البيانات
      _events = data.entries
          .map((entry) => UpcomingEvent.fromMap(entry.value, entry.key))
          .toList();

      // ترتيب الأحداث: الأحداث العاجلة أولًا، ثم حسب التاريخ
      _events.sort((a, b) {
        // العاجلة أولًا
        if (a.isUrgent != b.isUrgent) {
          return a.isUrgent ? -1 : 1;
        }
        // ثم حسب التاريخ (هنا نفترض أن التاريخ نصي، في التطبيق الفعلي يفضل استخدام DateTime)
        return a.date.compareTo(b.date);
      });

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
      _events = _getDefaultEvents(); // استخدام بيانات افتراضية في حالة الخطأ
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // بيانات افتراضية للعرض في حالة الخطأ
  List<UpcomingEvent> _getDefaultEvents() {
    return [
      UpcomingEvent(
        id: '1',
        title: 'اختبار نصفي - مقدمة في البرمجة',
        date: 'الثلاثاء، ١٠ يونيو',
        type: 'exam',
        isUrgent: true,
      ),
      UpcomingEvent(
        id: '2',
        title: 'تسليم واجب - هندسة البرمجيات',
        date: 'الخميس، ١٢ يونيو',
        type: 'assignment',
        isUrgent: false,
      ),
      UpcomingEvent(
        id: '3',
        title: 'محاضرة استثنائية - تصميم قواعد البيانات',
        date: 'الأحد، ١٥ يونيو',
        type: 'lecture',
        isUrgent: false,
      ),
    ];
  }

  // تحديث البيانات
  Future<void> refresh() async {
    await initialize();
  }

  // الحصول على الأحداث مع حد العرض
  List<UpcomingEvent> getLimitedEvents() {
    if (_events.length <= _displayLimit) {
      return _events;
    }
    return _events.sublist(0, _displayLimit);
  }

  // معالجة النقر على حدث
  void handleEventTap(String eventId) {
    // يمكن إضافة منطق معالجة النقر على الحدث هنا
    // مثل فتح صفحة تفاصيل الحدث
    print('تم النقر على الحدث: $eventId');
  }

  @override
  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
    super.dispose();
  }
}
