Import-Module ActiveDirectory

# Define your paths and domain information
$CSVPath = "C:\LabAutomation\new_hires.csv"
$Domain = "corp.local" # <--- Change this to match YOUR domain name if different

# Check if CSV exists before running
if (-not (Test-Path $CSVPath)) {
    Write-Error "CSV file not found at $CSVPath. Please check the path!"
    return
}

$Users = Import-Csv -Path $CSVPath

# Step 1: Ensure the Parent "CorpUsers" OU exists once before the loop
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'CorpUsers'")) {
    New-ADOrganizationalUnit -Name "CorpUsers" -Path "DC=corp,DC=local" # <--- Update DC components
    Write-Host "Created Top-Level OU: CorpUsers" -ForegroundColor Green
}

foreach ($User in $Users) {
    # Properly extract variables from the current row object
    $Firstname = $User.Firstname
    $Lastname = $User.Lastname
    $Department = $User.Department
    $Title = $User.Title
    
    # Properly construct enterprise username pattern using subexpressions (e.g., john.doe)
    $Username = "$($Firstname.ToLower()).$($Lastname.ToLower())"
    $UPN = "$Username@$Domain"
    
    # Dynamically inject the department into the target OU path
    $TargetOU = "OU=$Department,OU=CorpUsers,DC=corp,DC=local" # <--- Update DC components to match your domain

    # Step 2: Ensure the Department OU exists under CorpUsers
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$Department'")) {
        New-ADOrganizationalUnit -Name $Department -Path "OU=CorpUsers,DC=corp,DC=local" # <--- Update DC components
        Write-Host "Created Department OU: $Department" -ForegroundColor Green
    }

    # Step 3: Create the actual user account if it doesn't already exist
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$Username'")) {
        # Create a secure temporary password
        $SecurePassword = ConvertTo-SecureString "TempPass2026!" -AsPlainText -Force

        # Construct the Display Name properly
        $DisplayName = "$Firstname $Lastname"

        New-ADUser -Name $DisplayName `
                   -SamAccountName $Username `
                   -UserPrincipalName $UPN `
                   -GivenName $Firstname `
                   -Surname $Lastname `
                   -Department $Department `
                   -Title $Title `
                   -Path $TargetOU `
                   -AccountPassword $SecurePassword `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true
        
        Write-Host "Successfully onboarded user: $Username inside $Department OU" -ForegroundColor Cyan
    } else {
        Write-Host "User Account $Username already exists. Skipping." -ForegroundColor Yellow
    }
}