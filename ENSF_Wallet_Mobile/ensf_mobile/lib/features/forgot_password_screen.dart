import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ensf_mobile/core/constants/app_constants.dart';
import 'package:ensf_mobile/core/constants/theme_constants.dart';
import 'package:ensf_mobile/core/services/user_service.dart';
import 'package:ensf_mobile/core/models/api_models.dart';

/// 🔐 Forgot Password Screen
/// Handles password reset requests with proper API integration
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Form controllers and keys
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cniController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  
  // Services
  late UserService _userService;
  
  // State management
  String? _errorMessage;
  bool _isLoading = false;
  bool _resetLinkSent = false;

  @override
  void initState() {
    super.initState();
    _userService = Provider.of<UserService>(context, listen: false);
  }

  @override
  void dispose() {
    _cniController.dispose();
    _emailController.dispose();
    _numeroController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  /// Handle password reset request with proper API integration
  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call backend API for password reset
      await _userService.requestPasswordReset(
        cni: _cniController.text.trim(),
        email: _emailController.text.trim(),
        numero: _numeroController.text.trim(),
        nom: _nomController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _resetLinkSent = true;
      });
    } on ApiError catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur inattendue s\'est produite';
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeConstants.primaryColor,
        title: const Text(
          'Mot de passe oublié',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(ThemeConstants.largePadding),
              child: Card(
                elevation: ThemeConstants.defaultElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.largeBorderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(ThemeConstants.largePadding),
                  child: !_resetLinkSent ? _buildResetForm() : _buildSuccessMessage(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build password reset form
  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Icon(
            Icons.lock_reset,
            size: 64,
            color: ThemeConstants.primaryColor,
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),
          
          Text(
            'Réinitialiser le mot de passe',
            style: ThemeConstants.headingStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.smallPadding),
          
          Text(
            'Veuillez fournir vos informations pour vérifier votre identité',
            style: ThemeConstants.bodyStyle.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.largePadding),

          // Error message display
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(ThemeConstants.smallPadding),
              margin: const EdgeInsets.only(bottom: ThemeConstants.mediumPadding),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
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

          // CNI Field
          TextFormField(
            controller: _cniController,
            decoration: const InputDecoration(
              labelText: 'Numéro CNI*',
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le numéro CNI est requis';
              }
              if (value.length < 9) {
                return 'CNI invalide (minimum 9 chiffres)';
              }
              return null;
            },
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Adresse email*',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'L\'email est requis';
              }
              if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
                return 'Format email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),

          // Phone Number Field
          TextFormField(
            controller: _numeroController,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone*',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le numéro de téléphone est requis';
              }
              if (!RegExp(AppConstants.phonePattern).hasMatch(value)) {
                return 'Format: 6XXXXXXXX ou 7XXXXXXXX';
              }
              return null;
            },
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),

          // Name Field
          TextFormField(
            controller: _nomController,
            decoration: const InputDecoration(
              labelText: 'Nom de famille*',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nom est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: ThemeConstants.largePadding),

          // Submit Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handlePasswordReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Envoyer la demande',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          
          const SizedBox(height: ThemeConstants.mediumPadding),
          
          // Back to Login
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Retour à la connexion',
              style: TextStyle(
                color: ThemeConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build success message
  Widget _buildSuccessMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 80,
        ),
        const SizedBox(height: ThemeConstants.mediumPadding),
        
        Text(
          'Demande envoyée!',
          style: ThemeConstants.headingStyle.copyWith(
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ThemeConstants.smallPadding),
        
        Text(
          'Votre demande de réinitialisation de mot de passe a été envoyée. '
          'Vous recevrez des instructions par email si votre compte existe.',
          style: ThemeConstants.bodyStyle.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ThemeConstants.largePadding),
        
        // Information box
        Container(
          padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Que faire ensuite?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '1. Vérifiez votre email (et le dossier spam)\n'
                '2. Cliquez sur le lien de réinitialisation\n'
                '3. Créez un nouveau mot de passe sécurisé',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ThemeConstants.largePadding),
        
        // Back to Login Button
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConstants.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Retour à la connexion',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: ThemeConstants.mediumPadding),
        
        // Resend Button
        TextButton(
          onPressed: () {
            setState(() {
              _resetLinkSent = false;
              _errorMessage = null;
            });
          },
          child: Text(
            'Envoyer une nouvelle demande',
            style: TextStyle(
              color: ThemeConstants.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}