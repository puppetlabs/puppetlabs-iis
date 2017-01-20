def has_app_pool(pool_name)
  !(on(default, "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command \"& {Get-WebAppPoolState -Name #{@pool_name}}\"").stdout =~ /Started/i).nil?
end

def create_app_pool(pool_name)
  on(default, "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command \"& {New-WebAppPool -Name #{@pool_name}}\"") unless has_app_pool(pool_name)
end

def remove_app_pool(pool_name)
  on(default, "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command \"& {Remove-WebAppPool -Name #{@pool_name}}\"") if has_app_pool(pool_name)
end

def stop_app_pool(pool_name)
  on(default, "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command \"& {Stop-WebAppPool -Name #{@pool_name}}\"") if has_app_pool(pool_name)
end
