terraform {
  backend "gcs" {
    path = "/terraform.tfstate"
    credentials = "./account-folder/account.json"
  }
}
