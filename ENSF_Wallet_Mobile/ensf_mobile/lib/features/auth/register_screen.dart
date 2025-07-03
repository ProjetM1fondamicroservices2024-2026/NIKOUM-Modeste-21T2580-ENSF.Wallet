import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ensf_mobile/core/constants/app_constants.dart';
import 'package:ensf_mobile/core/constants/theme_constants.dart';
import 'package:ensf_mobile/core/services/user_service.dart';
import 'package:ensf_mobile/core/models/api_models.dart';
import 'package:ensf_mobile/core/services/api_service.dart';

/// 📝 Enhanced Registration Screen with Full API Integration
/// Handles user registration with document upload and backend validation
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  // Form and controllers
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  // Personal Information Controllers
  final TextEditingController _cniController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Services
  late UserService _userService;
  
  // State management
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  
  // Agency selection
  List<Map<String, String>> _agencies = [];
  String? _selectedAgencyId;
  bool _isLoadingAgencies = false;

  // Document upload
  File? _rectoCniImage;
  File? _versoCniImage;
  File? _selfieImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadAgencies();
    _setupAnimations();
    _userService = Provider.of<UserService>(context, listen: false);
  }



  @override
  void dispose() {
    _animationController.dispose();
    _cniController.dispose();
    _emailController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _numeroController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  ///Load agencies from the API
  Future<void> _loadAgencies() async {
  setState(() => _isLoadingAgencies = true);

  try {
    final agenciesJson = await ApiService.getAgencies(); 
    setState(() {
      _agencies = agenciesJson.map<Map<String, String>>((agency) {
        return {
          'id': agency['id'] ?? '', 
          'name': agency['nom'] ?? '',
        };
      }).toList();
    });

    // If no agencies found, show a warning
    if (_agencies.isEmpty) {
      setState(() {
        _errorMessage = 'Aucune agence disponible pour l\'inscription';
      });
    } else {
      // Automatically select the first agency
      _selectedAgencyId = _agencies.first['id'];
    }
  } on ApiError catch (e) {
    print("Erreur API lors du chargement des agences: ${e.message}");
    setState(() {
      _errorMessage = 'Erreur de chargement des agences: ${e.message}';
    });
  } catch (e) {
    print("Erreur lors du chargement des agences: $e");
  } finally {
    setState(() => _isLoadingAgencies = false);
  }
}

  /// Setup animations
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  /// Handle registration submission
  Future<void> _handleRegistration() async {
  try {

    if (!_termsAccepted) {
      _showErrorMessage('Vous devez accepter les conditions d\'utilisation');
      return;
    }

    if (_selectedAgencyId == null) {
      _showErrorMessage('Veuillez sélectionner une agence');
      return;
    }
    // Validate all required images are present
    if (_rectoCniImage == null || _versoCniImage == null || _selfieImage == null) {
      _showErrorMessage('Veuillez télécharger tous les documents requis');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Create registration request with file references (not base64)
    final registrationRequest = RegistrationRequest(
      cni: _cniController.text.trim(),
      email: _emailController.text.trim(),
      nom: _nomController.text.trim().toUpperCase(),
      prenom: _prenomController.text.trim(),
      numero: _numeroController.text.trim(),
      password: _passwordController.text.trim(),
      idAgence: _selectedAgencyId!,
      rectoCni: "any", // Empty string as backend will handle file path
      versoCni: "any", // Empty string as backend will handle file path
      selfieImage: "any", // Empty string as backend will handle file path
    );

    // Submit registration with files
    final response = await _userService.registerWithFiles(
      registrationRequest,
      _rectoCniImage!,
      _versoCniImage!,
      _selfieImage!,
    );

    // Check if widget is still mounted before updating state
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Navigate to registration status screen
      Navigator.pushReplacementNamed(
        context,
        '/registration-status',
        arguments: {
          'email': _emailController.text.trim(),
          'requestId': response.requestId,
          'status': response.status,
          'message': response.message,
        },
      );
    }
  } on ApiError catch (e) {
     print('🔥 API ERROR DETAILS:');
    print('  Error Code: ${e.error}');
    print('  Message: ${e.message}');
    print('  Path: ${e.path}');
    // Only update state if widget is still mounted
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
      _showErrorMessage(e.message);
    }
  } catch (e) {
    print('🔥 GENERAL ERROR: $e');
    // Only update state if widget is still mounted
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur réseau s\'est produite. Vérifiez votre connexion.';
      });
      _showErrorMessage('Erreur d\'inscription: ${e.toString()}');
    }
  }
}

// Future<void> _debugApiRequest() async {
//   try {
//     // Create the same request that will be sent
//     String? rectoCniBase64;
//     String? versoCniBase64;
//     String? selfieBase64;

//     if (_rectoCniImage != null) {
//       final bytes = await _rectoCniImage!.readAsBytes();
//       rectoCniBase64 = base64Encode(bytes);
//       print('🖼️ Recto CNI size: ${bytes.length} bytes');
//     }

//     if (_versoCniImage != null) {
//       final bytes = await _versoCniImage!.readAsBytes();
//       versoCniBase64 = base64Encode(bytes);
//       print('🖼️ Verso CNI size: ${bytes.length} bytes');
//     }

//     if (_selfieImage != null) {
//       final bytes = await _selfieImage!.readAsBytes();
//       selfieBase64 = base64Encode(bytes);
//       print('🖼️ Selfie size: ${bytes.length} bytes');
//     }

//     final registrationRequest = RegistrationRequest(
//       cni: _cniController.text.trim(),
//       email: _emailController.text.trim(),
//       nom: _nomController.text.trim().toUpperCase(),
//       prenom: _prenomController.text.trim(),
//       numero: _numeroController.text.trim(),
//       password: _passwordController.text.trim(),
//       idAgence: _selectedAgencyId!,
//       rectoCni: rectoCniBase64,
//       versoCni: versoCniBase64,
//       selfieImage: selfieBase64,
//     );

//     final jsonData = registrationRequest.toJson();
    
//     print('📤 FINAL REQUEST JSON:');
//     jsonData.forEach((key, value) {
//       if (key.contains('Cni') || key.contains('selfie')) {
//         print('  $key: ${value != null ? "${value.toString().substring(0, 50)}..." : "null"}');
//       } else {
//         print('  $key: $value');
//       }
//     });

//   } catch (e) {
//     print('❌ Debug error: $e');
//   }
// }

// void _debugRegistrationData() {
//   final userData = {
//     'cni': _cniController.text.trim(),
//     'email': _emailController.text.trim(),
//     'nom': _nomController.text.trim().toUpperCase(),
//     'prenom': _prenomController.text.trim(),
//     'numero': _numeroController.text.trim(),
//     'password': _passwordController.text.trim(),
//     'idAgence': _selectedAgencyId,
//     'hasRectoCni': _rectoCniImage != null,
//     'hasVersoCni': _versoCniImage != null,
//     'hasSelfie': _selfieImage != null,
//   };

//   print('🐛 DEBUG - Registration Data:');
//   userData.forEach((key, value) {
//     print('  $key: $value');
//   });

//   // Check for common validation issues
//   print('🔍 VALIDATION CHECKS:');
  
//   // CNI validation
//   if (_cniController.text.trim().length < 8) {
//     print('  ❌ CNI too short: ${_cniController.text.trim().length} characters');
//   }
  
//   // Email validation
//   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
//     print('  ❌ Invalid email format: ${_emailController.text.trim()}');
//   }
  
//   // Phone number validation (Cameroon format)
//   if (!RegExp(r'^6[5-9]\d{7}$').hasMatch(_numeroController.text.trim())) {
//     print('  ❌ Invalid phone format: ${_numeroController.text.trim()}');
//   }
  
//   // Password validation
//   if (_passwordController.text.trim().length < 8) {
//     print('  ❌ Password too short: ${_passwordController.text.trim().length} characters');
//   }
  
//   // Agency validation
//   if (_selectedAgencyId == null) {
//     print('  ❌ No agency selected');
//   }
  
//   // Image validation
//   if (_rectoCniImage == null) {
//     print('  ❌ Missing recto CNI image');
//   }
//   if (_versoCniImage == null) {
//     print('  ❌ Missing verso CNI image');
//   }
//   if (_selfieImage == null) {
//     print('  ❌ Missing selfie image');
//   }
// }

  /// Show error message
void _showErrorMessage(String message) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

  /// Pick image from camera or gallery
  Future<void> _pickImage(String type) async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        
        // Check file size (max 5MB)
        final bytes = await imageFile.readAsBytes();
        if (bytes.length > AppConstants.maxFileSize) {
          _showErrorMessage('L\'image est trop voluminteuse (max 5MB)');
          return;
        }

        setState(() {
          switch (type) {
            case 'recto':
              _rectoCniImage = imageFile;
              break;
            case 'verso':
              _versoCniImage = imageFile;
              break;
            case 'selfie':
              _selfieImage = imageFile;
              break;
          }
        });
      }
    } catch (e) {
      _showErrorMessage('Erreur lors de la sélection de l\'image: ${e.toString()}');
    }
  }

  /// Show image source dialog
  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner la source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Caméra'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to next step
void _nextStep() {
  if (_currentStep < 2) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (mounted) {
      setState(() {
        _currentStep++;
      });
    }
  }
}

  /// Navigate to previous step
void _previousStep() {
  if (_currentStep > 0) {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (mounted) {
      setState(() {
        _currentStep--;
      });
    }
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
          'Créer un compte',
          style: ThemeConstants.subheadingStyle.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildDocumentUploadStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  /// Build progress indicator
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
      color: Colors.white,
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive 
                        ? ThemeConstants.primaryColor 
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted 
                          ? ThemeConstants.primaryColor 
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Build personal information step
  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: ThemeConstants.headingStyle,
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            
            // CNI Field
            _buildTextField(
              controller: _cniController,
              label: 'Numéro CNI*',
              icon: Icons.credit_card,
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
            _buildTextField(
              controller: _emailController,
              label: 'Adresse email*',
              icon: Icons.email,
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
            
            // Name Fields Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nomController,
                    label: 'Nom*',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: ThemeConstants.smallPadding),
                Expanded(
                  child: _buildTextField(
                    controller: _prenomController,
                    label: 'Prénom*',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le prénom est requis';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            
            // Phone Field
            _buildTextField(
              controller: _numeroController,
              label: 'Numéro de téléphone*',
              icon: Icons.phone,
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
            
            // Agency Selection
          _isLoadingAgencies
          ? Center(child: CircularProgressIndicator())
          : DropdownButtonFormField<String>(
              value: _selectedAgencyId,
              decoration: InputDecoration(
                labelText: 'Agence*',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                ),
              ),
              items: _agencies.map((agency) {
                return DropdownMenuItem<String>(
                  value: agency['id'],
                  child: Text(agency['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAgencyId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner une agence';
                }
                return null;
              },
            ),

            const SizedBox(height: ThemeConstants.mediumPadding),
            
            // Password Fields
            _buildTextField(
              controller: _passwordController,
              label: 'Mot de passe*',
              icon: Icons.lock,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le mot de passe est requis';
                }
                if (value.length < 8) {
                  return 'Minimum 8 caractères';
                }
                if (!RegExp(AppConstants.passwordPattern).hasMatch(value)) {
                  return 'Doit contenir: majuscule, minuscule, chiffre, caractère spécial';
                }
                return null;
              },
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirmer le mot de passe*',
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez confirmer le mot de passe';
                }
                if (value != _passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildDocumentUploadStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents requis',
            style: ThemeConstants.headingStyle,
          ),
          const SizedBox(height: ThemeConstants.smallPadding),
          Text(
            'Veuillez télécharger vos documents d\'identité pour vérification',
            style: ThemeConstants.bodyStyle.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: ThemeConstants.largePadding),
          
          // Recto CNI
          _buildDocumentUploadCard(
            title: 'Recto de la CNI',
            subtitle: 'Face avant de votre carte d\'identité',
            icon: Icons.credit_card,
            image: _rectoCniImage,
            onTap: () => _pickImage('recto'),
            isRequired: true,
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),
          
          // Verso CNI
          _buildDocumentUploadCard(
            title: 'Verso de la CNI',
            subtitle: 'Face arrière de votre carte d\'identité',
            icon: Icons.credit_card,
            image: _versoCniImage,
            onTap: () => _pickImage('verso'),
            isRequired: true,
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),
          
          // Selfie (Optional)
          _buildDocumentUploadCard(
            title: 'Photo selfie',
            subtitle: 'Photo de vous (optionnel)',
            icon: Icons.camera_alt,
            image: _selfieImage,
            onTap: () => _pickImage('selfie'),
            isRequired: false,
          ),
          const SizedBox(height: ThemeConstants.largePadding),
          
          // Upload requirements
          Container(
            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Exigences des documents',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Format: JPG, JPEG, PNG\n'
                  '• Taille maximum: 5MB\n'
                  '• Documents lisibles et non flous\n'
                  '• Pas de photos d\'écran',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build review step
  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vérification des informations',
            style: ThemeConstants.headingStyle,
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),
          
          // Personal Info Review
          _buildReviewSection(
            title: 'Informations personnelles',
            children: [
              _buildReviewItem('CNI', _cniController.text),
              _buildReviewItem('Email', _emailController.text),
              _buildReviewItem('Nom', '${_prenomController.text} ${_nomController.text}'),
              _buildReviewItem('Téléphone', _numeroController.text),
              _buildReviewItem('Agence', _getSelectedAgencyName()),
            ],
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),
          
          // Documents Review
          _buildReviewSection(
            title: 'Documents téléchargés',
            children: [
              _buildDocumentReviewItem('Recto CNI', _rectoCniImage != null),
              _buildDocumentReviewItem('Verso CNI', _versoCniImage != null),
              _buildDocumentReviewItem('Selfie', _selfieImage != null, isOptional: true),
            ],
          ),
          const SizedBox(height: ThemeConstants.largePadding),
          
          // Terms and Conditions
          Container(
            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                  title: const Text(
                    'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: ThemeConstants.primaryColor,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Show terms of service
                        _showTermsDialog();
                      },
                      child: const Text('Conditions d\'utilisation'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Show privacy policy
                        _showPrivacyDialog();
                      },
                      child: const Text('Politique de confidentialité'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ThemeConstants.largePadding),
          
          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
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
        ],
      ),
    );
  }

  String _getSelectedAgencyName() {
  if (_selectedAgencyId == null) {
    return 'Aucune agence sélectionnée';
  }
  
  try {
    final agency = _agencies.firstWhere(
      (a) => a['id'] == _selectedAgencyId,
      orElse: () => {'id': '', 'name': 'Agence inconnue'},
    );
    print('_selectedAgencyId: $_selectedAgencyId, name: ${agency['name']}');
    return agency['name'] ?? 'Agence inconnue';
  } catch (e) {
    return 'Erreur de sélection d\'agence';
  }
}

  /// Build navigation buttons
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Précédent'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: ThemeConstants.mediumPadding),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : () {
                if (_currentStep < 2) {
                  if (_currentStep == 0) {
                    if (_formKey.currentState!.validate() && _selectedAgencyId != null) {
                      _nextStep();
                    } else if (_selectedAgencyId == null) {
                      setState(() {
                        _errorMessage = 'Veuillez sélectionner une agence';
                      });
                    }
                  } else {
                    _nextStep();
                  }
                } else {
                  _handleRegistration();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                  : Text(
                      _currentStep < 2 ? 'Suivant' : 'Créer le compte',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          borderSide: BorderSide(color: ThemeConstants.primaryColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  /// Build document upload card
  Widget _buildDocumentUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? image,
    required VoidCallback onTap,
    required bool isRequired,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, color: ThemeConstants.primaryColor),
                  const SizedBox(width: ThemeConstants.smallPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (isRequired)
                              Text(
                                ' *',
                                style: TextStyle(
                                  color: ThemeConstants.errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    image != null ? Icons.check_circle : Icons.cloud_upload,
                    color: image != null ? Colors.green : Colors.grey.shade400,
                  ),
                ],
              ),
              if (image != null) ...[
                const SizedBox(height: ThemeConstants.smallPadding),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build review section
  Widget _buildReviewSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: ThemeConstants.smallPadding),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Build review item
  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build document review item
  Widget _buildDocumentReviewItem(String title, bool isUploaded, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.cancel,
            color: isUploaded ? Colors.green : (isOptional ? Colors.orange : Colors.red),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isUploaded ? Colors.green : (isOptional ? Colors.orange : Colors.red),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isOptional)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Optionnel',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Show terms of service dialog
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: const SingleChildScrollView(
          child: Text(
            'En utilisant cette application, vous acceptez nos conditions d\'utilisation...\n\n'
            '1. Utilisation responsable du service\n'
            '2. Protection des données personnelles\n'
            '3. Sécurité des transactions\n'
            '4. Respect de la réglementation bancaire\n\n'
            'Pour consulter la version complète, visitez notre site web.',
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

  /// Show privacy policy dialog
  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Politique de confidentialité'),
        content: const SingleChildScrollView(
          child: Text(
            'Nous nous engageons à protéger vos données personnelles...\n\n'
            '• Collecte limitée aux données nécessaires\n'
            '• Stockage sécurisé et chiffré\n'
            '• Pas de partage avec des tiers non autorisés\n'
            '• Droit d\'accès et de rectification\n\n'
            'Pour plus de détails, consultez notre politique complète.',
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
}