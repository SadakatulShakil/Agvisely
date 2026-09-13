import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Notification inbox. NotificationService routes here on tap-through.
/// Build the list UI from the Figma "Notifications" frame.
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('common.notifications'.tr)),
      body: const Center(child: Text('Notifications — TODO from Figma')),
    );
  }
}
