// lib/features/withdraw/withdraw_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import '../../core/constants/theme_constants.dart';
import '../../core/services/account_service.dart';
import '../../core/models/api_models.dart';

/// 💸 Comprehensive Withdrawal Screen
/// Allows users to withdraw money to Orange Money/MTN Mobile Money
/// Integrates with money-service backend using RetraitRequest structure
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  // Form controllers
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Services
  final AccountService _accountService = AccountService();
  
  // State management
  bool _isLoading = false;
  String? _selectedProvider = 'ORANGE'; // Default to Orange Money
  
  // Constants
  static const double _minAmount = 500;
  static const double _maxAmount = 5000000;
  
  @override
  void dispose() {
    _receiverController.dispose();
    _montantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validate phone number based on provider
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir le numéro du destinataire';
    }
    
    // Remove spaces and formatting
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Validate Cameroon phone numbers
    if (_selectedProvider == 'ORANGE') {
      // Orange numbers: 6XXXXXXXX or 237XXXXXXXX
      if (!RegExp(r'^(237)?6[5-9]\d{7}$').hasMatch(cleanNumber)) {
        return 'Numéro Orange invalide (ex: 655123456)';
      }
    } else if (_selectedProvider == 'MTN') {
      // MTN numbers: 6XXXXXXXX or 237XXXXXXXX  
      if (!RegExp(r'^(237)?6[7-8]\d{7}$').hasMatch(cleanNumber)) {
        return 'Numéro MTN invalide (ex: 677123456)';
      }
    }
    
    return null;
  }

  /// Validate amount
  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir le montant';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Montant invalide';
    }
    
    if (amount < _minAmount) {
      return 'Montant minimum: ${_minAmount.toStringAsFixed(0)} FCFA';
    }
    
    if (amount > _maxAmount) {
      return 'Montant maximum: ${_maxAmount.toStringAsFixed(0)} FCFA';
    }
    
    return null;
  }

  /// Process withdrawal
  Future<void> _processWithdrawal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Format phone number
      String formattedReceiver = _receiverController.text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (!formattedReceiver.startsWith('237')) {
        formattedReceiver = '237$formattedReceiver';
      }

      final double amount = double.parse(_montantController.text);
      final String description = _descriptionController.text.isEmpty 
          ? 'Retrait ${_selectedProvider}' 
          : _descriptionController.text;

      // Call withdrawal service
      final PaymentResponse response = await _accountService.withdrawal(
        receiver: formattedReceiver,
        montant: amount,
        description: description,
      );

      // Handle response
      await _handleWithdrawalResponse(response);

    } catch (e) {
      developer.log('❌ Withdrawal error: $e', name: 'WithdrawScreen');
      _showErrorMessage(_getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle withdrawal response
  Future<void> _handleWithdrawalResponse(PaymentResponse response) async {
    if (response.isSuccess) {
      _showSuccessDialog(response);
    } else if (response.isPending) {
      _showPendingDialog(response);
    } else {
      _showErrorMessage(response.message);
    }
  }

  /// Show success dialog
  void _showSuccessDialog(PaymentResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: ThemeConstants.successColor),
            const SizedBox(width: 8),
            const Text('Retrait Réussi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montant: ${_montantController.text} FCFA'),
            const SizedBox(height: 8),
            Text('Destinataire: ${_receiverController.text}'),
            const SizedBox(height: 8),
            if (response.reference != null)
              Text('Référence: ${response.reference}'),
            const SizedBox(height: 8),
            Text(response.message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to home
            },
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );
  }

  /// Show pending dialog
  void _showPendingDialog(PaymentResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.hourglass_empty, color: ThemeConstants.warningColor),
            const SizedBox(width: 8),
            const Text('Retrait En Cours'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Votre demande de retrait a été initiée.'),
            const SizedBox(height: 8),
            Text('Montant: ${_montantController.text} FCFA'),
            const SizedBox(height: 8),
            Text('Destinataire: ${_receiverController.text}'),
            const SizedBox(height: 8),
            if (response.reference != null)
              Text('Référence: ${response.reference}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeConstants.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Le destinataire recevra une notification pour confirmer la réception des fonds.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to home
            },
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.errorColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is ApiError) {
      return error.message;
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundLight,
      appBar: AppBar(
        title: const Text('Retrait d\'argent'),
        backgroundColor: ThemeConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card
              _buildHeaderCard(),
              const SizedBox(height: 24),
              
              // Provider selection
              _buildProviderSelection(),
              const SizedBox(height: 24),
              
              // Receiver field
              _buildReceiverField(),
              const SizedBox(height: 20),
              
              // Amount field
              _buildAmountField(),
              const SizedBox(height: 20),
              
              // Description field
              _buildDescriptionField(),
              const SizedBox(height: 32),
              
              // Submit button
              _buildSubmitButton(),
              const SizedBox(height: 16),
              
              // Info card
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header card
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConstants.errorColor,
            ThemeConstants.errorColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Retrait Mobile Money',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Envoyez de l\'argent vers Orange Money ou MTN',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build provider selection
  Widget _buildProviderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opérateur Mobile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildProviderCard(
                provider: 'ORANGE',
                title: 'Orange Money',
                color: Colors.orange,
                icon: Icons.phone_android,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProviderCard(
                provider: 'MTN',
                title: 'MTN MoMo',
                color: Colors.yellow.shade700,
                icon: Icons.phone_android,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build provider card
  Widget _buildProviderCard({
    required String provider,
    required String title,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedProvider == provider;
    
    return InkWell(
      onTap: () => setState(() => _selectedProvider = provider),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build receiver field
  Widget _buildReceiverField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Numéro du destinataire',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _receiverController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          validator: _validatePhoneNumber,
          decoration: InputDecoration(
            hintText: _selectedProvider == 'ORANGE' 
                ? '655123456' 
                : '677123456',
            prefixIcon: Icon(
              Icons.person,
              color: ThemeConstants.primaryColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ThemeConstants.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build amount field
  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Montant (FCFA)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montantController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: _validateAmount,
          decoration: InputDecoration(
            hintText: 'Ex: 5000',
            prefixIcon: Icon(
              Icons.money_off,
              color: ThemeConstants.errorColor,
            ),
            suffixText: 'FCFA',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ThemeConstants.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build description field
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description (optionnel)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Ex: Envoi familial',
            prefixIcon: Icon(
              Icons.description,
              color: ThemeConstants.primaryColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ThemeConstants.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _processWithdrawal,
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeConstants.errorColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
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
              'Initier le Retrait',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// Build info card
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_outlined,
                color: Colors.red.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations importantes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('• Montant minimum: ${_minAmount.toStringAsFixed(0)} FCFA'),
          _buildInfoItem('• Montant maximum: ${_maxAmount.toStringAsFixed(0)} FCFA'),
          _buildInfoItem('• Vérifiez bien le numéro du destinataire'),
          _buildInfoItem('• Le retrait peut prendre 1-5 minutes à être validé'),
          _buildInfoItem('• Des frais peuvent s\'appliquer selon l\'opérateur'),
        ],
      ),
    );
  }

  /// Build info item
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.red.shade700,
        ),
      ),
    );
  }
}