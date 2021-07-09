# Posh-ACME-docker

An Azure-containerized version of [Posh-ACME](https://github.com/rmbolger/Posh-ACME).

[![Open in Visual Studio Code](https://open.vscode.dev/badges/open-in-vscode.svg)](https://open.vscode.dev/nidrissi/Posh-ACME-docker)
![Last commit](https://img.shields.io/github/last-commit/nidrissi/Posh-ACME-docker)

## Prerequisites

- An [Azure account](https://azure.microsoft.com/).
- An [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/).
- An [Azure-hosted DNS zone](https://azure.microsoft.com/en-us/services/dns/) for your domain.
- (Optional) If you want to use the `create.ps1` script, [Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/get-started-azureps) must be installed.
- (Optional) If you want to test locally, [Docker](https://www.docker.com/) must be installed.

## To test locally

1. Edit [`docker-compose.yml`](./Image/docker-compose.yml) with your environment variables.
2. Change `Connect-AzAccount -Identity` to `Connect-AzAccount -UseDeviceAuthentication` in [`run.ps1`](./Image/run.ps1) (the idea is that you will login with your own credentials, rather than the system-managed identity).
3. (Optional) Change `LE_PROD` to `LE_STAGE` in `run.ps1`.
4. Run `docker compose up`.
5. When prompted, perform the steps to login to Azure.

This should automatically obtain an SSL certificate from [Let's Encrypt](https://letsencrypt.org/) and upload it to your Key Vault.

## To deploy

1. Create a resource group.
2. Create an `azuredeploy.parameters.json` file with the following parameters:
   - `email`: You contact email for Let's Encrypt.
   - `domains`: A semicolon-separated list of domains for which certificates need to be gotten.
   - `imageVersion`: The version of the Docker image that you want to use.
3. Run the [`deploy.ps1`](./Deploy/deploy.ps1) script. Its parameters are:
   - `$ResourceGroup`: The name of the resource group you just created.
   - `$ZoneNames`: The names of your DNS zones, separated by semicolons.
4. The Logic App may require manual attention (the API connection isn't authenticated at first).

Everything should work. Feel free to [report any bugs](https://github.com/nidrissi/Posh-ACME-docker/issues).
