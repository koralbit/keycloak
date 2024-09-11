# CertModule.psm1

# Function to create the output directory if it doesn't exist
function New-OutputDirectory {
    param (
        [string]$outputDir
    )
    if (-Not (Test-Path -Path $outputDir)) {
        Write-Host "Creating output directory: $outputDir"
        New-Item -ItemType Directory -Path $outputDir
    } else {
        Write-Host "Output directory already exists: $outputDir"
    }
}

# Function to generate the private key
function New-PrivateKey {
    param (
        [string]$privateKey
    )
    Write-Host "Generating private key..."
    openssl genpkey -algorithm RSA -out $privateKey -pkeyopt rsa_keygen_bits:2048
}

# Function to generate the CSR
function New-CSR {
    param (
        [string]$privateKey,
        [string]$csrFile,
        [string]$cnfFile
    )
    Write-Host "Generating CSR..."
    openssl req -new -key $privateKey -out $csrFile -config $cnfFile
}

# Function to generate the self-signed certificate
function New-SelfSignedCert {
    param (
        [string]$csrFile,
        [string]$privateKey,
        [string]$crtFile,
        [string]$cnfFile,
        [int]$days = 365
    )
    Write-Host "Generating self-signed certificate..."
    openssl x509 -req -in $csrFile -signkey $privateKey -out $crtFile -days $days -extfile $cnfFile -extensions req_ext
}

# Function to display the certificate information
function Show-CertInfo {
    param (
        [string]$crtFile
    )
    Write-Host "Displaying certificate information..."
    openssl x509 -in $crtFile -text -noout
}

# Function to convert certificate to .cer format
function Convert-ToCerFormat {
    param (
        [string]$crtFile,
        [string]$cerFile
    )
    Write-Host "Converting certificate to .cer format..."
    openssl x509 -outform der -in $crtFile -out $cerFile
}

# Function to run the full certificate generation process
function New-Certificate {
    param (
        [string]$outputDir = "cert",
        [string]$cnfFile = ".\config\cert\cert.cnf",
        [string]$privateKey = "$outputDir\keycloak-privkey.pem",
        [string]$csrFile = "$outputDir\local-keycloak.csr",
        [string]$crtFile = "$outputDir\local-keycloak.crt",
        [string]$cerFile = "$outputDir\local-keycloak.cer"
    )

    # Create the output directory if it doesn't exist
    New-OutputDirectory -outputDir $outputDir

    # Step 1: Generate the Private Key
    New-PrivateKey -privateKey $privateKey

    # Step 2: Generate the CSR using the configuration file
    New-CSR -privateKey $privateKey -csrFile $csrFile -cnfFile $cnfFile

    # Step 3: Generate the Self-Signed Certificate
    New-SelfSignedCert -csrFile $csrFile -privateKey $privateKey -crtFile $crtFile -cnfFile $cnfFile

    # Step 4: Display the certificate information
    Show-CertInfo -crtFile $crtFile

    # Step 5: Convert the certificate to .cer format
    Convert-ToCerFormat -crtFile $crtFile -cerFile $cerFile

    # Display final information
    Write-Host "Process complete! Files generated:"
    Write-Host "Private Key: $privateKey"
    Write-Host "CSR: $csrFile"
    Write-Host "Certificate: $crtFile"
    Write-Host "CER: $cerFile"
}

# Copy to nginx directory
function Copy-ToNginxDir {
    param (
        [string]$nginxDir = ".\data\nginx\cert",
        [string]$certDir = ".\cert",
        [string]$privateKey = "$certDir\keycloak-privkey.pem",
        [string]$crtFile = "$certDir\local-keycloak.crt"
    )
    
    if (-Not (Test-Path -Path $nginxDir)) {
        #Create the directory if it doesn't exist
        Write-Host "Creating Nginx directory: $nginxDir"
        New-Item -ItemType Directory -Path $nginxDir
    }
    # Copy the files to the Nginx directory
    Write-Host "Copying files to Nginx directory..."
    Write-host "Copying $privateKey to $nginxDir" 
    Copy-Item -Path $privateKey -Destination $nginxDir -Force
    Write-host "Copying $crtFile to $nginxDir"
    Copy-Item -Path $crtFile -Destination $nginxDir -Force
    Write-Host "Files copied successfully."
}

# Export the functions
Export-ModuleMember -Function *  # Export all functions
