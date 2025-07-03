class ApiConfig {
  // Base URLs for different services
  static const String _userServiceUrl = 'http://172.20.10.13:8091/api/v1/users'; // Add UserService URL
  static const String _agenceServiceUrl = 'http://172.20.10.13:8092'; // Add AgenceService URL
  static const String _cardServiceUrl = 'http://172.20.10.13:8096';   // Add CardService URL
  static const String _moneyServiceUrl = 'http://172.20.10.13:8095';  // Add MoneyService URL

  // Environment configuration
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  /// Get service base URL
  static String getServiceUrl(String service) {
    switch (service.toLowerCase()) {
      case 'user':
      case 'users':
        return _userServiceUrl;
      case 'agence':
      case 'comptes':
        return _agenceServiceUrl;
      case 'cards':
      case 'cartes':
        return _cardServiceUrl;
      case 'money':
      case 'payments':
        return _moneyServiceUrl;
      default:
        return _userServiceUrl; // Default to user service
    }
  }
  
  /// API version prefix6863b4dcfbf87f0724d64bc7
  static const String apiVersion = '/api/v1';
  
  /// Complete base URL for user service (backward compatibility)
  static String get baseUrl => _userServiceUrl;
  static String get userServiceBaseUrl => '$_userServiceUrl$apiVersion/users';
}

// API Endpoints
class Endpoints {
  // ========================================
  // 🔐 AUTHENTICATION ENDPOINTS
  // ========================================
  static const String login = '/login';
  static const String register = '/register';
  static const String registrationStatus = '/registration-status';
  static const String passwordResetRequest = '/password-reset/request';
  static const String refreshToken = '/refresh-token';
  
  // ========================================
  // 👤 PROFILE MANAGEMENT ENDPOINTS
  // ========================================
  static const String profile = '/profile';
  static String updateProfile(String clientId) => '/profile/$clientId';
  
  // ========================================
  // 💰 FINANCIAL OPERATION ENDPOINTS
  // ========================================
  static const String deposit = '/deposit';
  static const String withdrawal = '/withdrawal';
  static const String transfer = '/transfer';
  
  // ========================================
  // 📊 ACCOUNT INFORMATION ENDPOINTS
  // ========================================
  static const String transactions = '/transactions';
  static const String statistics = '/statistics';
  
  // ========================================
  // 🔍 ADMIN/SEARCH ENDPOINTS
  // ========================================
  static const String search = '/search';
  static String unlockUser(String clientId) => '/$clientId/unlock';
  
  // ========================================
  // 📱 MOBILE SPECIFIC ENDPOINTS
  // ========================================
  static const String accountStatus = '/account-status';
  static const String transactionLimits = '/transaction-limits';
  static const String quickBalance = '/quick-balance';

  // ========================================
  // 💳 CARD OPERATION ENDPOINTS
  // ========================================
  static const String createCard = '/api/v1/cartes/create';
  static const String myCards = '/api/v1/cartes/my-cards';
  static const String cardDetails = '/api/v1/cartes'; // + /{idCarte}
  static const String cardSettings = '/api/v1/cartes'; // + /{idCarte}/settings
  static const String blockCard = '/api/v1/cartes'; // + /{idCarte}/block
  static const String unblockCard = '/api/v1/cartes'; // + /{idCarte}/unblock
  
  // ========================================
  // 🏦 ACCOUNT INFORMATION ENDPOINTS (AgenceService)
  // ========================================
  static const String balance = '/api/v1/agence/comptes/solde';
  static const String clientAccounts = '/api/v1/comptes/client'; // + /{idClient}
  static const String primaryAccount = '/api/v1/comptes/client'; // + /{idClient}/primary
  static const String accountByNumber = '/api/v1/comptes/numero'; // + /{numeroCompte}
  static const String accountAvailability = '/api/v1/comptes/numero'; // + /{numeroCompte}/availability
}

// HTTP Settings
class HttpSettings {
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);
  
  /// Default headers for all requests
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'ENSF-Mobile/1.0.0',
  };
  
  /// Headers with authentication
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
  
  /// Headers for file upload
  static Map<String, String> get fileUploadHeaders => {
    'Accept': 'application/json',
    // Content-Type will be set automatically for multipart
  };
}

// ========================================
// 💰 TRANSACTION LIMITS
// ========================================
class TransactionLimits {
  // Deposit limits
  static const double minDepositAmount = 100.0;
  static const double maxDepositAmount = 10000000.0;
  
  // Withdrawal limits
  static const double minWithdrawalAmount = 100.0;
  static const double maxWithdrawalAmount = 5000000.0;
  
  // Transfer limits
  static const double minTransferAmount = 100.0;
  static const double maxTransferAmount = 10000000.0;
  
  // Daily limits (if needed)
  static const double dailyWithdrawalLimit = 1000000.0;
  static const double dailyTransferLimit = 5000000.0;
}

// ========================================
// 📱 APP CONSTANTS
// ========================================
class AppConstants {
  static const String appName = 'ENSF Mobile';
  static const String appVersion = '1.0.0';
  static const String currency = 'FCFA';
  static const String defaultLocale = 'fr_CM';
  
  // Account status values
  static const String statusActive = 'ACTIVE';
  static const String statusPending = 'PENDING';
  static const String statusRejected = 'REJECTED';
  static const String statusBlocked = 'BLOCKED';
  
  // Transaction types
  static const String transactionDeposit = 'DEPOSIT';
  static const String transactionWithdrawal = 'WITHDRAWAL';
  static const String transactionTransfer = 'TRANSFER';
  
  // Transaction status
  static const String transactionSuccess = 'SUCCESS';
  static const String transactionPending = 'PENDING';
  static const String transactionFailed = 'FAILED';
}

// ========================================
// 🚨 ERROR MESSAGES
// ========================================
class ErrorMessages {
  // Network errors
  static const String networkError = 'Erreur de réseau. Vérifiez votre connexion.';
  static const String serverError = 'Erreur serveur. Veuillez réessayer plus tard.';
  static const String timeoutError = 'Délai d\'attente dépassé. Veuillez réessayer.';
  static const String unknownError = 'Une erreur inattendue s\'est produite.';
  
  // Authentication errors
  static const String unauthorizedError = 'Session expirée. Veuillez vous reconnecter.';
  static const String invalidCredentials = 'Identifiants invalides.';
  static const String accountNotFound = 'Compte utilisateur introuvable.';
  
  // Validation errors
  static const String validationError = 'Données invalides. Vérifiez vos informations.';
  static const String invalidAmount = 'Montant invalide.';
  static const String insufficientFunds = 'Solde insuffisant.';
  
  // Account status errors
  static const String accountNotApproved = 'Votre compte n\'est pas encore approuvé.';
  static const String accountBlocked = 'Votre compte est temporairement bloqué.';
  static const String accountRejected = 'Votre compte a été rejeté.';
  
  // Transaction errors
  static const String transactionFailed = 'Transaction échouée.';
  static const String invalidTransactionAmount = 'Montant de transaction invalide.';
  static const String dailyLimitExceeded = 'Limite quotidienne dépassée.';
}

// ========================================
// ✅ SUCCESS MESSAGES
// ========================================
class SuccessMessages {
  // Authentication
  static const String loginSuccess = 'Connexion réussie';
  static const String registrationSuccess = 'Inscription envoyée avec succès';
  static const String passwordResetSuccess = 'Demande de réinitialisation envoyée';
  
  // Profile
  static const String profileUpdateSuccess = 'Profil mis à jour avec succès';
  
  // Transactions
  static const String depositSuccess = 'Dépôt effectué avec succès';
  static const String withdrawalSuccess = 'Retrait effectué avec succès';
  static const String transferSuccess = 'Transfert effectué avec succès';
  static const String balanceRefreshed = 'Solde actualisé';
}

// ========================================
// 🎨 UI CONSTANTS
// ========================================
class UIConstants {
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Loading delays
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration refreshDelay = Duration(milliseconds: 500);
  
  // List pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Balance refresh intervals
  static const Duration balanceRefreshInterval = Duration(minutes: 5);
  static const Duration transactionRefreshInterval = Duration(minutes: 2);
}