import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final List<Map<String, dynamic>> _transactions = [
    {
      'type': 'purchase',
      'title': 'Grocery Shopping',
      'amount': -25000,
      'date': '2023-04-30',
      'category': 'Food & Dining',
    },
    {
      'type': 'transfer',
      'title': 'Transfer to John',
      'amount': -50000,
      'date': '2023-04-29',
      'category': 'Transfer',
    },
    {
      'type': 'deposit',
      'title': 'Salary Deposit',
      'amount': 500000,
      'date': '2023-04-28',
      'category': 'Income',
    },
    {
      'type': 'withdrawal',
      'title': 'ATM Withdrawal',
      'amount': -100000,
      'date': '2023-04-27',
      'category': 'Withdrawal',
    },
  ];

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'purchase':
        return Icons.shopping_cart;
      case 'transfer':
        return Icons.swap_horiz;
      case 'deposit':
        return Icons.arrow_downward;
      case 'withdrawal':
        return Icons.arrow_upward;
      default:
        return Icons.attach_money;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'purchase':
        return ThemeConstants.warningColor;
      case 'transfer':
        return ThemeConstants.accentColor;
      case 'deposit':
        return ThemeConstants.successColor;
      case 'withdrawal':
        return ThemeConstants.errorColor;
      default:
        return ThemeConstants.primaryColor;
    }
  }

  String _formatAmount(int amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formattedAmount = absAmount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '${isNegative ? '-' : ''}FCFA $formattedAmount';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions', style: ThemeConstants.subheadingStyle.copyWith(color: Colors.white)),
        elevation: ThemeConstants.defaultElevation,
        backgroundColor: ThemeConstants.primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          final isNegative = transaction['amount'] < 0;
          
          return Card(
            elevation: ThemeConstants.defaultElevation,
            margin: const EdgeInsets.only(bottom: ThemeConstants.smallPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getTransactionColor(transaction['type']).withOpacity(0.2),
                child: Icon(
                  _getTransactionIcon(transaction['type']),
                  color: _getTransactionColor(transaction['type']),
                ),
              ),
              title: Text(
                transaction['title'],
                style: ThemeConstants.cardTitleStyle,
              ),
              subtitle: Text(
                '${transaction['category']} • ${transaction['date']}',
                style: ThemeConstants.bodyStyle.copyWith(
                  color: ThemeConstants.textMedium,
                  fontSize: 14,
                ),
              ),
              trailing: Text(
                _formatAmount(transaction['amount']),
                style: ThemeConstants.balanceNumberStyle.copyWith(
                  color: isNegative ? ThemeConstants.errorColor : ThemeConstants.successColor,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement transaction filter
        },
        backgroundColor: ThemeConstants.primaryColor,
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}
