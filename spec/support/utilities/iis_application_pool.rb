def has_app_pool(pool_name)
  command = format_powershell_iis_command("Get-WebAppPoolState -Name #{@pool_name}")
  !(on(default, command).stdout =~ /Started/i).nil?
end

def create_app_pool(pool_name)
  command = format_powershell_iis_command("New-WebAppPool -Name #{@pool_name}")
  on(default, command) unless has_app_pool(pool_name)
end

def remove_app_pool(pool_name)
  command = format_powershell_iis_command("Remove-WebAppPool -Name #{@pool_name}")
  on(default, command) if has_app_pool(pool_name)
end

def stop_app_pool(pool_name)
  command = format_powershell_iis_command("Stop-WebAppPool -Name #{@pool_name}")
  on(default, command) if has_app_pool(pool_name)
end
