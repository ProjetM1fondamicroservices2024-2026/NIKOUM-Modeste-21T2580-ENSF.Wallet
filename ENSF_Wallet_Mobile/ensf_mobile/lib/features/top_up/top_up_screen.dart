import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({Key? key}) : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _processTopUp() {
    if (_amountController.text.isEmpty ||
        _cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: ThemeConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulating API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Top-up successful!'),
            backgroundColor: ThemeConstants.successColor,
          ),
        );

        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Up', style: ThemeConstants.subheadingStyle.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: ThemeConstants.defaultElevation,
        backgroundColor: ThemeConstants.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: ThemeConstants.bodyStyle,
                decoration: InputDecoration(
                  labelText: 'Amount (FCFA)',
                  labelStyle: ThemeConstants.bodyStyle.copyWith(color: ThemeConstants.textMedium),
                  prefixIcon: Icon(Icons.attach_money, color: ThemeConstants.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                    borderSide: const BorderSide(color: ThemeConstants.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                    borderSide: const BorderSide(color: ThemeConstants.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: ThemeConstants.defaultPadding),
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                style: ThemeConstants.bodyStyle,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  labelStyle: ThemeConstants.bodyStyle.copyWith(color: ThemeConstants.textMedium),
                  prefixIcon: Icon(Icons.credit_card, color: ThemeConstants.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                    borderSide: const BorderSide(color: ThemeConstants.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                    borderSide: const BorderSide(color: ThemeConstants.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: ThemeConstants.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.datetime,
                      style: ThemeConstants.bodyStyle,
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        labelStyle: ThemeConstants.bodyStyle.copyWith(color: ThemeConstants.textMedium),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                          borderSide: const BorderSide(color: ThemeConstants.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                          borderSide: const BorderSide(color: ThemeConstants.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: ThemeConstants.defaultPadding),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      style: ThemeConstants.bodyStyle,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        labelStyle: ThemeConstants.bodyStyle.copyWith(color: ThemeConstants.textMedium),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                          borderSide: const BorderSide(color: ThemeConstants.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                          borderSide: const BorderSide(color: ThemeConstants.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                      maxLength: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ThemeConstants.largePadding),
              ElevatedButton(
                onPressed: _isLoading ? null : _processTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: ThemeConstants.buttonHeight / 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                  ),
                  elevation: ThemeConstants.defaultElevation,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Top Up',
                        style: ThemeConstants.buttonTextStyle,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
