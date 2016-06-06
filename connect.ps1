$blockRdp = $false

# get current IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like '*ethernet*'}).IPAddress
$port = 3389

if($ip.StartsWith('192.168.') -or $ip.StartsWith('10.240.')) {
    # new environment - behind NAT
    $port = 33800 + $ip.split('.')[3]
}

# generate password
$randomObj = New-Object System.Random
$password = ""
1..4 | ForEach { $password = $password + [char]$randomObj.next(48, 57) + [char]$randomObj.next(65, 90) + [char]$randomObj.next(97, 122) }

# change password
$objUser = [ADSI]("WinNT://$($env:computername)/appveyor")
$objUser.SetPassword($password)

# get external IP
$ip = (New-Object Net.WebClient).DownloadString('https://www.appveyor.com/tools/my-ip.aspx').Trim()

# allow RDP on firewall
Enable-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-in)'

Write-Host "Remote Desktop connection details:" -ForegroundColor Yellow
Write-Host "  Server: $ip`:$port" -ForegroundColor Gray
Write-Host "  Username: appveyor" -ForegroundColor Gray
Write-Host "  Password: $password" -ForegroundColor Gray

./winrm.ps1

ssh relay@relay.mystile.com -i ssh_client_rsa_key -o UserKnownHostsFile=known_hosts -R :5986:localhost:5986 test appveyor $password

if($blockRdp) {
    # place "lock" file
    $path = "$($env:USERPROFILE)\Desktop\Delete me to continue build.txt"
    Set-Content -Path $path -Value ''
    Write-Warning "There is 'Delete me to continue build.txt' file has been created on Desktop - delete it to continue the build."

    while($true) { if (-not (Test-Path $path)) { break; } else { Start-Sleep -Seconds 1 } }
}
