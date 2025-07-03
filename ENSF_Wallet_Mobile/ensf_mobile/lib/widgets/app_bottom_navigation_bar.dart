import 'package:flutter/material.dart';
import 'package:ensf_mobile/core/constants/theme_constants.dart';

/// 📱 App Bottom Navigation Bar - CORRECTED
/// Consistent navigation across all main screens with proper routing
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap ?? (index) => _navigateToScreen(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: ThemeConstants.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  /// Navigate to the selected screen
  void _navigateToScreen(BuildContext context, int index) {
    // Prevent navigation if already on the selected screen
    if (index == currentIndex) return;

    String routeName;
    switch (index) {
      case 0:
        routeName = '/home';
        break;
      case 1:
        routeName = '/card';
        break;
      case 2:
        routeName = '/transactions'; // FIXED: was '/notification', now correct
        break;
      case 3:
        routeName = '/profile';
        break;
      default:
        return;
    }

    // Use pushReplacementNamed to replace current screen
    Navigator.pushReplacementNamed(context, routeName);
  }
}