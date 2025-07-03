// lib/features/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import '../core/constants/app_constants.dart';
import '../core/constants/theme_constants.dart';
import '../core/services/account_service.dart';
import '../core/services/user_service.dart';
import '../core/models/api_models.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import '../widgets/account_status_banner.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

/// 🏠 Home Screen with Complete Banking Functionality
/// Features:
/// - Real-time balance display
/// - Account status verification
/// - Recent transactions
/// - Quick action buttons
/// - Professional UI with proper error handling
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Services
  final AccountService _accountService = AccountService();
  final UserService _userService = UserService();

  // State variables
  String _currency = 'FCFA';
  double _balance = 0.0;
  bool _isLoading = true;
  bool _isRefreshing = false;
  List<TransactionResponse> _recentTransactions = [];
  AccountStatusResult? _accountStatus;
  UserProfile? _userProfile;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _balanceAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _balanceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  @override
  void dispose() {
    _balanceAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  /// Initialize animation controllers
  void _initializeAnimations() {
    _balanceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _balanceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _balanceAnimationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
  }

  /// Initialize all data on screen load
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load data concurrently
      await Future.wait([
        _checkAccountStatus(),
        _fetchUserProfile(),
        _fetchBalance(),
        _fetchRecentTransactions(),
      ]);

      // Start animations
      _fadeAnimationController.forward();
      _balanceAnimationController.forward();

    } catch (e) {
      developer.log('❌ Home screen initialization error: $e', name: 'HomeScreen');
      setState(() {
        _errorMessage = e is ApiError ? e.message : 'Erreur lors du chargement des données';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Check account approval status
  Future<void> _checkAccountStatus() async {
    try {
      final status = await _accountService.checkAccountStatus();
      setState(() {
        _accountStatus = status;
      });
    } catch (e) {
      developer.log('❌ Account status check failed: $e', name: 'HomeScreen');
      // Continue even if status check fails
    }
  }

  /// Fetch user profile
  Future<void> _fetchUserProfile() async {
    try {
      final profile = await _userService.getUserProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      developer.log('❌ Profile fetch failed: $e', name: 'HomeScreen');
      // Continue even if profile fetch fails
    }
  }

  /// Fetch account balance
  Future<void> _fetchBalance() async {
    
    try {
      developer.log(_userProfile?.idClient ?? 'No idClient', name: "HomeScreen");
      if (_userProfile?.idClient != null) {
        final balance = await _accountService.getBalance(_userProfile!.idClient);
        setState(() {
          _balance = balance;
        });
      }
    } catch (e) {
      developer.log('❌ Balance fetch failed: $e', name: 'HomeScreen');
      throw e; // Re-throw to show error to user
    }
  }

  /// Fetch recent transactions
  Future<void> _fetchRecentTransactions() async {
    try {
      final transactions = await _accountService.getRecentTransactions();
      setState(() {
        _recentTransactions = transactions;
      });
    } catch (e) {
      developer.log('❌ Transactions fetch failed: $e', name: 'HomeScreen');
      // Continue even if transactions fetch fails
    }
  }

  /// Refresh all data
  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      await _initializeData();
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données actualisées'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Error is already handled in _initializeData
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  /// Validate account before performing operations
  Future<bool> _validateAccountForOperation() async {
    try {
      await _accountService.validateAccountForOperations();
      return true;
    } catch (e) {
      _showAccountStatusDialog(e is ApiError ? e.message : 'Compte non approuvé');
      return false;
    }
  }

  /// Show account status dialog
  void _showAccountStatusDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compte non approuvé'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (_accountStatus?.status.toUpperCase() == 'REJECTED')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToRegistrationUpdate();
              },
              child: const Text('Mettre à jour'),
            ),
        ],
      ),
    );
  }

  /// Navigate to registration update
  void _navigateToRegistrationUpdate() {
    Navigator.pushNamed(context, '/registration-update');
  }

  /// Handle quick action button press
  Future<void> _onQuickActionPressed(String action) async {
    // Validate account status first
    final isValid = await _validateAccountForOperation();
    if (!isValid) return;

    // Navigate to appropriate screen
    switch (action) {
      case 'deposit':
        Navigator.pushNamed(context, '/deposit');
        break;
      case 'withdraw':
        Navigator.pushNamed(context, '/withdraw');
        break;
      case 'transfer':
        Navigator.pushNamed(context, '/transfer');
        break;
      case 'top_up':
        Navigator.pushNamed(context, '/top-up');
        break;
      default:
        developer.log('Unknown action: $action', name: 'HomeScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(
        message: 'Chargement de vos informations...',
      ),
    );
  }

  /// Build main content
  Widget _buildMainContent() {
    if (_errorMessage != null) {
      return CustomErrorWidget(
        message: _errorMessage!,
        onRetry: _initializeData,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: ThemeConstants.primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Account status banner
                  if (_accountStatus != null && !_accountStatus!.canPerformOperations)
                    AccountStatusBanner(accountStatus: _accountStatus!),
                  
                  const SizedBox(height: ThemeConstants.defaultPadding),
                  
                  // Balance card
                  _buildBalanceCard(),
                  
                  const SizedBox(height: ThemeConstants.largePadding),
                  
                  // Quick actions
                  _buildQuickActionButtons(),
                  
                  const SizedBox(height: ThemeConstants.largePadding),
                  
                  // Recent transactions
                  _buildRecentTransactionsSection(),
                  
                  const SizedBox(height: ThemeConstants.largePadding),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build app bar
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: ThemeConstants.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Bonjour ${_userProfile?.prenom ?? 'Utilisateur'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeConstants.primaryColor,
                ThemeConstants.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
    );
  }

  /// Build balance card
  Widget _buildBalanceCard() {
    return AnimatedBuilder(
      animation: _balanceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _balanceAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.defaultPadding),
            padding: const EdgeInsets.all(ThemeConstants.largePadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeConstants.primaryColor,
                  ThemeConstants.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.largeBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solde disponible',
                      style: ThemeConstants.bodyStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    if (_isRefreshing)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                        onPressed: _refreshData,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_balance.toStringAsFixed(0)} $_currency',
                  style: ThemeConstants.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dernière mise à jour: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: ThemeConstants.captionStyle.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build quick action buttons
  Widget _buildQuickActionButtons() {
    final actions = [
      {
        'title': 'Dépôt',
        'icon': Icons.add_circle_outline,
        'color': Colors.green,
        'action': 'deposit',
      },
      {
        'title': 'Retrait',
        'icon': Icons.remove_circle_outline,
        'color': Colors.orange,
        'action': 'withdrawal',
      },
      {
        'title': 'Transfert',
        'icon': Icons.swap_horiz,
        'color': Colors.blue,
        'action': 'transfer',
      },
      {
        'title': 'Recharge',
        'icon': Icons.phone_android,
        'color': Colors.purple,
        'action': 'top_up',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: ThemeConstants.subheadingStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ThemeConstants.defaultPadding),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: ThemeConstants.defaultPadding,
              mainAxisSpacing: ThemeConstants.defaultPadding,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildQuickActionCard(
                title: action['title'] as String,
                icon: action['icon'] as IconData,
                color: action['color'] as Color,
                onTap: () => _onQuickActionPressed(action['action'] as String),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build individual quick action card
  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: ThemeConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build recent transactions section
  Widget _buildRecentTransactionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: ThemeConstants.subheadingStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/transactions'),
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: ThemeConstants.defaultPadding),
          _recentTransactions.isEmpty
              ? _buildEmptyTransactions()
              : _buildTransactionsList(),
        ],
      ),
    );
  }

  /// Build empty transactions widget
  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.largePadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction récente',
            style: ThemeConstants.bodyStyle.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos transactions apparaîtront ici',
            style: ThemeConstants.captionStyle.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build transactions list
  Widget _buildTransactionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentTransactions.length > 5 ? 5 : _recentTransactions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final transaction = _recentTransactions[index];
          return _buildTransactionItem(transaction);
        },
      ),
    );
  }

  /// Build individual transaction item
  Widget _buildTransactionItem(TransactionResponse transaction) {
    return ListTile(
      contentPadding: const EdgeInsets.all(ThemeConstants.defaultPadding),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getTransactionColor(transaction).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getTransactionIcon(transaction),
          color: _getTransactionColor(transaction),
          size: 20,
        ),
      ),
      title: Text(
        _getTransactionTitle(transaction),
        style: ThemeConstants.bodyStyle.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _formatTransactionDate(transaction.timestamp),
        style: ThemeConstants.captionStyle.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _getFormattedAmount(transaction),
            style: ThemeConstants.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: _getTransactionColor(transaction),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getStatusText(transaction),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(transaction),
              ),
            ),
          ),
        ],
      ),
      onTap: () => _showTransactionDetails(transaction),
    );
  }

  /// Get transaction icon
  IconData _getTransactionIcon(TransactionResponse transaction) {
    switch (transaction.typeOperation?.toUpperCase()) {
      case 'DEPOSIT':
        return Icons.add_circle_outline;
      case 'WITHDRAWAL':
        return Icons.remove_circle_outline;
      case 'TRANSFER':
        return Icons.swap_horiz;
      default:
        return Icons.receipt;
    }
  }

  /// Get transaction color
  Color _getTransactionColor(TransactionResponse transaction) {
    switch (transaction.typeOperation?.toUpperCase()) {
      case 'DEPOSIT':
        return Colors.green;
      case 'WITHDRAWAL':
        return Colors.orange;
      case 'TRANSFER':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Get transaction title
  String _getTransactionTitle(TransactionResponse transaction) {
    switch (transaction.typeOperation?.toUpperCase()) {
      case 'DEPOSIT':
        return 'Dépôt';
      case 'WITHDRAWAL':
        return 'Retrait';
      case 'TRANSFER':
        return transaction.numeroCompteSource == _userProfile?.idClient ? 'Transfert envoyé' : 'Transfert reçu';
      default:
        return transaction.typeOperation ?? 'Transaction';
    }
  }

  /// Get formatted amount with sign
  String _getFormattedAmount(TransactionResponse transaction) {
    final amount = transaction.montant ?? 0.0;
    final sign = transaction.typeOperation?.toUpperCase() == 'DEPOSIT' ? '+' : '-';
    return '$sign${amount.toStringAsFixed(0)} FCFA';
  }

  /// Get status color
  Color _getStatusColor(TransactionResponse transaction) {
    switch (transaction.status.toUpperCase()) {
      case 'SUCCESS':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get status text
  String _getStatusText(TransactionResponse transaction) {
    switch (transaction.status.toUpperCase()) {
      case 'SUCCESS':
        return 'Réussi';
      case 'PENDING':
        return 'En cours';
      case 'FAILED':
      case 'REJECTED':
        return 'Échec';
      default:
        return transaction.status;
    }
  }

  /// Format transaction date
  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Show transaction details
  void _showTransactionDetails(TransactionResponse transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailsSheet(transaction),
    );
  }

  /// Build transaction details sheet
  Widget _buildTransactionDetailsSheet(TransactionResponse transaction) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.largePadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ThemeConstants.largeBorderRadius),
          topRight: Radius.circular(ThemeConstants.largeBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: ThemeConstants.largePadding),
          
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTransactionColor(transaction).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTransactionIcon(transaction),
                  color: _getTransactionColor(transaction),
                  size: 24,
                ),
              ),
              const SizedBox(width: ThemeConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTransactionTitle(transaction),
                      style: ThemeConstants.subheadingStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getFormattedAmount(transaction),
                      style: ThemeConstants.headingStyle.copyWith(
                        color: _getTransactionColor(transaction),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: ThemeConstants.largePadding),
          
          // Details
          _buildDetailRow('ID Transaction', transaction.transactionId ?? 'N/A'),
          _buildDetailRow('Date', _formatTransactionDate(transaction.timestamp)),
          _buildDetailRow('Statut', _getStatusText(transaction)),
          if (transaction.description != null)
            _buildDetailRow('Description', transaction.description!),
          if (transaction.referenceNumber != null)
            _buildDetailRow('Référence', transaction.referenceNumber!),
          
          const SizedBox(height: ThemeConstants.largePadding),
          
          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                ),
              ),
              child: const Text(
                'Fermer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: ThemeConstants.captionStyle.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: ThemeConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}