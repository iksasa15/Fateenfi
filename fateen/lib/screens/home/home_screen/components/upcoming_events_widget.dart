import 'package:flutter/material.dart';
import '../controllers/upcoming_events_controller.dart';
import '../constants/upcoming_events_constants.dart';

class UpcomingEventsWidget extends StatelessWidget {
  final UpcomingEventsController controller;
  final VoidCallback? onViewAllPressed;

  const UpcomingEventsWidget({
    Key? key,
    required this.controller,
    this.onViewAllPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة للتصميم المتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    // حساب الأحجام النسبية
    final double horizontalPadding = screenSize.width * 0.04;
    final double smallSpacing = screenSize.height * 0.01;
    final double fontSize =
        isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);

    // التحقق من حالة التحميل
    if (controller.isLoading) {
      return _buildLoadingState(horizontalPadding);
    }

    // عرض رسالة الخطأ إذا وجدت
    if (controller.errorMessage != null) {
      return _buildErrorState(controller.errorMessage!, horizontalPadding);
    }

    // الحصول على المواعيد القادمة مع مراعاة حد العرض
    final events = controller.getLimitedEvents();

    // التحقق من وجود مواعيد
    if (events.isEmpty) {
      return _buildEmptyState(horizontalPadding);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم وزر "عرض الكل"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                UpcomingEventsConstants.sectionTitle,
                style: TextStyle(
                  fontFamily: UpcomingEventsConstants.fontFamily,
                  fontSize: fontSize + 1,
                  fontWeight: FontWeight.bold,
                  color: UpcomingEventsConstants.textColor,
                ),
              ),
              TextButton(
                onPressed: onViewAllPressed,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  UpcomingEventsConstants.viewAllButtonText,
                  style: TextStyle(
                    fontFamily: UpcomingEventsConstants.fontFamily,
                    fontSize: fontSize - 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: smallSpacing),

          // قائمة المواعيد القادمة
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(
                context: context,
                event: event,
                fontSize: fontSize,
                smallSpacing: smallSpacing,
                onTap: () => controller.handleEventTap(event.id),
              );
            },
          ),
        ],
      ),
    );
  }

  // بناء بطاقة حدث
  Widget _buildEventCard({
    required BuildContext context,
    required UpcomingEvent event,
    required double fontSize,
    required double smallSpacing,
    required VoidCallback onTap,
  }) {
    // الحصول على لون ورمز الحدث حسب نوعه
    final Color eventColor =
        UpcomingEventsConstants.eventTypeColors[event.type] ??
            UpcomingEventsConstants.eventTypeColors['other']!;
    final IconData eventIcon =
        UpcomingEventsConstants.eventTypeIcons[event.type] ??
            UpcomingEventsConstants.eventTypeIcons['other']!;

    return Container(
      margin: EdgeInsets.only(bottom: smallSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(UpcomingEventsConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: UpcomingEventsConstants.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: UpcomingEventsConstants.borderColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              eventColor.withOpacity(UpcomingEventsConstants.avatarOpacity),
          child: Icon(
            eventIcon,
            color: eventColor,
            size: UpcomingEventsConstants.iconSize,
          ),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            fontFamily: UpcomingEventsConstants.fontFamily,
            fontSize: fontSize - 1,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          event.date,
          style: TextStyle(
            fontFamily: UpcomingEventsConstants.fontFamily,
            fontSize: fontSize - 3,
            color: Colors.grey[600],
          ),
        ),
        trailing: event.isUrgent
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: UpcomingEventsConstants.urgentBackgroundColor,
                  borderRadius: BorderRadius.circular(
                      UpcomingEventsConstants.urgentBadgeBorderRadius),
                ),
                child: Text(
                  UpcomingEventsConstants.urgentText,
                  style: TextStyle(
                    fontFamily: UpcomingEventsConstants.fontFamily,
                    fontSize: fontSize - 4,
                    fontWeight: FontWeight.bold,
                    color: UpcomingEventsConstants.urgentTextColor,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  // حالة التحميل
  Widget _buildLoadingState(double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.symmetric(vertical: 20),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState(String errorMessage, double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontFamily: UpcomingEventsConstants.fontFamily,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(
              fontFamily: UpcomingEventsConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  // حالة عدم وجود مواعيد
  Widget _buildEmptyState(double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              color: Colors.grey,
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              'لا توجد مواعيد قادمة',
              style: TextStyle(
                fontFamily: UpcomingEventsConstants.fontFamily,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
