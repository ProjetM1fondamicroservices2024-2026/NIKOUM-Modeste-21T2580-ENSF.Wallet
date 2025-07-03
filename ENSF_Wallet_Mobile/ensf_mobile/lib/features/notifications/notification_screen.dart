import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Transaction Successful',
      'message': 'You successfully transferred FCFA 50,000 to John Doe',
      'time': '10:30 AM',
      'type': 'success',
    },
    {
      'title': 'New Offer Available',
      'message': 'Get 10% cashback on all food purchases this week',
      'time': '9:45 AM',
      'type': 'info',
    },
    {
      'title': 'Low Balance Alert',
      'message': 'Your account balance is below FCFA 10,000',
      'time': 'Yesterday',
      'type': 'warning',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // TODO: Implement clear all notifications
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          
          return Card(
            elevation: ThemeConstants.defaultElevation,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                _getNotificationIcon(notification['type']),
                color: _getNotificationColor(notification['type']),
              ),
              title: Text(notification['title']),
              subtitle: Text(notification['message']),
              trailing: Text(
                notification['time'],
                style: TextStyle(
                  color: ThemeConstants.textMedium,
                ),
              ),
            ),
          );
        },
      ),
      // TODO: Add bottom navigation bar once the widget is created
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return ThemeConstants.successColor;
      case 'warning':
        return ThemeConstants.warningColor;
      case 'info':
        return ThemeConstants.accentColor;
      default:
        return ThemeConstants.primaryColor;
    }
  }
}
