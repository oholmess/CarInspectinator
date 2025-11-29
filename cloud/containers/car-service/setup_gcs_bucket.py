#!/usr/bin/env python3
"""Script to create and configure the GCS bucket for car 3D models."""

import sys
import os
from google.cloud import storage

# Configuration
PROJECT_ID = os.getenv("GCP_PROJECT_ID", "car-inspectinator-3000")
BUCKET_NAME = os.getenv("STORAGE_BUCKET", "carinspectinator-car-models")
REGION = os.getenv("GCS_REGION", "europe-west1")


def create_bucket():
    """Create GCS bucket for car models."""
    try:
        client = storage.Client(project=PROJECT_ID)
        
        # Check if bucket already exists
        bucket = client.bucket(BUCKET_NAME)
        if bucket.exists():
            print(f"✅ Bucket '{BUCKET_NAME}' already exists")
            return bucket
        
        # Create bucket
        bucket = client.create_bucket(
            BUCKET_NAME,
            location=REGION
        )
        
        print(f"✅ Created bucket '{BUCKET_NAME}' in {REGION}")
        return bucket
        
    except Exception as e:
        print(f"❌ Error creating bucket: {e}")
        sys.exit(1)


def configure_bucket(bucket):
    """Configure bucket settings."""
    try:
        # Set CORS for Vision Pro app to download models directly
        cors_config = [
            {
                "origin": ["*"],  # Allow all origins (you can restrict this later)
                "method": ["GET", "HEAD"],
                "responseHeader": ["Content-Type", "Content-Length"],
                "maxAgeSeconds": 3600
            }
        ]
        bucket.cors = cors_config
        bucket.patch()
        print("✅ Configured CORS policy")
        
        # Set lifecycle rule to delete old signed URLs (optional)
        # This doesn't delete the files, just helps with management
        
        # Set uniform bucket-level access
        bucket.iam_configuration.uniform_bucket_level_access_enabled = True
        bucket.patch()
        print("✅ Enabled uniform bucket-level access")
        
    except Exception as e:
        print(f"⚠️  Warning: Could not configure all bucket settings: {e}")


def grant_permissions(bucket):
    """Grant necessary permissions to service accounts."""
    try:
        policy = bucket.get_iam_policy(requested_policy_version=3)
        
        # Grant backend service account read access
        backend_sa = f"backend-service@{PROJECT_ID}.iam.gserviceaccount.com"
        
        # Add role for viewing objects
        policy.bindings.append({
            "role": "roles/storage.objectViewer",
            "members": {f"serviceAccount:{backend_sa}"}
        })
        
        bucket.set_iam_policy(policy)
        print(f"✅ Granted permissions to {backend_sa}")
        
    except Exception as e:
        print(f"⚠️  Warning: Could not grant permissions: {e}")
        print("   You may need to grant permissions manually:")
        print(f"   gcloud storage buckets add-iam-policy-binding gs://{BUCKET_NAME} \\")
        print(f"     --member='serviceAccount:backend-service@{PROJECT_ID}.iam.gserviceaccount.com' \\")
        print(f"     --role='roles/storage.objectViewer'")


def create_folder_structure(bucket):
    """Create folder structure in bucket."""
    try:
        # Create a placeholder file to establish the models/ folder
        blob = bucket.blob("models/.placeholder")
        blob.upload_from_string("")
        print("✅ Created folder structure (models/)")
        
    except Exception as e:
        print(f"⚠️  Warning: Could not create folder structure: {e}")


def main():
    """Main setup function."""
    print(f"🚀 Setting up GCS bucket for car models")
    print(f"   Project: {PROJECT_ID}")
    print(f"   Bucket: {BUCKET_NAME}")
    print(f"   Region: {REGION}")
    print()
    
    # Create bucket
    bucket = create_bucket()
    
    # Configure bucket
    configure_bucket(bucket)
    
    # Grant permissions
    grant_permissions(bucket)
    
    # Create folder structure
    create_folder_structure(bucket)
    
    print()
    print("✅ Setup complete!")
    print()
    print("📝 Next steps:")
    print(f"   1. Upload 3D models: python upload_models.py")
    print(f"   2. Update environment variable in Cloud Run:")
    print(f"      STORAGE_BUCKET={BUCKET_NAME}")
    print()
    print(f"📦 Bucket URL: https://console.cloud.google.com/storage/browser/{BUCKET_NAME}")


if __name__ == "__main__":
    main()

