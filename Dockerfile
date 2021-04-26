FROM mcr.microsoft.com/azure-powershell:latest

# Install dependencies
ENV POSHACME_HOME "/var/acme-posh"
RUN [ "mkdir", "/var/acme-posh" ]
RUN [ "pwsh", "-command", "Install-Module", "Posh-ACME", "-Force" ]

# My scripts
RUN mkdir /opt/acme-posh
COPY init.ps1 /opt/acme-posh/init.ps1
COPY profile.ps1 /opt/acme-posh/profile.ps1
COPY renew.ps1 /opt/acme-posh/renew.ps1
COPY import.ps1 /opt/acme-posh/import.ps1

ENTRYPOINT [ "pwsh", "-Command" ]
CMD [ "pwsh" ]
