import React, { useState, useEffect } from 'react';
import { 
  Building2, Plus, Edit, Trash2, Eye, Search, RefreshCw, Loader,
  X, MapPin, Phone, Mail, DollarSign, Calendar, AlertTriangle,
  CheckCircle, XCircle, Save
} from 'lucide-react';
import ApiService from '../../services/ApiService';

/**
 * 🏢 Agency Management Component
 * 
 * Complete CRUD operations for agencies:
 * ✅ View all agencies with search/filter
 * ✅ Add new agency
 * ✅ Edit existing agency
 * ✅ Delete agency
 * ✅ View agency details
 */
const AgencyManagement = () => {
  // =====================================
  // STATE MANAGEMENT
  // =====================================
  
  const [agencies, setAgencies] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Modal states
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState(''); // 'add', 'edit', 'view', 'delete'
  const [selectedAgency, setSelectedAgency] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  // Form data for add/edit
  const [formData, setFormData] = useState({
    codeAgence: '',
    nom: '',
    adresse: '',
    ville: '',
    email: '',
    telephone: '',
    capital: '',
    soldeDisponible: '',
    limiteDailyTransactions: '50000000',
    limiteMonthlyTransactions: '500000000'
  });

  // =====================================
  // API INTEGRATION
  // =====================================

  /**
   * Fetch all agencies
   */
  const fetchAgencies = async () => {
    try {
      setLoading(true);
      setError(null);
        console.log('🏢 Fetching all agencies...');
      const response = await ApiService.agenceService.getAllAgencies();
      
      if (response.success) {
        setAgencies(response.data || []);
      } else {
        setError(response.error || 'Erreur lors du chargement des agences');
      }
    } catch (err) {
      console.error('❌ Error fetching agencies:', err);
      setError('Erreur de connexion au serveur');
    } finally {
      setLoading(false);
    }
  };

  /**
   * Create new agency
   */
  const createAgency = async (agencyData) => {
    try {
      setIsSubmitting(true);
      
      const response = await ApiService.agenceService.createAgency(agencyData);
      
      if (response.success) {
        showNotification('success', 'Agence créée avec succès');
        fetchAgencies(); // Refresh list
        closeModal();
        return true;
      } else {
        setError(response.error || 'Erreur lors de la création');
        return false;
      }
    } catch (err) {
      console.error('❌ Error creating agency:', err);
      setError('Erreur lors de la création de l\'agence');
      return false;
    } finally {
      setIsSubmitting(false);
    }
  };

  /**
   * Update existing agency
   */
  const updateAgency = async (agencyId, agencyData) => {
    try {
      setIsSubmitting(true);
      
      const response = await ApiService.agenceService.updateAgency(agencyId, agencyData);
      
      if (response.success) {
        showNotification('success', 'Agence mise à jour avec succès');
        fetchAgencies(); // Refresh list
        closeModal();
        return true;
      } else {
        setError(response.error || 'Erreur lors de la mise à jour');
        return false;
      }
    } catch (err) {
      console.error('❌ Error updating agency:', err);
      setError('Erreur lors de la mise à jour de l\'agence');
      return false;
    } finally {
      setIsSubmitting(false);
    }
  };

  /**
   * Delete agency
   */
  const deleteAgency = async (agencyId) => {
    try {
      setIsSubmitting(true);
      
      const response = await ApiService.agenceService.deleteAgency(agencyId);
      
      if (response.success) {
        showNotification('success', 'Agence supprimée avec succès');
        fetchAgencies(); // Refresh list
        closeModal();
        return true;
      } else {
        setError(response.error || 'Erreur lors de la suppression');
        return false;
      }
    } catch (err) {
      console.error('❌ Error deleting agency:', err);
      setError('Erreur lors de la suppression de l\'agence');
      return false;
    } finally {
      setIsSubmitting(false);
    }
  };

  // =====================================
  // UI HELPERS
  // =====================================

  /**
   * Show notification (you can implement this with toast library)
   */
  const showNotification = (type, message) => {
    // Simple console log for now - implement with toast library later
    console.log(`${type.toUpperCase()}: ${message}`);
  };

  /**
   * Open modal
   */
  const openModal = (type, agency = null) => {
    setModalType(type);
    setSelectedAgency(agency);
    setShowModal(true);
    setError(null);
    
    if (type === 'add') {
      setFormData({
        codeAgence: '',
        nom: '',
        adresse: '',
        ville: '',
        email: '',
        telephone: '',
        capital: '',
        soldeDisponible: '',
        limiteDailyTransactions: '50000000',
        limiteMonthlyTransactions: '500000000'
      });
    } else if (type === 'edit' && agency) {
      setFormData({
        codeAgence: agency.codeAgence || '',
        nom: agency.nom || '',
        adresse: agency.adresse || '',
        ville: agency.ville || '',
        email: agency.email || '',
        telephone: agency.telephone || '',
        capital: agency.capital?.toString() || '',
        soldeDisponible: agency.soldeDisponible?.toString() || '',
        limiteDailyTransactions: agency.limiteDailyTransactions?.toString() || '50000000',
        limiteMonthlyTransactions: agency.limiteMonthlyTransactions?.toString() || '500000000'
      });
    }
  };

  /**
   * Close modal
   */
  const closeModal = () => {
    setShowModal(false);
    setModalType('');
    setSelectedAgency(null);
    setError(null);
  };

  /**
   * Handle form submission
   */
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Basic validation
    if (!formData.codeAgence || !formData.nom || !formData.ville) {
      setError('Veuillez remplir tous les champs obligatoires');
      return;
    }
    
    // Prepare data
    const agencyData = {
      ...formData,
      capital: parseFloat(formData.capital) || 0,
      soldeDisponible: parseFloat(formData.soldeDisponible) || 0,
      limiteDailyTransactions: parseFloat(formData.limiteDailyTransactions) || 50000000,
      limiteMonthlyTransactions: parseFloat(formData.limiteMonthlyTransactions) || 500000000
    };
    
    if (modalType === 'add') {
      await createAgency(agencyData);
    } else if (modalType === 'edit') {
      await updateAgency(selectedAgency.idAgence, agencyData);
    } 
  };

  /**
   * Filter agencies based on search term
   */
  const filteredAgencies = agencies.filter(agency =>
    agency.nom?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    agency.codeAgence?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    agency.ville?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // =====================================
  // EFFECTS
  // =====================================

  useEffect(() => {
    fetchAgencies();
  }, []);

  // =====================================
  // RENDER COMPONENTS
  // =====================================

  /**
   * Agency Status Badge
   */
  const StatusBadge = ({ status }) => {
    const styles = {
      ACTIVE: 'bg-green-100 text-green-800 border-green-200',
      INACTIVE: 'bg-gray-100 text-gray-800 border-gray-200',
      SUSPENDED: 'bg-red-100 text-red-800 border-red-200'
    };
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium border ${styles[status] || styles.ACTIVE}`}>
        {status || 'ACTIVE'}
      </span>
    );
  };

  /**
   * Agency Form Modal
   */
  const AgencyFormModal = () => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-hidden">
        
        {/* Modal Header */}
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900">
              {modalType === 'add' ? 'Nouvelle Agence' : 
               modalType === 'edit' ? 'Modifier Agence' :
               modalType === 'view' ? 'Détails Agence' : 'Supprimer Agence'}
               
            </h3>
            <button onClick={closeModal} className="p-2 text-gray-400 hover:text-gray-600 rounded-lg">
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>

        {/* Modal Content */}
        <div className="p-6 overflow-y-auto max-h-[70vh]">
          
          {/* Error Display */}
          {error && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
              <div className="flex items-center gap-2">
                <AlertTriangle className="h-4 w-4 text-red-600" />
                <span className="text-red-700 text-sm">{error}</span>
              </div>
            </div>
          )}

          {modalType === 'delete' ? (
            // Delete Confirmation
            <div className="text-center">
              <AlertTriangle className="h-12 w-12 text-red-600 mx-auto mb-4" />
              <h4 className="text-lg font-semibold text-gray-900 mb-2">Confirmer la suppression</h4>
              <p className="text-gray-600 mb-6">
                Êtes-vous sûr de vouloir supprimer l'agence <strong>{selectedAgency?.nom}</strong> ?
                Cette action est irréversible.
              </p>
              <div className="flex justify-center gap-3">
                <button onClick={closeModal} className="px-4 py-2 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300">
                  Annuler
                </button>
                <button
                  onClick={() => deleteAgency(selectedAgency?.idAgence)}
                  disabled={isSubmitting}
                  className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50"
                >
                  {isSubmitting ? <Loader className="h-4 w-4 animate-spin" /> : <Trash2 className="h-4 w-4" />}
                  Supprimer
                </button>
              </div>
            </div>
          ) : modalType === 'view' ? (
            // View Details
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Code Agence</label>
                  <div className="text-sm text-gray-900 font-mono">{selectedAgency?.codeAgence}</div>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Nom</label>
                  <div className="text-sm text-gray-900">{selectedAgency?.nom}</div>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Ville</label>
                  <div className="text-sm text-gray-900">{selectedAgency?.ville}</div>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Statut</label>
                  <div className="mt-1"><StatusBadge status={selectedAgency?.status} /></div>
                </div>
                <div className="md:col-span-2">
                  <label className="text-xs font-medium text-gray-500 uppercase">Adresse</label>
                  <div className="text-sm text-gray-900">{selectedAgency?.adresse}</div>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Email</label>
                  <div className="text-sm text-gray-900">{selectedAgency?.email}</div>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Téléphone</label>
                  <div className="text-sm text-gray-900">{selectedAgency?.telephone}</div>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Capital</label>
                  <div className="text-sm text-gray-900">{selectedAgency?.capital?.toLocaleString()} FCFA</div>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Solde Disponible</label>
                  <div className="text-sm text-gray-900">{selectedAgency?.soldeDisponible?.toLocaleString()} FCFA</div>
                </div>
              </div>
            </div>
          ) : (
            // Add/Edit Form
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Code Agence *
                  </label>
                  <input
                    type="text"
                    value={formData.codeAgence}
                    onChange={(e) => setFormData(prev => ({ ...prev, codeAgence: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    placeholder="Ex: AG001"
                    maxLength={10}
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Nom Agence *
                  </label>
                  <input
                    type="text"
                    value={formData.nom}
                    onChange={(e) => setFormData(prev => ({ ...prev, nom: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    placeholder="Nom de l'agence"
                    maxLength={100}
                    required
                  />
                </div>
                
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Adresse *
                  </label>
                  <input
                    type="text"
                    value={formData.adresse}
                    onChange={(e) => setFormData(prev => ({ ...prev, adresse: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    placeholder="Adresse complète"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Ville *
                  </label>
                  <input
                    type="text"
                    value={formData.ville}
                    onChange={(e) => setFormData(prev => ({ ...prev, ville: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    placeholder="Ville"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Email
                  </label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    placeholder="email@example.com"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Téléphone *
                  </label>
                  <input
                    type="tel"
                    value={formData.telephone}
                    onChange={(e) => setFormData(prev => ({ ...prev, telephone: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    placeholder="+237 6XX XXX XXX"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Capital (FCFA)
                  </label>
                  <input
                    type="number"
                    value={formData.capital}
                    onChange={(e) => setFormData(prev => ({ ...prev, capital: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    placeholder="0"
                    min="0"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Solde Disponible (FCFA)
                  </label>
                  <input
                    type="number"
                    value={formData.soldeDisponible}
                    onChange={(e) => setFormData(prev => ({ ...prev, soldeDisponible: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    placeholder="0"
                    min="0"
                  />
                </div>
              </div>
            </form>
          )}
        </div>

        {/* Modal Footer */}
        {(modalType === 'add' || modalType === 'edit') && (
          <div className="px-6 py-4 border-t border-gray-200 bg-gray-50">
            <div className="flex justify-end gap-3">
              <button
                type="button"
                onClick={closeModal}
                className="px-4 py-2 text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50"
              >
                Annuler
              </button>
              <button
                onClick={handleSubmit}
                disabled={isSubmitting}
                className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                {isSubmitting ? <Loader className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
                {modalType === 'add' ? 'Créer' : 'Modifier'}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );

  // =====================================
  // MAIN RENDER
  // =====================================

  return (
    <div className="space-y-6">
      
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Gestion des Agences</h2>
          <p className="text-gray-600 mt-1">Administration et configuration des agences</p>
        </div>
        <button
          onClick={() => openModal('add')}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          <Plus className="h-4 w-4" />
          Nouvelle Agence
        </button>
      </div>

      {/* Search and Controls */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
        <div className="flex flex-col sm:flex-row gap-4 items-center">
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Rechercher par nom, code ou ville..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
          <button
            onClick={fetchAgencies}
            disabled={loading}
            className="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 disabled:opacity-50"
          >
            <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
            Actualiser
          </button>
        </div>
      </div>

      {/* Agencies Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        {loading ? (
          <div className="flex items-center justify-center py-12">
            <Loader className="h-8 w-8 animate-spin text-blue-600" />
            <span className="ml-3 text-gray-600">Chargement des agences...</span>
          </div>
        ) : filteredAgencies.length === 0 ? (
          <div className="text-center py-12">
            <Building2 className="h-12 w-12 mx-auto text-gray-300 mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune agence trouvée</h3>
            <p className="text-gray-500 mb-4">
              {searchTerm ? 'Aucune agence ne correspond à votre recherche.' : 'Commencez par créer votre première agence.'}
            </p>
            <button
              onClick={() => openModal('add')}
              className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              <Plus className="h-4 w-4" />
              Créer une agence
            </button>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nom</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Localisation</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Contact</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Statut</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredAgencies.map((agency) => (
                  <tr key={agency.idAgence} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-mono text-gray-900">{agency.codeAgence}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">{agency.nom}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center text-sm text-gray-500">
                        <MapPin className="h-4 w-4 mr-2" />
                        {agency.ville}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{agency.telephone}</div>
                      <div className="text-sm text-gray-500">{agency.email}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <StatusBadge status={agency.status} />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right space-x-2">
                      <button
                        onClick={() => openModal('view', agency)}
                        className="inline-flex items-center gap-1 px-2 py-1 text-blue-600 hover:bg-blue-50 rounded"
                      >
                        <Eye className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => openModal('edit', agency)}
                        className="inline-flex items-center gap-1 px-2 py-1 text-green-600 hover:bg-green-50 rounded"
                      >
                        <Edit className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => openModal('delete', agency)}
                        className="inline-flex items-center gap-1 px-2 py-1 text-red-600 hover:bg-red-50 rounded"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal */}
      {showModal && <AgencyFormModal />}
    </div>
  );
};

export default AgencyManagement;