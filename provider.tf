provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = "eu-west-1"  ## my default region  
  # No importance for this value currently
  #region = "us-east-2"
}