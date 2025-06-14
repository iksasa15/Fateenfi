import 'package:flutter/material.dart';
import '../controllers/upcoming_events_controller.dart';
import '../constants/upcoming_events_constants.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

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
    // التحقق من حالة التحميل
    if (controller.isLoading) {
      return _buildLoadingState(context);
    }

    // عرض رسالة الخطأ إذا وجدت
    if (controller.errorMessage != null) {
      return _buildErrorState(context, controller.errorMessage!);
    }

    // الحصول على المواعيد القادمة مع مراعاة حد العرض
    final events = controller.getLimitedEvents();

    // التحقق من وجود مواعيد
    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.getSpacing(context),
      ),
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
                  fontSize: AppDimensions.getBodyFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: context.colorTextPrimary,
                ),
              ),
              TextButton(
                onPressed: onViewAllPressed,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.getSpacing(context,
                        size: SpacingSize.small),
                    vertical: AppDimensions.getSpacing(context,
                            size: SpacingSize.small) /
                        2,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  UpcomingEventsConstants.viewAllButtonText,
                  style: TextStyle(
                    fontFamily: UpcomingEventsConstants.fontFamily,
                    fontSize: AppDimensions.getLabelFontSize(context),
                    color: context.colorPrimary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),

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
      margin: EdgeInsets.only(
        bottom: AppDimensions.getSpacing(context, size: SpacingSize.small),
      ),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: context.colorBorder,
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
            size: AppDimensions.getIconSize(context, size: IconSize.small, small: true),
          ),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            fontFamily: UpcomingEventsConstants.fontFamily,
            fontSize: AppDimensions.getBodyFontSize(context),
            fontWeight: FontWeight.w600,
            color: context.colorTextPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          event.date,
          style: TextStyle(
            fontFamily: UpcomingEventsConstants.fontFamily,
            fontSize: AppDimensions.getLabelFontSize(context),
            color: context.colorTextSecondary,
          ),
        ),
        trailing: event.isUrgent
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.getSpacing(context,
                      size: SpacingSize.small),
                  vertical: AppDimensions.getSpacing(context,
                          size: SpacingSize.small) /
                      2,
                ),
                decoration: BoxDecoration(
                  color: context.colorError.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius / 2),
                ),
                child: Text(
                  UpcomingEventsConstants.urgentText,
                  style: TextStyle(
                    fontFamily: UpcomingEventsConstants.fontFamily,
                    fontSize:
                        AppDimensions.getLabelFontSize(context, small: true),
                    fontWeight: FontWeight.bold,
                    color: context.colorError,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  // حالة التحميل
  Widget _buildLoadingState(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.getSpacing(context),
      ),
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.getSpacing(context, size: SpacingSize.medium),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: context.colorPrimary,
        ),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.getSpacing(context),
      ),
      padding: EdgeInsets.all(
        AppDimensions.getSpacing(context),
      ),
      decoration: BoxDecoration(
        color: context.colorError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        border: Border.all(color: context.colorError.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: context.colorError,
                size: AppDimensions.getIconSize(context, size: IconSize.small, small: true),
              ),
              SizedBox(
                  width: AppDimensions.getSpacing(context,
                      size: SpacingSize.small)),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorError,
                    fontFamily: UpcomingEventsConstants.fontFamily,
                    fontSize: AppDimensions.getBodyFontSize(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          Text(
            errorMessage,
            style: TextStyle(
              fontFamily: UpcomingEventsConstants.fontFamily,
              color: context.colorTextPrimary,
              fontSize: AppDimensions.getLabelFontSize(context),
            ),
          ),
        ],
      ),
    );
  }

  // حالة عدم وجود مواعيد
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.getSpacing(context),
      ),
      padding: EdgeInsets.all(
        AppDimensions.getSpacing(context),
      ),
      decoration: BoxDecoration(
        color: context.colorSurfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              color: context.colorTextHint,
              size: AppDimensions.getIconSize(context, size: IconSize.large, small: false),
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            Text(
              'لا توجد مواعيد قادمة',
              style: TextStyle(
                fontFamily: UpcomingEventsConstants.fontFamily,
                color: context.colorTextSecondary,
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.getBodyFontSize(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
