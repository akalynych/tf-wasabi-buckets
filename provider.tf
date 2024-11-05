provider "aws" {
  region                      = "us-east-1"
  profile                     = "wasabi"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  endpoints {
    s3  = "https://s3.wasabisys.com"
    iam = "https://iam.wasabisys.com"
  }
}
