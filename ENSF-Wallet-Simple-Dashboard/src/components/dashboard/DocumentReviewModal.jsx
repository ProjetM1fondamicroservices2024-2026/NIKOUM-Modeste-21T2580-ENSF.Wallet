import React, { useState, useEffect } from 'react';
import { 
  X, CheckCircle, XCircle, Loader, Calendar, Clock, User, Eye,
  AlertTriangle, Shield, Image as ImageIcon
} from 'lucide-react';
import ApiService from '../../services/ApiService';

/**
 * 📋 Document Review Modal Component
 * 
 * Fetches and displays complete document review data from backend
 * Shows document images, extracted info, and verification scores
 */
const DocumentReviewModal = ({ documentId, onClose, onApprove, onReject, isLoading }) => {
  const [reviewData, setReviewData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [comment, setComment] = useState('');

  // =====================================
  // API INTEGRATION
  // =====================================

  /**
   * Fetch complete document review data
   */
  const fetchDocumentReview = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await ApiService.agenceService.getDocumentReview(documentId);
      
      if (response.success) {
        setReviewData(response.data);
        console.log('✅ Document review data fetched');
      } else {
        setError(response.error || 'Erreur lors du chargement');
      }
    } catch (err) {
      console.error('❌ Error fetching document review:', err);
      setError('Erreur de connexion au serveur');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (documentId) {
      fetchDocumentReview();
    }
  }, [documentId]);

  // =====================================
  // UI HELPERS
  // =====================================

  /**
   * Get status badge styling
   */
  const getStatusBadge = (status) => {
    const styles = {
      PENDING: 'bg-yellow-100 text-yellow-800 border-yellow-200',
      RECEIVED: 'bg-blue-100 text-blue-800 border-blue-200',
      UNDER_REVIEW: 'bg-orange-100 text-orange-800 border-orange-200',
      APPROVED: 'bg-green-100 text-green-800 border-green-200',
      REJECTED: 'bg-red-100 text-red-800 border-red-200',
      EXPIRED: 'bg-gray-100 text-gray-800 border-gray-200'
    };
    return styles[status] || styles.PENDING;
  };

  /**
   * Get score color based on value
   */
  const getScoreColor = (score) => {
    if (score >= 80) return 'text-green-600';
    if (score >= 60) return 'text-yellow-600';
    return 'text-red-600';
  };

  // =====================================
  // RENDER FUNCTIONS
  // =====================================

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-xl p-8 text-center">
          <Loader className="h-8 w-8 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-gray-600">Chargement des détails du document...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-xl p-8 text-center max-w-md">
          <AlertTriangle className="h-8 w-8 text-red-600 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-900 mb-2">Erreur</h3>
          <p className="text-red-600 mb-4">{error}</p>
          <button
            onClick={onClose}
            className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700"
          >
            Fermer
          </button>
        </div>
      </div>
    );
  }

  if (!reviewData) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-2xl max-w-6xl w-full mx-4 max-h-[95vh] overflow-hidden">
        
        {/* Modal Header */}
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-900">Examen Détaillé du Document</h3>
              <p className="text-sm text-gray-600 mt-1">CNI: {reviewData.cni}</p>
            </div>
            <button
              onClick={onClose}
              className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>

        {/* Modal Content */}
        <div className="flex">
          
          {/* Left Panel - Document Images */}
          <div className="w-1/2 p-6 border-r border-gray-200">
            <h4 className="font-medium text-gray-900 mb-4">Images du Document</h4>
            
            <div className="space-y-4">
              {/* Recto Image */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Face Recto
                </label>
                <div className="border border-gray-300 rounded-lg overflow-hidden bg-gray-50">
                  {reviewData.rectoImageBase64 ? (
                    <img 
                      src={reviewData.rectoImageBase64} 
                      alt="Document Recto"
                      className="w-full h-48 object-contain"
                    />
                  ) : (
                    <div className="w-full h-48 flex items-center justify-center">
                      <ImageIcon className="h-8 w-8 text-gray-400" />
                      <span className="ml-2 text-gray-500">Image non disponible</span>
                    </div>
                  )}
                </div>
              </div>

              {/* Verso Image */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Face Verso
                </label>
                <div className="border border-gray-300 rounded-lg overflow-hidden bg-gray-50">
                  {reviewData.versoImageBase64 ? (
                    <img 
                      src={reviewData.versoImageBase64} 
                      alt="Document Verso"
                      className="w-full h-48 object-contain"
                    />
                  ) : (
                    <div className="w-full h-48 flex items-center justify-center">
                      <ImageIcon className="h-8 w-8 text-gray-400" />
                      <span className="ml-2 text-gray-500">Image non disponible</span>
                    </div>
                  )}
                </div>
              </div>

              {/* Selfie Image */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Selfie Utilisateur
                </label>
                <div className="border border-gray-300 rounded-lg overflow-hidden bg-gray-50">
                  {reviewData.selfieImageBase64 ? (
                    <img 
                      src={reviewData.selfieImageBase64} 
                      alt="Selfie Utilisateur"
                      className="w-full h-48 object-contain"
                    />
                  ) : (
                    <div className="w-full h-48 flex items-center justify-center">
                      <User className="h-8 w-8 text-gray-400" />
                      <span className="ml-2 text-gray-500">Selfie non disponible</span>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Right Panel - Document Information */}
          <div className="w-1/2 p-6 overflow-y-auto max-h-[80vh]">
            
            {/* Extracted Information */}
            <div className="mb-6">
              <h4 className="font-medium text-gray-900 border-b border-gray-200 pb-2 mb-4">
                Informations Extraites
              </h4>
              
              <div className="space-y-3">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="text-xs font-medium text-gray-500 uppercase">Nom</label>
                    <div className="text-sm text-gray-900 font-medium">{reviewData.nomExtrait}</div>
                  </div>
                  <div>
                    <label className="text-xs font-medium text-gray-500 uppercase">Prénom</label>
                    <div className="text-sm text-gray-900 font-medium">{reviewData.prenomExtrait}</div>
                  </div>
                </div>
                
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Date de Naissance</label>
                  <div className="text-sm text-gray-900">
                    {reviewData.dateNaissanceExtraite ? 
                      new Date(reviewData.dateNaissanceExtraite).toLocaleDateString('fr-FR') : 
                      'Non extraite'
                    }
                  </div>
                </div>
                
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Lieu de Naissance</label>
                  <div className="text-sm text-gray-900">{reviewData.lieuNaissanceExtrait || 'Non extrait'}</div>
                </div>
              </div>
            </div>

            {/* Verification Scores */}
            <div className="mb-6">
              <h4 className="font-medium text-gray-900 border-b border-gray-200 pb-2 mb-4">
                Scores de Vérification
              </h4>
              
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Qualité Document</span>
                  <span className={`text-sm font-medium ${getScoreColor(reviewData.qualityScore)}`}>
                    {reviewData.qualityScore}%
                  </span>
                </div>
                
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Qualité Selfie</span>
                  <span className={`text-sm font-medium ${getScoreColor(reviewData.selfieQualityScore)}`}>
                    {reviewData.selfieQualityScore}%
                  </span>
                </div>
                
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Similarité Faciale</span>
                  <span className={`text-sm font-medium ${getScoreColor(reviewData.selfieSimilarityScore)}`}>
                    {reviewData.selfieSimilarityScore}%
                  </span>
                </div>
                
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Détection de Vie</span>
                  <span className={`text-sm font-medium ${reviewData.livenessDetected ? 'text-green-600' : 'text-red-600'}`}>
                    {reviewData.livenessDetected ? 'Détectée' : 'Non détectée'}
                  </span>
                </div>
              </div>
            </div>

            {/* Status and Metadata */}
            <div className="mb-6">
              <h4 className="font-medium text-gray-900 border-b border-gray-200 pb-2 mb-4">
                Statut et Métadonnées
              </h4>
              
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Statut</span>
                  <span className={`px-2 py-1 rounded-full text-xs font-medium border ${getStatusBadge(reviewData.status)}`}>
                    {reviewData.status}
                  </span>
                </div>
                
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Date Upload</span>
                  <span className="text-sm text-gray-900">
                    {new Date(reviewData.uploadedAt).toLocaleString('fr-FR')}
                  </span>
                </div>
              </div>
            </div>

            {/* Anomalies */}
            {(reviewData.anomaliesDetectees?.length > 0 || reviewData.selfieAnomalies?.length > 0) && (
              <div className="mb-6">
                <h4 className="font-medium text-gray-900 border-b border-gray-200 pb-2 mb-4">
                  Anomalies Détectées
                </h4>
                
                {reviewData.anomaliesDetectees?.length > 0 && (
                  <div className="mb-3">
                    <label className="text-xs font-medium text-red-600 uppercase">Document</label>
                    <ul className="text-sm text-red-700 list-disc list-inside">
                      {reviewData.anomaliesDetectees.map((anomaly, index) => (
                        <li key={index}>{anomaly}</li>
                      ))}
                    </ul>
                  </div>
                )}
                
                {reviewData.selfieAnomalies?.length > 0 && (
                  <div>
                    <label className="text-xs font-medium text-red-600 uppercase">Selfie</label>
                    <ul className="text-sm text-red-700 list-disc list-inside">
                      {reviewData.selfieAnomalies.map((anomaly, index) => (
                        <li key={index}>{anomaly}</li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            )}

            {/* Recommendation */}
            {reviewData.facialVerificationRecommendation && (
              <div className="mb-6">
                <h4 className="font-medium text-gray-900 border-b border-gray-200 pb-2 mb-4">
                  Recommandation
                </h4>
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
                  <p className="text-sm text-blue-800">{reviewData.facialVerificationRecommendation}</p>
                </div>
              </div>
            )}

            {/* Comment Section */}
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Commentaire Administrateur
              </label>
              <textarea
                value={comment}
                onChange={(e) => setComment(e.target.value)}
                placeholder="Ajouter un commentaire sur la décision..."
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
              />
            </div>
          </div>
        </div>

        {/* Modal Footer */}
        <div className="px-6 py-4 border-t border-gray-200 bg-gray-50">
          <div className="flex items-center justify-end gap-3">
            <button
              onClick={onClose}
              disabled={isLoading}
              className="px-4 py-2 text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50"
            >
              Annuler
            </button>
            
            <button
              onClick={() => onReject(reviewData.id, comment)}
              disabled={isLoading}
              className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50"
            >
              {isLoading ? <Loader className="h-4 w-4 animate-spin" /> : <XCircle className="h-4 w-4" />}
              Rejeter
            </button>
            
            <button
              onClick={() => onApprove(reviewData.id, comment)}
              disabled={isLoading}
              className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
            >
              {isLoading ? <Loader className="h-4 w-4 animate-spin" /> : <CheckCircle className="h-4 w-4" />}
              Approuver
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DocumentReviewModal;