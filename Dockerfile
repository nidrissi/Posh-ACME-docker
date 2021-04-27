FROM mcr.microsoft.com/azure-powershell:latest

# Install dependencies
ENV POSHACME_HOME "/var/acme-posh"
RUN [ "mkdir", "/var/acme-posh" ]
RUN [ "pwsh", "-command", "Install-Module", "Posh-ACME", "-Force" ]

# My scripts
RUN mkdir /opt/acme-posh
COPY run.ps1 /opt/run.ps1

ENTRYPOINT [ "pwsh", "-Command" ]
CMD [ "/opt/run.ps1" ]
