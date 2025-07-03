// lib/core/services/user_service.dart

import 'dart:developer' as developer;
import 'dart:io';
import '../config/api_config.dart';
import '../models/api_models.dart';
import 'http_service.dart';
import 'storage_service.dart';

/// 👤 User Service
/// Handles all user-related API operations including authentication,
/// registration, profile management, and financial operations
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final HttpService _httpService = HttpService();
  final StorageService _storageService = StorageService();

  UserProfile? _currentUser;
  String? _currentToken;

  /// Get current authenticated user
  UserProfile? get currentUser => _currentUser;

  /// Get current authentication token
  String? get currentToken => _currentToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null && _currentToken != null;

  // ========================================
  // 🔐 AUTHENTICATION METHODS
  // ========================================

  /// User login
  /// Returns [LoginResponse] on success, throws [ApiError] on failure
  Future<LoginResponse> login(String identifier, String password) async {
    try {
      developer.log('🔐 Attempting login for: $identifier', name: 'UserService');

      final request = LoginRequest(
        identifier: identifier,
        password: password,
      );

      final response = await _httpService.post<Map<String, dynamic>>(
        Endpoints.login,
        body: request.toJson(),
        requiresAuth: false,
      );

      developer.log('🔐 Login response: ${response.data}', name: 'UserService') ;
      if (response.isSuccess && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data!);
        
        // Store authentication data
        await _storeAuthData(loginResponse);
        
        // Load user profile
        await _loadUserProfile();
        
        developer.log('✅ Login successful for: ${loginResponse.email}', name: 'UserService');
        return loginResponse;
      } else {
        developer.log('❌ Login failed: ${response.errorMessage}', name: 'UserService');
        throw response.error ?? ApiError(
          error: 'LOGIN_FAILED',
          message: 'Login failed',
          timestamp: DateTime.now(),
          path: Endpoints.login,
        );
      }
    } catch (e) {
      developer.log('❌ Login error: $e', name: 'UserService');
      rethrow;
    }
  }

  /// User registration
  /// Returns [RegistrationResponse] on success
  Future<RegistrationResponse> register(RegistrationRequest request) async {
    try {
      developer.log('📝 Attempting registration for: ${request.email}', name: 'UserService');

      final response = await _httpService.post<Map<String, dynamic>>(
        Endpoints.register,
        body: request.toJson(),
        requiresAuth: false,
      );

      if (response.isSuccess && response.data != null) {
        final registrationResponse = RegistrationResponse.fromJson(response.data!);
        developer.log('✅ Registration successful: ${registrationResponse.status}', name: 'UserService');
        return registrationResponse;
      } else {
        developer.log('❌ Registration failed: ${response.errorMessage}', name: 'UserService');
        throw response.error ?? ApiError(
          error: 'REGISTRATION_FAILED',
          message: 'Registration failed',
          timestamp: DateTime.now(),
          path: Endpoints.register,
        );
      }
    } catch (e) {
      developer.log('❌ Registration error: $e', name: 'UserService');
      rethrow;
    }
  }

  Future<RegistrationResponse> registerWithFiles(
    RegistrationRequest request,
    File rectoCniImage,
    File versoCniImage,
    File selfieImage,
  ) async {
    try {
      developer.log('📝 Attempting registration with files for: ${request.email}', name: 'UserService');

      final response = await _httpService.postMultipart<Map<String, dynamic>>(
        Endpoints.register,
        fields: request.toJson(),
        files: [
          {'fieldName': 'images', 'file': rectoCniImage},
          {'fieldName': 'images', 'file': versoCniImage},
          {'fieldName': 'images', 'file': selfieImage},
        ],
        requiresAuth: false,
      );

      if (response.isSuccess && response.data != null) {
        final registrationResponse = RegistrationResponse.fromJson(response.data!);
        developer.log('✅ Registration with files successful: ${registrationResponse.status}', name: 'UserService');
        return registrationResponse;
      } else {
        developer.log('❌ Registration with files failed: ${response.errorMessage}', name: 'UserService');
        throw response.error ?? ApiError(
          error: 'REGISTRATION_FAILED',
          message: 'Registration failed',
          timestamp: DateTime.now(),
          path: Endpoints.register,
        );
      }
    } catch (e) {
      developer.log('❌ Registration with files error: $e', name: 'UserService');
      rethrow;
    }
  }
  /// Check registration status
  Future<Map<String, dynamic>> checkRegistrationStatus(String email) async {
    try {
      final response = await _httpService.get<Map<String, dynamic>>(
        Endpoints.registrationStatus,
        queryParams: {'email': email},
        requiresAuth: false,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw response.error ?? ApiError(
          error: 'STATUS_CHECK_FAILED',
          message: 'Failed to check registration status',
          timestamp: DateTime.now(),
          path: Endpoints.registrationStatus,
        );
      }
    } catch (e) {
      developer.log('❌ Status check error: $e', name: 'UserService');
      rethrow;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset({
    required String cni,
    required String email,
    required String numero,
    required String nom,
  }) async {
    try {
      final response = await _httpService.post<Map<String, dynamic>>(
        Endpoints.passwordResetRequest,
        body: {
          'cni': cni,
          'email': email,
          'numero': numero,
          'nom': nom,
        },
        requiresAuth: false,
      );

      if (!response.isSuccess) {
        throw response.error ?? ApiError(
          error: 'PASSWORD_RESET_FAILED',
          message: 'Password reset request failed',
          timestamp: DateTime.now(),
          path: Endpoints.passwordResetRequest,
        );
      }
    } catch (e) {
      developer.log('❌ Password reset error: $e', name: 'UserService');
      rethrow;
    }
  }

  // ========================================
  // 👤 PROFILE MANAGEMENT
  // ========================================

  /// Get user profile
  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _httpService.get<Map<String, dynamic>>(
        Endpoints.profile,
        requiresAuth: true,
      );

      developer.log(response.toString(), name: 'UserService');

      if (response.isSuccess && response.data != null) {
        final profile = UserProfile.fromJson(response.data!);
        _currentUser = profile;
        await _storageService.saveUserProfile(profile);
        return profile;
      } else {
        throw response.error ?? ApiError(
          error: 'PROFILE_FETCH_FAILED',
          message: 'Failed to fetch user profile',
          timestamp: DateTime.now(),
          path: Endpoints.profile,
        );
      }
    } catch (e) {
      developer.log('❌ Profile fetch error: $e', name: 'UserService');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserProfile> updateProfile(String clientId, Map<String, dynamic> updates) async {
    try {
      final response = await _httpService.put<Map<String, dynamic>>(
        '${Endpoints.profile}/$clientId',
        body: updates,
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final profile = UserProfile.fromJson(response.data!);
        _currentUser = profile;
        await _storageService.saveUserProfile(profile);
        return profile;
      } else {
        throw response.error ?? ApiError(
          error: 'PROFILE_UPDATE_FAILED',
          message: 'Failed to update profile',
          timestamp: DateTime.now(),
          path: Endpoints.profile,
        );
      }
    } catch (e) {
      developer.log('❌ Profile update error: $e', name: 'UserService');
      rethrow;
    }
  }

  // ========================================
  // 💰 FINANCIAL OPERATIONS
  // ========================================

  /// Make a deposit
  Future<TransactionResponse> makeDeposit({
    required double amount,
    required String numeroClient,
    required int numeroCompte,
  }) async {
    try {
      developer.log('💰 Making deposit: $amount FCFA', name: 'UserService');

      final request = DepositRequest(
        montant: amount,
        numeroClient: numeroClient,
        numeroCompte: numeroCompte,
      );

      final response = await _httpService.post<Map<String, dynamic>>(
        Endpoints.deposit,
        body: request.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final transactionResponse = TransactionResponse.fromJson(response.data!);
        developer.log('✅ Deposit successful: ${transactionResponse.transactionId}', name: 'UserService');
        return transactionResponse;
      } else {
        throw response.error ?? ApiError(
          error: 'DEPOSIT_FAILED',
          message: 'Deposit transaction failed',
          timestamp: DateTime.now(),
          path: Endpoints.deposit,
        );
      }
    } catch (e) {
      developer.log('❌ Deposit error: $e', name: 'UserService');
      rethrow;
    }
  }

  /// Make a withdrawal
  Future<TransactionResponse> makeWithdrawal({
    required double amount,
    required String numeroClient,
    required int numeroCompte,
  }) async {
    try {
      developer.log('💸 Making withdrawal: $amount FCFA', name: 'UserService');

      final request = WithdrawalRequest(
        montant: amount,
        numeroClient: numeroClient,
        numeroCompte: numeroCompte,
      );

      final response = await _httpService.post<Map<String, dynamic>>(
        Endpoints.withdrawal,
        body: request.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final transactionResponse = TransactionResponse.fromJson(response.data!);
        developer.log('✅ Withdrawal successful: ${transactionResponse.transactionId}', name: 'UserService');
        return transactionResponse;
      } else {
        throw response.error ?? ApiError(
          error: 'WITHDRAWAL_FAILED',
          message: 'Withdrawal transaction failed',
          timestamp: DateTime.now(),
          path: Endpoints.withdrawal,
        );
      }
    } catch (e) {
      developer.log('❌ Withdrawal error: $e', name: 'UserService');
      rethrow;
    }
  }

  /// Make a transfer
  Future<TransactionResponse> makeTransfer({
    required double amount,
    required int fromAccount,
    required int toAccount,
  }) async {
    try {
      developer.log('🔄 Making transfer: $amount FCFA from $fromAccount to $toAccount', name: 'UserService');

      final request = TransferRequest(
        montant: amount,
        numeroCompteSend: fromAccount,
        numeroCompteReceive: toAccount,
      );

      final response = await _httpService.post<Map<String, dynamic>>(
        Endpoints.transfer,
        body: request.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final transactionResponse = TransactionResponse.fromJson(response.data!);
        developer.log('✅ Transfer successful: ${transactionResponse.transactionId}', name: 'UserService');
        return transactionResponse;
      } else {
        throw response.error ?? ApiError(
          error: 'TRANSFER_FAILED',
          message: 'Transfer transaction failed',
          timestamp: DateTime.now(),
          path: Endpoints.transfer,
        );
      }
    } catch (e) {
      developer.log('❌ Transfer error: $e', name: 'UserService');
      rethrow;
    }
  }

  /// Get account balance
  Future<Map<String, dynamic>> getAccountBalance() async {
    try {
      final response = await _httpService.get<Map<String, dynamic>>(
        Endpoints.balance,
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw response.error ?? ApiError(
          error: 'BALANCE_FETCH_FAILED',
          message: 'Failed to fetch account balance',
          timestamp: DateTime.now(),
          path: Endpoints.balance,
        );
      }
    } catch (e) {
      developer.log('❌ Balance fetch error: $e', name: 'UserService');
      rethrow;
    }
  }

  /// Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _httpService.get<Map<String, dynamic>>(
        Endpoints.transactions,
        queryParams: {
          'page': page.toString(),
          'size': size.toString(),
        },
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final content = response.data!['content'] as List<dynamic>?;
        return content?.cast<Map<String, dynamic>>() ?? [];
      } else {
        throw response.error ?? ApiError(
          error: 'TRANSACTIONS_FETCH_FAILED',
          message: 'Failed to fetch transaction history',
          timestamp: DateTime.now(),
          path: Endpoints.transactions,
        );
      }
    } catch (e) {
      developer.log('❌ Transaction history fetch error: $e', name: 'UserService');
      rethrow;
    }
  }

  // ========================================
  // 🔧 UTILITY METHODS
  // ========================================

  /// Store authentication data locally
  Future<void> _storeAuthData(LoginResponse loginResponse) async {
    _currentToken = loginResponse.token;
    _httpService.setTokens(loginResponse.token, loginResponse.refreshToken);
    
    await _storageService.saveAuthToken(loginResponse.token);
    await _storageService.saveRefreshToken(loginResponse.refreshToken);
    
    // Store basic user info
    await _storageService.saveUserInfo({
      'userId': loginResponse.userId,
      'email': loginResponse.email,
      'nom': loginResponse.nom,
      'prenom': loginResponse.prenom,
    });
  }

  /// Load user profile after authentication
  Future<void> _loadUserProfile() async {
    try {
      _currentUser = await getUserProfile();
    } catch (e) {
      developer.log('⚠️ Failed to load user profile: $e', name: 'UserService');
      // Don't throw here, as login was successful but profile fetch failed
    }
  }

  /// Initialize service from stored data
  Future<void> initializeFromStorage() async {
    try {
      final token = await _storageService.getAuthToken();
      final refreshToken = await _storageService.getRefreshToken();
      final userProfile = await _storageService.getUserProfile();

      if (token != null && refreshToken != null) {
        _currentToken = token;
        _httpService.setTokens(token, refreshToken);
        
        if (userProfile != null) {
          _currentUser = userProfile;
        } else {
          // Try to fetch fresh profile data
          await _loadUserProfile();
        }
      }
    } catch (e) {
      developer.log('⚠️ Failed to initialize from storage: $e', name: 'UserService');
      await logout(); // Clear any corrupted data
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      developer.log('🚪 Logging out user', name: 'UserService');
      
      // Clear local state
      _currentUser = null;
      _currentToken = null;
      _httpService.clearTokens();
      
      // Clear stored data
      await _storageService.clearAll();
      
      developer.log('✅ Logout successful', name: 'UserService');
    } catch (e) {
      developer.log('❌ Logout error: $e', name: 'UserService');
      rethrow;
    }
  }

  /// Refresh authentication token
  Future<bool> refreshAuthToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      
      if (refreshToken == null) {
        developer.log('❌ No refresh token available', name: 'UserService');
        return false;
      }

      final response = await _httpService.post<Map<String, dynamic>>(
        Endpoints.refreshToken,
        body: {'refreshToken': refreshToken},
        requiresAuth: false,
      );

      if (response.isSuccess && response.data != null) {
        final newToken = response.data!['token'] as String;
        final newRefreshToken = response.data!['refreshToken'] as String;
        
        _currentToken = newToken;
        _httpService.setTokens(newToken, newRefreshToken);
        
        await _storageService.saveAuthToken(newToken);
        await _storageService.saveRefreshToken(newRefreshToken);
        
        developer.log('✅ Token refreshed successfully', name: 'UserService');
        return true;
      } else {
        developer.log('❌ Token refresh failed', name: 'UserService');
        await logout(); // Clear session if refresh fails
        return false;
      }
    } catch (e) {
      developer.log('❌ Token refresh error: $e', name: 'UserService');
      await logout(); // Clear session on error
      return false;
    }
  }

  /// Dispose service resources
  void dispose() {
    _httpService.dispose();
  }
}