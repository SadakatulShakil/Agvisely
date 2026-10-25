import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../models/notification_model.dart';
import '../../domen/controllers/notification_controller.dart';

/// Notification inbox — `GET /notifications`. NotificationService routes
/// here on tap-through from a push.
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final NotificationController controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationController());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<NotificationController>();
    super.dispose();
  }

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
                  SizedBox(width: 8.w),
                  Obx(() {
                    final count = controller.unreadCount.value;
                    if (count <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  Obx(() {
                    if (controller.unreadCount.value <= 0) return const SizedBox.shrink();
                    return TextButton(
                      onPressed: controller.markAllAsRead,
                      child: Text('notifications.mark_all_read'.tr),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final error = controller.errorMessage.value;
                if (error != null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 36.sp, color: AppColors.textSecondaryLight),
                          SizedBox(height: 12.h),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
                          ),
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed: controller.loadNotifications,
                            child: Text('common.retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = controller.notifications;
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'notifications.empty'.tr,
                      style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadNotifications,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    itemCount: items.length + 1,
                    separatorBuilder: (context, i) => SizedBox(height: 12.h),
                    itemBuilder: (context, i) {
                      if (i == items.length) {
                        return Obx(
                          () => controller.isLoadingMore.value
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        );
                      }
                      final notification = items[i];
                      return GestureDetector(
                        onTap: () => controller.markAsRead(notification),
                        child: _NotificationCard(notification: notification),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final NotificationModel notification;

  String _time(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    return isToday ? DateFormat('hh:mm a').format(dt) : DateFormat('MMM d, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: !notification.isRead
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
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
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            _time(notification.createdAt),
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }
}
