## DESCRIPTION

This repo contains a script that is used to deploy a bucketlist application on google cloud platform. It sets up the networking infrastructure required for the application to run on google cloud platform. 

## Tech Stack

- Terraform Version 0.10.6
- Shell Script
- Google Cloud Platform

## Before Setup

- Ensure you have a google cloud platform account and a project on which you can host the application.

- Reserve a static IP address and note down the region in which the IP is on. This region will be used in running the terraform commands.

- Create a storage bucket where your terraform.state file will be stored. 

- Create a postgres sql instance on google cloud platform and add a database. Add the static IP address created above to the list of authorized networks.
For postgres the DATABASE_URI format will be as below:
 1.  **IP_ADDRESS_DATABASE** - This refers to the IP Address of the database that allows it to be accessed externally.
 2.  **DATABASE_NAME** - This refers to the name of the database you have created.
postgresql://postgres:postgres@**IP_ADDRESS_DATABASE**:5432/**DATABASE_NAME**

- Create a service account key with the roles of Editor, Viewer and Storage Admin.

- Copy the contents of the downloaded service key into the account.json file in the folder account-folder.



## Running the script

1. Clone the repository.

`git clone https://github.com/winstonkamau/googleterraform.git`

2. Change directory into the repository.

`cd googleterraform`

3. Initialise terraform

`terraform init -backend-config=bucket=<PROJECT_BUCKET>`

* PROJECT_BUCKET should be the bucket created in set up to store the terraform file.

4. Plan terraform

`terraform plan -var=project=<PROJECT_ID> -var=ip-address=<IP_ADDRESS> -var=database-uri=<DATABASE_URI> -var=region=<REGION> -var=zone=<ZONE>`

* PROJECT_ID is the id of your project on google cloud platform
* IP_ADDRESS refers to the static IP Address created on set up
* DATABASE_URI is the one created on setup
* REGION is the region where the static IP Address exists.
* ZONE is a zone within the region that you desire to deploy


5. Apply terraform

`terraform apply -var=project=<PROJECT_ID> -var=ip-address=<IP_ADDRESS> -var=database-uri=<DATABASE_URI> -var=region=<REGION> -var=zone=<ZONE>`





