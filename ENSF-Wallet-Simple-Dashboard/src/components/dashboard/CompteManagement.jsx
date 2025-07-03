import React, { useState, useEffect } from 'react';
import { 
  CreditCard, Plus, Edit, Trash2, Eye, Search, RefreshCw, Loader,
  X, User, Building2, DollarSign, Calendar, AlertTriangle,
  CheckCircle, XCircle, Save, Shield, Lock, Unlock, History,
  TrendingUp, TrendingDown, Filter, Download, Ban, RotateCcw,
  Activity, Clock, AlertCircle
} from 'lucide-react';
import ApiService from '../../services/ApiService';

/**
 * 💳 Compte Management Component
 * 
 * Complete CRUD operations for user accounts:
 * ✅ View all accounts with search/filter
 * ✅ Add new account
 * ✅ Edit existing account
 * ✅ Delete/Close account
 * ✅ View account details with transaction history
 * ✅ Block/Unblock accounts
 * ✅ Manage account limits
 * ✅ View account statistics
 */
const CompteManagement = () => {
  // =====================================
  // STATE MANAGEMENT
  // =====================================
  
  const [comptes, setComptes] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [typeFilter, setTypeFilter] = useState('ALL');
  
  // Modal states
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState(''); // 'add', 'edit', 'view', 'delete', 'block', 'limits'
  const [selectedCompte, setSelectedCompte] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  // Form data for add/edit
  const [formData, setFormData] = useState({
    numeroCompte: '',
    idClient: '',
    idAgence: '',
    solde: '0',
    type: 'STANDARD',
    status: 'PENDING',
    limiteDailyWithdrawal: '1000000',
    limiteDailyTransfer: '2000000',
    limiteMonthlyOperations: '10000000'
  });

  const [cardFormData, setCardFormData] = useState({
  type:'VIRTUELLE_GRATUITE',
  nomPorteur: '',
  codePin: '',
  limiteDailyPurchase: '500000',
  limiteDailyWithdrawal: '200000',
  limiteMonthly: '2000000',
  contactless: true,
  internationalPayments: false,
  onlinePayments: true
});

  // Statistics state
  const [statistics, setStatistics] = useState({
    totalComptes: 0,
    activeComptes: 0,
    pendingComptes: 0,
    blockedComptes: 0,
    totalSolde: 0,
    averageSolde: 0
  });

  // =====================================
  // API INTEGRATION
  // =====================================

  /**
   * Fetch all comptes with pagination and filters
   */
  const fetchComptes = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Build query parameters
      const params = {
        page: 0,
        size: 50,
        ...(statusFilter !== 'ALL' && { status: statusFilter }),
        ...(typeFilter !== 'ALL' && { type: typeFilter }),
        ...(searchTerm && { search: searchTerm })
      };
      
      console.log('🔍 Fetching comptes with params:', params);
      
      // Call the API endpoint for getting all comptes
      const response = await ApiService.agenceService.getAllComptes(params);
      
      if (response.success) {
        setComptes(response.data.content || response.data || []);
        updateStatistics(response.data.content || response.data || []);
        console.log('✅ Comptes fetched successfully:', response.data);
      } else {
        setError(response.error || 'Erreur lors du chargement des comptes');
      }
    } catch (err) {
      console.error('❌ Error fetching comptes:', err);
      setError('Impossible de charger les comptes. Vérifiez votre connexion.');
    } finally {
      setLoading(false);
    }
  };

  /**
   * Create new compte
   */
  const createCompte = async (compteData) => {
    try {
      setIsSubmitting(true);
      console.log('🆕 Creating new compte:', compteData);
      
      const response = await ApiService.agenceService.createCompte(compteData);
      
      if (response.success) {
        console.log('✅ Compte created successfully');
        fetchComptes(); // Refresh list
        resetModal();
        showNotification('success', 'Compte créé avec succès');
      } else {
        setError(response.error || 'Erreur lors de la création du compte');
      }
    } catch (err) {
      console.error('❌ Error creating compte:', err);
      setError('Erreur lors de la création du compte');
    } finally {
      setIsSubmitting(false);
    }
  };

  /**
   * Update existing compte
   */
  const updateCompte = async (compteId, compteData) => {
    try {
      setIsSubmitting(true);
      console.log('📝 Updating compte:', compteId, compteData);
      
      const response = await ApiService.agenceService.updateCompte(compteId, compteData);
      
      if (response.success) {
        console.log('✅ Compte updated successfully');
        fetchComptes(); // Refresh list
        resetModal();
        showNotification('success', 'Compte mis à jour avec succès');
      } else {
        setError(response.error || 'Erreur lors de la mise à jour');
      }
    } catch (err) {
      console.error('❌ Error updating compte:', err);
      setError('Erreur lors de la mise à jour du compte');
    } finally {
      setIsSubmitting(false);
    }
  };

  /**
   * Delete/Close compte
   */
  const deleteCompte = async (compteId) => {
    try {
      setIsSubmitting(true);
      console.log('🗑️ Closing compte:', compteId);
      
      const response = await ApiService.agenceService.closeCompte(compteId);
      
      if (response.success) {
        console.log('✅ Compte closed successfully');
        fetchComptes(); // Refresh list
        resetModal();
        showNotification('success', 'Compte fermé avec succès');
      } else {
        setError(response.error || 'Erreur lors de la fermeture');
      }
    } catch (err) {
      console.error('❌ Error closing compte:', err);
      setError('Erreur lors de la fermeture du compte');
    } finally {
      setIsSubmitting(false);
    }
  };

  /**
   * Block/Unblock compte
   */
  const toggleBlockCompte = async (compteId, block = true) => {
    try {
      setIsSubmitting(true);
      console.log(`${block ? '🔒' : '🔓'} ${block ? 'Blocking' : 'Unblocking'} compte:`, compteId);
      
      const response = block 
        ? await ApiService.agenceService.blockCompte(compteId, { reason: 'Bloqué par l\'administrateur' })
        : await ApiService.agenceService.unblockCompte(compteId);
      
      if (response.success) {
        console.log(`✅ Compte ${block ? 'blocked' : 'unblocked'} successfully`);
        fetchComptes(); // Refresh list
        resetModal();
        showNotification('success', `Compte ${block ? 'bloqué' : 'débloqué'} avec succès`);
      } else {
        setError(response.error || `Erreur lors du ${block ? 'blocage' : 'déblocage'}`);
      }
    } catch (err) {
      console.error(`❌ Error ${block ? 'blocking' : 'unblocking'} compte:`, err);
      setError(`Erreur lors du ${block ? 'blocage' : 'déblocage'} du compte`);
    } finally {
      setIsSubmitting(false);
    }
  };

  /**
   * Get compte details with transaction history
   */
  const getCompteDetails = async (compteId) => {
    try {
      console.log('📋 Fetching compte details:', compteId);
      
      const response = await ApiService.agenceService.getCompteDetails(compteId);
      
      if (response.success) {
        setSelectedCompte(response.data);
        setModalType('view');
        setShowModal(true);
        console.log('✅ Compte details fetched successfully');
      } else {
        setError(response.error || 'Erreur lors du chargement des détails');
      }
    } catch (err) {
      console.error('❌ Error fetching compte details:', err);
      setError('Erreur lors du chargement des détails du compte');
    }
  };

  // =====================================
  // UTILITY FUNCTIONS
  // =====================================

  /**
   * Reset modal state
   */
  const resetModal = () => {
    setShowModal(false);
    setModalType('');
    setSelectedCompte(null);
    setFormData({
      numeroCompte: '',
      idClient: '',
      idAgence: '',
      solde: '0',
      type: 'STANDARD',
      status: 'PENDING',
      limiteDailyWithdrawal: '1000000',
      limiteDailyTransfer: '2000000',
      limiteMonthlyOperations: '10000000'
    });

    setCardFormData({
    type: 'VIRTUELLE_GRATUITE',
    nomPorteur: '',
    codePin: '',
    limiteDailyPurchase: '500000',
    limiteDailyWithdrawal: '200000',
    limiteMonthly: '2000000',
    contactless: true,
    internationalPayments: false,
    onlinePayments: true
  });
    setError(null);
  };

  /**
   * Handle form submission
   */
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Convert string values to appropriate types
    const compteData = {
      ...formData,
      numeroCompte: parseInt(formData.numeroCompte) || null,
      solde: parseFloat(formData.solde) || 0,
      limiteDailyWithdrawal: parseFloat(formData.limiteDailyWithdrawal) || 1000000,
      limiteDailyTransfer: parseFloat(formData.limiteDailyTransfer) || 2000000,
      limiteMonthlyOperations: parseFloat(formData.limiteMonthlyOperations) || 10000000
    };
    
    if (modalType === 'add') {
      await createCompte(compteData);
    } else if (modalType === 'edit') {
      await updateCompte(selectedCompte.id, compteData);
    }
  };

  /**
 * Handle form submission properly to prevent input interference
 */
const handleSubmitCard = async (e) => {
  e.preventDefault();
  
  if (!selectedCompte) {
    setError('Aucun compte sélectionné');
    return;
  }
  
  // Prepare card data with compte information
  const cardData = {
    ...cardFormData,
    idClient: selectedCompte.idClient,
    idAgence: selectedCompte.idAgence,
    numeroCompte: selectedCompte.numeroCompte.toString(),
    codePin: parseInt(cardFormData.codePin),
    limiteDailyPurchase: parseFloat(cardFormData.limiteDailyPurchase) || 500000,
    limiteDailyWithdrawal: parseFloat(cardFormData.limiteDailyWithdrawal) || 200000,
    limiteMonthly: parseFloat(cardFormData.limiteMonthly) || 2000000
  };
  
  await createCard(cardData);
};

  /**
   * Create new card for a compte
   */
  const createCard = async (cardData) => {
  try {
    setIsSubmitting(true);
    console.log('💳 Creating card for compte:', selectedCompte.numeroCompte);
    console.log('💳 Card data being sent:', cardData);
    
    const response = await ApiService.agenceService.createCard(cardData);
    
    if (response.success) {
      console.log('✅ Card created successfully');
      resetModal(); // CHANGE: Use resetModal instead of closeModal
      showNotification('success', 'Carte créée avec succès');
    } else {
      setError(response.error || 'Erreur lors de la création de la carte');
    }
  } catch (err) {
    console.error('❌ Error creating card:', err);
    setError('Erreur lors de la création de la carte');
  } finally {
    setIsSubmitting(false);
  }
};

  /**
   * Update statistics based on current comptes data
   */
  const updateStatistics = (comptesData) => {
    const stats = {
      totalComptes: comptesData.length,
      activeComptes: comptesData.filter(c => c.status === 'ACTIVE').length,
      pendingComptes: comptesData.filter(c => c.status === 'PENDING').length,
      blockedComptes: comptesData.filter(c => c.blocked === true).length,
      totalSolde: comptesData.reduce((sum, c) => sum + (parseFloat(c.solde) || 0), 0),
      averageSolde: comptesData.length > 0 ? 
        comptesData.reduce((sum, c) => sum + (parseFloat(c.solde) || 0), 0) / comptesData.length : 0
    };
    setStatistics(stats);
  };

  /**
   * Filter comptes based on search term and filters
   */
  const filteredComptes = comptes.filter(compte => {
    const matchesSearch = 
      compte.numeroCompte?.toString().includes(searchTerm) ||
      compte.idClient?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      compte.idAgence?.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = statusFilter === 'ALL' || compte.status === statusFilter;
    const matchesType = typeFilter === 'ALL' || compte.type === typeFilter;
    
    return matchesSearch && matchesStatus && matchesType;
  });

  /**
   * Show notification helper
   */
  const showNotification = (type, message) => {
    // This would typically integrate with a notification system
    console.log(`${type.toUpperCase()}: ${message}`);
  };

  // =====================================
  // EFFECTS
  // =====================================

  useEffect(() => {
    fetchComptes();
  }, []);

  useEffect(() => {
    // Re-filter when search term or filters change
    updateStatistics(filteredComptes);
  }, [searchTerm, statusFilter, typeFilter, comptes]);

  // =====================================
  // RENDER COMPONENTS
  // =====================================

  /**
   * Compte Status Badge
   */
  const StatusBadge = ({ status, blocked }) => {
    if (blocked) {
      return (
        <span className="px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800 border border-red-200">
          <Ban className="h-3 w-3 inline mr-1" />
          Bloqué
        </span>
      );
    }

    const styles = {
      ACTIVE: 'bg-green-100 text-green-800 border-green-200',
      PENDING: 'bg-yellow-100 text-yellow-800 border-yellow-200',
      SUSPENDED: 'bg-orange-100 text-orange-800 border-orange-200',
      BLOCKED: 'bg-red-100 text-red-800 border-red-200',
      CLOSED: 'bg-gray-100 text-gray-800 border-gray-200'
    };
    
    const statusLabels = {
      ACTIVE: 'Actif',
      PENDING: 'En attente',
      SUSPENDED: 'Suspendu',
      BLOCKED: 'Bloqué',
      CLOSED: 'Fermé'
    };
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium border ${styles[status] || styles.PENDING}`}>
        {statusLabels[status] || status}
      </span>
    );
  };

  /**
   * Compte Type Badge
   */
  const TypeBadge = ({ type }) => {
    const styles = {
      STANDARD: 'bg-blue-100 text-blue-800 border-blue-200',
      PREMIUM: 'bg-purple-100 text-purple-800 border-purple-200',
      BUSINESS: 'bg-indigo-100 text-indigo-800 border-indigo-200',
      SAVING: 'bg-green-100 text-green-800 border-green-200'
    };
    
    const typeLabels = {
      STANDARD: 'Standard',
      PREMIUM: 'Premium',
      BUSINESS: 'Entreprise',
      SAVING: 'Épargne'
    };
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium border ${styles[type] || styles.STANDARD}`}>
        {typeLabels[type] || type}
      </span>
    );
  };

  /**
   * Statistics Cards Component
   */
  const StatisticsCards = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4 mb-6">
      <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Total Comptes</p>
            <p className="text-2xl font-bold text-gray-900">{statistics.totalComptes}</p>
          </div>
          <CreditCard className="h-8 w-8 text-blue-500" />
        </div>
      </div>
      
      <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Comptes Actifs</p>
            <p className="text-2xl font-bold text-green-600">{statistics.activeComptes}</p>
          </div>
          <CheckCircle className="h-8 w-8 text-green-500" />
        </div>
      </div>
      
      <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">En Attente</p>
            <p className="text-2xl font-bold text-yellow-600">{statistics.pendingComptes}</p>
          </div>
          <Clock className="h-8 w-8 text-yellow-500" />
        </div>
      </div>
      
      <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Bloqués</p>
            <p className="text-2xl font-bold text-red-600">{statistics.blockedComptes}</p>
          </div>
          <Ban className="h-8 w-8 text-red-500" />
        </div>
      </div>
      
      <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Solde Total</p>
            <p className="text-2xl font-bold text-blue-600">
              {new Intl.NumberFormat('fr-FR', {
                style: 'currency',
                currency: 'XAF',
                minimumFractionDigits: 0
              }).format(statistics.totalSolde)}
            </p>
          </div>
          <DollarSign className="h-8 w-8 text-blue-500" />
        </div>
      </div>
      
      <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Solde Moyen</p>
            <p className="text-2xl font-bold text-purple-600">
              {new Intl.NumberFormat('fr-FR', {
                style: 'currency',
                currency: 'XAF',
                minimumFractionDigits: 0
              }).format(statistics.averageSolde)}
            </p>
          </div>
          <TrendingUp className="h-8 w-8 text-purple-500" />
        </div>
      </div>
    </div>
  );

  /**
   * Search and Filter Controls
   */
  const SearchAndFilters = () => (
    <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-100 mb-6">
      <div className="flex flex-col lg:flex-row lg:items-center gap-4">
        {/* Search Input */}
        <div className="flex-1">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Rechercher par numéro de compte, client, agence..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>
        
        {/* Filters */}
        <div className="flex flex-col sm:flex-row gap-3">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="ALL">Tous les statuts</option>
            <option value="ACTIVE">Actifs</option>
            <option value="PENDING">En attente</option>
            <option value="SUSPENDED">Suspendus</option>
            <option value="BLOCKED">Bloqués</option>
            <option value="CLOSED">Fermés</option>
          </select>
          
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="ALL">Tous les types</option>
            <option value="VIRTUELLE_GRATUITE">gratuite</option>
            <option value="VITUELLE_PREMIUM">Premium</option>
            <option value="PHYSIQUE">physique</option>
          </select>
          
          <button
            onClick={fetchComptes}
            disabled={loading}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2"
          >
            <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
            Actualiser
          </button>
          
          <button
            onClick={() => {
              setModalType('add');
              setShowModal(true);
            }}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 flex items-center gap-2"
          >
            <Plus className="h-4 w-4" />
            Nouveau Compte
          </button>
        </div>
      </div>
    </div>
  );

  /**
   * Comptes Table Component
   */
  const ComptesTable = () => (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      {/* Table Header */}
      <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
        <h3 className="text-lg font-semibold text-gray-900">
          Liste des Comptes ({filteredComptes.length})
        </h3>
      </div>
      
      {/* Loading State */}
      {loading && (
        <div className="flex items-center justify-center py-12">
          <Loader className="h-8 w-8 animate-spin text-blue-600" />
          <span className="ml-2 text-gray-600">Chargement des comptes...</span>
        </div>
      )}
      
      {/* Error State */}
      {error && (
        <div className="p-6 text-center">
          <AlertTriangle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <p className="text-red-600 mb-4">{error}</p>
          <button
            onClick={fetchComptes}
            className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
          >
            Réessayer
          </button>
        </div>
      )}
      
      {/* Table Content */}
      {!loading && !error && (
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Numéro de Compte
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Client
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Agence
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Statut
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Solde
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Dernière Transaction
                </th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredComptes.length === 0 ? (
                <tr>
                  <td colSpan="8" className="px-6 py-12 text-center text-gray-500">
                    <CreditCard className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                    <p>Aucun compte trouvé</p>
                    <p className="text-sm mt-1">
                      {searchTerm || statusFilter !== 'ALL' || typeFilter !== 'ALL'
                        ? 'Essayez de modifier vos critères de recherche'
                        : 'Commencez par créer votre premier compte'
                      }
                    </p>
                  </td>
                </tr>
              ) : (
                filteredComptes.map((compte) => (
                  <tr key={compte.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="font-medium text-gray-900">
                        {compte.numeroCompte}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <User className="h-4 w-4 text-gray-400 mr-2" />
                        <span className="text-sm text-gray-900">{compte.idClient}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <Building2 className="h-4 w-4 text-gray-400 mr-2" />
                        <span className="text-sm text-gray-900">{compte.idAgence}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <TypeBadge type={compte.type} />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <StatusBadge status={compte.status} blocked={compte.blocked} />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        {new Intl.NumberFormat('fr-FR', {
                          style: 'currency',
                          currency: 'XAF',
                          minimumFractionDigits: 0
                        }).format(compte.solde || 0)}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {compte.lastTransactionAt ? 
                        new Date(compte.lastTransactionAt).toLocaleDateString('fr-FR') : 
                        'Aucune'
                      }
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-center">
                      <div className="flex items-center justify-center space-x-2">
                        <button
                          onClick={() => getCompteDetails(compte.id)}
                          className="text-blue-600 hover:text-blue-800 p-1"
                          title="Voir détails"
                        >
                          <Eye className="h-4 w-4" />
                        </button>
                        
                        <button
                            onClick={() => {
                            setSelectedCompte(compte);
                            setModalType('createCard');
                            setShowModal(true);
                            }}
                            className="text-purple-600 hover:text-purple-800 p-1"
                            title="Créer une carte"
                        >
                            <CreditCard className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => {
                            setSelectedCompte(compte);
                            setFormData({
                              numeroCompte: compte.numeroCompte?.toString() || '',
                              idClient: compte.idClient || '',
                              idAgence: compte.idAgence || '',
                              solde: compte.solde?.toString() || '0',
                              type: compte.type || 'STANDARD',
                              status: compte.status || 'PENDING',
                              limiteDailyWithdrawal: compte.limiteDailyWithdrawal?.toString() || '1000000',
                              limiteDailyTransfer: compte.limiteDailyTransfer?.toString() || '2000000',
                              limiteMonthlyOperations: compte.limiteMonthlyOperations?.toString() || '10000000'
                            });
                            setModalType('edit');
                            setShowModal(true);
                          }}
                          className="text-indigo-600 hover:text-indigo-800 p-1"
                          title="Modifier"
                        >
                          <Edit className="h-4 w-4" />
                        </button>

                        
                        <button
                          onClick={() => toggleBlockCompte(compte.id, !compte.blocked)}
                          className={`p-1 ${compte.blocked ? 
                            'text-green-600 hover:text-green-800' : 
                            'text-red-600 hover:text-red-800'}`}
                          title={compte.blocked ? 'Débloquer' : 'Bloquer'}
                        >
                          {compte.blocked ? <Unlock className="h-4 w-4" /> : <Lock className="h-4 w-4" />}
                        </button>
                        
                        <button
                          onClick={() => {
                            setSelectedCompte(compte);
                            setModalType('delete');
                            setShowModal(true);
                          }}
                          className="text-red-600 hover:text-red-800 p-1"
                          title="Fermer compte"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );

  /**
   * Compte Form Modal
   */
  const CompteFormModal = () => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-hidden">
        
        {/* Modal Header */}
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900">
              {modalType === 'add' ? 'Nouveau Compte' : 
               modalType === 'edit' ? 'Modifier Compte' :
               modalType === 'view' ? 'Détails du Compte' :
               modalType === 'createCard' ? 'Créer une Carte' :
               modalType === 'delete' ? 'Fermer Compte' :
               'Gestion Compte'}
            </h3>
            <button
              onClick={resetModal}
              className="text-gray-400 hover:text-gray-600"
            >
              <X className="h-6 w-6" />
            </button>
          </div>
        </div>

        {/* Modal Body */}
        <div className="p-6 max-h-[70vh] overflow-y-auto">
          {error && (
            <div className="mb-4 p-3 bg-red-100 border border-red-200 text-red-700 rounded-lg">
              {error}
            </div>
          )}

          {/* Delete Confirmation */}
          {modalType === 'delete' && (
            <div className="text-center">
              <AlertTriangle className="h-16 w-16 text-red-500 mx-auto mb-4" />
              <h4 className="text-lg font-semibold text-gray-900 mb-2">
                Confirmer la fermeture du compte
              </h4>
              <p className="text-gray-600 mb-6">
                Êtes-vous sûr de vouloir fermer le compte <strong>{selectedCompte?.numeroCompte}</strong> ?
                Cette action est irréversible.
              </p>
              <div className="flex gap-3 justify-center">
                <button
                  onClick={resetModal}
                  className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
                >
                  Annuler
                </button>
                <button
                  onClick={() => deleteCompte(selectedCompte.id)}
                  disabled={isSubmitting}
                  className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 flex items-center gap-2"
                >
                  {isSubmitting && <Loader className="h-4 w-4 animate-spin" />}
                  Fermer le Compte
                </button>
              </div>
            </div>
          )}

          {/* View Details */}
          {modalType === 'view' && selectedCompte && (
            <div className="space-y-6">
              {/* Account Information */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-4">
                  <h4 className="font-semibold text-gray-900 border-b pb-2">Informations du Compte</h4>
                  
                  <div>
                    <label className="text-sm font-medium text-gray-600">Numéro de Compte</label>
                    <p className="text-lg font-mono font-bold text-gray-900">{selectedCompte.numeroCompte}</p>
                  </div>
                  
                  <div>
                    <label className="text-sm font-medium text-gray-600">Client</label>
                    <p className="text-gray-900">{selectedCompte.idClient}</p>
                  </div>
                  
                  <div>
                    <label className="text-sm font-medium text-gray-600">Agence</label>
                    <p className="text-gray-900">{selectedCompte.idAgence}</p>
                  </div>
                  
                  <div>
                    <label className="text-sm font-medium text-gray-600">Type de Compte</label>
                    <div className="mt-1">
                      <TypeBadge type={selectedCompte.type} />
                    </div>
                  </div>
                  
                  <div>
                    <label className="text-sm font-medium text-gray-600">Statut</label>
                    <div className="mt-1">
                      <StatusBadge status={selectedCompte.status} blocked={selectedCompte.blocked} />
                    </div>
                  </div>
                </div>
                
                <div className="space-y-4">
                  <h4 className="font-semibold text-gray-900 border-b pb-2">Informations Financières</h4>
                  
                  <div>
                    <label className="text-sm font-medium text-gray-600">Solde Actuel</label>
                    <p className="text-2xl font-bold text-green-600">
                      {new Intl.NumberFormat('fr-FR', {
                        style: 'currency',
                        currency: 'XAF',
                        minimumFractionDigits: 0
                      }).format(selectedCompte.solde || 0)}
                    </p>
                  </div>
                  
                  <div>
                    <label className="text-sm font-medium text-gray-600">Limite Retrait Journalier</label>
                    <p className="text-gray-900">
                      {new Intl.NumberFormat('fr-FR', {
                        style: 'currency',
                        currency: 'XAF',
                        minimumFractionDigits: 0
                      }).format(selectedCompte.limiteDailyWithdrawal || 0)}
                    </p>
                  </div>
                  
                  <div>
                    <label className="text-sm font-medium text-gray-600">Limite Transfert Journalier</label>
                    <p className="text-gray-900">
                      {new Intl.NumberFormat('fr-FR', {
                        style: 'currency',
                        currency: 'XAF',
                        minimumFractionDigits: 0
                      }).format(selectedCompte.limiteDailyTransfer || 0)}
                    </p>
                  </div>
                  
                  <div>
                    <label className="text-sm font-medium text-gray-600">Limite Mensuelle</label>
                    <p className="text-gray-900">
                      {new Intl.NumberFormat('fr-FR', {
                        style: 'currency',
                        currency: 'XAF',
                        minimumFractionDigits: 0
                      }).format(selectedCompte.limiteMonthlyOperations || 0)}
                    </p>
                  </div>
                </div>
              </div>

              {/* Transaction Statistics */}
              <div className="border-t pt-4">
                <h4 className="font-semibold text-gray-900 mb-4">Statistiques des Transactions</h4>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="bg-blue-50 p-4 rounded-lg">
                    <p className="text-sm text-blue-600 font-medium">Total Transactions</p>
                    <p className="text-2xl font-bold text-blue-900">{selectedCompte.totalTransactions || 0}</p>
                  </div>
                  <div className="bg-green-50 p-4 rounded-lg">
                    <p className="text-sm text-green-600 font-medium">Volume Total</p>
                    <p className="text-lg font-bold text-green-900">
                      {new Intl.NumberFormat('fr-FR', {
                        style: 'currency',
                        currency: 'XAF',
                        minimumFractionDigits: 0
                      }).format(selectedCompte.totalVolume || 0)}
                    </p>
                  </div>
                  <div className="bg-orange-50 p-4 rounded-lg">
                    <p className="text-sm text-orange-600 font-medium">Transactions Aujourd'hui</p>
                    <p className="text-2xl font-bold text-orange-900">{selectedCompte.dailyTransactionCount || 0}</p>
                  </div>
                </div>
              </div>

              {/* Dates */}
              <div className="border-t pt-4">
                <h4 className="font-semibold text-gray-900 mb-4">Historique</h4>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                  <div>
                    <label className="font-medium text-gray-600">Date de Création</label>
                    <p className="text-gray-900">
                      {selectedCompte.createdAt ? 
                        new Date(selectedCompte.createdAt).toLocaleString('fr-FR') : 
                        'Non disponible'
                      }
                    </p>
                  </div>
                  <div>
                    <label className="font-medium text-gray-600">Dernière Transaction</label>
                    <p className="text-gray-900">
                      {selectedCompte.lastTransactionAt ? 
                        new Date(selectedCompte.lastTransactionAt).toLocaleString('fr-FR') : 
                        'Aucune transaction'
                      }
                    </p>
                  </div>
                  {selectedCompte.activatedAt && (
                    <div>
                      <label className="font-medium text-gray-600">Date d'Activation</label>
                      <p className="text-gray-900">
                        {new Date(selectedCompte.activatedAt).toLocaleString('fr-FR')}
                      </p>
                    </div>
                  )}
                  {selectedCompte.blockedAt && (
                    <div>
                      <label className="font-medium text-gray-600">Date de Blocage</label>
                      <p className="text-gray-900">
                        {new Date(selectedCompte.blockedAt).toLocaleString('fr-FR')}
                      </p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Add/Edit Form */}
          {(modalType === 'add' || modalType === 'edit') && (
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Account Information */}
                <div className="space-y-4">
                  <h4 className="font-semibold text-gray-900 border-b pb-2">Informations de Base</h4>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Numéro de Compte *
                    </label>
                    <input
                      type="number"
                      value={formData.numeroCompte}
                      onChange={(e) => setFormData(prev => ({ ...prev, numeroCompte: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      required
                      placeholder="Ex: 1234567890"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      ID Client *
                    </label>
                    <input
                      type="text"
                      value={formData.idClient}
                      onChange={(e) => setFormData(prev => ({ ...prev, idClient: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      required
                      placeholder="Ex: CLIENT_001"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      ID Agence *
                    </label>
                    <input
                      type="text"
                      value={formData.idAgence}
                      onChange={(e) => setFormData(prev => ({ ...prev, idAgence: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      required
                      placeholder="Ex: AGENCE_001"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Type de Compte
                    </label>
                    <select
                      value={formData.type}
                      onChange={(e) => setFormData(prev => ({ ...prev, type: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="VIRTUELLE_GRATUITE">gratuite</option>
                      <option value="VIRTUELLE_PREMIUM">Premium</option>
                      <option value="PHYSIQUE">physique (a retirer au pres de l'agence)</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Statut
                    </label>
                    <select
                      value={formData.status}
                      onChange={(e) => setFormData(prev => ({ ...prev, status: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="PENDING">En attente</option>
                      <option value="ACTIVE">Actif</option>
                      <option value="SUSPENDED">Suspendu</option>
                      <option value="BLOCKED">Bloqué</option>
                    </select>
                  </div>
                </div>
                
                {/* Financial Information */}
                <div className="space-y-4">
                  <h4 className="font-semibold text-gray-900 border-b pb-2">Informations Financières</h4>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Solde Initial (XAF)
                    </label>
                    <input
                      type="number"
                      step="0.01"
                      min="0"
                      value={formData.solde}
                      onChange={(e) => setFormData(prev => ({ ...prev, solde: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="0"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Limite Retrait Journalier (XAF)
                    </label>
                    <input
                      type="number"
                      min="0"
                      value={formData.limiteDailyWithdrawal}
                      onChange={(e) => setFormData(prev => ({ ...prev, limiteDailyWithdrawal: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="1000000"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Limite Transfert Journalier (XAF)
                    </label>
                    <input
                      type="number"
                      min="0"
                      value={formData.limiteDailyTransfer}
                      onChange={(e) => setFormData(prev => ({ ...prev, limiteDailyTransfer: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="2000000"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Limite Opérations Mensuelles (XAF)
                    </label>
                    <input
                      type="number"
                      min="0"
                      value={formData.limiteMonthlyOperations}
                      onChange={(e) => setFormData(prev => ({ ...prev, limiteMonthlyOperations: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="10000000"
                    />
                  </div>
                </div>
              </div>

              {/* Form Actions */}
              <div className="flex gap-3 justify-end pt-4 border-t">
                <button
                  type="button"
                  onClick={resetModal}
                  className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2"
                >
                  {isSubmitting && <Loader className="h-4 w-4 animate-spin" />}
                  <Save className="h-4 w-4" />
                  {modalType === 'add' ? 'Créer le Compte' : 'Mettre à Jour'}
                </button>
              </div>
            </form>
          )}
          {modalType === 'createCard' && selectedCompte && (
            <form onSubmit={handleSubmitCard} className="space-y-6">
                
                {/* Account Information Display */}
                <div className="bg-blue-50 p-4 rounded-lg">
                <h4 className="font-semibold text-blue-900 mb-2">Compte Sélectionné</h4>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-2 text-sm">
                    <div><span className="font-medium">Compte:</span> {selectedCompte.numeroCompte}</div>
                    <div><span className="font-medium">Client:</span> {selectedCompte.idClient}</div>
                    <div><span className="font-medium">Agence:</span> {selectedCompte.idAgence}</div>
                </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Card Information */}
                <div className="space-y-4">
                    <h4 className="font-semibold text-gray-900 border-b pb-2">Informations Carte</h4>
                    
                    <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Type de Carte *</label>
                    <select
                        value={cardFormData.type}
                        onChange={(e) => {
                        const { value } = e.target;
                        setCardFormData(prev => ({ ...prev, type: value }));
                        }}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        required
                    >
                        <option value="VIRTUELLE_GRATUITE">Gratuite</option>
                        <option value="VIRTUELLE_PREMIUM">Premium</option>
                        <option value="PHYSIQUE">Physique</option>
                    </select>
                    </div>
                    
                    <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Nom du Porteur *</label>
                    <input
                        type="text"
                        value={cardFormData.nomPorteur}
                        onChange={(e) => {
                        const { value } = e.target;
                        setCardFormData(prev => ({ ...prev, nomPorteur: value }));
                        }}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        required
                        placeholder="Ex: JEAN DUPONT"
                        autoComplete="off"
                        spellCheck="false"
                    />
                    </div>
                    
                    <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Code PIN *</label>
                    <input
                        type="password"
                        value={cardFormData.codePin}
                        onChange={(e) => {
                        const { value } = e.target;
                        setCardFormData(prev => ({ ...prev, codePin: value }));
                        }}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        required
                        placeholder="4 chiffres"
                        minLength="4"
                        maxLength="4"
                        pattern="[0-9]{4}"
                        autoComplete="new-password"
                    />
                    </div>
                </div>
                
                {/* Limits and Options */}
                <div className="space-y-4">
                    <h4 className="font-semibold text-gray-900 border-b pb-2">Limites et Options</h4>
                    
                    <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Limite Achat Journalier (XAF)</label>
                    <input
                        type="number"
                        min="0"
                        value={cardFormData.limiteDailyPurchase}
                        onChange={(e) => {
                        const { value } = e.target;
                        setCardFormData(prev => ({ ...prev, limiteDailyPurchase: value }));
                        }}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        placeholder="500000"
                    />
                    </div>
                    
                    <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Limite Retrait Journalier (XAF)</label>
                    <input
                        type="number"
                        min="0"
                        value={cardFormData.limiteDailyWithdrawal}
                        onChange={(e) => {
                        const { value } = e.target;
                        setCardFormData(prev => ({ ...prev, limiteDailyWithdrawal: value }));
                        }}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        placeholder="200000"
                    />
                    </div>
                    
                    <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Limite Mensuelle (XAF)</label>
                    <input
                        type="number"
                        min="0"
                        value={cardFormData.limiteMonthly}
                        onChange={(e) => {
                        const { value } = e.target;
                        setCardFormData(prev => ({ ...prev, limiteMonthly: value }));
                        }}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        placeholder="2000000"
                    />
                    </div>
                    
                    {/* Options */}
                    <div className="space-y-3">
                    <div className="flex items-center">
                        <input
                        type="checkbox"
                        id="contactless"
                        checked={cardFormData.contactless}
                        onChange={(e) => {
                            const { checked } = e.target;
                            setCardFormData(prev => ({ ...prev, contactless: checked }));
                        }}
                        className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                        />
                        <label htmlFor="contactless" className="ml-2 text-sm text-gray-700">Paiement sans contact</label>
                    </div>
                    
                    <div className="flex items-center">
                        <input
                        type="checkbox"
                        id="international"
                        checked={cardFormData.internationalPayments}
                        onChange={(e) => {
                            const { checked } = e.target;
                            setCardFormData(prev => ({ ...prev, internationalPayments: checked }));
                        }}
                        className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                        />
                        <label htmlFor="international" className="ml-2 text-sm text-gray-700">Paiements internationaux</label>
                    </div>
                    
                    <div className="flex items-center">
                        <input
                        type="checkbox"
                        id="online"
                        checked={cardFormData.onlinePayments}
                        onChange={(e) => {
                            const { checked } = e.target;
                            setCardFormData(prev => ({ ...prev, onlinePayments: checked }));
                        }}
                        className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                        />
                        <label htmlFor="online" className="ml-2 text-sm text-gray-700">Paiements en ligne</label>
                    </div>
                    </div>
                </div>
                </div>

                {/* Form Actions */}
                <div className="flex gap-3 justify-end pt-4 border-t">
                <button
                    type="button"
                    onClick={resetModal}
                    className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
                >
                    Annuler
                </button>
                <button
                    type="submit"
                    disabled={isSubmitting}
                    className="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50 flex items-center gap-2"
                >
                    {isSubmitting && <Loader className="h-4 w-4 animate-spin" />}
                    <CreditCard className="h-4 w-4" />
                    Créer la Carte
                </button>
                </div>
            </form>
            )}
        </div>
      </div>
    </div>
  );

  
  // =====================================
  // MAIN RENDER
  // =====================================

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Gestion des Comptes</h1>
          <p className="text-gray-600 mt-1">
            Administration des comptes bancaires et de leurs paramètres
          </p>
        </div>
        
        <div className="flex items-center gap-3">
          <button className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 flex items-center gap-2">
            <Download className="h-4 w-4" />
            Exporter
          </button>
        </div>
      </div>

      {/* Statistics Cards */}
      <StatisticsCards />

      {/* Search and Filters */}
      <SearchAndFilters />

      {/* Comptes Table */}
      <ComptesTable />

      {/* Modal */}
      {showModal && <CompteFormModal />}
    </div>
  );
};

export default CompteManagement;