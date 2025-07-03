import 'package:flutter/material.dart';
import '../core/constants/theme_constants.dart';

/// 🚨 Custom Error Widget
/// Professional error display with retry functionality
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? actionText;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon container
            Container(
              padding: const EdgeInsets.all(ThemeConstants.largePadding),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.largeBorderRadius),
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            
            const SizedBox(height: ThemeConstants.largePadding),
            
            // Error title
            Text(
              'Oops ! Une erreur s\'est produite',
              style: ThemeConstants.subheadingStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: ThemeConstants.defaultPadding),
            
            // Error message
            Text(
              message,
              style: ThemeConstants.bodyStyle.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Retry button (if provided)
            if (onRetry != null) ...[
              const SizedBox(height: ThemeConstants.largePadding),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(actionText ?? 'Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.largePadding,
                    vertical: ThemeConstants.defaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🚨 Network Error Widget
/// Specific error widget for network-related issues
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: 'Vérifiez votre connexion internet et réessayez.',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      actionText: 'Réessayer',
    );
  }
}

/// 🚨 Server Error Widget
/// Specific error widget for server-related issues
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: 'Le serveur rencontre des difficultés. Veuillez réessayer plus tard.',
      onRetry: onRetry,
      icon: Icons.cloud_off,
      actionText: 'Réessayer',
    );
  }
}

/// 🚨 Authentication Error Widget
/// Specific error widget for authentication issues
class AuthErrorWidget extends StatelessWidget {
  final VoidCallback? onLogin;

  const AuthErrorWidget({
    Key? key,
    this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: 'Votre session a expiré. Veuillez vous reconnecter.',
      onRetry: onLogin,
      icon: Icons.lock_outline,
      actionText: 'Se connecter',
    );
  }
}

/// 🚨 Empty State Widget
/// Widget for empty states (no data)
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon container
            Container(
              padding: const EdgeInsets.all(ThemeConstants.largePadding),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.largeBorderRadius),
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            
            const SizedBox(height: ThemeConstants.largePadding),
            
            // Empty state title
            Text(
              title,
              style: ThemeConstants.subheadingStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: ThemeConstants.defaultPadding),
            
            // Empty state message
            Text(
              message,
              style: ThemeConstants.bodyStyle.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button (if provided)
            if (onAction != null) ...[
              const SizedBox(height: ThemeConstants.largePadding),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.largePadding,
                    vertical: ThemeConstants.defaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                  ),
                ),
                child: Text(actionText ?? 'Action'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🚨 Maintenance Mode Widget
/// Widget for when the app is in maintenance mode
class MaintenanceModeWidget extends StatelessWidget {
  final String? customMessage;

  const MaintenanceModeWidget({
    Key? key,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: customMessage ?? 
          'L\'application est en maintenance. Veuillez réessayer plus tard.',
      icon: Icons.build_outlined,
      actionText: null, // No retry for maintenance
    );
  }
}

/// 🚨 No Internet Widget
/// Widget for when there's no internet connection
class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: 'Aucune connexion internet détectée. Vérifiez vos paramètres réseau.',
      onRetry: onRetry,
      icon: Icons.signal_wifi_off,
      actionText: 'Réessayer',
    );
  }
}

/// 🚨 Generic Error Dialog
/// Reusable error dialog for showing errors in modal
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryText,
  }) : super(key: key);

  /// Show error dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        retryText: retryText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 24,
          ),
          const SizedBox(width: ThemeConstants.smallPadding),
          Expanded(
            child: Text(
              title,
              style: ThemeConstants.headingStyle.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: ThemeConstants.bodyStyle,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(retryText ?? 'Réessayer'),
          ),
      ],
    );
  }
}