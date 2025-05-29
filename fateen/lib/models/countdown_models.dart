class CountdownModel {
  // اسم العداد
  final String title;

  // تاريخ انتهاء العداد
  final DateTime targetDate;

  // Constructor للكلاس
  CountdownModel({required this.title, required this.targetDate});

  // دالة لحساب الأيام المتبقية حتى التاريخ المستهدف
  int get daysLeft {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }
}
