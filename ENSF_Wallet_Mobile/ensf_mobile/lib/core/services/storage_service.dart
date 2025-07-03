import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';

/// 💾 Storage Service
/// Handles local storage of user data, tokens, and app preferences
/// Uses SharedPreferences for persistent storage
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Storage Keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyUserInfo = 'user_info';
  static const String _keyAppSettings = 'app_settings';
  static const String _keyLastLoginEmail = 'last_login_email';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPinEnabled = 'pin_enabled';
  static const String _keyPinCode = 'pin_code';
  static const String _keyLanguage = 'language';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  /// Initialize SharedPreferences
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      developer.log('✅ Storage service initialized', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Storage initialization error: $e', name: 'StorageService');
      rethrow;
    }
  }

  /// Get SharedPreferences instance
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // ========================================
  // 🔐 AUTHENTICATION STORAGE
  // ========================================

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    try {
      await _preferences.setString(_keyAuthToken, token);
      developer.log('💾 Auth token saved', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving auth token: $e', name: 'StorageService');
      rethrow;
    }
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    try {
      final token = _preferences.getString(_keyAuthToken);
      if (token != null) {
        developer.log('📖 Auth token retrieved', name: 'StorageService');
      }
      return token;
    } catch (e) {
      developer.log('❌ Error getting auth token: $e', name: 'StorageService');
      return null;
    }
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _preferences.setString(_keyRefreshToken, refreshToken);
      developer.log('💾 Refresh token saved', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving refresh token: $e', name: 'StorageService');
      rethrow;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = _preferences.getString(_keyRefreshToken);
      if (token != null) {
        developer.log('📖 Refresh token retrieved', name: 'StorageService');
      }
      return token;
    } catch (e) {
      developer.log('❌ Error getting refresh token: $e', name: 'StorageService');
      return null;
    }
  }

  /// Clear authentication tokens
  Future<void> clearAuthTokens() async {
    try {
      await _preferences.remove(_keyAuthToken);
      await _preferences.remove(_keyRefreshToken);
      developer.log('🗑️ Auth tokens cleared', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error clearing auth tokens: $e', name: 'StorageService');
      rethrow;
    }
  }

  // ========================================
  // 👤 USER DATA STORAGE
  // ========================================

  /// Save user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final profileJson = json.encode({
        'idClient': profile.idClient,
        'nom': profile.nom,
        'prenom': profile.prenom,
        'email': profile.email,
        'numero': profile.numero,
        'status': profile.status,
        'createdAt': profile.createdAt?.toIso8601String(),
        'lastLogin': profile.lastLogin?.toIso8601String(),
      });
      
      await _preferences.setString(_keyUserProfile, profileJson);
      developer.log('💾 User profile saved', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving user profile: $e', name: 'StorageService');
      rethrow;
    }
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      final profileJson = _preferences.getString(_keyUserProfile);
      if (profileJson != null) {
        final profileData = json.decode(profileJson) as Map<String, dynamic>;
        final profile = UserProfile.fromJson(profileData);
        developer.log('📖 User profile retrieved', name: 'StorageService');
        return profile;
      }
      return null;
    } catch (e) {
      developer.log('❌ Error getting user profile: $e', name: 'StorageService');
      return null;
    }
  }

  /// Save basic user info (from login)
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final userInfoJson = json.encode(userInfo);
      await _preferences.setString(_keyUserInfo, userInfoJson);
      developer.log('💾 User info saved', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving user info: $e', name: 'StorageService');
      rethrow;
    }
  }

  /// Get basic user info
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final userInfoJson = _preferences.getString(_keyUserInfo);
      if (userInfoJson != null) {
        final userInfo = json.decode(userInfoJson) as Map<String, dynamic>;
        developer.log('📖 User info retrieved', name: 'StorageService');
        return userInfo;
      }
      return null;
    } catch (e) {
      developer.log('❌ Error getting user info: $e', name: 'StorageService');
      return null;
    }
  }

  /// Clear user data
  Future<void> clearUserData() async {
    try {
      await _preferences.remove(_keyUserProfile);
      await _preferences.remove(_keyUserInfo);
      developer.log('🗑️ User data cleared', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error clearing user data: $e', name: 'StorageService');
      rethrow;
    }
  }

  // ========================================
  // 🔒 SECURITY SETTINGS
  // ========================================

  /// Save last login email for convenience
  Future<void> saveLastLoginEmail(String email) async {
    try {
      await _preferences.setString(_keyLastLoginEmail, email);
      developer.log('💾 Last login email saved', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving last login email: $e', name: 'StorageService');
    }
  }

  /// Get last login email
  Future<String?> getLastLoginEmail() async {
    try {
      return _preferences.getString(_keyLastLoginEmail);
    } catch (e) {
      developer.log('❌ Error getting last login email: $e', name: 'StorageService');
      return null;
    }
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _preferences.setBool(_keyBiometricEnabled, enabled);
      developer.log('💾 Biometric setting saved: $enabled', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving biometric setting: $e', name: 'StorageService');
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      return _preferences.getBool(_keyBiometricEnabled) ?? false;
    } catch (e) {
      developer.log('❌ Error getting biometric setting: $e', name: 'StorageService');
      return false;
    }
  }

  /// Enable/disable PIN authentication
  Future<void> setPinEnabled(bool enabled) async {
    try {
      await _preferences.setBool(_keyPinEnabled, enabled);
      developer.log('💾 PIN setting saved: $enabled', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving PIN setting: $e', name: 'StorageService');
    }
  }

  /// Check if PIN authentication is enabled
  Future<bool> isPinEnabled() async {
    try {
      return _preferences.getBool(_keyPinEnabled) ?? false;
    } catch (e) {
      developer.log('❌ Error getting PIN setting: $e', name: 'StorageService');
      return false;
    }
  }

  /// Save PIN code (should be hashed in production)
  Future<void> savePinCode(String pinCode) async {
    try {
      // Note: In production, hash the PIN before storing
      await _preferences.setString(_keyPinCode, pinCode);
      developer.log('💾 PIN code saved', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving PIN code: $e', name: 'StorageService');
    }
  }

  /// Get PIN code
  Future<String?> getPinCode() async {
    try {
      return _preferences.getString(_keyPinCode);
    } catch (e) {
      developer.log('❌ Error getting PIN code: $e', name: 'StorageService');
      return null;
    }
  }

  // ========================================
  // ⚙️ APP SETTINGS
  // ========================================

  /// Save app language
  Future<void> saveLanguage(String languageCode) async {
    try {
      await _preferences.setString(_keyLanguage, languageCode);
      developer.log('💾 Language saved: $languageCode', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving language: $e', name: 'StorageService');
    }
  }

  /// Get app language
  Future<String?> getLanguage() async {
    try {
      return _preferences.getString(_keyLanguage);
    } catch (e) {
      developer.log('❌ Error getting language: $e', name: 'StorageService');
      return null;
    }
  }

  /// Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    try {
      await _preferences.setString(_keyThemeMode, themeMode);
      developer.log('💾 Theme mode saved: $themeMode', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving theme mode: $e', name: 'StorageService');
    }
  }

  /// Get theme mode
  Future<String?> getThemeMode() async {
    try {
      return _preferences.getString(_keyThemeMode);
    } catch (e) {
      developer.log('❌ Error getting theme mode: $e', name: 'StorageService');
      return null;
    }
  }

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _preferences.setBool(_keyNotificationsEnabled, enabled);
      developer.log('💾 Notifications setting saved: $enabled', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving notifications setting: $e', name: 'StorageService');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      return _preferences.getBool(_keyNotificationsEnabled) ?? true;
    } catch (e) {
      developer.log('❌ Error getting notifications setting: $e', name: 'StorageService');
      return true; // Default to enabled
    }
  }

  /// Save custom app settings
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final settingsJson = json.encode(settings);
      await _preferences.setString(_keyAppSettings, settingsJson);
      developer.log('💾 App settings saved', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error saving app settings: $e', name: 'StorageService');
    }
  }

  /// Get custom app settings
  Future<Map<String, dynamic>?> getAppSettings() async {
    try {
      final settingsJson = _preferences.getString(_keyAppSettings);
      if (settingsJson != null) {
        return json.decode(settingsJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('❌ Error getting app settings: $e', name: 'StorageService');
      return null;
    }
  }

  // ========================================
  // 🧹 CLEANUP METHODS
  // ========================================

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _preferences.clear();
      developer.log('🗑️ All data cleared', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error clearing all data: $e', name: 'StorageService');
      rethrow;
    }
  }

  /// Clear only authentication data
  Future<void> clearAuthData() async {
    try {
      await clearAuthTokens();
      await clearUserData();
      developer.log('🗑️ Auth data cleared', name: 'StorageService');
    } catch (e) {
      developer.log('❌ Error clearing auth data: $e', name: 'StorageService');
      rethrow;
    }
  }

  /// Check if user data exists
  Future<bool> hasUserData() async {
    try {
      final token = await getAuthToken();
      final profile = await getUserProfile();
      return token != null && profile != null;
    } catch (e) {
      developer.log('❌ Error checking user data: $e', name: 'StorageService');
      return false;
    }
  }

  /// Get storage size information
  Future<Map<String, int>> getStorageInfo() async {
    try {
      final keys = _preferences.getKeys();
      int totalSize = 0;
      Map<String, int> keysSizes = {};

      for (final key in keys) {
        final value = _preferences.get(key);
        final size = value.toString().length;
        keysSizes[key] = size;
        totalSize += size;
      }

      keysSizes['total'] = totalSize;
      return keysSizes;
    } catch (e) {
      developer.log('❌ Error getting storage info: $e', name: 'StorageService');
      return {'total': 0};
    }
  }
}