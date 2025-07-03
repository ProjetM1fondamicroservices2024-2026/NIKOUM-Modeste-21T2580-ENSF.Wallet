import 'package:flutter/material.dart';
import '../core/constants/theme_constants.dart';
import '../core/models/api_models.dart';

/// 🚨 Account Status Banner Widget
/// Displays account status information to users
/// Shows appropriate messages based on account approval status
class AccountStatusBanner extends StatelessWidget {
  final AccountStatusResult accountStatus;

  const AccountStatusBanner({
    Key? key,
    required this.accountStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(ThemeConstants.defaultPadding),
      padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
      decoration: BoxDecoration(
        color: _getBannerColor(),
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(),
              color: _getIconColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: ThemeConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: ThemeConstants.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  accountStatus.message,
                  style: ThemeConstants.bodyStyle.copyWith(
                    color: _getTextColor().withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                if (_showActionButton()) ...[
                  const SizedBox(height: ThemeConstants.defaultPadding),
                  _buildActionButton(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get banner background color based on status
  Color _getBannerColor() {
    switch (accountStatus.status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange.withOpacity(0.1);
      case 'REJECTED':
        return Colors.red.withOpacity(0.1);
      case 'BLOCKED':
        return Colors.grey.withOpacity(0.1);
      default:
        return Colors.blue.withOpacity(0.1);
    }
  }

  /// Get border color based on status
  Color _getBorderColor() {
    switch (accountStatus.status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange.withOpacity(0.3);
      case 'REJECTED':
        return Colors.red.withOpacity(0.3);
      case 'BLOCKED':
        return Colors.grey.withOpacity(0.3);
      default:
        return Colors.blue.withOpacity(0.3);
    }
  }

  /// Get icon background color
  Color _getIconBackgroundColor() {
    switch (accountStatus.status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange.withOpacity(0.2);
      case 'REJECTED':
        return Colors.red.withOpacity(0.2);
      case 'BLOCKED':
        return Colors.grey.withOpacity(0.2);
      default:
        return Colors.blue.withOpacity(0.2);
    }
  }

  /// Get icon color based on status
  Color _getIconColor() {
    switch (accountStatus.status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'BLOCKED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// Get text color based on status
  Color _getTextColor() {
    switch (accountStatus.status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange.shade800;
      case 'REJECTED':
        return Colors.red.shade800;
      case 'BLOCKED':
        return Colors.grey.shade800;
      default:
        return Colors.blue.shade800;
    }
  }

  /// Get status icon
  IconData _getStatusIcon() {
    switch (accountStatus.status.toUpperCase()) {
      case 'PENDING':
        return Icons.access_time;
      case 'REJECTED':
        return Icons.error_outline;
      case 'BLOCKED':
        return Icons.block;
      default:
        return Icons.info_outline;
    }
  }

  /// Get status title
  String _getStatusTitle() {
    switch (accountStatus.status.toUpperCase()) {
      case 'PENDING':
        return 'Compte en cours de vérification';
      case 'REJECTED':
        return 'Compte rejeté';
      case 'BLOCKED':
        return 'Compte temporairement bloqué';
      default:
        return 'Information compte';
    }
  }

  /// Check if action button should be shown
  bool _showActionButton() {
    return accountStatus.status.toUpperCase() == 'REJECTED';
  }

  /// Build action button for rejected accounts
  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleActionButtonPress(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getIconColor(),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          ),
        ),
        child: const Text(
          'Mettre à jour mes documents',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Handle action button press
  void _handleActionButtonPress(BuildContext context) {
    Navigator.pushNamed(context, '/registration-update');
  }
}