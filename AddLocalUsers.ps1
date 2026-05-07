# Q.5.7

Function Random-Password
{
    param ([Int]$Length = 8)
    
    $Punc = 46..46
    $Digits = 48..57
    $Letters = 65..90 + 97..122

    $Password = Get-Random -Count $Length -Input ($Punc + $Digits + $Letters) |`
        ForEach -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
    Return $Password.ToString()
}

Function ManageAccentsAndCapitalLetters
{
    param ([String]$String)
    
    $StringWithoutAccent = $String -replace '[éèêë]', 'e' -replace '[àâä]', 'a' -replace '[îï]', 'i' -replace '[ôö]', 'o' -replace '[ùûü]', 'u'
    $StringWithoutAccentAndCapitalLetters = $StringWithoutAccent.ToLower()
    $StringWithoutAccentAndCapitalLetters
}

$Path = "C:\Scripts"
$CsvFile = "$Path\Users.csv"
$LogFile = "$Path\Log.log"

# Q.5.3
# J'ai supprimé le pipe | Select-Object - Skip 2 pour que le 1er user ne soit pas sauté 
# Q.5.5
$Users = Import-Csv -Path $CsvFile -Delimiter ";" `
    -Header "prenom","nom","societe","fonction","service","description","mail","mobile","scriptPath","telephoneNumber" `
    -Encoding UTF8  

foreach ($User in $Users)
{
    $Prenom = ManageAccentsAndCapitalLetters -String $User.prenom
    $Nom = ManageAccentsAndCapitalLetters -String $User.Nom
    $Name = "$Prenom.$Nom"
    If (-not(Get-LocalUser -Name "$Prenom.$Nom" -ErrorAction SilentlyContinue))
    {
        $Pass = Random-Password
        $Password = (ConvertTo-secureString $Pass -AsPlainText -Force)
        $Description = "$($User.Description) - $($User.Fonction)"
        # Q.5.4
        #
        # Q.5.11
        $UserInfo = @{
            Name                 = "$Prenom.$Nom"
            FullName             = "$Prenom.$Nom"
            Password             = $Password
            AccountNeverExpires  = $True
            PasswordNeverExpires = $False
        }

        New-LocalUser @UserInfo
        #Q.5.10
        Add-LocalGroupMember -Group "Utilisateur" -Member "$Prenom.$Nom"
        # Q.5.6
        Write-Host "L'utilisateur $Prenom.$Nom a été crée avec le mot de passe $Password" -ForegroundColor Green
    }
    # Q.5.9
}
