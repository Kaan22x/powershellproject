# AD modülünü içe aktar
Import-Module ActiveDirectory

# Kilitlenen kullanıcıları bul (son 30 dakika içinde)
$TimeFrame = (Get-Date).AddMinutes(-30)
$LockedUsers = Search-ADAccount -LockedOut | Where-Object { $_.WhenChanged -ge $TimeFrame }

# Kilitlenen kullanıcı varsa e-posta gönder
if ($LockedUsers) {
    $Body = ""
    foreach ($User in $LockedUsers) {
        $Body += "Kullanici Adi: $($User.SamAccountName)`n"
        $Body += "İsim: $($User.Name)`n"
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
}
