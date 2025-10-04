"""Firebase initialization and Firestore client."""
from __future__ import annotations

import os
import logging
from typing import Optional

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore import Client

logger = logging.getLogger(__name__)

_db: Optional[Client] = None


def initialize_firebase() -> None:
    """Initialize Firebase Admin SDK and Firestore client.
    
    This should be called once at application startup.
    Uses Application Default Credentials in GCP or a service account key file locally.
    """
    global _db
    
    if _db is not None:
        logger.info("Firebase already initialized")
        return
    
    try:
        # Check if running in GCP (Application Default Credentials)
        if os.getenv("GOOGLE_CLOUD_PROJECT"):
            # Running in GCP - use Application Default Credentials
            if not firebase_admin._apps:
                firebase_admin.initialize_app()
            logger.info("Firebase initialized with Application Default Credentials")
        else:
            # Local development - try to use service account key
            service_account_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
            
            if service_account_path and os.path.exists(service_account_path):
                if not firebase_admin._apps:
                    cred = credentials.Certificate(service_account_path)
                    firebase_admin.initialize_app(cred)
                logger.info(f"Firebase initialized with service account: {service_account_path}")
            else:
                # Fallback to default credentials
                if not firebase_admin._apps:
                    firebase_admin.initialize_app()
                logger.info("Firebase initialized with default credentials")
        
        _db = firestore.client()
        logger.info("Firestore client created successfully")
        
    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {e}")
        raise


def get_firestore_client() -> Client:
    """Get the Firestore client instance.
    
    Returns:
        Firestore client
        
    Raises:
        RuntimeError: If Firebase hasn't been initialized
    """
    if _db is None:
        raise RuntimeError(
            "Firebase not initialized. Call initialize_firebase() first."
        )
    return _db

