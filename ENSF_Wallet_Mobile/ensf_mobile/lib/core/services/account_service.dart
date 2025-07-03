// lib/core/services/account_service.dart

import 'dart:developer' as developer;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/api_models.dart';
import 'http_service.dart';
import 'user_service.dart';

/// 🏦 Account Service
/// Handles all account and financial operations including:
/// - Balance management
/// - Transactions (deposit, withdrawal, transfer)
/// - Transaction history
/// - Account status verification
class AccountService {
  static final AccountService _instance = AccountService._internal();
  factory AccountService() => _instance;
  AccountService._internal();

  final HttpService _httpService = HttpService();
  final UserService _userService = UserService();

  // ========================================
  // 💰 BALANCE OPERATIONS
  // ========================================

  /// Get user account balance
  /// Returns the current balance for the authenticated user
  Future<double> getBalance(String userId) async {
    try {
      developer.log('💰 Fetching balance for user: $userId', name: 'AccountService');
      final endpoint = Endpoints.balance;

      final response = await _httpService.get<Map<String, dynamic>>(
        '$endpoint/$userId',
        requiresAuth: true,
      );

      
      developer.log('📥 Balance response: ${response.data}', name: 'AccountService');

      if (response.isSuccess && response.data != null) {
        final balance = response.data!['solde'] as num? ?? 0.0;
        developer.log('✅ Balance fetched: $balance FCFA', name: 'AccountService');
        return balance.toDouble();
      } else {
        developer.log('❌ Failed to fetch balance: ${response.errorMessage}', name: 'AccountService');
        throw response.error ?? ApiError(
          error: 'BALANCE_FETCH_FAILED',
          message: 'Failed to fetch balance',
          timestamp: DateTime.now(),
          path: Endpoints.balance,
        );
      }
    } catch (e) {
      developer.log('❌ Balance error: $e', name: 'AccountService');
      rethrow;
    }
  }

  /// Refresh balance from server
  Future<double> refreshBalance() async {
    final currentUser = _userService.currentUser;
    if (currentUser == null) {
      throw ApiError(
        error: 'NOT_AUTHENTICATED',
        message: 'User not authenticated',
        timestamp: DateTime.now(),
        path: Endpoints.balance,
      );
    }
    return await getBalance(currentUser.idClient);
  }

  // ========================================
  // 📊 TRANSACTION OPERATIONS
  // ========================================

  /// Get user transaction history
  /// Returns list of transactions with pagination support
  Future<List<TransactionResponse>> getTransactions({
    String? userId,
    int page = 0,
    int size = 20,
    String? type, // DEPOSIT, WITHDRAWAL, TRANSFER
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      developer.log('📊 Fetching transactions', name: 'AccountService');

      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (userId != null) queryParams['clientId'] = userId;
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _httpService.get<Map<String, dynamic>>(
        Endpoints.transactions,
        queryParams: queryParams,
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final transactionsData = response.data!['content'] as List<dynamic>? ?? [];
        final transactions = transactionsData
            .map((item) => TransactionResponse.fromJson(item as Map<String, dynamic>))
            .toList();

        developer.log('✅ Fetched ${transactions.length} transactions', name: 'AccountService');
        return transactions;
      } else {
        developer.log('❌ Failed to fetch transactions: ${response.errorMessage}', name: 'AccountService');
        throw response.error ?? ApiError(
          error: 'TRANSACTIONS_FETCH_FAILED',
          message: 'Failed to fetch transactions',
          timestamp: DateTime.now(),
          path: Endpoints.transactions,
        );
      }
    } catch (e) {
      developer.log('❌ Transactions error: $e', name: 'AccountService');
      rethrow;
    }
  }

  /// Get recent transactions (last 10)
  Future<List<TransactionResponse>> getRecentTransactions() async {
    return await getTransactions(page: 0, size: 10);
  }

  // ========================================
  // 💸 FINANCIAL OPERATIONS
  // ========================================

  /// Perform deposit operation
  /// Adds money to user's account
  /// Perform deposit operation with money-service integration
  /// Integrates with PaymentRequest/PaymentResponse structure
  Future<PaymentResponse> deposit({
    required String CardId,
    required String payer,
    required double montant,
    required String description,
  }) async {
    try {
      developer.log('💸 Processing deposit: $montant FCFA from $payer', name: 'AccountService');

      // Validate deposit amount
      if (montant < 100) {
        throw ApiError(
          error: 'INVALID_AMOUNT',
          message: 'Le montant minimum pour un dépôt est de 100 FCFA',
          timestamp: DateTime.now(),
          path: Endpoints.deposit,
        );
      }

      if (montant > 10000000) {
        throw ApiError(
          error: 'INVALID_AMOUNT',
          message: 'Le montant maximum pour un dépôt est de 10,000,000 FCFA',
          timestamp: DateTime.now(),
          path: Endpoints.deposit,
        );
      }

      // Get current user for client ID
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        throw ApiError(
          error: 'NOT_AUTHENTICATED',
          message: 'Utilisateur non authentifié',
          timestamp: DateTime.now(),
          path: Endpoints.deposit,
        );
      }

      // Prepare PaymentRequest structure matching money-service entity
      final requestBody = {
        'numeroOrangeMoney': payer,                    // Phone number of the payer
        'montant': montant,                 // Amount to deposit
        'description': description,        // User-provided description
      };

      // Add client ID header for money-service
      final response = await _httpService.post2<Map<String, dynamic>>(
        "http://172.20.10.13:8096/api/v1/cartes/recharge-orange-money/$CardId", // Using the money-service deposit endpoint
        body: requestBody,
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final paymentResponse = PaymentResponse.fromJson(response.data!);
        developer.log('✅ Deposit initiated: ${paymentResponse.reference}', name: 'AccountService');
        return paymentResponse;
      } else {
        developer.log('❌ Deposit failed: ${response.errorMessage}', name: 'AccountService');
        throw response.error ?? ApiError(
          error: 'DEPOSIT_FAILED',
          message: 'Échec du traitement du dépôt',
          timestamp: DateTime.now(),
          path: Endpoints.deposit,
        );
      }
    } catch (e) {
      developer.log('❌ Deposit error: $e', name: 'AccountService');
      rethrow;
    }
  }

  /// Perform withdrawal operation
  /// Removes money from user's account
  Future<PaymentResponse> withdrawal({
    required String receiver,
    required double montant,
    required String description,
  }) async {
    try {
      developer.log('💸 Processing withdrawal: $montant FCFA to $receiver', name: 'AccountService');

      // Validate withdrawal amount
      if (montant < 500) {
        throw ApiError(
          error: 'INVALID_AMOUNT',
          message: 'Le montant minimum pour un retrait est de 500 FCFA',
          timestamp: DateTime.now(),
          path: Endpoints.withdrawal,
        );
      }

      if (montant > 5000000) {
        throw ApiError(
          error: 'INVALID_AMOUNT',
          message: 'Le montant maximum pour un retrait est de 5,000,000 FCFA',
          timestamp: DateTime.now(),
          path: Endpoints.withdrawal,
        );
      }

      // Get current user for client ID
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        throw ApiError(
          error: 'NOT_AUTHENTICATED',
          message: 'Utilisateur non authentifié',
          timestamp: DateTime.now(),
          path: Endpoints.withdrawal,
        );
      }

      // Prepare RetraitRequest structure matching money-service entity
      final requestBody = {
        'receiver': receiver,              // Phone number of the receiver
        'amount': montant,                 // Amount to withdraw
        'callback': '',                    // Empty string as specified
        'externalId': '',                  // Empty string as specified
        'description': description,        // User-provided description
      };

      // Add client ID header for money-service (using withdrawals endpoint)
      final response = await _httpService.post2<Map<String, dynamic>>(
        'http://localhost:8080/api/withdrawals',               // Using the money-service withdrawals endpoint
        body: requestBody,
        requiresAuth: true
      );

      if (response.isSuccess && response.data != null) {
        final paymentResponse = PaymentResponse.fromJson(response.data!);
        developer.log('✅ Withdrawal initiated: ${paymentResponse.reference}', name: 'AccountService');
        return paymentResponse;
      } else {
        developer.log('❌ Withdrawal failed: ${response.errorMessage}', name: 'AccountService');
        throw response.error ?? ApiError(
          error: 'WITHDRAWAL_FAILED',
          message: 'Échec du traitement du retrait',
          timestamp: DateTime.now(),
          path: '/api/withdrawals',
        );
      }
    } catch (e) {
      developer.log('❌ Withdrawal error: $e', name: 'AccountService');
      rethrow;
    }
  }

  /// Perform transfer operation
  /// Transfers money between accounts
  Future<TransactionResponse> transfer({
    required double montant,
    required int numeroCompteSend,
    required int numeroCompteReceive,
  }) async {
    try {
      developer.log('🔄 Processing transfer: $montant FCFA', name: 'AccountService');

      // Validate transfer amount
      if (montant < 100) {
        throw ApiError(
          error: 'INVALID_AMOUNT',
          message: 'Le montant minimum pour un transfert est de 100 FCFA',
          timestamp: DateTime.now(),
          path: Endpoints.transfer,
        );
      }

      // Validate accounts are different
      if (numeroCompteSend == numeroCompteReceive) {
        throw ApiError(
          error: 'INVALID_ACCOUNTS',
          message: 'Les comptes expéditeur et destinataire doivent être différents',
          timestamp: DateTime.now(),
          path: Endpoints.transfer,
        );
      }

      final requestBody = {
        'montant': montant,
        'numeroCompteSend': numeroCompteSend,
        'numeroCompteReceive': numeroCompteReceive,
      };

      final response = await _httpService.post<Map<String, dynamic>>(
        Endpoints.transfer,
        body: requestBody,
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final result = TransactionResponse.fromJson(response.data!);
        developer.log('✅ Transfer successful: ${result.transactionId}', name: 'AccountService');
        return result;
      } else {
        developer.log('❌ Transfer failed: ${response.errorMessage}', name: 'AccountService');
        throw response.error ?? ApiError(
          error: 'TRANSFER_FAILED',
          message: 'Failed to process transfer',
          timestamp: DateTime.now(),
          path: Endpoints.transfer,
        );
      }
    } catch (e) {
      developer.log('❌ Transfer error: $e', name: 'AccountService');
      rethrow;
    }
  }

  // ========================================
  // 🔍 ACCOUNT STATUS VERIFICATION
  // ========================================

  /// Check if user account is approved for operations
  /// Returns true if account status is ACTIVE
  Future<AccountStatusResult> checkAccountStatus() async {
    try {
      developer.log('🔍 Checking account status', name: 'AccountService');

      final userProfile = await _userService.getUserProfile();
      
      if (userProfile == null) {
        throw ApiError(
          error: 'USER_NOT_FOUND',
          message: 'User profile not found',
          timestamp: DateTime.now(),
          path: '/profile',
        );
      }

      final status = userProfile.status?.toUpperCase() ?? 'UNKNOWN';
      
      switch (status) {
        case 'ACTIVE':
          return AccountStatusResult(
            isApproved: true,
            status: status,
            message: 'Votre compte est actif et vous pouvez effectuer des opérations.',
            canPerformOperations: true,
          );
        
        case 'PENDING':
          return AccountStatusResult(
            isApproved: false,
            status: status,
            message: 'Votre compte est en cours de vérification. Veuillez patienter pendant que nos équipes examinent vos documents.',
            canPerformOperations: false,
          );
        
        case 'REJECTED':
          return AccountStatusResult(
            isApproved: false,
            status: status,
            message: 'Votre compte a été rejeté. Veuillez mettre à jour vos documents et soumettre une nouvelle demande.',
            canPerformOperations: false,
          );
        
        case 'BLOCKED':
          return AccountStatusResult(
            isApproved: false,
            status: status,
            message: 'Votre compte est temporairement bloqué. Contactez le service client pour plus d\'informations.',
            canPerformOperations: false,
          );
        
        default:
          return AccountStatusResult(
            isApproved: false,
            status: status,
            message: 'Statut de compte inconnu. Contactez le service client.',
            canPerformOperations: false,
          );
      }
    } catch (e) {
      developer.log('❌ Account status check error: $e', name: 'AccountService');
      rethrow;
    }
  }

  /// Validate user can perform financial operations
  /// Throws exception if account is not approved
  Future<void> validateAccountForOperations() async {
    final statusResult = await checkAccountStatus();
    
    if (!statusResult.canPerformOperations) {
      throw ApiError(
        error: 'ACCOUNT_NOT_APPROVED',
        message: statusResult.message,
        timestamp: DateTime.now(),
        path: '/account-validation',
      );
    }
  }
/// Create a new card for the current user
Future<CardCreationResult> createCard({
  required String nomPorteur,
  required int codePin,
  required String carteType,
  double? limiteDailyPurchase,
  double? limiteDailyWithdrawal,
  double? limiteMonthly,
  bool contactless = true,
  bool internationalPayments = false,
  bool onlinePayments = true,
}) async {
  try {
    developer.log('💳 Creating card for: $nomPorteur', name: 'AccountService');

    // Get current user
    final currentUser = _userService.currentUser;
    if (currentUser == null) {
      throw ApiError(
        error: 'NOT_AUTHENTICATED',
        message: 'Utilisateur non authentifié',
        timestamp: DateTime.now(),
        path: '/api/v1/cartes/create',
      );
    }

    // Get account information to retrieve idAgence and numeroCompte
    final accountInfo = await _getClientPrimaryAccount(currentUser.idClient);
    
    // Validate PIN
    if (codePin < 1000 || codePin > 9999) {
      throw ApiError(
        error: 'INVALID_PIN',
        message: 'Le code PIN doit être composé de 4 chiffres',
        timestamp: DateTime.now(),
        path: '/api/v1/cartes/create',
      );
    }

    // Prepare CarteCreationRequest structure matching bank-card-service
    final requestBody = {
      'idClient': currentUser.idClient,
      'idAgence': accountInfo['idAgence'],
      'numeroCompte': accountInfo['numeroCompte'].toString(),
      'type': carteType.toUpperCase(), // VIRTUELLE or PHYSIQUE
      'nomPorteur': nomPorteur,
      'codePin': codePin,
      'limiteDailyPurchase': limiteDailyPurchase,
      'limiteDailyWithdrawal': limiteDailyWithdrawal,
      'limiteMonthly': limiteMonthly,
      'contactless': contactless,
      'internationalPayments': internationalPayments,
      'onlinePayments': onlinePayments,
    };

    // Call bank-card-service
    final response = await _httpService.post<Map<String, dynamic>>(
      '/api/v1/cartes/create',
      body: requestBody,
      requiresAuth: true,
    );

    if (response.isSuccess && response.data != null) {
      final cardResult = CardCreationResult.fromJson(response.data!);
      developer.log('✅ Card created: ${cardResult.idCarte}', name: 'AccountService');
      return cardResult;
    } else {
      developer.log('❌ Card creation failed: ${response.errorMessage}', name: 'AccountService');
      throw response.error ?? ApiError(
        error: 'CARD_CREATION_FAILED',
        message: 'Échec de la création de la carte',
        timestamp: DateTime.now(),
        path: '/api/v1/cartes/create',
      );
    }
  } catch (e) {
    developer.log('❌ Card creation error: $e', name: 'AccountService');
    rethrow;
  }
}

Future<List<BankCard>> getClientCards() async {
  try {
    developer.log('📋 Fetching client cards', name: 'AccountService');

    final currentUser = _userService.currentUser;
    if (currentUser == null) {
      throw ApiError(
        error: 'NOT_AUTHENTICATED',
        message: 'Utilisateur non authentifié',
        timestamp: DateTime.now(),
        path: '/api/v1/cartes/my-cards',
      );
    }

    final response = await _httpService.get<Map<String, dynamic>>(
      '/api/v1/cartes/my-cards',
      requiresAuth: true,
    );

    developer.log("response: ${response.data}", name: 'AccountService');

    if (response.isSuccess && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;
      
      // Handle different possible response structures
      List<dynamic> cardsData;
              
        if (responseData.containsKey('message')) {
          // Handle the case where response is wrapped in 'message' key
          final messageData = responseData['message'];
          
          if (messageData is List) {
            cardsData = messageData;
          } else if (messageData is String) {
            // Parse the JSON string to get the actual list
            try {
              final parsedMessage = jsonDecode(messageData) as List<dynamic>;
              cardsData = parsedMessage;
              developer.log('✅ Successfully parsed JSON string message to List', name: 'AccountService');
            } catch (parseError) {
              developer.log('⚠️ Failed to parse message JSON string: $parseError', name: 'AccountService');
              return [];
            }
          } else {
            // Try to cast it as List<dynamic> in case of other type issues
            try {
              cardsData = List<dynamic>.from(messageData);
              developer.log('✅ Successfully cast message data to List', name: 'AccountService');
            } catch (castError) {
              developer.log('⚠️ Message is not a list and cannot be cast: $messageData', name: 'AccountService');
              developer.log('⚠️ Message data type: ${messageData.runtimeType}', name: 'AccountService');
              return [];
            }
          }
        } else {
        // If the response itself is the cards array wrapped in an object
        developer.log('⚠️ Unexpected response structure: $responseData', name: 'AccountService');
        throw ApiError(
          error: 'INVALID_RESPONSE_FORMAT',
          message: 'Format de réponse invalide',
          timestamp: DateTime.now(),
          path: '/api/v1/cartes/my-cards',
        );
      }

      // Handle empty cards list
      if (cardsData.isEmpty) {
        developer.log('ℹ️ No cards found for user', name: 'AccountService');
        return [];
      }

      final cards = cardsData
          .map((item) => BankCard.fromJson(item as Map<String, dynamic>))
          .toList();

      developer.log('✅ Fetched ${cards.length} cards', name: 'AccountService');
      return cards;
    } else {
      developer.log('❌ Failed to fetch cards: ${response.errorMessage}', name: 'AccountService');
      throw response.error ?? ApiError(
        error: 'CARDS_FETCH_FAILED',
        message: 'Échec de la récupération des cartes',
        timestamp: DateTime.now(),
        path: '/api/v1/cartes/my-cards',
      );
    }
  } catch (e) {
    developer.log('❌ Cards fetch error: $e', name: 'AccountService');
    rethrow;
  }
}

  /// Helper method to get client's primary account information
  Future<Map<String, dynamic>> _getClientPrimaryAccount(String idClient) async {
    try {
      // Call AgenceService to get account information
      final response = await _httpService.get<Map<String, dynamic>>(
        '/api/v1/comptes/client/$idClient/primary',
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final accountData = response.data!;
        return {
          'idAgence': accountData['idAgence'],
          'numeroCompte': accountData['numeroCompte'],
          'solde': accountData['solde'],
          'status': accountData['status'],
        };
      } else {
        throw ApiError(
          error: 'ACCOUNT_NOT_FOUND',
          message: 'Aucun compte actif trouvé pour ce client',
          timestamp: DateTime.now(),
          path: '/api/v1/comptes/client/$idClient/primary',
        );
      }
    } catch (e) {
      developer.log('❌ Account fetch error: $e', name: 'AccountService');
      rethrow;
    }
  }
}