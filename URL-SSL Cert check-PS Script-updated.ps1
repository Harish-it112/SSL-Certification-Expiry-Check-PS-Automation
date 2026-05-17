$targetURL = Read-Host "Enter URL to Scan SSL Certifcate validity"

function Get-SSLCertExpiry {
    param([string]$Url)

    try {
        $uri = [uri]$Url

        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($uri.Host, 443)

        $sslStream = New-Object System.Net.Security.SslStream(
            $tcpClient.GetStream(),
            $false,
            ({ $true })
        )

        $sslStream.AuthenticateAsClient($uri.Host)

        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $sslStream.RemoteCertificate

        [PSCustomObject]@{
            URL       = $Url
            Expiry    = $cert.NotAfter
            DaysLeft  = ($cert.NotAfter - (Get-Date)).Days
            Issuer    = $cert.Issuer
            Subject   = $cert.Subject
            Thumbprint= $cert.Thumbprint
        }

        $tcpClient.Close()
    }
    catch {
        Write-Host "Failed for: $Url" -ForegroundColor Red
    }
}

Get-SSLCertExpiry "$targetURL"