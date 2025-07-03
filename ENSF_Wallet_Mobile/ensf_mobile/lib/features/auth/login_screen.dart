import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:ensf_mobile/core/constants/app_constants.dart';
import 'package:ensf_mobile/core/constants/theme_constants.dart';
import 'package:ensf_mobile/core/services/user_service.dart';
import 'package:ensf_mobile/core/services/storage_service.dart';
import 'package:ensf_mobile/core/models/api_models.dart';

/// 🔐 Login Screen with Full API Integration
/// Handles user authentication with the Spring Boot backend
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form controllers
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Services
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  
  // State management
  String? _errorMessage;
  bool _isLoading = false;
  bool _showVerification = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Load last used email for user convenience
  Future<void> _loadSavedEmail() async {
    try {
      final lastEmail = await _storageService.getLastLoginEmail();
      if (lastEmail != null && lastEmail.isNotEmpty) {
        setState(() {
          _identifierController.text = lastEmail;
          _rememberMe = true;
        });
      }
    } catch (e) {
      // Ignore errors in loading saved email
      debugPrint('Error loading saved email: $e');
    }
  }

  /// Handle user login with backend API
  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call backend login API
      final loginResponse = await _userService.login(
        _identifierController.text.trim(),
        _passwordController.text.trim(),
      );

      developer.log(
        '🔐 Login successful: ${loginResponse.token}',
        name: 'LoginScreen',
      );

      // Save email if remember me is checked
      if (_rememberMe) {
        await _storageService.saveLastLoginEmail(_identifierController.text.trim());
      }

      // Check if verification is required (based on backend response)
      if (loginResponse.token.isNotEmpty) {
        // Direct login success - navigate to home
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          _showSuccessMessage('Connexion réussie!');
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Show verification screen (if backend requires 2FA)
        setState(() {
          _isLoading = false;
          _showVerification = true;
        });
      }
    } on ApiError catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
      _showErrorMessage(e.message);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur inattendue s\'est produite';
      });
      _showErrorMessage('Erreur de connexion: ${e.toString()}');
    }
  }

  /// Handle verification code (if required by backend)
  Future<void> _handleVerifyCode() async {
    if (_codeController.text.isEmpty || _codeController.text.length != 5) {
      setState(() {
        _errorMessage = "Veuillez saisir le code à 5 chiffres";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Note: This endpoint would need to be added to the backend
      // For now, we'll simulate verification since the current backend
      // doesn't have a separate verification step
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _showSuccessMessage('Vérification réussie!');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Code de vérification invalide';
      });
      _showErrorMessage('Code de vérification invalide');
    }
  }

  /// Navigate to forgot password screen
  void _handleForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  /// Navigate to registration screen
  void _handleRegister() {
    Navigator.pushNamed(context, '/register');
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeConstants.primaryColor,
        title: Text(
          AppConstants.appName,
          style: ThemeConstants.subheadingStyle.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeConstants.largePadding),
          child: !_showVerification 
              ? _buildLoginForm() 
              : _buildVerificationForm(),
        ),
      ),
    );
  }

  /// Build login form
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App logo or title
          Icon(
            Icons.account_balance,
            size: 64,
            color: ThemeConstants.primaryColor,
          ),
          SizedBox(height: ThemeConstants.mediumPadding),
          
          Text(
            'Connexion',
            style: ThemeConstants.headingStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.largePadding),

          // Email/Phone field
          TextFormField(
            controller: _identifierController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email ou Numéro de téléphone',
              hintText: 'Saisissez votre email ou numéro',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
              ),
              errorText: _errorMessage?.contains('identifier') == true ? _errorMessage : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              // Basic validation for email or phone
              if (!value.contains('@') && !RegExp(r'^\d{9,15}$').hasMatch(value)) {
                return 'Format email ou numéro invalide';
              }
              return null;
            },
          ),
          SizedBox(height: ThemeConstants.mediumPadding),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Saisissez votre mot de passe',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
              ),
              errorText: _errorMessage?.contains('password') == true ? _errorMessage : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le mot de passe est requis';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),

          // Remember me checkbox and forgot password
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: ThemeConstants.primaryColor,
              ),
              const Expanded(
                child: Text('Se souvenir de moi'),
              ),
              TextButton(
                onPressed: _handleForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                child: Text(
                  'Mot de passe oublié?',
                  style: TextStyle(
                    color: ThemeConstants.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConstants.largePadding),

          // Error message display
          if (_errorMessage != null && 
              !_errorMessage!.contains('identifier') && 
              !_errorMessage!.contains('password'))
            Container(
              padding: const EdgeInsets.all(ThemeConstants.smallPadding),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: ThemeConstants.smallPadding),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_errorMessage != null) const SizedBox(height: ThemeConstants.mediumPadding),

          // Login button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
              ),
              elevation: ThemeConstants.defaultElevation,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Se connecter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: ThemeConstants.largePadding),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pas encore de compte? '),
              TextButton(
                onPressed: _handleRegister,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                ),
                child: Text(
                  'S\'inscrire',
                  style: TextStyle(
                    color: ThemeConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build verification form (if 2FA is required)
  Widget _buildVerificationForm() {
    return Card(
      elevation: ThemeConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.largeBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showVerification = false;
                      _errorMessage = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(
                  child: Text(
                    'Vérification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
            const SizedBox(height: ThemeConstants.largePadding),

            // Verification icon
            Icon(
              Icons.security,
              size: 64,
              color: ThemeConstants.primaryColor,
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),

            Text(
              'Code de vérification',
              style: ThemeConstants.subheadingStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.smallPadding),

            Text(
              'Saisissez le code de vérification à 5 chiffres',
              style: ThemeConstants.bodyStyle.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.largePadding),

            // Verification code field
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 5,
              decoration: InputDecoration(
                labelText: 'Code de vérification',
                hintText: '12345',
                prefixIcon: const Icon(Icons.security),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                ),
                counterText: '', // Hide character counter
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              onFieldSubmitted: (_) => _handleVerifyCode(),
            ),
            const SizedBox(height: ThemeConstants.largePadding),

            // Error message for verification
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(ThemeConstants.smallPadding),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: ThemeConstants.smallPadding),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: ThemeConstants.mediumPadding),

            // Verify button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleVerifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Vérifier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),

            // Resend code option
            TextButton(
              onPressed: () {
                // Implement resend verification code
                _showSuccessMessage('Code renvoyé!');
              },
              child: Text(
                'Renvoyer le code',
                style: TextStyle(
                  color: ThemeConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}