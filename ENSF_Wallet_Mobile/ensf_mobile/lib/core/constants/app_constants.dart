// lib/core/constants/app_constants.dart

/// 📱 Application Constants
/// Centralized constants for the ENSF Mobile Banking Application
class AppConstants {
  // App Information
  static const String appName = 'ENSF Mobile Banking';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Company Information
  static const String companyName = 'ENSF Bank';
  static const String companyWebsite = 'https://ensfbank.cm';
  static const String supportEmail = 'support@ensfbank.cm';
  static const String supportPhone = '+237 699 123 456';
  
  // API Information
  static const String apiVersion = 'v1';
  static const String userAgent = '$appName/$appVersion';
  
  // Transaction Limits (in FCFA)
  static const double minDepositAmount = 100.0;
  static const double maxDepositAmount = 10000000.0; // 10M FCFA
  static const double minWithdrawalAmount = 100.0;
  static const double maxWithdrawalAmount = 5000000.0; // 5M FCFA
  static const double minTransferAmount = 100.0;
  static const double maxTransferAmount = 10000000.0; // 10M FCFA
  
  // Security Settings
  static const int maxLoginAttempts = 3;
  static const int pinLength = 4;
  static const int sessionTimeoutMinutes = 30;
  static const int tokenRefreshThresholdMinutes = 5;
  
  // UI Constants
  static const int animationDurationMs = 300;
  static const double maxScreenWidth = 600.0;
  static const int splashScreenDurationMs = 2000;
  
  // Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enablePinAuth = true;
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;
  static const bool enableOfflineMode = false;
  
  // Error Messages
  static const String genericErrorMessage = 'Une erreur inattendue s\'est produite';
  static const String networkErrorMessage = 'Problème de connexion réseau';
  static const String serverErrorMessage = 'Erreur du serveur';
  static const String authErrorMessage = 'Erreur d\'authentification';
  
  // Success Messages
  static const String loginSuccessMessage = 'Connexion réussie';
  static const String registrationSuccessMessage = 'Inscription réussie';
  static const String transactionSuccessMessage = 'Transaction effectuée avec succès';
  static const String profileUpdateSuccessMessage = 'Profil mis à jour';
  
  // Storage Keys
  static const String storagePrefix = 'ensf_mobile_';
  
  // Validation Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[6-7][0-9]{8}$'; // Cameroon phone format
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ss';
  
  // Currency
  static const String currencySymbol = 'FCFA';
  static const String currencyCode = 'XAF';
  
  // Languages
  static const List<String> supportedLanguages = ['fr', 'en'];
  static const String defaultLanguage = 'fr';
  
  // Agencies (could be loaded from API)
  static const List<Map<String, String>> agencies = [
    {'id': 'AGENCE001', 'name': 'Yaoundé Centre'},
    {'id': 'AGENCE002', 'name': 'Douala Akwa'},
    {'id': 'AGENCE003', 'name': 'Bafoussam Centre'},
    {'id': 'AGENCE004', 'name': 'Bamenda Commercial'},
    {'id': 'AGENCE005', 'name': 'Garoua Principal'},
  ];
  
  // Transaction Types
  static const List<String> transactionTypes = [
    'DEPOT',
    'RETRAIT',
    'TRANSFERT',
    'ACHAT_CREDIT',
    'PAIEMENT_FACTURE'
  ];
  
  // Account Status
  static const List<String> accountStatuses = [
    'PENDING',
    'ACTIVE',
    'BLOCKED',
    'REJECTED',
    'SUSPENDED'
  ];
  
  // Notification Types
  static const String notificationTypeTransaction = 'TRANSACTION';
  static const String notificationTypeAccount = 'ACCOUNT';
  static const String notificationTypeSecurity = 'SECURITY';
  static const String notificationTypePromotion = 'PROMOTION';
  
  // File Upload Limits
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentFormats = ['pdf', 'doc', 'docx'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Duration
  static const int cacheDurationHours = 24;
  static const int profileCacheDurationHours = 6;
  static const int balanceCacheDurationMinutes = 5;
  
  // URLs (for production)
  static const String termsOfServiceUrl = 'https://ensfbank.cm/terms';
  static const String privacyPolicyUrl = 'https://ensfbank.cm/privacy';
  static const String helpCenterUrl = 'https://ensfbank.cm/help';
  static const String contactUsUrl = 'https://ensfbank.cm/contact';
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/ensfbank';
  static const String twitterUrl = 'https://twitter.com/ensfbank';
  static const String linkedinUrl = 'https://linkedin.com/company/ensfbank';
  static const String youtubeUrl = 'https://youtube.com/c/ensfbank';
  
  // Development Settings
  static const bool isDevelopment = bool.fromEnvironment('dart.vm.product') == false;
  static const bool enableDebugLogging = isDevelopment;
  static const bool enableNetworkLogging = isDevelopment;
  
  // Biometric Settings
  static const String biometricLocalizedFallbackTitle = 'Utiliser le mot de passe';
  static const String biometricSignInTitle = 'Authentification biométrique';
  static const String biometricSignInSubtitle = 'Utilisez votre empreinte digitale pour vous connecter';
  
  // PIN Settings
  static const String pinSignInTitle = 'Saisir votre PIN';
  static const String pinSignInSubtitle = 'Entrez votre code PIN à 4 chiffres';
  
  // Accessibility
  static const String semanticLoginButton = 'Bouton de connexion';
  static const String semanticPasswordField = 'Champ mot de passe';
  static const String semanticEmailField = 'Champ email';
  static const String semanticBalanceCard = 'Carte de solde du compte';
  
  // Performance
  static const int imageLoadTimeout = 10; // seconds
  static const int httpTimeout = 30; // seconds
  static const int retryAttempts = 3;
  static const int retryDelay = 1000; // milliseconds
}