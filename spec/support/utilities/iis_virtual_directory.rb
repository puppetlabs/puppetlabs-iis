# frozen_string_literal: true

def has_vdir(vdir_name)
  command = format_powershell_iis_command("Get-WebVirtualDirectory -Name #{vdir_name}")
  result = run_shell(command, expect_failure: true)
  if result.exit_code == 0
    !(result.stdout =~ %r{Name}i).nil?
  else
    false
  end
end

def create_vdir(vdir_name, site = 'foo', path = 'C:\inetpub\wwwroot')
  command = format_powershell_iis_command("New-WebVirtualDirectory -Name #{vdir_name} -Site #{site} -PhysicalPath #{path}")
  run_shell(command) unless has_vdir(vdir_name)
end

def remove_vdir(vdir_name, site = 'foo')
  command = format_powershell_iis_command("Remove-Item -Path 'IIS:\\Sites\\#{site}\\#{vdir_name}' -Recurse -ErrorAction Stop")
  run_shell(command) if has_vdir(vdir_name)
end

def stop_vdir(vdir_name)
  command = format_powershell_iis_command("Stop-WebVirtualDirectory -Name #{vdir_name}")
  run_shell(command) if has_vdir(vdir_name)
end
