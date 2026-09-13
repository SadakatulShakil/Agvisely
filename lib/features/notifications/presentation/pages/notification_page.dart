import 'package:flutter/material.dart';

import '../../../../core/services/localization_string.dart';

/// Notification inbox. NotificationService routes here on tap-through.
/// Build the list UI from the Figma "Notifications" frame.
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('common.notifications'))),
      body: const Center(child: Text('Notifications — TODO from Figma')),
    );
  }
}
