# Set up 

## Create GCP Project
Create a new project and switch to the project.
Go to the left panel of your project, select Compute Engine API:
- Enable the API
- Go to VM instances, select CREATE INSTANCE
	region: closest to you with low co2
	Machine Type: e2-standard-4 (4 vCPU, 16 GB Memory)
	Change boot disk: Ubuntu 20.04 LTS, a larger size > 30 GB
- Configure SSH to VM
	Create SSH key following: https://cloud.google.com/compute/docs/connect/create-ssh-keys#windows-10-or-later
	Add SSH key to VM following: https://cloud.google.com/compute/docs/connect/add-ssh-keys
	Create a config-file locally under your .ssh directory with the following content:
			Host <hostname to use when connecting>
			HostName <external IP>
			User <DESIREDUSERNAMEONVM you specified in ssh-keygen command>
			IdentityFile <path to your private key> e.g.  ~/.ssh/privatekey
	Go to local terminal and start SSH connection to host:
		`ssh <hostname to use when connecting>`
- Configure VSCode with SSH
	Search extension SSH and install Remote-SSH
	Under lower left corner, select Open a Remote Window, then follow 'Connect to Host' to your project 

## Set up Git in your VM instance
- Install Git:
	`sudo apt update`
	`sudo apt install git -y`
- Configure your identity
	`git config --global user.name "Your Name"`
	`git config --global user.email "your_email@example.com"`
- Generate SSH key Pair for Github
	`ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`
- Add SSH key to Github
	first display the pub key:
	`cat ~/.ssh/id_rsa.pub`
	then log in to your GitHub account, go to Settings > SSH and GPG keys > New SSH key, paste your public key, and save it.
- Clone the repo using SSH:
	`git clone git@github.com:azurey0/FANNG_stock_pipeline.git`

## Terraform
- Install terraform following https://developer.hashicorp.com/terraform/install?ajs_aid=48c747ef-af7e-48b2-8013-4059f650dda5&product_intent=terraform#Linux
    ```
    {
	wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg`
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt update && sudo apt install terraform
     }
    ```

- Configure a service account
	Go to IAM Admin - Service Account:
	Create a service account and grant following roles:
		Storage Admin
		BigQuery Admin
		Compute Engine Admin
	Go 'Manage Keys' for this service account, then go to 'Create JSON keys' to download key
	Then sftp the downloaded key to GCP: in your local terminal, cd to the directory having the JSON keys, then 
    ```
    {
		sftp <YOUR_GSC_PROJECT>
    }
    ```
	Then in sftp:
    ```
    {
		mkdir .gc
		cd .gc
		put <YOUR_JSON_FILE_NAME>
    }
    ```
	Back to SSH session, use the following command to add service account keys to GCP authorization:
    ```
    {
		export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/<YOUR_JSON_FILE_NAME>
		gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
    }
    ```


