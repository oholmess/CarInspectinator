"""Google Cloud Storage utilities for managing car 3D models."""
from __future__ import annotations

import os
import logging
from datetime import timedelta
from typing import Optional

from google.cloud import storage

logger = logging.getLogger(__name__)

# Environment variables
STORAGE_BUCKET = os.getenv("STORAGE_BUCKET", "carinspectinator-car-models")
MODEL_URL_EXPIRATION_HOURS = int(os.getenv("MODEL_URL_EXPIRATION_HOURS", "24"))


def get_storage_client() -> storage.Client:
    """Get Google Cloud Storage client.
    
    Returns:
        Storage client instance
    """
    return storage.Client()


def generate_signed_url(
    blob_name: str,
    bucket_name: Optional[str] = None,
    expiration_hours: Optional[int] = None
) -> Optional[str]:
    """Generate a signed URL for a GCS object.
    
    Args:
        blob_name: Name of the blob in the bucket (e.g., "models/vw_golf_5_gti.usdz")
        bucket_name: GCS bucket name (defaults to STORAGE_BUCKET env var)
        expiration_hours: URL expiration in hours (defaults to MODEL_URL_EXPIRATION_HOURS)
        
    Returns:
        Signed URL string, or None if the blob doesn't exist or an error occurs
    """
    try:
        bucket_name = bucket_name or STORAGE_BUCKET
        expiration_hours = expiration_hours or MODEL_URL_EXPIRATION_HOURS
        
        if not bucket_name:
            logger.error("No storage bucket configured")
            return None
        
        client = get_storage_client()
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(blob_name)
        
        # Check if blob exists (optional - removes this if you want to generate URLs for non-existent files)
        if not blob.exists():
            logger.warning(f"Blob does not exist: {blob_name}")
            return None
        
        # Generate signed URL
        url = blob.generate_signed_url(
            version="v4",
            expiration=timedelta(hours=expiration_hours),
            method="GET"
        )
        
        logger.info(f"Generated signed URL for {blob_name}, expires in {expiration_hours}h")
        return url
        
    except Exception as e:
        logger.error(f"Error generating signed URL for {blob_name}: {e}")
        return None


def get_model_url_for_volume_id(volume_id: str) -> Optional[str]:
    """Get signed URL for a car's 3D model by its volumeId.
    
    Args:
        volume_id: The volumeId of the car (e.g., "vw_golf_5_gti")
        
    Returns:
        Signed URL string, or None if not found
    """
    if not volume_id:
        return None
    
    # Models are stored as: models/{volumeId}.usdz
    blob_name = f"models/{volume_id}.usdz"
    return generate_signed_url(blob_name)


def upload_model(
    local_path: str,
    volume_id: str,
    bucket_name: Optional[str] = None
) -> bool:
    """Upload a 3D model file to GCS.
    
    Args:
        local_path: Path to the local USDZ file
        volume_id: The volumeId to use as the filename
        bucket_name: GCS bucket name (defaults to STORAGE_BUCKET env var)
        
    Returns:
        True if successful, False otherwise
    """
    try:
        bucket_name = bucket_name or STORAGE_BUCKET
        
        if not os.path.exists(local_path):
            logger.error(f"Local file not found: {local_path}")
            return False
        
        client = get_storage_client()
        bucket = client.bucket(bucket_name)
        blob_name = f"models/{volume_id}.usdz"
        blob = bucket.blob(blob_name)
        
        # Upload with content type
        blob.upload_from_filename(
            local_path,
            content_type="model/vnd.usdz+zip"
        )
        
        logger.info(f"Uploaded {local_path} to gs://{bucket_name}/{blob_name}")
        return True
        
    except Exception as e:
        logger.error(f"Error uploading model for {volume_id}: {e}")
        return False


def delete_model(volume_id: str, bucket_name: Optional[str] = None) -> bool:
    """Delete a 3D model from GCS.
    
    Args:
        volume_id: The volumeId of the model to delete
        bucket_name: GCS bucket name (defaults to STORAGE_BUCKET env var)
        
    Returns:
        True if successful, False otherwise
    """
    try:
        bucket_name = bucket_name or STORAGE_BUCKET
        
        client = get_storage_client()
        bucket = client.bucket(bucket_name)
        blob_name = f"models/{volume_id}.usdz"
        blob = bucket.blob(blob_name)
        
        blob.delete()
        logger.info(f"Deleted gs://{bucket_name}/{blob_name}")
        return True
        
    except Exception as e:
        logger.error(f"Error deleting model for {volume_id}: {e}")
        return False


def model_exists(volume_id: str, bucket_name: Optional[str] = None) -> bool:
    """Check if a 3D model exists in GCS.
    
    Args:
        volume_id: The volumeId to check
        bucket_name: GCS bucket name (defaults to STORAGE_BUCKET env var)
        
    Returns:
        True if the model exists, False otherwise
    """
    try:
        bucket_name = bucket_name or STORAGE_BUCKET
        
        client = get_storage_client()
        bucket = client.bucket(bucket_name)
        blob_name = f"models/{volume_id}.usdz"
        blob = bucket.blob(blob_name)
        
        return blob.exists()
        
    except Exception as e:
        logger.error(f"Error checking if model exists for {volume_id}: {e}")
        return False

