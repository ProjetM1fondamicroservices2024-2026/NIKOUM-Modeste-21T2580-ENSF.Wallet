import React, { useState, useEffect } from 'react';
import { 
  FileText, Eye, CheckCircle, XCircle, Clock, Search, Filter,
  RefreshCw, Loader, User, Calendar, AlertTriangle, Menu,
  Home, LogOut, Bell, Settings, Building2, CreditCard,
  ChevronRight, X, MessageSquare
} from 'lucide-react';
import ApiService from '../../services/ApiService';
import DocumentReviewModal from './DocumentReviewModal';
import AgencyManagement from './AgencyManagement';
import CompteManagement from './CompteManagement';

/**
 * 🏦 Simple Admin Dashboard - Focused Implementation
 * 
 * Core Features:
 * ✅ Document Management (Pending, Approve, Reject)
 * 🔄 Agency Management (Coming Next)
 * 🔄 Account Management (Coming Next)
 * 
 * Professional, maintainable code with clear commenting
 */
const SimpleDashboard = ({ onLogout }) => {
  // =====================================
  // STATE MANAGEMENT
  // =====================================
  
  const [activeTab, setActiveTab] = useState('documents');
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [loading, setLoading] = useState({
    documents: false,
    action: false
  });
  
  // Documents state
  const [documents, setDocuments] = useState([]);
  const [selectedDocument, setSelectedDocument] = useState(null);
  const [filters, setFilters] = useState({
    search: '',
    status: 'PENDING'
  });
  
  // Modal states
  const [showReviewModal, setShowReviewModal] = useState(false);
  const [actionComment, setActionComment] = useState('');
  const [actionType, setActionType] = useState(''); // 'approve' or 'reject'
  
  // Error and success states
  const [notification, setNotification] = useState(null);

  // =====================================
  // API INTEGRATION FUNCTIONS
  // =====================================

  /**
   * Fetch pending documents from backend
   */
  const fetchPendingDocuments = async () => {
    try {
      setLoading(prev => ({ ...prev, documents: true }));
      
      // Using existing AgenceService endpoint
      const response = await ApiService.agenceService.getPendingDocuments({
        search: filters.search,
        status: filters.status
      });

      console.log('response 4555:', response.data.data.content);
      
      if (response.success) {
        setDocuments(response.data.data.content || []);
        console.log('✅ Documents fetched successfully:', response.data.data.content?.length || 0);
      } else {
        showNotification('error', 'Erreur lors du chargement des documents');
      }
    } catch (error) {
      console.error('❌ Error fetching documents:', error);
      showNotification('error', 'Erreur de connexion au serveur');
    } finally {
      setLoading(prev => ({ ...prev, documents: false }));
    }
  };

  /**
   * Handle document approval
   */
  const handleApproveDocument = async (documentId, comment = '') => {
    try {
      setLoading(prev => ({ ...prev, action: true }));
      
      const response = await ApiService.agenceService.approveDocument(documentId, {
        comment: comment || 'Document approuvé'
      });
      
      if (response.success) {
        showNotification('success', 'Document approuvé avec succès');
        fetchPendingDocuments(); // Refresh list
        setShowReviewModal(false);
        setSelectedDocument(null);
      } else {
        showNotification('error', response.error || 'Erreur lors de l\'approbation');
      }
    } catch (error) {
      console.error('❌ Error approving document:', error);
      showNotification('error', 'Erreur lors de l\'approbation');
    } finally {
      setLoading(prev => ({ ...prev, action: false }));
    }
  };

  /**
   * Handle document rejection
   */
  const handleRejectDocument = async (documentId, reason = '') => {
    try {
      setLoading(prev => ({ ...prev, action: true }));
      
      const response = await ApiService.agenceService.rejectDocument(documentId, {
        reason: reason || 'Document rejeté'
      });
      
      if (response.success) {
        showNotification('success', 'Document rejeté');
        fetchPendingDocuments(); // Refresh list
        setShowReviewModal(false);
        setSelectedDocument(null);
      } else {
        showNotification('error', response.error || 'Erreur lors du rejet');
      }
    } catch (error) {
      console.error('❌ Error rejecting document:', error);
      showNotification('error', 'Erreur lors du rejet');
    } finally {
      setLoading(prev => ({ ...prev, action: false }));
    }
  };

  /**
   * Show notification helper
   */
  const showNotification = (type, message) => {
    setNotification({ type, message });
    setTimeout(() => setNotification(null), 5000);
  };

  // =====================================
  // EFFECTS
  // =====================================

  useEffect(() => {
    if (activeTab === 'documents') {
      fetchPendingDocuments();
    }
  }, [activeTab, filters]);

  // =====================================
  // COMPONENT RENDERERS
  // =====================================

  /**
   * Sidebar Navigation Component
   */
  const Sidebar = () => (
    <div className={`${sidebarCollapsed ? 'w-16' : 'w-64'} bg-gradient-to-b from-gray-900 to-gray-800 text-white transition-all duration-300 flex flex-col`}>
      {/* Header */}
      <div className="p-4 border-b border-gray-700">
        <div className="flex items-center justify-between">
          {!sidebarCollapsed && (
            <div>
              <h1 className="text-lg font-bold">Admin Portal</h1>
              <p className="text-xs text-gray-300">Tableau de bord</p>
            </div>
          )}
          <button
            onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
            className="p-2 hover:bg-gray-700 rounded-lg transition-colors"
          >
            <Menu className="h-5 w-5" />
          </button>
        </div>
      </div>

      {/* Navigation Menu */}
      <nav className="flex-1 p-4 space-y-2">
        {/* Documents Tab */}
        <button
          onClick={() => setActiveTab('documents')}
          className={`w-full flex items-center gap-3 p-3 rounded-lg transition-colors ${
            activeTab === 'documents' 
              ? 'bg-blue-600 text-white' 
              : 'text-gray-300 hover:bg-gray-700'
          }`}
        >
          <FileText className="h-5 w-5 flex-shrink-0" />
          {!sidebarCollapsed && (
            <div className="flex-1 text-left">
              <div className="font-medium">Documents</div>
              <div className="text-xs opacity-75">Approbation en attente</div>
            </div>
          )}
        </button>

        {/* Agencies Tab - Placeholder */}
        <button
          onClick={() => setActiveTab('agencies')}
          className={`w-full flex items-center gap-3 p-3 rounded-lg transition-colors ${
            activeTab === 'agencies' 
              ? 'bg-blue-600 text-white' 
              : 'text-gray-300 hover:bg-gray-700'
          }`}
        >
          <Building2 className="h-5 w-5 flex-shrink-0" />
          {!sidebarCollapsed && (
            <div className="flex-1 text-left">
              <div className="font-medium">Agences</div>
              <div className="text-xs opacity-75">Gestion CRUD</div>
            </div>
          )}
        </button>

        {/* Accounts Tab - Placeholder */}
        <button
          onClick={() => setActiveTab('accounts')}
          className={`w-full flex items-center gap-3 p-3 rounded-lg transition-colors ${
            activeTab === 'accounts' 
              ? 'bg-blue-600 text-white' 
              : 'text-gray-300 hover:bg-gray-700'
          }`}
        >
          <CreditCard className="h-5 w-5 flex-shrink-0" />
          {!sidebarCollapsed && (
            <div className="flex-1 text-left">
              <div className="font-medium">Comptes</div>
              <div className="text-xs opacity-75">Gestion CRUD</div>
            </div>
          )}
        </button>
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-gray-700">
        <button 
          onClick={handleLogout}
          className="w-full flex items-center gap-3 p-3 text-gray-300 hover:bg-gray-700 rounded-lg transition-colors"
        >
          <LogOut className="h-5 w-5 flex-shrink-0" />
          {!sidebarCollapsed && <span>Déconnexion</span>}
        </button>
      </div>
    </div>
  );

  /**
   * Top Header Component
   */
  const Header = () => (
    <header className="bg-white shadow-sm border-b border-gray-200 px-6 py-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold text-gray-900">
            {activeTab === 'documents' && 'Gestion des Documents'}
            {activeTab === 'agencies' && 'Gestion des Agences'}
            {activeTab === 'accounts' && 'Gestion des Comptes'}
          </h2>
          <p className="text-sm text-gray-600 mt-1">
            {activeTab === 'documents' && 'Approbation et validation des documents'}
            {activeTab === 'agencies' && 'Configuration et maintenance des agences'}
            {activeTab === 'accounts' && 'Administration des comptes utilisateurs'}
          </p>
        </div>
        
        <div className="flex items-center gap-3">
          <button className="p-2 text-gray-400 hover:text-gray-600 relative">
            <Bell className="h-5 w-5" />
            <span className="absolute -top-1 -right-1 h-3 w-3 bg-red-500 rounded-full"></span>
          </button>
          <button className="p-2 text-gray-400 hover:text-gray-600">
            <Settings className="h-5 w-5" />
          </button>
        </div>
      </div>
    </header>
  );

  /**
   * Document Status Badge Component
   */
  const DocumentStatusBadge = ({ status }) => {
    const statusConfig = {
      PENDING: { bg: 'bg-yellow-100', text: 'text-yellow-800', icon: Clock },
      APPROVED: { bg: 'bg-green-100', text: 'text-green-800', icon: CheckCircle },
      REJECTED: { bg: 'bg-red-100', text: 'text-red-800', icon: XCircle }
    };
    
    const config = statusConfig[status] || statusConfig.PENDING;
    const Icon = config.icon;
    
    return (
      <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${config.bg} ${config.text}`}>
        <Icon className="h-3 w-3" />
        {status === 'PENDING' ? 'En attente' : status === 'APPROVED' ? 'Approuvé' : 'Rejeté'}
      </span>
    );
  };

  /**
   * Documents Management Tab
   */
  const DocumentsTab = () => (
    <div className="space-y-6">
      
      {/* Filters and Search */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
        <div className="flex flex-col sm:flex-row gap-4">
          {/* Search */}
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Rechercher par nom d'utilisateur ou numéro..."
                value={filters.search}
                onChange={(e) => setFilters(prev => ({ ...prev, search: e.target.value }))}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>
          
          {/* Status Filter */}
          <div className="sm:w-48">
            <select
              value={filters.status}
              onChange={(e) => setFilters(prev => ({ ...prev, status: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="PENDING">En attente</option>
              <option value="APPROVED">Approuvés</option>
              <option value="REJECTED">Rejetés</option>
              <option value="ALL">Tous</option>
            </select>
          </div>
          
          {/* Refresh Button */}
          <button
            onClick={fetchPendingDocuments}
            disabled={loading.documents}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors"
          >
            <RefreshCw className={`h-4 w-4 ${loading.documents ? 'animate-spin' : ''}`} />
            Actualiser
          </button>
        </div>
      </div>

      {/* Documents List */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        {loading.documents ? (
          <div className="flex items-center justify-center py-12">
            <Loader className="h-8 w-8 animate-spin text-blue-600" />
            <span className="ml-3 text-gray-600">Chargement des documents...</span>
          </div>
        ) : documents.length === 0 ? (
          <div className="text-center py-12">
            <FileText className="h-12 w-12 mx-auto text-gray-300 mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun document trouvé</h3>
            <p className="text-gray-500">Aucun document ne correspond aux critères de recherche.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Utilisateur
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Type de Document
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Date de Soumission
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Statut
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {documents.map((doc) => (
                  <tr key={doc.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <User className="h-5 w-5 text-gray-400 mr-3" />
                        <div>
                          <div className="text-sm font-medium text-gray-900">
                            {doc.nomClient || 'Utilisateur inconnu'}
                          </div>
                          <div className="text-sm text-gray-500">
                            {doc.cni || 'cni non disponible'}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{doc.documentType || 'Creation de compte'}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center text-sm text-gray-500">
                        <Calendar className="h-4 w-4 mr-2" />
                        {doc.uploadedAt ? new Date(doc.uploadedAt).toLocaleDateString('fr-FR') : 'Date inconnue'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <DocumentStatusBadge status={doc.status || 'PENDING'} />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                      <button
                        onClick={() => {
                          setSelectedDocument(doc);
                          setShowReviewModal(true);
                        }}
                        className="inline-flex items-center gap-1 px-3 py-1.5 text-blue-600 hover:text-blue-700 hover:bg-blue-50 rounded-lg transition-colors"
                      >
                        <Eye className="h-4 w-4" />
                        Examiner
                      </button>
                      <button
                        onClick={() => {
                          setSelectedDocument(doc);
                          handleApproveDocument(doc.id);
                        }}
                        className="inline-flex items-center gap-1 px-3 py-1.5 text-blue-600 hover:text-blue-700 hover:bg-blue-50 rounded-lg transition-colors"
                      >
                        <Eye className="h-4 w-4" />
                        Approuver
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );

  /**
   * Placeholder for other tabs
   */
  const PlaceholderTab = ({ title, description, icon: Icon }) => (
    <div className="text-center py-12">
      <Icon className="h-16 w-16 mx-auto text-gray-300 mb-4" />
      <h3 className="text-lg font-medium text-gray-900 mb-2">{title}</h3>
      <p className="text-gray-500">{description}</p>
      <p className="text-sm text-blue-600 mt-2">Fonctionnalité en cours de développement...</p>
    </div>
  );

  /**
   * Handle user logout
   */
  const handleLogout = () => {
    try {
      console.log('🚪 Logging out user...');
      
      // Clear any pending states
      setLoading({ documents: false, action: false });
      setShowReviewModal(false);
      setSelectedDocument(null);
      
      // Call the parent logout function
      if (onLogout) {
        onLogout();
      }
      
      console.log('✅ Logout completed');
    } catch (error) {
      console.error('❌ Error during logout:', error);
      // Force logout even if there's an error
      if (onLogout) {
        onLogout();
      }
    }
  };
  // =====================================
  // MAIN RENDER
  // =====================================

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      
      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        
        {/* Notification */}
        {notification && (
          <div className={`mx-6 mt-4 p-4 rounded-lg border ${
            notification.type === 'success' 
              ? 'bg-green-50 border-green-200 text-green-700' 
              : 'bg-red-50 border-red-200 text-red-700'
          }`}>
            <div className="flex items-center justify-between">
              <span>{notification.message}</span>
              <button onClick={() => setNotification(null)}>
                <X className="h-4 w-4" />
              </button>
            </div>
          </div>
        )}
        
        {/* Main Content Area */}
        <main className="flex-1 p-6 overflow-auto">
          {activeTab === 'documents' && <DocumentsTab />}
          {activeTab === 'agencies' && <AgencyManagement />}
          {activeTab === 'accounts' && <CompteManagement />}
        </main>
      </div>

      {/* Document Review Modal - To be implemented next */}
        {showReviewModal && selectedDocument && (
        <DocumentReviewModal 
            documentId={selectedDocument.id}
            onClose={() => {
            setShowReviewModal(false);
            setSelectedDocument(null);
            }}
            onApprove={(documentId, comment) => handleApproveDocument(documentId, comment)}
            onReject={(documentId, reason) => handleRejectDocument(documentId, reason)}
            isLoading={loading.action}
        />
        )}
    </div>
  );
};

export default SimpleDashboard;