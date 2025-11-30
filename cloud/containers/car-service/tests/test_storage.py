"""
Tests for Google Cloud Storage utilities.
"""
import pytest
from unittest.mock import patch, MagicMock
import os


class TestGetStorageClient:
    """Tests for get_storage_client function."""
    
    def test_get_storage_client_returns_client(self):
        """Test that get_storage_client returns a client."""
        with patch('app.storage.storage.Client') as mock_client_class:
            mock_client = MagicMock()
            mock_client_class.return_value = mock_client
            
            from app.storage import get_storage_client
            result = get_storage_client()
            
            mock_client_class.assert_called_once()
            assert result == mock_client


class TestGenerateSignedUrl:
    """Tests for generate_signed_url function."""
    
    def test_generate_signed_url_success(self, mock_storage):
        """Test successful signed URL generation."""
        from app.storage import generate_signed_url
        
        result = generate_signed_url("models/test.usdz")
        
        assert result == "https://storage.googleapis.com/signed-url"
    
    def test_generate_signed_url_blob_not_exists(self):
        """Test signed URL generation when blob doesn't exist."""
        with patch('app.storage.storage.Client') as mock_client_class:
            mock_bucket = MagicMock()
            mock_blob = MagicMock()
            mock_blob.exists.return_value = False
            mock_bucket.blob.return_value = mock_blob
            mock_client_class.return_value.bucket.return_value = mock_bucket
            
            from app.storage import generate_signed_url
            result = generate_signed_url("models/nonexistent.usdz")
            
            assert result is None
    
    def test_generate_signed_url_error(self):
        """Test signed URL generation handles errors."""
        with patch('app.storage.storage.Client') as mock_client_class:
            mock_client_class.side_effect = Exception("Storage error")
            
            from app.storage import generate_signed_url
            result = generate_signed_url("models/test.usdz")
            
            assert result is None
    
    def test_generate_signed_url_no_bucket(self):
        """Test signed URL generation with no bucket configured."""
        with patch('app.storage.STORAGE_BUCKET', ''):
            from app.storage import generate_signed_url
            result = generate_signed_url("models/test.usdz", bucket_name='')
            
            assert result is None


class TestGetModelUrlForVolumeId:
    """Tests for get_model_url_for_volume_id function."""
    
    def test_get_model_url_success(self, mock_storage):
        """Test successful model URL retrieval."""
        from app.storage import get_model_url_for_volume_id
        
        result = get_model_url_for_volume_id("bmw_m3")
        
        assert result is not None
        assert "storage.googleapis.com" in result
    
    def test_get_model_url_empty_volume_id(self):
        """Test with empty volume ID."""
        from app.storage import get_model_url_for_volume_id
        
        result = get_model_url_for_volume_id("")
        
        assert result is None
    
    def test_get_model_url_none_volume_id(self):
        """Test with None volume ID."""
        from app.storage import get_model_url_for_volume_id
        
        result = get_model_url_for_volume_id(None)
        
        assert result is None


class TestUploadModel:
    """Tests for upload_model function."""
    
    def test_upload_model_success(self, mock_storage, tmp_path):
        """Test successful model upload."""
        # Create a temporary file
        test_file = tmp_path / "test.usdz"
        test_file.write_text("test content")
        
        from app.storage import upload_model
        result = upload_model(str(test_file), "test_volume")
        
        assert result is True
        mock_storage['blob'].upload_from_filename.assert_called_once()
    
    def test_upload_model_file_not_found(self):
        """Test upload_model with non-existent file."""
        from app.storage import upload_model
        result = upload_model("/nonexistent/path/model.usdz", "test_volume")
        
        assert result is False
    
    def test_upload_model_error(self, mock_storage, tmp_path):
        """Test upload_model handles errors."""
        test_file = tmp_path / "test.usdz"
        test_file.write_text("test content")
        
        mock_storage['blob'].upload_from_filename.side_effect = Exception("Upload error")
        
        from app.storage import upload_model
        result = upload_model(str(test_file), "test_volume")
        
        assert result is False


class TestDeleteModel:
    """Tests for delete_model function."""
    
    def test_delete_model_success(self, mock_storage):
        """Test successful model deletion."""
        from app.storage import delete_model
        result = delete_model("test_volume")
        
        assert result is True
        mock_storage['blob'].delete.assert_called_once()
    
    def test_delete_model_error(self, mock_storage):
        """Test delete_model handles errors."""
        mock_storage['blob'].delete.side_effect = Exception("Delete error")
        
        from app.storage import delete_model
        result = delete_model("test_volume")
        
        assert result is False


class TestModelExists:
    """Tests for model_exists function."""
    
    def test_model_exists_true(self, mock_storage):
        """Test model_exists returns True when model exists."""
        mock_storage['blob'].exists.return_value = True
        
        from app.storage import model_exists
        result = model_exists("test_volume")
        
        assert result is True
    
    def test_model_exists_false(self, mock_storage):
        """Test model_exists returns False when model doesn't exist."""
        mock_storage['blob'].exists.return_value = False
        
        from app.storage import model_exists
        result = model_exists("test_volume")
        
        assert result is False
    
    def test_model_exists_error(self, mock_storage):
        """Test model_exists handles errors."""
        mock_storage['blob'].exists.side_effect = Exception("Error")
        
        from app.storage import model_exists
        result = model_exists("test_volume")
        
        assert result is False

