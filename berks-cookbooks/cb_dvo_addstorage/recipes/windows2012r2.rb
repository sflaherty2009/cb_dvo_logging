#
# Cookbook:: cb_dvo_addStorage
# Recipe:: windows2012r2
#
# Copyright (c) 2017 Ray Crawford,
# Trek Bicycle Corporation, All Rights Reserved.
#

powershell_script 'add-drives' do
  code <<-EOH
  if (!(Test-Path S:)) {
    Stop-Service -Name ShellHWDetection
    $standardDrives = @()
    $standardDrives = (Get-PhysicalDisk | Where-Object -FilterScript {($_.CanPool -eq $true) -and ($_.Size -eq 1051193245696)})

    if ($standardDrives) {
      New-StoragePool -FriendlyName "Standard_SP" -StorageSubSystemUniqueId (Get-StorageSubSystem -FriendlyName "*Storage*").uniqueID -PhysicalDisks $standardDrives
      New-VirtualDisk -FriendlyName "Standard_VD" -StoragePoolFriendlyName "Standard_SP" -UseMaximumSize -ResiliencySettingName Simple
      Initialize-Disk -Number (Get-VirtualDisk -FriendlyName "Standard_VD" | Get-Disk).Number
      New-Partition -DiskNumber (Get-VirtualDisk -FriendlyName "Standard_VD" | Get-Disk).Number -UseMaximumSize -DriveLetter S
      Format-Volume -DriveLetter S -FileSystem NTFS -NewFileSystemLabel "Azure Standard Storage" -Confirm:$false
      Start-Service -Name ShellHWDetection

      $acl = Get-Acl ('S:')
      $account = new-object System.Security.Principal.NTAccount('Everyone')
      $acl.PurgeAccessRules($account)
      $rule = New-Object System.Security.AccessControl.FileSystemAccessRule ('Users', 'FullControl', 'Allow')
      $acl.SetAccessRule($rule)
      Set-Acl -AclObject $acl -path 'S:'
    }
  }

  if (!(Test-Path P:)) {
    Stop-Service -Name ShellHWDetection
    $premiumDrives = @()
    $premiumDrives = (Get-PhysicalDisk | Where-Object -FilterScript {($_.CanPool -eq $true) -and ($_.Size -ne 1051193245696)})

    if ($premiumDrives) {
      New-StoragePool -FriendlyName "Premium_SP" -StorageSubSystemUniqueId (Get-StorageSubSystem -FriendlyName "*Space*").uniqueID -PhysicalDisks $premiumDrives
      New-VirtualDisk -FriendlyName "Premium_VD" -StoragePoolFriendlyName "Premium_SP" -UseMaximumSize -ResiliencySettingName Simple
      Initialize-Disk -Number (Get-VirtualDisk -FriendlyName "Premium_VD" | Get-Disk).Number
      New-Partition -DiskNumber (Get-VirtualDisk -FriendlyName "Premium_VD" | Get-Disk).Number -UseMaximumSize -DriveLetter P
      Format-Volume -DriveLetter P -FileSystem NTFS -NewFileSystemLabel "Azure Premium Storage" -Confirm:$false
      Start-Service -Name ShellHWDetection

      $acl = Get-Acl ('P:')
      $account = new-object System.Security.Principal.NTAccount('Everyone')
      $acl.PurgeAccessRules($account)
      $rule = New-Object System.Security.AccessControl.FileSystemAccessRule ('Users', 'FullControl', 'Allow')
      $acl.SetAccessRule($rule)
      Set-Acl -AclObject $acl -path 'P:'
    }
  }
  EOH
  not_if '(Test-Path S:) -or (Test-Path P:)'
end

ruby_block 'Set storage class attributes' do
  block do
    node.normal['dvo']['storage']['standard_available'] = Dir.exist?('S:/')
    node.normal['dvo']['storage']['premium_available'] = Dir.exist?('P:/')
  end
  not_if { node.normal['dvo']['storage'].attribute?('standard_available') || node.normal['dvo']['storage'].attribute?('premium_available') }
end
