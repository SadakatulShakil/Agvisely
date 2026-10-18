import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';

class _DemoNotification {
  const _DemoNotification(this.title, this.body, this.time);
  final String title;
  final String body;
  final String time;
}

/// Notification inbox. NotificationService routes here on tap-through.
/// Demo data only for now — no backend-persisted notification history
/// exists yet (FCM/local notifications fire directly, nothing is stored).
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const _demoNotifications = [
    _DemoNotification(
      'Rain Alert',
      'Rain starting soon ☔: Expect a light shower in about 15 minutes near you.',
      '03:34 PM',
    ),
    _DemoNotification(
      'Rain Alert',
      'Rain starting soon ☔: Expect a light shower in about 15 minutes near you.',
      '03:34 PM',
    ),
    _DemoNotification(
      'Rain Alert',
      'Rain starting soon ☔: Expect a light shower in about 15 minutes near you.',
      '03:34 PM',
    ),
    _DemoNotification(
      'Rain Alert',
      'Rain starting soon ☔: Expect a light shower in about 15 minutes near you.',
      '03:34 PM',
    ),
    _DemoNotification(
      'Rain Alert',
      'Rain starting soon ☔: Expect a light shower in about 15 minutes near you.',
      '03:34 PM',
    ),
    _DemoNotification(
      'Rain Alert',
      'Rain starting soon ☔: Expect a light shower in about 15 minutes near you.',
      '03:34 PM',
    ),
    _DemoNotification(
      'Rain Alert',
      'Rain starting soon ☔: Expect a light shower in about 15 minutes near you.',
      '03:34 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 20.h, 16.w, 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'common.notifications'.tr,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _demoNotifications.isEmpty
                  ? Center(
                      child: Text(
                        'notifications.empty'.tr,
                        style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                      itemCount: _demoNotifications.length,
                      separatorBuilder: (context, i) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) => _NotificationCard(
                        notification: _demoNotifications[i],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final _DemoNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14.sp, color: AppColors.navy, height: 1.4),
              children: [
                TextSpan(
                  text: '${notification.title}: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '"${notification.body}"'),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            notification.time,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }
}
