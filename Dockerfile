FROM mcr.microsoft.com/azure-powershell:latest

# Install dependencies
ENV POSHACME_HOME "/mnt/acishare"
RUN [ "mkdir", "/mnt/acishare" ]
RUN [ "pwsh", "-command", "Install-Module", "Posh-ACME", "-Force" ]

COPY run.ps1 /opt/run.ps1

ENTRYPOINT [ "pwsh", "-Command" ]
CMD [ "/opt/run.ps1" ]
