import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ensf_mobile/core/constants/theme_constants.dart';
import 'package:ensf_mobile/core/services/api_service.dart';


class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({Key? key}) : super(key: key);

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Form controllers
  final TextEditingController _cniController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Image files
  File? _rectoCniImage;
  File? _versoCniImage;
  File? _selfieImage;

  // Selected agency
  String _selectedAgency = 'AGENCE001'; // Default agency

  final List<String> _agencies = [
    'AGENCE001',
    'AGENCE002', 
    'AGENCE003',
    'AGENCE_YAO_001',
    'AGENCE_DLA_001',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeConstants.primaryColor,
        title: Text(
          'Ouverture de Compte',
          style: ThemeConstants.subheadingStyle.copyWith(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildProgressIndicator(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoStep(),
                _buildCNIFrontStep(),
                _buildCNIBackStep(),
                _buildSelfieStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(5, (index) {
          bool isActive = index <= _currentStep;
          bool isCurrent = index == _currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive 
                  ? (isCurrent ? Colors.white : Colors.white70)
                  : Colors.white30,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              '1. Informations Personnelles',
              'Renseignez vos informations de base',
            ),
            
            const SizedBox(height: 24),
            
            // CNI Number
            _buildTextField(
              controller: _cniController,
              label: 'Numéro CNI*',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Numéro CNI obligatoire';
                }
                if (!ApiService.isValidCameroonCNI(value)) {
                  return 'Format CNI camerounais invalide (8-12 chiffres)';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email*',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email obligatoire';
                }
                if (!ApiService.isValidEmail(value)) {
                  return 'Format email invalide';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Name row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nomController,
                    label: 'Nom*',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nom obligatoire';
                      }
                      if (value.length < 2) {
                        return 'Nom trop court';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _prenomController,
                    label: 'Prénom*',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prénom obligatoire';
                      }
                      if (value.length < 2) {
                        return 'Prénom trop court';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Phone number
            _buildTextField(
              controller: _numeroController,
              label: 'Numéro de téléphone*',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Numéro de téléphone obligatoire';
                }
                if (!ApiService.isValidCameroonPhone(value)) {
                  return 'Format téléphone camerounais invalide (6XXXXXXXX)';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Agency selection
            DropdownButtonFormField<String>(
              value: _selectedAgency,
              decoration: InputDecoration(
                labelText: 'Agence*',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _agencies.map((agency) {
                return DropdownMenuItem(
                  value: agency,
                  child: Text(agency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAgency = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Password
            _buildTextField(
              controller: _passwordController,
              label: 'Mot de passe*',
              icon: Icons.lock,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mot de passe obligatoire';
                }
                final validation = ApiService.validatePassword(value);
                if (!validation['valid']) {
                  return validation['error'];
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Confirm password
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirmer le mot de passe*',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirmation obligatoire';
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

  Widget _buildCNIFrontStep() {
    return _buildImageCaptureStep(
      stepNumber: '2',
      title: 'Photo CNI - Recto',
      description: 'Prenez une photo claire du recto de votre CNI',
      currentImage: _rectoCniImage,
      onImageSelected: (file) {
        setState(() {
          _rectoCniImage = file;
        });
      },
      tips: [
        '📋 Assurez-vous que tous les textes sont lisibles',
        '💡 Évitez les reflets et ombres',
        '📐 Cadrez bien toute la carte',
      ],
    );
  }

  Widget _buildCNIBackStep() {
    return _buildImageCaptureStep(
      stepNumber: '3',
      title: 'Photo CNI - Verso',
      description: 'Prenez une photo claire du verso de votre CNI',
      currentImage: _versoCniImage,
      onImageSelected: (file) {
        setState(() {
          _versoCniImage = file;
        });
      },
      tips: [
        '📋 Vérifiez que la signature est visible',
        '💡 Bonne luminosité requise',
        '📐 Photo bien centrée',
      ],
    );
  }

  Widget _buildSelfieStep() {
    return _buildImageCaptureStep(
      stepNumber: '4',
      title: 'Selfie de Vérification',
      description: 'Prenez un selfie pour la vérification biométrique',
      currentImage: _selfieImage,
      onImageSelected: (file) {
        setState(() {
          _selfieImage = file;
        });
      },
      tips: [
        '😊 Regardez directement la caméra',
        '💡 Bonne luminosité sur le visage',
        '🚫 Pas d\'objets cachant le visage',
        '📱 Tenez le téléphone verticalement',
      ],
      isSelfie: true,
    );
  }

  Widget _buildImageCaptureStep({
    required String stepNumber,
    required String title,
    required String description,
    required File? currentImage,
    required Function(File) onImageSelected,
    required List<String> tips,
    bool isSelfie = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStepHeader(stepNumber + '. ' + title, description),
          
          const SizedBox(height: 24),
          
          // Image preview or placeholder
          Container(
            width: double.infinity,
            height: isSelfie ? 300 : 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: currentImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      currentImage,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelfie ? Icons.face : Icons.credit_card,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSelfie ? 'Aucun selfie pris' : 'Aucune photo prise',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
          
          const SizedBox(height: 24),
          
          // Capture buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _captureImage(ImageSource.camera, onImageSelected),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Prendre Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _captureImage(ImageSource.gallery, onImageSelected),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseils pour une bonne photo :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    tip,
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            '5. Vérification',
            'Vérifiez vos informations avant soumission',
          ),
          
          const SizedBox(height: 24),
          
          // Personal info summary
          _buildSummaryCard(
            'Informations Personnelles',
            [
              'CNI: ${_cniController.text}',
              'Email: ${_emailController.text}',
              'Nom: ${_nomController.text}',
              'Prénom: ${_prenomController.text}',
              'Téléphone: ${_numeroController.text}',
              'Agence: $_selectedAgency',
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Documents summary
          _buildSummaryCard(
            'Documents KYC',
            [
              'CNI Recto: ${_rectoCniImage != null ? "✅ Fourni" : "❌ Manquant"}',
              'CNI Verso: ${_versoCniImage != null ? "✅ Fourni" : "❌ Manquant"}',
              'Selfie: ${_selfieImage != null ? "✅ Fourni" : "❌ Manquant"}',
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ThemeConstants.headingStyle,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ThemeConstants.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousStep,
                child: const Text('Précédent'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                  : Text(_currentStep == 4 ? 'Soumettre' : 'Suivant'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureImage(ImageSource source, Function(File) onImageSelected) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: _currentStep == 3 ? CameraDevice.front : CameraDevice.rear,
      );

      if (image != null) {
        final file = File(image.path);
        
        // Validate image
        final validation = await ApiService.validateImage(
          file,
          type: _currentStep == 3 ? 'Selfie' : 'CNI',
        );

        if (validation['valid']) {
          onImageSelected(file);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo ajoutée avec succès (${validation['sizeKB']}KB)'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validation['error']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur capture photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() async {
    setState(() {
      _errorMessage = null;
    });

    // Validate current step
    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit registration
      await _submitRegistration();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        if (_rectoCniImage == null) {
          setState(() {
            _errorMessage = 'Photo du recto CNI requise';
          });
          return false;
        }
        return true;
      case 2:
        if (_versoCniImage == null) {
          setState(() {
            _errorMessage = 'Photo du verso CNI requise';
          });
          return false;
        }
        return true;
      case 3:
        if (_selfieImage == null) {
          setState(() {
            _errorMessage = 'Selfie requis pour la vérification biométrique';
          });
          return false;
        }
        return true;
      case 4:
        return _rectoCniImage != null && _versoCniImage != null && _selfieImage != null;
      default:
        return true;
    }
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Convert images to Base64
      final rectoCniBase64 = await ApiService.fileToBase64(_rectoCniImage!);
      final versoCniBase64 = await ApiService.fileToBase64(_versoCniImage!);
      final selfieBase64 = await ApiService.fileToBase64(_selfieImage!);

      // Submit registration
      final result = await ApiService.registerClient(
        cni: _cniController.text.trim(),
        email: _emailController.text.trim(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        numero: _numeroController.text.trim(),
        password: _passwordController.text.trim(),
        idAgence: _selectedAgency,
        rectoCniBase64: rectoCniBase64,
        versoCniBase64: versoCniBase64,
        selfieImageBase64: selfieBase64,
      );

      if (result['success']) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('✅ Demande Soumise'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result['message']),
                const SizedBox(height: 16),
                Text(
                  'Statut: ${result['status']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (result['requestId'] != null) ...[
                  const SizedBox(height: 8),
                  Text('ID Demande: ${result['requestId']}'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('Connexion'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur lors de la soumission';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cniController.dispose();
    _emailController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _numeroController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}