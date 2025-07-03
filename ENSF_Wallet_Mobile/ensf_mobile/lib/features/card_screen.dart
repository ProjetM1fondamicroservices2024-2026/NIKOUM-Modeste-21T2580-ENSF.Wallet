import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import '../core/constants/theme_constants.dart';
import '../core/services/account_service.dart';
import '../core/models/api_models.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

/// 💳 Enhanced Card Screen with Backend Integration
/// Features:
/// - Real card data from bank-card-service
/// - Card creation functionality
/// - Professional UI with error handling
class CardScreen extends StatefulWidget {
  const CardScreen({Key? key}) : super(key: key);

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  // Services
  final AccountService _accountService = AccountService();
  
  // State variables
  bool _isLoading = true;
  bool _isCreatingCard = false;
  List<BankCard> _cards = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  /// Fetch cards from backend
  Future<void> _fetchCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cards = await _accountService.getClientCards();
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('❌ Error fetching cards: $e', name: 'CardScreen');
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  /// Show card creation dialog
  void _showCreateCardDialog() {
    showDialog(
      context: context,
      builder: (context) => _CardCreationDialog(
        onCardCreated: (CardCreationResult result) {
          if (result.isSuccess) {
            _showSuccessMessage('Carte créée avec succès!');
            _fetchCards(); // Refresh the list
          } else {
            _showErrorMessage(result.message);
          }
        },
      ),
    );
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.successColor,
        duration: const Duration(seconds: 3),
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ThemeConstants.appBarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(ThemeConstants.largeBorderRadius),
            bottomRight: Radius.circular(ThemeConstants.largeBorderRadius),
          ),
          child: AppBar(
            backgroundColor: ThemeConstants.primaryColor,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: const Padding(
              padding: EdgeInsets.only(left: ThemeConstants.defaultPadding, top: 40),
              child: Text(
                "Mes Cartes",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 38, right: ThemeConstants.defaultPadding),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add, color: Colors.white, size: 28),
                  onPressed: _showCreateCardDialog,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchCards,
          color: ThemeConstants.primaryColor,
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }

  /// Build main body content
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Chargement de vos cartes...'),
      );
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(
        message: _errorMessage!,
        onRetry: _fetchCards,
      );
    }

    if (_cards.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCardsList();
  }
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.credit_card,
                size: 80,
                color: ThemeConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune carte trouvée',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Créez votre première carte bancaire pour commencer à effectuer des paiements',
              style: TextStyle(
                fontSize: 16,
                color: ThemeConstants.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _showCreateCardDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Créer ma première carte',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCardsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return _buildCardItem(card, index);
      },
    );
  }

  /// Build individual card item
  Widget _buildCardItem(BankCard card, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: card.isVirtual 
            ? [Colors.purple.shade400, Colors.purple.shade600]
            : [ThemeConstants.primaryColor, ThemeConstants.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Card type and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        card.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: card.isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        card.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Card number
                Text(
                  card.maskedCardNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bottom row: Name and expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TITULAIRE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            card.nomPorteur.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'EXPIRE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          card.formattedExpirationDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Card actions
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => _handleCardAction(value, card),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 18),
                      SizedBox(width: 8),
                      Text('Détails'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 18),
                      SizedBox(width: 8),
                      Text('Paramètres'),
                    ],
                  ),
                ),
                if (card.isActive)
                  const PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Bloquer'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle card actions
  void _handleCardAction(String action, BankCard card) {
    switch (action) {
      case 'details':
        _showCardDetails(card);
        break;
      case 'settings':
        _showCardSettings(card);
        break;
      case 'block':
        _showBlockCardDialog(card);
        break;
    }
  }

  /// Show card details
  void _showCardDetails(BankCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la carte'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', card.type),
              _buildDetailRow('Numéro', card.maskedCardNumber),
              _buildDetailRow('Titulaire', card.nomPorteur),
              _buildDetailRow('Statut', card.status),
              _buildDetailRow('Solde', '${card.soldeActuel.toStringAsFixed(0)} FCFA'),
              _buildDetailRow('Limite journalière achat', '${card.limiteDailyPurchase.toStringAsFixed(0)} FCFA'),
              _buildDetailRow('Limite journalière retrait', '${card.limiteDailyWithdrawal.toStringAsFixed(0)} FCFA'),
              _buildDetailRow('Limite mensuelle', '${card.limiteMonthly.toStringAsFixed(0)} FCFA'),
              _buildDetailRow('Sans contact', card.contactless ? 'Activé' : 'Désactivé'),
              _buildDetailRow('Paiements internationaux', card.internationalPayments ? 'Activé' : 'Désactivé'),
              _buildDetailRow('Paiements en ligne', card.onlinePayments ? 'Activé' : 'Désactivé'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Show card settings (placeholder)
  void _showCardSettings(BankCard card) {
    _showErrorMessage('Paramètres de carte - Fonctionnalité en développement');
  }

  /// Show block card dialog (placeholder)
  void _showBlockCardDialog(BankCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquer la carte'),
        content: Text('Êtes-vous sûr de vouloir bloquer la carte ${card.maskedCardNumber} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showErrorMessage('Blocage de carte - Fonctionnalité en développement');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Bloquer'),
          ),
        ],
      ),
    );
  }
}

/// 💳 Card Creation Dialog
class _CardCreationDialog extends StatefulWidget {
  final Function(CardCreationResult) onCardCreated;

  const _CardCreationDialog({required this.onCardCreated});

  @override
  State<_CardCreationDialog> createState() => _CardCreationDialogState();
}

class _CardCreationDialogState extends State<_CardCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomPorteurController = TextEditingController();
  final _pinController = TextEditingController();
  
  final AccountService _accountService = AccountService();
  
  CardType _selectedType = CardType.VIRTUELLE;
  bool _isCreating = false;

  @override
  void dispose() {
    _nomPorteurController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  /// Create card
  Future<void> _createCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final result = await _accountService.createCard(
        nomPorteur: _nomPorteurController.text.trim(),
        codePin: int.parse(_pinController.text),
        carteType: _selectedType.name,
        contactless: true,
        internationalPayments: false,
        onlinePayments: true,
      );

      Navigator.pop(context);
      widget.onCardCreated(result);

    } catch (e) {
      final errorResult = CardCreationResult(
        success: false,
        message: e is ApiError ? e.message : 'Erreur lors de la création de la carte',
        timestamp: DateTime.now(),
      );
      Navigator.pop(context);
      widget.onCardCreated(errorResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer une nouvelle carte'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card type selection
              const Text(
                'Type de carte',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(CardType.VIRTUELLE),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeCard(CardType.PHYSIQUE),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Cardholder name
              TextFormField(
                controller: _nomPorteurController,
                decoration: const InputDecoration(
                  labelText: 'Nom du porteur',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir le nom du porteur';
                  }
                  if (value.trim().length < 2) {
                    return 'Le nom doit contenir au moins 2 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // PIN
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(
                  labelText: 'Code PIN (4 chiffres)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.length != 4) {
                    return 'Le PIN doit contenir 4 chiffres';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createCard,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Créer'),
        ),
      ],
    );
  }

  /// Build card type selection
  Widget _buildTypeCard(CardType type) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? ThemeConstants.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? ThemeConstants.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              type == CardType.VIRTUELLE ? Icons.smartphone : Icons.credit_card,
              color: isSelected ? ThemeConstants.primaryColor : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? ThemeConstants.primaryColor : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type.description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  }