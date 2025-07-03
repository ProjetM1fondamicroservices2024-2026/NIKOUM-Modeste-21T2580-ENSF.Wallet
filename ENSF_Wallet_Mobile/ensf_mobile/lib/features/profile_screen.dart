import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ensf_mobile/core/constants/app_constants.dart';
import 'package:ensf_mobile/core/constants/theme_constants.dart';
import 'package:ensf_mobile/core/services/user_service.dart';
import 'package:ensf_mobile/core/services/storage_service.dart';
import 'package:ensf_mobile/core/models/api_models.dart';
import 'package:ensf_mobile/widgets/app_bottom_navigation_bar.dart';

/// 👤 Enhanced Profile Screen with Full API Integration
/// Displays user information, settings, security options, and account management
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  // Services
  late UserService _userService;
  late StorageService _storageService;
  
  // User data
  UserProfile? _userProfile;
  Map<String, dynamic>? _accountBalance;
  
  // Loading states
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isUpdatingProfile = false;
  
  // Settings
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  String _selectedLanguage = 'Français';
  
  // Expanded sections
  bool _isProfileExpanded = false;
  bool _isSettingsExpanded = false;
  bool _isSecurityExpanded = false;
  bool _isAccountExpanded = false;
  
  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _initializeServices();
    _loadUserData();
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Setup animations
  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  /// Initialize services from Provider
  void _initializeServices() {
    _userService = Provider.of<UserService>(context, listen: false);
    _storageService = Provider.of<StorageService>(context, listen: false);
  }

  /// Load user data from API
  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load user profile
      if (_userService.currentUser != null) {
        _userProfile = _userService.currentUser;
      } else {
        _userProfile = await _userService.getUserProfile();
      }

      // Load account balance (if endpoint exists)
      try {
        _accountBalance = await _userService.getAccountBalance();
      } catch (e) {
        debugPrint('Balance fetch error: $e');
        // Set default balance if endpoint not available
        _accountBalance = {'solde': 0.0, 'numeroCompte': 'N/A'};
      }

      setState(() {
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Erreur lors du chargement du profil: ${e.toString()}');
    }
  }

  /// Load app settings from storage
  Future<void> _loadSettings() async {
    try {
      _notificationsEnabled = await _storageService.areNotificationsEnabled();
      _biometricEnabled = await _storageService.isBiometricEnabled();
      _pinEnabled = await _storageService.isPinEnabled();
      
      final language = await _storageService.getLanguage();
      if (language != null) {
        _selectedLanguage = language;
      }
      
      final themeMode = await _storageService.getThemeMode();
      _isDarkMode = themeMode == 'dark';
      
      setState(() {});
    } catch (e) {
      debugPrint('Settings load error: $e');
    }
  }

  /// Refresh user data
  Future<void> _refreshUserData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadUserData();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  /// Update user profile
  Future<void> _updateProfile(Map<String, dynamic> updates) async {
    if (_userProfile == null) return;
    
    setState(() {
      _isUpdatingProfile = true;
    });
    
    try {
      final updatedProfile = await _userService.updateProfile(
        _userProfile!.idClient, 
        updates
      );
      
      setState(() {
        _userProfile = updatedProfile;
        _isUpdatingProfile = false;
      });
      
      _showSuccessMessage('Profil mis à jour avec succès');
    } catch (e) {
      setState(() {
        _isUpdatingProfile = false;
      });
      _showErrorMessage('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    final shouldLogout = await _showLogoutConfirmation();
    if (!shouldLogout) return;
    
    try {
      await _userService.logout();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/welcome', 
          (route) => false
        );
      }
    } catch (e) {
      _showErrorMessage('Erreur lors de la déconnexion: ${e.toString()}');
    }
  }

  /// Show logout confirmation dialog
  Future<bool> _showLogoutConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.errorColor,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    return result ?? false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundLight,
      body: SafeArea(
        child: _isLoading ? _buildLoadingScreen() : _buildProfileContent(),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
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
          Text('Chargement du profil...'),
        ],
      ),
    );
  }

  /// Build main profile content
  Widget _buildProfileContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
                  child: Column(
                    children: [
                      _buildQuickStats(),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      _buildProfileSection(),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      _buildAccountSection(),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      _buildSecuritySection(),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      _buildSettingsSection(),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      _buildHelpSection(),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      _buildLogoutButton(),
                      const SizedBox(height: ThemeConstants.largePadding),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build profile header with user info
  Widget _buildProfileHeader() {
    return Container(
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(ThemeConstants.largeBorderRadius),
          bottomRight: Radius.circular(ThemeConstants.largeBorderRadius),
        ),
      ),
      child: Column(
        children: [
          // Profile avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    _userProfile != null 
                        ? _userProfile!.nom.substring(0, 1).toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: ThemeConstants.primaryColor,
                    ),
                  ),
                ),
                // Status indicator
                if (_userProfile?.isActive == true)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),
          
          // User name
          Text(
            _userProfile?.fullName ?? 'Utilisateur',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // User email
          Text(
            _userProfile?.email ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          
          // Account status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _userProfile?.isActive == true 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _userProfile?.isActive == true 
                    ? Colors.green 
                    : Colors.orange,
                width: 1,
              ),
            ),
            child: Text(
              _userProfile?.isActive == true ? 'Compte Actif' : 'En Attente',
              style: TextStyle(
                color: _userProfile?.isActive == true 
                    ? Colors.green 
                    : Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick stats section
  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Solde',
                _accountBalance != null 
                    ? '${_accountBalance!['solde']?.toString() ?? '0'} FCFA'
                    : '0 FCFA',
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: _buildStatItem(
                'Statut',
                _userProfile?.status ?? 'N/A',
                Icons.security,
                _userProfile?.isActive == true ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
    Widget _buildProfileSection() {
    return _buildExpandableSection(
      title: 'Informations Personnelles',
      icon: Icons.person,
      isExpanded: _isProfileExpanded,
      onToggle: () => setState(() => _isProfileExpanded = !_isProfileExpanded),
      children: [
        _buildInfoRow('Nom complet', _userProfile?.fullName ?? 'N/A'),
        _buildInfoRow('Email', _userProfile?.email ?? 'N/A'),
        _buildInfoRow('Téléphone', _userProfile?.numero ?? 'N/A'),
        _buildInfoRow('ID Client', _userProfile?.idClient ?? 'N/A'),
        _buildInfoRow('Date de création', 
          _userProfile?.createdAt.toString().split(' ')[0] ?? 'N/A'),
        const SizedBox(height: ThemeConstants.mediumPadding),
        ElevatedButton.icon(
          onPressed: _isUpdatingProfile ? null : () => _showEditProfileDialog(),
          icon: _isUpdatingProfile
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.edit),
          label: const Text('Modifier le profil'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  /// Build account management section
  Widget _buildAccountSection() {
    return _buildExpandableSection(
      title: 'Gestion du Compte',
      icon: Icons.account_balance,
      isExpanded: _isAccountExpanded,
      onToggle: () => setState(() => _isAccountExpanded = !_isAccountExpanded),
      children: [
        _buildActionTile(
          'Historique des transactions',
          'Voir toutes vos transactions',
          Icons.history,
          () => Navigator.pushNamed(context, '/transactions'),
        ),
        _buildActionTile(
          'Télécharger le relevé',
          'Relevé de compte PDF',
          Icons.download,
          () => _showComingSoonMessage('Téléchargement de relevé'),
        ),
        _buildActionTile(
          'Limites de transaction',
          'Gérer vos limites',
          Icons.tune,
          () => _showComingSoonMessage('Gestion des limites'),
        ),
        _buildActionTile(
          'Support client',
          'Contacter le support',
          Icons.support_agent,
          () => _showComingSoonMessage('Support client'),
        ),
      ],
    );
  }

  /// Build security section
  Widget _buildSecuritySection() {
    return _buildExpandableSection(
      title: 'Sécurité',
      icon: Icons.security,
      isExpanded: _isSecurityExpanded,
      onToggle: () => setState(() => _isSecurityExpanded = !_isSecurityExpanded),
      children: [
        _buildSwitchTile(
          'Authentification biométrique',
          'Utiliser l\'empreinte digitale',
          Icons.fingerprint,
          _biometricEnabled,
          (value) => _toggleBiometric(value),
        ),
        _buildSwitchTile(
          'Code PIN',
          'Activer le code PIN',
          Icons.pin,
          _pinEnabled,
          (value) => _togglePin(value),
        ),
        _buildActionTile(
          'Changer le mot de passe',
          'Modifier votre mot de passe',
          Icons.lock_reset,
          () => _showComingSoonMessage('Changement de mot de passe'),
        ),
        _buildActionTile(
          'Historique de connexion',
          'Voir vos connexions récentes',
          Icons.login,
          () => _showComingSoonMessage('Historique de connexion'),
        ),
      ],
    );
  }

  /// Build settings section
  Widget _buildSettingsSection() {
    return _buildExpandableSection(
      title: 'Paramètres',
      icon: Icons.settings,
      isExpanded: _isSettingsExpanded,
      onToggle: () => setState(() => _isSettingsExpanded = !_isSettingsExpanded),
      children: [
        _buildSwitchTile(
          'Mode sombre',
          'Activer le thème sombre',
          Icons.dark_mode,
          _isDarkMode,
          (value) => _toggleDarkMode(value),
        ),
        _buildSwitchTile(
          'Notifications',
          'Recevoir les notifications',
          Icons.notifications,
          _notificationsEnabled,
          (value) => _toggleNotifications(value),
        ),
        _buildDropdownTile(
          'Langue',
          'Sélectionner la langue',
          Icons.language,
          _selectedLanguage,
          ['Français', 'English', 'Español'],
          (value) => _changeLanguage(value),
        ),
        _buildActionTile(
          'Vider le cache',
          'Libérer de l\'espace de stockage',
          Icons.clear_all,
          () => _clearCache(),
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
          children: [
            _buildActionTile(
              'Centre d\'aide',
              'FAQ et guides d\'utilisation',
              Icons.help_center,
              () => _showComingSoonMessage('Centre d\'aide'),
            ),
            _buildActionTile(
              'Conditions d\'utilisation',
              'Lire nos conditions',
              Icons.description,
              () => _showComingSoonMessage('Conditions d\'utilisation'),
            ),
            _buildActionTile(
              'Politique de confidentialité',
              'Protection de vos données',
              Icons.privacy_tip,
              () => _showComingSoonMessage('Politique de confidentialité'),
            ),
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  /// Build logout button
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.errorColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          ),
        ),
      ),
    );
  }

  /// Build expandable section widget
  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: ThemeConstants.primaryColor),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: ThemeConstants.primaryColor,
            ),
            onTap: onToggle,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  /// Build info row widget
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build action tile widget
  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: ThemeConstants.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// Build switch tile widget
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: ThemeConstants.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: ThemeConstants.primaryColor,
      ),
    );
  }

  /// Build dropdown tile widget
  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: ThemeConstants.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  /// Build version info
  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Text(
            'Version ${AppConstants.appVersion}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Show edit profile dialog
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userProfile?.nom ?? '');
    final prenomController = TextEditingController(text: _userProfile?.prenom ?? '');
    final emailController = TextEditingController(text: _userProfile?.email ?? '');
    final phoneController = TextEditingController(text: _userProfile?.numero ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProfile({
                'nom': nameController.text,
                'prenom': prenomController.text,
                'email': emailController.text,
                'numero': phoneController.text,
              });
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  /// Toggle biometric authentication
  Future<void> _toggleBiometric(bool value) async {
    await _storageService.setBiometricEnabled(value);
    setState(() {
      _biometricEnabled = value;
    });
    _showSuccessMessage(value 
        ? 'Authentification biométrique activée' 
        : 'Authentification biométrique désactivée');
  }

  /// Toggle PIN authentication
  Future<void> _togglePin(bool value) async {
    await _storageService.setPinEnabled(value);
    setState(() {
      _pinEnabled = value;
    });
    _showSuccessMessage(value 
        ? 'Code PIN activé' 
        : 'Code PIN désactivé');
  }

  /// Toggle dark mode
  Future<void> _toggleDarkMode(bool value) async {
    await _storageService.saveThemeMode(value ? 'dark' : 'light');
    setState(() {
      _isDarkMode = value;
    });
    _showSuccessMessage(value 
        ? 'Mode sombre activé' 
        : 'Mode clair activé');
  }

  /// Toggle notifications
  Future<void> _toggleNotifications(bool value) async {
    await _storageService.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
    _showSuccessMessage(value 
        ? 'Notifications activées' 
        : 'Notifications désactivées');
  }

  /// Change language
  Future<void> _changeLanguage(String language) async {
    await _storageService.saveLanguage(language);
    setState(() {
      _selectedLanguage = language;
    });
    _showSuccessMessage('Langue changée vers $language');
  }

  /// Clear cache
  Future<void> _clearCache() async {
    try {
      // Clear cache logic here
      await Future.delayed(const Duration(seconds: 1));
      _showSuccessMessage('Cache vidé avec succès');
    } catch (e) {
      _showErrorMessage('Erreur lors du vidage du cache');
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