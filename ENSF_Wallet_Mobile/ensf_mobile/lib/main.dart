// lib/main.dart - CORRECTED VERSION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Core imports
import 'package:ensf_mobile/core/constants/app_constants.dart';
import 'package:ensf_mobile/core/constants/theme_constants.dart';
import 'package:ensf_mobile/core/services/user_service.dart' as core;
import 'package:ensf_mobile/core/services/storage_service.dart';

// Screen imports
import 'package:ensf_mobile/features/auth/welcome_screen.dart';
import 'package:ensf_mobile/features/auth/login_screen.dart';
import 'package:ensf_mobile/features/auth/register_screen.dart';
import 'package:ensf_mobile/features/auth/registration_status_screen.dart';
import 'package:ensf_mobile/features/forgot_password_screen.dart';
import 'package:ensf_mobile/features/home_screen.dart';
import 'package:ensf_mobile/features/card_screen.dart';
import 'package:ensf_mobile/features/profile_screen.dart';
import 'package:ensf_mobile/features/transactions/transactions_screen.dart';
import 'package:ensf_mobile/features/notifications/notification_screen.dart';
import 'package:ensf_mobile/features/settings/settings_screen.dart';
import 'package:ensf_mobile/features/transfer/transfer_screen.dart';
import 'package:ensf_mobile/features/withdraw/withdraw_screen.dart';
import 'package:ensf_mobile/features/top_up/top_up_screen.dart';
import 'package:ensf_mobile/features/purchases/purchase_screen.dart';
import 'package:ensf_mobile/features/deposit/deposit_screen.dart';

/// 🏦 ENSF Mobile Banking Application - CORRECTED VERSION
/// Professional banking application with full backend integration
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeServices();

  // Set system UI preferences
  _configureSystemUI();

  // Run the application
  runApp(const EnsfMobileApp());
}

/// Initialize core services before app starts
Future<void> _initializeServices() async {
  try {
    debugPrint('🚀 Initializing services...');
    
    // Initialize storage service
    final storageService = StorageService();
    await storageService.initialize();
    
    // Initialize user service from stored data
    final userService = core.UserService();
    await userService.initializeFromStorage();
    
    debugPrint('✅ Services initialized successfully');
  } catch (e) {
    debugPrint('❌ Service initialization error: $e');
    // Continue app startup even if service initialization fails
  }
}

/// Configure system UI (status bar, navigation bar, etc.)
void _configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// Main Application Widget
class EnsfMobileApp extends StatelessWidget {
  const EnsfMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide UserService globally
        Provider<core.UserService>(
          create: (_) => core.UserService(),
          dispose: (_, userService) => userService.dispose(),
        ),
        
        // Provide StorageService globally
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
      ],
      child: MaterialApp(
        // App configuration
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: _buildAppTheme(),
        
        // Route configuration - CORRECTED
        initialRoute: '/auth-check',
        routes: _buildAppRoutes(),
        
        // Route generation for dynamic routes
        onGenerateRoute: _generateRoute,
        
        // Global error handling
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0), // Prevent font scaling issues
            ),
            child: child!,
          );
        },
      ),
    );
  }

  /// Build application theme - ENHANCED
  ThemeData _buildAppTheme() {
    return ThemeData(
      // Color scheme
      primaryColor: ThemeConstants.primaryColor,
      colorScheme: ColorScheme.light(
        primary: ThemeConstants.primaryColor,
        secondary: ThemeConstants.secondaryColor,
        error: ThemeConstants.errorColor,
        surface: Colors.white,
        background: ThemeConstants.backgroundLight,
      ),
      
      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: ThemeConstants.headingStyle,
        displayMedium: ThemeConstants.subheadingStyle,
        bodyLarge: ThemeConstants.bodyStyle,
        bodyMedium: ThemeConstants.bodyStyle,
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: ThemeConstants.defaultElevation,
        centerTitle: true,
        titleTextStyle: ThemeConstants.subheadingStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: ThemeConstants.defaultElevation,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: ThemeConstants.defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
        ),
        color: Colors.white,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          borderSide: BorderSide(color: ThemeConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          borderSide: BorderSide(color: ThemeConstants.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ThemeConstants.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      
      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ThemeConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      
      // Use Material 3
      useMaterial3: true,
    );
  }

  /// Build application routes - CORRECTED & COMPLETE
  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      // Authentication Check
      '/auth-check': (context) => const AuthenticationCheck(),
      
      // Auth flow routes (without bottom navigation bar)
      '/welcome': (context) => const WelcomeScreen(),
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/registration-status': (context) => const RegistrationStatusScreen(),
      '/forgot-password': (context) => const ForgotPasswordScreen(),
      
      // Main app routes (with bottom navigation bar)
      '/home': (context) => const HomeScreen(),
      '/card': (context) => const CardScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/transactions': (context) => const TransactionsScreen(), // FIXED: was missing proper route
      
      // Feature routes (standalone screens)
      '/notifications': (context) => const NotificationScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/transfer': (context) => const TransferScreen(),
      '/withdraw': (context) => const WithdrawScreen(),
      '/top-up': (context) => const TopUpScreen(),
      '/purchases': (context) => const PurchaseScreen(),
      '/deposit': (context) => const DepositScreen(),
    };
  }

  /// Generate routes for dynamic routing
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // Handle dynamic routes here if needed
    // For example: /transaction/details/123
    switch (settings.name) {
      case '/transaction-details':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => TransactionDetailsScreen(
            transactionId: args?['transactionId'] as String? ?? '',
          ),
        );
      default:
        // Return 404-like screen for unknown routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page non trouvée')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Page non trouvée',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('La page demandée n\'existe pas.'),
                ],
              ),
            ),
          ),
        );
    }
  }
}

/// Authentication Check Widget - CORRECTED
/// Determines which screen to show based on authentication state
class AuthenticationCheck extends StatefulWidget {
  const AuthenticationCheck({Key? key}) : super(key: key);

  @override
  State<AuthenticationCheck> createState() => _AuthenticationCheckState();
}

class _AuthenticationCheckState extends State<AuthenticationCheck> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final userService = Provider.of<core.UserService>(context, listen: false);
      
      // Small delay to show splash screen
      await Future.delayed(const Duration(seconds: 2));
      
      if (userService.isAuthenticated) {
        // User is authenticated, go to home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // User is not authenticated, go to welcome
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      }
    } catch (e) {
      debugPrint('Authentication check error: $e');
      // On error, go to welcome screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance,
                size: 60,
                color: ThemeConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            
            // App name
            Text(
              AppConstants.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            
            // Loading text
            const Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction Details Screen - NEW (for dynamic routing)
class TransactionDetailsScreen extends StatelessWidget {
  final String transactionId;
  
  const TransactionDetailsScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la transaction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64),
            const SizedBox(height: 16),
            Text(
              'Transaction ID: $transactionId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Détails de la transaction à implémenter'),
          ],
        ),
      ),
    );
  }
}