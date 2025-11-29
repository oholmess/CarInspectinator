#!/usr/bin/env python3
"""Script to upload car 3D models to GCS."""

import sys
import os
from pathlib import Path
from google.cloud import storage

# Configuration
PROJECT_ID = os.getenv("GCP_PROJECT_ID", "car-inspectinator-3000")
BUCKET_NAME = os.getenv("STORAGE_BUCKET", "carinspectinator-car-models")

# Model mappings: volumeId -> local file path
# Update these paths to match your local structure
MODELS = {
    "vw_golf_5_gti": "../../../vision-pro/CarInspectinator/Assets.xcassets/vw_golf_5_gti.dataset/vw_golf_5_gti.usdz",
    "BMW_M4_f82": "../../../vision-pro/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/BMW_M4_f82.usdz",
    "2020_Audi_RS7_Sportback": "../../../vision-pro/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/2020_Audi_RS7_Sportback.usdz",
    "2020_Mercedes-Benz_G-Class_AMG_G63": "../../../vision-pro/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/2020_Mercedes-Benz_G-Class_AMG_G63.usdz",
    "Toyota_Supra": "../../../vision-pro/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/Toyota_Supra.usdz",
}


def upload_model(client: storage.Client, volume_id: str, local_path: str) -> bool:
    """Upload a single model to GCS.
    
    Args:
        client: Storage client
        volume_id: Volume ID to use as filename
        local_path: Local path to USDZ file
        
    Returns:
        True if successful, False otherwise
    """
    try:
        # Resolve path relative to script location
        script_dir = Path(__file__).parent
        full_path = (script_dir / local_path).resolve()
        
        if not full_path.exists():
            print(f"⚠️  File not found: {full_path}")
            return False
        
        # Get file size
        file_size_mb = full_path.stat().st_size / (1024 * 1024)
        
        bucket = client.bucket(BUCKET_NAME)
        blob_name = f"models/{volume_id}.usdz"
        blob = bucket.blob(blob_name)
        
        # Check if already exists
        if blob.exists():
            print(f"⚠️  {volume_id}: Already exists, skipping")
            return True
        
        print(f"⬆️  Uploading {volume_id} ({file_size_mb:.2f} MB)...", end=" ")
        
        # Upload with content type
        blob.upload_from_filename(
            str(full_path),
            content_type="model/vnd.usdz+zip"
        )
        
        print("✅")
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def main():
    """Main upload function."""
    print(f"🚀 Uploading car 3D models to GCS")
    print(f"   Project: {PROJECT_ID}")
    print(f"   Bucket: {BUCKET_NAME}")
    print()
    
    try:
        client = storage.Client(project=PROJECT_ID)
        
        # Check if bucket exists
        bucket = client.bucket(BUCKET_NAME)
        if not bucket.exists():
            print(f"❌ Bucket '{BUCKET_NAME}' does not exist")
            print(f"   Run: python setup_gcs_bucket.py")
            sys.exit(1)
        
        # Upload each model
        success_count = 0
        skip_count = 0
        fail_count = 0
        
        for volume_id, local_path in MODELS.items():
            if local_path is None:
                print(f"⏭️  {volume_id}: No path configured, skipping")
                skip_count += 1
                continue
            
            if upload_model(client, volume_id, local_path):
                success_count += 1
            else:
                fail_count += 1
        
        print()
        print(f"✅ Upload complete!")
        print(f"   Successful: {success_count}")
        print(f"   Skipped: {skip_count}")
        print(f"   Failed: {fail_count}")
        
        if fail_count > 0:
            print()
            print("⚠️  Some uploads failed. Check the errors above.")
        
        print()
        print(f"📦 View uploaded models:")
        print(f"   https://console.cloud.google.com/storage/browser/{BUCKET_NAME}/models")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()

