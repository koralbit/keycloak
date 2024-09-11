# Setup.ps1

param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("generate", "import")]
    [string]$Operation,  # Choose "generate" or "import"

    [string]$OutputDir = ".\cert",  # Default output directory for certificate generation
    [string]$CnfFile = ".\config\cert\cert.cnf",  # Path to the certificate config file for generating the certificate
    [string]$CertPath = ".\cert\local-keycloak.cer",  # Path to the .cer file for importing
    [string]$PrivateKey = "keycloak-privkey.pem",  # Private key file name for generation
    [string]$CsrFile = "local-keycloak.csr",  # CSR file name for generation
    [string]$CrtFile = "local-keycloak.crt",  # Certificate file name for generation
    [string]$CerFile = "local-keycloak.cer",   # CER file name for conversion
    [string]$NginxCertDir = ".\data\nginx\cert"   # CER file name for conversion
)
# Optional: Remove any previously loaded instance of the module
Remove-Module CertModule -ErrorAction SilentlyContinue
Remove-Module CertImportModule -ErrorAction SilentlyContinue
# Import the module containing functions for generating and importing certificates
Import-Module ".\scripts\CertModule" 
Import-Module ".\scripts\CertImportModule" 

# If the operation is to generate a certificate
if ($Operation -eq "generate") {
    Write-Host "Generating certificate..."

    # Call the function to generate the certificate
    New-Certificate `
        -outputDir $OutputDir `
        -cnfFile $CnfFile `
        -privateKey "$OutputDir\$PrivateKey" `
        -csrFile "$OutputDir\$CsrFile" `
        -crtFile "$OutputDir\$CrtFile" `
        -cerFile "$OutputDir\$CerFile" `

    Write-Host "Certificate generation completed."
    
    # Copy the certificate to nginx
    Copy-ToNginxDir -nginxDir $NginxCertDir -certDir $OutputDir -privateKey "$OutputDir\$PrivateKey" -crtFile "$OutputDir\$CrtFile"
}

# If the operation is to import a certificate
elseif ($Operation -eq "import") {
    Write-Host "Importing certificate..."

    # Call the function to import the certificate
    Import-Certificate -certPath $CertPath

    Write-Host "Certificate imported successfully."
}
else {
    Write-Host "Invalid operation specified. Please use 'generate' or 'import'."
}
