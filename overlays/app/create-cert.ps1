$cert = New-SelfSignedCertificate -DnsName "aks-test-stage.swedencentral.cloudapp.azure.com" -CertStoreLocation "Cert:\LocalMachine\My"

$password = ConvertTo-SecureString -String "AdmPwd@251024" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "C:\Temp\tls-secret-hallinc.pfx" -Password $password

$pfxPath = "C:\Temp\tls-secret-hallinc.pfx"
$certPassword = ConvertTo-SecureString -String "your_password" -Force -AsPlainText
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import($pfxPath, $certPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

$certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
[System.IO.File]::WriteAllBytes("C:\Temp\tls-secret-hallinc.crt", $certBytes)

$keyBytes = $cert.PrivateKey.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs8, $certPassword)
[System.IO.File]::WriteAllBytes("C:\Temp\tls-secret-hallinc.key", $keyBytes)