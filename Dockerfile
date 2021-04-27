FROM mcr.microsoft.com/azure-powershell:latest

# Install dependencies
RUN [ "pwsh", "-command", "Install-Module", "Posh-ACME", "-Force" ]

ENV POSHACME_HOME "/mnt/acishare"
RUN [ "mkdir", "/mnt/acishare" ]
COPY run.ps1 /opt/run.ps1

ENTRYPOINT [ "pwsh", "-Command" ]
CMD [ "/opt/run.ps1", "-Verbose" ]
