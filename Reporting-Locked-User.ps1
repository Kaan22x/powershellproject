# AD modülünü içe aktar
Import-Module ActiveDirectory

# Tüm Domain Controller'ları al
$DCs = Get-ADDomainController -Filter *

# Kilitlenen kullanıcıları depolamak için bir array oluştur
$LockedUsers = @()

# Her bir DC üzerinde sorgu yap
foreach ($DC in $DCs) {
    Write-Output "Sorgulanan DC: $($DC.Name)"
    
    # Her DC üzerinde kilitli kullanıcıları sorgula
    $Users = Search-ADAccount -Server $DC.Name -LockedOut
    
    # Kilitli kullanıcı varsa array'e ekle
    if ($Users) {
        $LockedUsers += $Users
    }
}

# Kilitlenen kullanıcı varsa e-posta gönder
if ($LockedUsers.Count -gt 0) {
    $Body = ""
    foreach ($User in $LockedUsers) {
        $Body += "Kullanici Adi: $($User.SamAccountName)`n"
        $Body += "isim: $($User.Name)`n"
        $Body += "OU: $($User.DistinguishedName)`n"
        $Body += "Tarih: $(Get-Date)`n"
        $Body += "`n----------------------`n"
    }

    # Mail ayarları
    $MailParams = @{
        SmtpServer = "smtp.domain.com"  # Şirketinizin SMTP sunucusu
        From       = "it@domain.com"
        To         = "it@domain.com"
        Subject    = "Kilitlenen Kullanici(lar) Tespit Edildi"
        Body       = $Body
        BodyAsHtml = $false
    }

    Send-MailMessage @MailParams
} else {
    Write-Output "Kilitlenen kullanıcı bulunamadı."
}
