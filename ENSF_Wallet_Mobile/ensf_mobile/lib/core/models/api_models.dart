class LoginRequest {
  final String identifier; // Email or phone number
  final String password;

  LoginRequest({
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'password': password,
  };
}

/// 🔐 Login Response Model
class LoginResponse {
  final String token;
  final String refreshToken;
  final String userId;
  final String email;
  final String? nom;
  final String? prenom;
  final DateTime? expiresAt;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.userId,
    required this.email,
    this.nom,
    this.prenom,
    this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['clientId'] as String,
      email: json['email'] as String,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

/// 📝 Registration Request Model
class RegistrationRequest {
  final String cni;
  final String email;
  final String nom;
  final String prenom;
  final String numero;
  final String password;
  final String idAgence;
  final String? rectoCni;
  final String? versoCni;
  final String? selfieImage; // CHANGED: backend expects 'selfieImage', not 'selfie'

  const RegistrationRequest({
    required this.cni,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.numero,
    required this.password,
    required this.idAgence,
    this.rectoCni,
    this.versoCni,
    this.selfieImage, // CHANGED: renamed from 'selfie'
  });

  Map<String, dynamic> toJson() {
    return {
      'cni': cni,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'numero': numero,
      'password': password,
      'idAgence': idAgence,
      if (rectoCni != null) 'rectoCni': rectoCni,
      if (versoCni != null) 'versoCni': versoCni,
      if (selfieImage != null) 'selfieImage': selfieImage, // CHANGED: field name
    };
  }

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) {
    return RegistrationRequest(
      cni: json['cni'] as String,
      email: json['email'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      numero: json['numero'] as String,
      password: json['password'] as String,
      idAgence: json['idAgence'] as String,
      rectoCni: json['rectoCni'] as String?,
      versoCni: json['versoCni'] as String?,
      selfieImage: json['selfieImage'] as String?, // CHANGED: field name
    );
  }
}

/// 📝 Registration Response Model
class RegistrationResponse {
  final String status;
  final String message;
  final String requestId;
  final DateTime timestamp;

  RegistrationResponse({
    required this.status,
    required this.message,
    required this.requestId,
    required this.timestamp,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      requestId: json['requestId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// 💰 Transaction Request Models
class DepositRequest {
  final double montant;
  final String numeroClient;
  final int numeroCompte;

  DepositRequest({
    required this.montant,
    required this.numeroClient,
    required this.numeroCompte,
  });

  Map<String, dynamic> toJson() => {
    'montant': montant,
    'numeroClient': numeroClient,
    'numeroCompte': numeroCompte,
  };
}

class WithdrawalRequest {
  final double montant;
  final String numeroClient;
  final int numeroCompte;

  WithdrawalRequest({
    required this.montant,
    required this.numeroClient,
    required this.numeroCompte,
  });

  Map<String, dynamic> toJson() => {
    'montant': montant,
    'numeroClient': numeroClient,
    'numeroCompte': numeroCompte,
  };
}

class TransferRequest {
  final double montant;
  final int numeroCompteSend;
  final int numeroCompteReceive;

  TransferRequest({
    required this.montant,
    required this.numeroCompteSend,
    required this.numeroCompteReceive,
  });

  Map<String, dynamic> toJson() => {
    'montant': montant,
    'numeroCompteSend': numeroCompteSend,
    'numeroCompteReceive': numeroCompteReceive,
  };
}

/// 💰 Transaction Response Model
class TransactionResponse {
  final String? transactionId;
  final String status;
  final String message;
  final double? montant;
  final double? frais;
  final double? montantNet;
  final String? numeroCompteSource;
  final String? numeroCompteDestination;
  final String? typeOperation;
  final DateTime timestamp;
  final DateTime? processedAt;
  final String? referenceNumber;
  final String? description;
  final String? errorCode;
  final String? errorDetails;

  TransactionResponse({
    this.transactionId,
    required this.status,
    required this.message,
    this.montant,
    this.frais,
    this.montantNet,
    this.numeroCompteSource,
    this.numeroCompteDestination,
    this.typeOperation,
    required this.timestamp,
    this.processedAt,
    this.referenceNumber,
    this.description,
    this.errorCode,
    this.errorDetails,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactionId: json['transactionId'] as String?,
      status: json['status'] as String,
      message: json['message'] as String,
      montant: (json['montant'] as num?)?.toDouble(),
      frais: (json['frais'] as num?)?.toDouble(),
      montantNet: (json['montantNet'] as num?)?.toDouble(),
      numeroCompteSource: json['numeroCompteSource'] as String?,
      numeroCompteDestination: json['numeroCompteDestination'] as String?,
      typeOperation: json['typeOperation'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      processedAt: json['processedAt'] != null 
          ? DateTime.parse(json['processedAt'] as String) 
          : null,
      referenceNumber: json['referenceNumber'] as String?,
      description: json['description'] as String?,
      errorCode: json['errorCode'] as String?,
      errorDetails: json['errorDetails'] as String?,
    );
  }

  /// Check if transaction was successful
  bool get isSuccess => status == 'SUCCESS';
  
  /// Check if transaction failed
  bool get isFailed => status == 'FAILED' || status == 'REJECTED';
  
  /// Check if transaction is pending
  bool get isPending => status == 'PENDING';
}

/// 👤 User Profile Model
class UserProfile {
  final String idClient;
  final String nom;
  final String prenom;
  final String email;
  final String numero;
  final String status;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserProfile({
    required this.idClient,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.numero,
    required this.status,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      idClient: json['idClient'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      numero: json['numero'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String) 
          : null,
    );
  }

  /// Get full name
  String get fullName => '$prenom $nom';
  
  /// Check if user is active
  bool get isActive => status == 'ACTIVE';
}

/// ⚠️ API Error Response Model
class ApiError {
  final String error;
  final String message;
  final DateTime timestamp;
  final String path;
  final int? statusCode;

  ApiError({
    required this.error,
    required this.message,
    required this.timestamp,
    required this.path,
    this.statusCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      error: json['error'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      path: json['path'] as String,
      statusCode: json['statusCode'] as int?,
    );
  }

  @override
  String toString() => message;
}

class AccountStatusResult {
  final bool isApproved;
  final String status;
  final String message;
  final bool canPerformOperations;
  final DateTime? lastStatusUpdate;

  AccountStatusResult({
    required this.isApproved,
    required this.status,
    required this.message,
    required this.canPerformOperations,
    this.lastStatusUpdate,
  });

  factory AccountStatusResult.fromJson(Map<String, dynamic> json) {
    return AccountStatusResult(
      isApproved: json['isApproved'] as bool,
      status: json['status'] as String,
      message: json['message'] as String,
      canPerformOperations: json['canPerformOperations'] as bool,
      lastStatusUpdate: json['lastStatusUpdate'] != null
          ? DateTime.parse(json['lastStatusUpdate'] as String)
          : null,
    );
  }

  /// Get status color for UI
  String get statusColor {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'green';
      case 'PENDING':
        return 'orange';
      case 'REJECTED':
        return 'red';
      case 'BLOCKED':
        return 'gray';
      default:
        return 'gray';
    }
  }

  /// Get status icon
  String get statusIcon {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return '✅';
      case 'PENDING':
        return '⏳';
      case 'REJECTED':
        return '❌';
      case 'BLOCKED':
        return '🔒';
      default:
        return '❓';
    }
  }
}

class PaymentResponse {
  final String? reference;
  final String status;
  final String message;

  PaymentResponse({
    this.reference,
    required this.status,
    required this.message,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      reference: json['reference'] as String?,
      status: json['status'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'status': status,
      'message': message,
    };
  }

  /// Check if payment was successful
  bool get isSuccess => status.toUpperCase() == 'SUCCESS';
  
  /// Check if payment failed
  bool get isFailed => status.toUpperCase() == 'FAILED';
  
  /// Check if payment was canceled
  bool get isCanceled => status.toUpperCase() == 'CANCELED';
  
  /// Check if payment is pending
  bool get isPending => status.toUpperCase() == 'PENDING';

  /// Get user-friendly status message
  String get statusMessage {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return 'Dépôt réussi';
      case 'FAILED':
        return 'Dépôt échoué';
      case 'CANCELED':
        return 'Dépôt annulé';
      case 'PENDING':
        return 'Dépôt en cours...';
      default:
        return 'Statut inconnu';
    }
  }
}

class CardCreationResult {
  final bool success;
  final String? idCarte;
  final String? numeroCarte;
  final String? errorCode;
  final String message;
  final double? fraisDebites;
  final DateTime timestamp;

  CardCreationResult({
    required this.success,
    this.idCarte,
    this.numeroCarte,
    this.errorCode,
    required this.message,
    this.fraisDebites,
    required this.timestamp,
  });

  factory CardCreationResult.fromJson(Map<String, dynamic> json) {
    return CardCreationResult(
      success: json['success'] as bool,
      idCarte: json['idCarte'] as String?,
      numeroCarte: json['numeroCarte'] as String?,
      errorCode: json['errorCode'] as String?,
      message: json['message'] as String,
      fraisDebites: (json['fraisDebites'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Check if card creation was successful
  bool get isSuccess => success;
  
  /// Check if card creation failed
  bool get isFailed => !success;

  /// Get user-friendly status message
  String get statusMessage {
    if (success) {
      return 'Carte créée avec succès';
    } else {
      return errorCode != null ? '$errorCode: $message' : message;
    }
  }
}

/// 💳 Bank Card Model
/// Matches Carte entity from bank-card-service
class BankCard {
  final String idCarte;
  final String numeroCarte;
  final String nomPorteur;
  final String type;
  final String status;
  final String idClient;
  final String idAgence;
  final String numeroCompte;
  final DateTime dateCreation;
  final DateTime dateExpiration;
  final double limiteDailyPurchase;
  final double limiteDailyWithdrawal;
  final double limiteMonthly;
  final bool contactless;
  final bool internationalPayments;
  final bool onlinePayments;
  final bool isBlocked;
  final double soldeActuel;

  BankCard({
    required this.idCarte,
    required this.numeroCarte,
    required this.nomPorteur,
    required this.type,
    required this.status,
    required this.idClient,
    required this.idAgence,
    required this.numeroCompte,
    required this.dateCreation,
    required this.dateExpiration,
    required this.limiteDailyPurchase,
    required this.limiteDailyWithdrawal,
    required this.limiteMonthly,
    required this.contactless,
    required this.internationalPayments,
    required this.onlinePayments,
    required this.isBlocked,
    required this.soldeActuel,
  });

  factory BankCard.fromJson(Map<String, dynamic> json) {
  return BankCard(
    idCarte: json['idCarte'] as String,
    numeroCarte: json['numeroCarte'] as String,
    nomPorteur: json['nomPorteur'] as String,
    type: json['type'] as String,
    status: json['status'] as String,
    idClient: json['idClient'] as String,
    idAgence: json['idAgence'] as String,
    numeroCompte: json['numeroCompte'] as String,
    // Map 'createdAt' from response to 'dateCreation' in model
    dateCreation: DateTime.parse(json['createdAt'] as String),
    dateExpiration: DateTime.parse(json['dateExpiration'] as String),
    limiteDailyPurchase: (json['limiteDailyPurchase'] as num).toDouble(),
    limiteDailyWithdrawal: (json['limiteDailyWithdrawal'] as num).toDouble(),
    limiteMonthly: (json['limiteMonthly'] as num).toDouble(),
    contactless: json['contactless'] as bool,
    internationalPayments: json['internationalPayments'] as bool,
    onlinePayments: json['onlinePayments'] as bool,
    // Map 'pinBlocked' from response to 'isBlocked' in model
    isBlocked: json['pinBlocked'] as bool,
    // Map 'solde' from response to 'soldeActuel' in model
    soldeActuel: (json['solde'] as num).toDouble(),
  );
}

  /// Get masked card number (e.g., "**** **** **** 1234")
  String get maskedCardNumber {
    if (numeroCarte.length >= 4) {
      return "**** **** **** ${numeroCarte.substring(numeroCarte.length - 4)}";
    }
    return numeroCarte;
  }

  /// Check if card is active
  bool get isActive => status.toUpperCase() == 'ACTIVE' && !isBlocked;

  /// Check if card is virtual
  bool get isVirtual => type.toUpperCase() == 'VIRTUELLE';

  /// Check if card is physical
  bool get isPhysical => type.toUpperCase() == 'PHYSIQUE';

  /// Get card status color
  String get statusColor {
    if (isBlocked) return 'RED';
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'GREEN';
      case 'EXPIRED':
        return 'ORANGE';
      case 'SUSPENDED':
        return 'YELLOW';
      default:
        return 'GREY';
    }
  }

  /// Get formatted expiration date
  String get formattedExpirationDate {
    return '${dateExpiration.month.toString().padLeft(2, '0')}/${dateExpiration.year.toString().substring(2)}';
  }
}

/// 💳 Card Type Enum
enum CardType {
  VIRTUELLE,
  PHYSIQUE,
}

extension CardTypeExtension on CardType {
  String get displayName {
    switch (this) {
      case CardType.VIRTUELLE:
        return 'Virtuelle';
      case CardType.PHYSIQUE:
        return 'Physique';
    }
  }

  String get description {
    switch (this) {
      case CardType.VIRTUELLE:
        return 'Carte numérique pour paiements en ligne';
      case CardType.PHYSIQUE:
        return 'Carte plastique pour tous types de paiements';
    }
  }
}