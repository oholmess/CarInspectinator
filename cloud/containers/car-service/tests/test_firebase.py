"""
Tests for Firebase initialization and client management.
"""
import pytest
from unittest.mock import patch, MagicMock


class TestInitializeFirebase:
    """Tests for initialize_firebase function."""
    
    def test_initialize_firebase_in_gcp(self):
        """Test Firebase initialization in GCP environment."""
        with patch.dict('os.environ', {'GOOGLE_CLOUD_PROJECT': 'test-project'}), \
             patch('app.firebase.firebase_admin') as mock_admin, \
             patch('app.firebase.firestore') as mock_firestore:
            
            mock_admin._apps = {}  # No apps initialized
            mock_db = MagicMock()
            mock_firestore.client.return_value = mock_db
            
            # Reset module state
            import app.firebase
            app.firebase._db = None
            
            from app.firebase import initialize_firebase
            initialize_firebase()
            
            mock_admin.initialize_app.assert_called_once()
    
    def test_initialize_firebase_local_with_credentials(self, tmp_path):
        """Test Firebase initialization with service account file."""
        # Create a mock credentials file
        cred_file = tmp_path / "credentials.json"
        cred_file.write_text('{"type": "service_account"}')
        
        with patch.dict('os.environ', {
            'GOOGLE_CLOUD_PROJECT': '',
            'GOOGLE_APPLICATION_CREDENTIALS': str(cred_file)
        }), \
             patch('app.firebase.firebase_admin') as mock_admin, \
             patch('app.firebase.firestore') as mock_firestore, \
             patch('app.firebase.credentials') as mock_creds:
            
            mock_admin._apps = {}
            mock_db = MagicMock()
            mock_firestore.client.return_value = mock_db
            
            import app.firebase
            app.firebase._db = None
            
            from app.firebase import initialize_firebase
            initialize_firebase()
            
            mock_creds.Certificate.assert_called_once()
    
    def test_initialize_firebase_already_initialized(self):
        """Test that initialize_firebase is idempotent."""
        with patch('app.firebase.firebase_admin') as mock_admin, \
             patch('app.firebase.firestore') as mock_firestore:
            
            mock_db = MagicMock()
            
            import app.firebase
            app.firebase._db = mock_db  # Already initialized
            
            from app.firebase import initialize_firebase
            initialize_firebase()
            
            # Should not try to initialize again
            mock_admin.initialize_app.assert_not_called()


class TestGetFirestoreClient:
    """Tests for get_firestore_client function."""
    
    def test_get_firestore_client_success(self):
        """Test successful client retrieval."""
        mock_db = MagicMock()
        
        import app.firebase
        app.firebase._db = mock_db
        
        from app.firebase import get_firestore_client
        result = get_firestore_client()
        
        assert result == mock_db
    
    def test_get_firestore_client_not_initialized(self):
        """Test error when Firebase not initialized."""
        import app.firebase
        app.firebase._db = None
        
        from app.firebase import get_firestore_client
        
        with pytest.raises(RuntimeError) as exc_info:
            get_firestore_client()
        
        assert "not initialized" in str(exc_info.value)

