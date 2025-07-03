import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://172.20.10.13:8091/api/v1/users';
  static const String agenciesUrl = 'http://172.20.10.13:8092/api/v1/agence';

  // Auth token management
  static String? _authToken;
  
  /// Set authentication token
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  /// Get authentication headers
  static Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // =====================================
  // REGISTRATION WITH KYC
  // =====================================
  
  /// Register new client with complete KYC documents
  static Future<Map<String, dynamic>> registerClient({
    required String cni,
    required String email,
    required String nom,
    required String prenom,
    required String numero,
    required String password,
    required String idAgence,
    required String rectoCniBase64,
    required String versoCniBase64,
    required String selfieImageBase64,
  }) async {
    try {
      print('📤 Envoi demande enregistrement pour: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cni': cni,
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'numero': numero,
          'password': password,
          'idAgence': idAgence,
          'rectoCni': rectoCniBase64,
          'versoCni': versoCniBase64,
          'selfieImage': selfieImageBase64, // Using existing field name
        }),
      );

      print('📥 Réponse reçue: ${response.statusCode}');
      
      if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'message': data['message'],
          'requestId': data['requestId'],
          'timestamp': data['timestamp'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Erreur lors de l\'enregistrement',
          'details': error,
        };
      }
    } catch (e) {
      print('❌ Erreur enregistrement: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion au serveur',
        'details': e.toString(),
      };
    }
  }

  /// Check registration status
  static Future<Map<String, dynamic>> checkRegistrationStatus(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/registration-status?email=${Uri.encodeComponent(email)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'message': data['message'],
          'createdAt': data['createdAt'],
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors de la vérification du statut',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion',
        'details': e.toString(),
      };
    }
  }

  // =====================================
  // IMAGE PROCESSING UTILITIES
  // =====================================

  /// Convert File to Base64 with data URL format
  static Future<String> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Determine MIME type based on file extension
      String mimeType = 'image/jpeg';
      if (file.path.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      }
      
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw Exception('Erreur conversion image: $e');
    }
  }

  /// Convert Uint8List to Base64 with data URL format
  static String bytesToBase64(Uint8List bytes, {String mimeType = 'image/jpeg'}) {
    final base64String = base64Encode(bytes);
    return 'data:$mimeType;base64,$base64String';
  }

  /// Get agencies from the API
  static Future<List<Map<String, String>>> getAgencies() async {
    try {
      final response = await http.get(Uri.parse('$agenciesUrl/getAgences'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          return {
            'id': item['idAgence'].toString(),
            'nom': item['nom'].toString(),
          };
        }).toList();
      } else {
        throw Exception('Failed to load agencies');
      }
    } catch (e) {
      print('❌ Erreur chargement agences: $e');
      return [];
    }
  }

  /// Validate image size and format
  static Future<Map<String, dynamic>> validateImage(File imageFile, {
    int minSizeKB = 50,
    int maxSizeMB = 5,
    required String type,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final sizeKB = bytes.length / 1024;
      final sizeMB = sizeKB / 1024;

      // Check file size
      if (sizeKB < minSizeKB) {
        return {
          'valid': false,
          'error': '$type trop petit (minimum ${minSizeKB}KB)',
        };
      }

      if (sizeMB > maxSizeMB) {
        return {
          'valid': false,
          'error': '$type trop volumineux (maximum ${maxSizeMB}MB)',
        };
      }

      // Check format by file signature
      if (bytes.length < 4) {
        return {
          'valid': false,
          'error': 'Format $type invalide',
        };
      }

      bool isJPEG = bytes[0] == 0xFF && bytes[1] == 0xD8;
      bool isPNG = bytes[0] == 0x89 && bytes[1] == 0x50 && 
                   bytes[2] == 0x4E && bytes[3] == 0x47;

      if (!isJPEG && !isPNG) {
        return {
          'valid': false,
          'error': '$type doit être au format JPEG ou PNG',
        };
      }

      return {
        'valid': true,
        'sizeKB': sizeKB.round(),
        'format': isJPEG ? 'JPEG' : 'PNG',
      };
    } catch (e) {
      return {
        'valid': false,
        'error': 'Erreur validation $type: $e',
      };
    }
  }

  // =====================================
  // VALIDATION UTILITIES
  // =====================================

  /// Validate Cameroon CNI format
  static bool isValidCameroonCNI(String cni) {
    if (cni.isEmpty) return false;
    
    final cleanCNI = cni.replaceAll(RegExp(r'\s+'), '');
    final regex = RegExp(r'^\d{8,12}$');
    
    return regex.hasMatch(cleanCNI) && cleanCNI.length >= 8 && cleanCNI.length <= 12;
  }

  /// Validate Cameroon phone number
  static bool isValidCameroonPhone(String phone) {
    if (phone.isEmpty) return false;
    
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final regex = RegExp(r'^6[5-9]\d{7}$');
    
    return regex.hasMatch(cleanPhone);
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[A-Za-z0-9+_.-]+@(.+)$');
    return regex.hasMatch(email.trim());
  }

  /// Validate password strength
  static Map<String, dynamic> validatePassword(String password) {
    if (password.length < 8) {
      return {
        'valid': false,
        'error': 'Le mot de passe doit contenir au moins 8 caractères',
      };
    }

    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUpper || !hasLower || !hasDigit) {
      return {
        'valid': false,
        'error': 'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre',
      };
    }

    return {
      'valid': true,
      'strength': hasSpecial ? 'Fort' : 'Moyen',
    };
  }
}