function Import-Certificate {
    [CmdletBinding()]
    param (
        [string]$certPath,  # Path to the certificate
        [string]$certStore = "Cert:\LocalMachine\Root"  # Default store to import the certificate
    )

    # Resolve the full path of the certificate file
    try {
        $resolvedCertPath = Resolve-Path -Path $certPath
        Write-Verbose "Resolved certificate path: $resolvedCertPath"
    }
    catch {
        Write-Host "Error: Certificate path could not be resolved: $certPath" -ForegroundColor Red
        return
    }

    # Load the certificate
    Write-Host "Loading certificate from path: $resolvedCertPath"
    try {
        $certToImport = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($resolvedCertPath)
    }
    catch {
        Write-Host "Error: Failed to load the certificate from $resolvedCertPath" -ForegroundColor Red
        return
    }

    # Open the certificate store
    Write-Host "Opening certificate store: $certStore"
    try {
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
        $store.Open("ReadWrite")
    }
    catch {
        Write-Host "Error: Failed to open the certificate store $certStore" -ForegroundColor Red
        return
    }

    # Check if the certificate already exists in the store
    Write-Verbose "Checking if the certificate is already in the store..."
    $existingCert = $store.Certificates | Where-Object { $_.Thumbprint -eq $certToImport.Thumbprint }

    if ($existingCert) {
        Write-Host "The certificate is already present in the store." -ForegroundColor Yellow
        # Ask user if they want to reimport the certificate
        $response = Read-Host "Do you want to reimport the certificate? (yes/no)"
        if ($response -eq "yes") {
            Write-Host "Reimporting the certificate..."
            try {
                $store.Remove($existingCert)  # Remove existing certificate
                $store.Add($certToImport)     # Add the new certificate
                Write-Host "Certificate reimported successfully." -ForegroundColor Green
            }
            catch {
                Write-Host "Error: Failed to reimport the certificate" -ForegroundColor Red
            }
        }
        else {
            Write-Host "Skipping the import as per user request."
        }
    }
    else {
        # Add the certificate to the store
        Write-Verbose "Adding certificate to store..."
        try {
            $store.Add($certToImport)
            Write-Host "Certificate added to the store successfully."
        }
        catch {
            Write-Host "Error: Failed to add the certificate to the store" -ForegroundColor Red
        }
    }

    # Close the store
    Write-Verbose "Closing certificate store..."
    $store.Close()

    Write-Host "Certificate import process completed."
}
