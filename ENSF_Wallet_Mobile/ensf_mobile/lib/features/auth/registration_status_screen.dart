// lib/features/auth/registration_status_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ensf_mobile/core/constants/app_constants.dart';
import 'package:ensf_mobile/core/constants/theme_constants.dart';
import 'package:ensf_mobile/core/services/user_service.dart';
import 'package:ensf_mobile/core/models/api_models.dart';

/// 📋 Registration Status Screen
/// Displays registration status and allows users to check for updates
class RegistrationStatusScreen extends StatefulWidget {
  const RegistrationStatusScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationStatusScreen> createState() => _RegistrationStatusScreenState();
}

class _RegistrationStatusScreenState extends State<RegistrationStatusScreen>
    with TickerProviderStateMixin {
  // Services
  late UserService _userService;
  
  // Data from previous screen
  String? _email;
  String? _requestId;
  String? _initialStatus;
  String? _initialMessage;
  
  // Current status
  String _currentStatus = 'PENDING';
  String _statusMessage = 'En attente de vérification...';
  DateTime? _createdAt;
  bool _isLoading = false;
  bool _isRefreshing = false;
  
  // Auto refresh
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);
  
  // Animations
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _userService = Provider.of<UserService>(context, listen: false);
    
    // Get data from navigation arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getNavigationData();
      _setupAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Setup animations
  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  /// Get data from navigation arguments
  void _getNavigationData() {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (arguments != null) {
      _email = arguments['email'] as String?;
      _requestId = arguments['requestId'] as String?;
      _initialStatus = arguments['status'] as String?;
      _initialMessage = arguments['message'] as String?;
      
      if (_initialStatus != null) {
        setState(() {
          _currentStatus = _initialStatus!;
          _statusMessage = _initialMessage ?? _getStatusMessage(_initialStatus!);
        });
      }
    }
    
    // Load initial status
    _checkRegistrationStatus();
  }

  /// Setup auto refresh for pending status
  void _setupAutoRefresh() {
    if (_currentStatus == 'PENDING') {
      _pulseController.repeat(reverse: true);
      _refreshTimer = Timer.periodic(_refreshInterval, (_) {
        if (_currentStatus == 'PENDING' && mounted) {
          _checkRegistrationStatus(showLoading: false);
        }
      });
    }
  }

  /// Check registration status with backend
  Future<void> _checkRegistrationStatus({bool showLoading = true}) async {
    if (_email == null) return;
    
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _isRefreshing = true;
      });
    }
    
    try {
      final statusData = await _userService.checkRegistrationStatus(_email!);
      
      setState(() {
        _currentStatus = statusData['status'] as String? ?? 'UNKNOWN';
        _statusMessage = statusData['message'] as String? ?? _getStatusMessage(_currentStatus);
        
        if (statusData['createdAt'] != null) {
          _createdAt = DateTime.parse(statusData['createdAt'] as String);
        }
        
        _isLoading = false;
        _isRefreshing = false;
      });
      
      // Stop auto refresh if status is no longer pending
      if (_currentStatus != 'PENDING') {
        _refreshTimer?.cancel();
        _pulseController.stop();
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      
      _showErrorMessage('Erreur lors de la vérification du statut: ${e.toString()}');
    }
  }

  /// Get status message based on status code
  String _getStatusMessage(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Votre demande est en cours de vérification par notre équipe. Cela peut prendre 24-48 heures.';
      case 'ACTIVE':
        return 'Félicitations! Votre compte a été approuvé et est maintenant actif.';
      case 'REJECTED':
        return 'Votre demande a été rejetée. Veuillez contacter le support ou soumettre une nouvelle demande.';
      case 'BLOCKED':
        return 'Votre compte a été bloqué. Veuillez contacter le service client.';
      case 'NOT_FOUND':
        return 'Aucune demande d\'inscription trouvée pour cet email.';
      default:
        return 'Statut inconnu. Veuillez contacter le support.';
    }
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'ACTIVE':
        return Colors.green;
      case 'REJECTED':
      case 'BLOCKED':
        return Colors.red;
      case 'NOT_FOUND':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get status icon
  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_top;
      case 'ACTIVE':
        return Icons.check_circle;
      case 'REJECTED':
      case 'BLOCKED':
        return Icons.cancel;
      case 'NOT_FOUND':
        return Icons.search_off;
      default:
        return Icons.help;
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Handle navigation based on status
  void _handleNavigation() {
    switch (_currentStatus.toUpperCase()) {
      case 'ACTIVE':
        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
        break;
      case 'REJECTED':
      case 'NOT_FOUND':
        // Navigate back to registration
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/register',
          (route) => false,
        );
        break;
      default:
        // Stay on this screen for pending/blocked status
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeConstants.primaryColor,
        title: const Text(
          'Statut de l\'inscription',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading ? _buildLoadingScreen() : _buildStatusContent(),
      ),
    );
  }

  /// Build loading screen
  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Vérification du statut...'),
        ],
      ),
    );
  }

  /// Build main status content
  Widget _buildStatusContent() {
    return RefreshIndicator(
      onRefresh: () => _checkRegistrationStatus(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
          child: Column(
            children: [
              const SizedBox(height: ThemeConstants.largePadding),
              _buildStatusCard(),
              const SizedBox(height: ThemeConstants.largePadding),
              _buildInfoCard(),
              const SizedBox(height: ThemeConstants.largePadding),
              _buildActionButtons(),
              const SizedBox(height: ThemeConstants.largePadding),
              _buildHelpSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build main status card
  Widget _buildStatusCard() {
    final statusColor = _getStatusColor(_currentStatus);
    final statusIcon = _getStatusIcon(_currentStatus);
    
    return Card(
      elevation: ThemeConstants.defaultElevation,
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.largePadding),
        child: Column(
          children: [
            // Status icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _currentStatus == 'PENDING' ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 2),
                    ),
                    child: Icon(
                      statusIcon,
                      size: 40,
                      color: statusColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            
            // Status title
            Text(
              _getStatusTitle(_currentStatus),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.smallPadding),
            
            // Status message
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Refresh indicator for pending status
            if (_currentStatus == 'PENDING' && _isRefreshing)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Vérification...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build information card
  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations sur votre demande',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            
            if (_email != null)
              _buildInfoRow('Email', _email!),
            
            if (_requestId != null)
              _buildInfoRow('ID de demande', _requestId!),
            
            _buildInfoRow('Statut actuel', _currentStatus),
            
            if (_createdAt != null)
              _buildInfoRow(
                'Date de soumission',
                '${_createdAt!.day}/${_createdAt!.month}/${_createdAt!.year}',
              ),
            
            // Estimated processing time for pending status
            if (_currentStatus == 'PENDING')
              _buildInfoRow(
                'Délai estimé',
                '24-48 heures',
                isHighlighted: true,
              ),
          ],
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action button
        if (_currentStatus == 'ACTIVE')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleNavigation,
              icon: const Icon(Icons.login),
              label: const Text('Se connecter maintenant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          )
        else if (_currentStatus == 'REJECTED' || _currentStatus == 'NOT_FOUND')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleNavigation,
              icon: const Icon(Icons.refresh),
              label: const Text('Nouvelle inscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          )
        else if (_currentStatus == 'PENDING')
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _checkRegistrationStatus(),
              icon: const Icon(Icons.refresh),
              label: const Text('Vérifier le statut'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        
        const SizedBox(height: ThemeConstants.mediumPadding),
        
        // Secondary action button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (route) => false,
            ),
            icon: const Icon(Icons.home),
            label: const Text('Retour à l\'accueil'),
          ),
        ),
      ],
    );
  }

  /// Build help section
  Widget _buildHelpSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Besoin d\'aide?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            
            _buildHelpItem(
              icon: Icons.email,
              title: 'Support par email',
              subtitle: AppConstants.supportEmail,
              onTap: () => _showComingSoonMessage('Support par email'),
            ),
            
            _buildHelpItem(
              icon: Icons.phone,
              title: 'Support téléphonique',
              subtitle: AppConstants.supportPhone,
              onTap: () => _showComingSoonMessage('Support téléphonique'),
            ),
            
            _buildHelpItem(
              icon: Icons.help_center,
              title: 'Centre d\'aide',
              subtitle: 'FAQ et guides',
              onTap: () => _showComingSoonMessage('Centre d\'aide'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                color: isHighlighted ? ThemeConstants.primaryColor : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build help item
  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: ThemeConstants.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// Get status title
  String _getStatusTitle(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En cours de vérification';
      case 'ACTIVE':
        return 'Compte activé!';
      case 'REJECTED':
        return 'Demande rejetée';
      case 'BLOCKED':
        return 'Compte bloqué';
      case 'NOT_FOUND':
        return 'Demande introuvable';
      default:
        return 'Statut inconnu';
    }
  }

  /// Show coming soon message
  void _showComingSoonMessage(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bientôt disponible'),
        content: Text('La fonctionnalité "$feature" sera disponible dans une prochaine mise à jour.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}