# Posh-ACME-docker

An Azure-containerized version of [Posh-ACME](https://github.com/rmbolger/Posh-ACME).

## Prerequisites

- An [Azure account](https://azure.microsoft.com/);
- An [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/);
- An [Azure-hosted DNS zone](https://azure.microsoft.com/en-us/services/dns/) for your domain.

## To test locally

1. Edit [`docker-compose.yml`](./docker-compose.yml) with your environment variables.
2. Change `Connect-AzAccount -Identity` to `Connect-AzAccount -UseDeviceAuthentication` in [`run.ps1`](./run.ps1) (the idea is that you will login with your own credentials, rather than the system-managed identity).
3. (Optional) Change `LE_PROD` to `LE_STAGE` in `run.ps1`.
4. Run `docker compose up`.
5. When prompted, perform the steps to login to Azure.

This should automatically obtain an SSL certificate from [Let's Encrypt](https://letsencrypt.org/) and upload it to your Key Vault.

## To deploy

1. Create a storage account and a [file share](https://azure.microsoft.com/en-us/services/storage/files/) named `acishare`; at first, create a single file named `.wait` inside.
2. Edit [`create.ps1`](./create.ps1) with your information and run it. This will create an [Azure Container Instance](https://azure.microsoft.com/en-us/services/container-instances/) that pulls my [docker image](https://hub.docker.com/r/nidrissi/posh-acme).
3. However, it would fail because it doesn't have the correct permissions. The instance will have a [managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview). Grant that identity access to the storage account that you created earlier, and to your key vault.
4. Remove the `.wait` file from the file share to tell the container to actually do stuff this time.
5. Start the container instance again. Now it should work!
6. (Optional) Create a [Logic app](https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-overview) (or an Azure function if you prefer) to start the container periodically. It will automatically check if a new certificate is needed. If so, it will obtain it and upload it to the key vault.
