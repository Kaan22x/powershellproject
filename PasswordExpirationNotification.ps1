$expiryDaysList = @(7, 3, 1)  
$smtpServer = "smtp.domain.com"
$from = "it@domain.com"
$subject = "Kullanici Sifre Yenileme Uyarisi"
$bodyTemplate = @"
Merhaba {0}, 

Kullanici sifrenizin suresi {1} gun icinde dolacak. Lutfen sifrenizi yenilemeyi unutmayin.

Tesekkurler,
BT Departmani
"@

# AD modülünü yükle
Import-Module ActiveDirectory

# Tüm etkin kullanıcıları al (şifresi sonsuza kadar geçerli olmayanlar)
$users = Get-ADUser -Filter {Enabled -eq $true -and PasswordNeverExpires -eq $false} `
-Properties "DisplayName", "mail", "msDS-UserPasswordExpiryTimeComputed"

foreach ($user in $users) {
    # Şifre bitiş tarihi varsa
    if ($user."msDS-UserPasswordExpiryTimeComputed") {
        # Şifre bitiş tarihini hesapla
        $expiryDate = [datetime]::FromFileTime($user."msDS-UserPasswordExpiryTimeComputed")
        $daysLeft = ($expiryDate - (Get-Date)).Days

        # Belirlenen günlerden birine eşitse ve mail adresi varsa
        if ($user.mail -and $expiryDaysList -contains $daysLeft) {
            $body = [string]::Format($bodyTemplate, $user.DisplayName, $daysLeft)

            # E-posta gönder
            Send-MailMessage -To $user.mail -From $from -Subject $subject -Body $body -SmtpServer $smtpServer
        }
    }
}
