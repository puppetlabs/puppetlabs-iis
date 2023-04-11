# frozen_string_literal: true

def has_app_pool(pool_name)
  command = format_powershell_iis_command("Get-WebAppPoolState -Name #{pool_name}")
  result = run_shell(command, expect_failures: true)
  return false if result.exit_code != 0

  true
end

def app_pool_started(pool_name)
  command = format_powershell_iis_command("Get-WebAppPoolState -Name #{pool_name}")
  !(run_shell(command).stdout =~ %r{Started}i).nil?
end

def create_app_pool(pool_name)
  command = format_powershell_iis_command("New-WebAppPool -Name #{pool_name}")
  run_shell(command) unless has_app_pool(pool_name)
end

def remove_app_pool(pool_name)
  command = format_powershell_iis_command("Remove-WebAppPool -Name #{pool_name}")
  run_shell(command) if has_app_pool(pool_name)
end

def stop_app_pool(pool_name)
  command = format_powershell_iis_command("Stop-WebAppPool -Name #{pool_name}")
  run_shell(command) if app_pool_started(pool_name)
end
