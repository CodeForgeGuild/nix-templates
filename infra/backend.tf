terraform {
  backend "gcs" {
    bucket = "<GCS_BUCKET_NAME>"  # e.g. my-project-tfstate
    prefix = "state/<MODULE>"     # e.g. state/networking
  }

  encryption {
    key_provider "gcp_kms" "tofu" {
      kms_encryption_key = "projects/<GCP_PROJECT>/locations/global/keyRings/<KEYRING>/cryptoKeys/<KEY>"
      key_length         = 32
    }
    method "aes_gcm" "method" {
      keys = key_provider.gcp_kms.tofu
    }
    state {
      method = method.aes_gcm.method
    }
    remote_state_data_sources {
      default {
        method = method.aes_gcm.method
      }
    }
  }
}
