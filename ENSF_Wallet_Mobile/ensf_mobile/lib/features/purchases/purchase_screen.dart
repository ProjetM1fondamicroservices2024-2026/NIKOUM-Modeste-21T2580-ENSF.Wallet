import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';


class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Food & Dining';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food & Dining',
      'icon': Icons.restaurant,
      'color': ThemeConstants.primaryColor,
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_car,
      'color': ThemeConstants.secondaryColor,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': ThemeConstants.accentColor,
    },
    {
      'name': 'Bills',
      'icon': Icons.receipt,
      'color': ThemeConstants.warningColor,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': ThemeConstants.successColor,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': ThemeConstants.textMedium,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _makePurchase() async {
    if (_amountController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate purchase processing
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase successful!')),
      );
      
      // Navigate back to home
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making purchase: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Purchase', style: ThemeConstants.subheadingStyle.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: ThemeConstants.defaultElevation,
        backgroundColor: ThemeConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: ThemeConstants.defaultElevation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      style: ThemeConstants.bodyStyle,
                      decoration: InputDecoration(
                        labelText: 'Category',
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
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['name'] as String,
                          child: Row(
                            children: [
                              Icon(category['icon'] as IconData, color: category['color'] as Color, size: 20),
                              const SizedBox(width: 8),
                              Text(category['name'] as String, style: ThemeConstants.bodyStyle),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      style: ThemeConstants.bodyStyle,
                      decoration: InputDecoration(
                        labelText: 'Description',
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
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _makePurchase,
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
                      'Make Purchase',
                      style: ThemeConstants.buttonTextStyle,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
