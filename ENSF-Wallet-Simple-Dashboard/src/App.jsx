import React, { useState, useEffect } from 'react';
import { Loader, Building2 } from 'lucide-react';
import SimpleDashboard from './components/dashboard/simpleDashboard';
import AdminLoginPage from './components/auth/AdminLoginPage';
import './index.css';

/**
 * 🚀 Simple Application Component with Authentication Flow
 * 
 * Features:
 * - Authentication state management
 * - Route protection for admin dashboard
 * - Simple JWT token validation
 * - Clean loading states
 */
function App() {
  // =====================================
  // STATE MANAGEMENT
  // =====================================
  
  const [authState, setAuthState] = useState({
    isAuthenticated: false,
    isLoading: true,
    user: null,
    token: null
  });

  // =====================================
  // AUTHENTICATION UTILITIES
  // =====================================
  
  const AuthUtils = {
    /**
     * Check if user is authenticated
     */
    isAuthenticated() {
      const token = localStorage.getItem('authToken');
      const user = localStorage.getItem('currentUser');
      return !!(token && user);
    },

    /**
     * Get stored user data
     */
    getCurrentUser() {
      try {
        const userData = localStorage.getItem('currentUser');
        return userData ? JSON.parse(userData) : null;
      } catch {
        return null;
      }
    },

    /**
     * Get stored token
     */
    getToken() {
      return localStorage.getItem('authToken');
    },

    /**
     * Clear authentication data
     */
    clearAuth() {
      localStorage.removeItem('authToken');
      localStorage.removeItem('currentUser');
      localStorage.removeItem('loginTimestamp');
      delete window.authToken;
    },

    /**
     * Store authentication data
     */
    storeAuth(token, user) {
      try {
        localStorage.setItem('authToken', token);
        localStorage.setItem('currentUser', JSON.stringify(user));
        localStorage.setItem('loginTimestamp', Date.now().toString());
        window.authToken = token;
        return true;
      } catch (error) {
        console.error('❌ Error storing auth data:', error);
        return false;
      }
    }
  };

  // =====================================
  // COMPONENT LIFECYCLE
  // =====================================
  
  useEffect(() => {
    /**
     * Initialize authentication state on app load
     */
    const initializeAuth = () => {
      console.log('🔍 Checking authentication status...');
      
      try {
        const isAuth = AuthUtils.isAuthenticated();
        const user = AuthUtils.getCurrentUser();
        const token = AuthUtils.getToken();
        
        if (isAuth && user && token) {
          console.log('✅ Valid authentication found for user:', user.username);
          window.authToken = token;
          
          setAuthState({
            isAuthenticated: true,
            isLoading: false,
            user: user,
            token: token
          });
        } else {
          console.log('❌ No valid authentication found');
          AuthUtils.clearAuth();
          
          setAuthState({
            isAuthenticated: false,
            isLoading: false,
            user: null,
            token: null
          });
        }
      } catch (error) {
        console.error('❌ Error initializing authentication:', error);
        AuthUtils.clearAuth();
        
        setAuthState({
          isAuthenticated: false,
          isLoading: false,
          user: null,
          token: null
        });
      }
    };

    // Initialize with small delay for better UX
    const timer = setTimeout(initializeAuth, 500);
    return () => clearTimeout(timer);
  }, []);

  // =====================================
  // EVENT HANDLERS
  // =====================================
  
  /**
   * Handle successful login
   */
  const handleLoginSuccess = (token, user) => {
    console.log('✅ Login successful, updating app state');
    
    // Store authentication data
    AuthUtils.storeAuth(token, user);
    
    // Update app state
    setAuthState({
      isAuthenticated: true,
      isLoading: false,
      user: user,
      token: token
    });
  };

  /**
   * Handle logout
   */
  const handleLogout = () => {
    console.log('🚪 Logging out user');
    AuthUtils.clearAuth();
    
    setAuthState({
      isAuthenticated: false,
      isLoading: false,
      user: null,
      token: null
    });
  };

  // =====================================
  // LOADING SCREEN COMPONENT
  // =====================================
  
  const LoadingScreen = () => (
    <div className="min-h-screen bg-gradient-to-br from-blue-900 via-blue-800 to-indigo-900 flex items-center justify-center">
      <div className="text-center text-white">
        {/* App Logo */}
        <div className="mb-8">
          <div className="w-20 h-20 bg-white bg-opacity-20 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <Building2 className="h-10 w-10" />
          </div>
          <h1 className="text-2xl font-bold">Admin Portal</h1>
          <p className="text-blue-200 text-sm">Tableau de bord administrateur</p>
        </div>
        
        {/* Loading Indicator */}
        <div className="flex items-center justify-center gap-3">
          <Loader className="h-6 w-6 animate-spin" />
          <span className="text-lg">Initialisation...</span>
        </div>
        
        {/* Loading Steps */}
        <div className="mt-6 space-y-2 text-sm text-blue-200">
          <p>🔍 Vérification de l'authentification...</p>
          <p>🔐 Validation des tokens...</p>
          <p>⚡ Chargement de l'interface...</p>
        </div>
      </div>
    </div>
  );

  // =====================================
  // MAIN RENDER
  // =====================================
  
  // Show loading screen while checking authentication
  if (authState.isLoading) {
    return <LoadingScreen />;
  }

  // Show login page if not authenticated
  if (!authState.isAuthenticated) {
    return (
      <AdminLoginPage
        onLoginSuccess={handleLoginSuccess}
      />
    );
  }

  // Show dashboard if authenticated
  return (
    <SimpleDashboard
      user={authState.user}
      token={authState.token}
      onLogout={handleLogout}
    />
  );
}

export default App;