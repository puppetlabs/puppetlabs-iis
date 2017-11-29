def has_vdir(vdir_name)
  command = format_powershell_iis_command("Get-WebVirtualDirectory -Name #{@vdir_name}")
  !(on(default, command).stdout =~ /Name/i).nil?
end

def create_vdir(vdir_name, site = 'foo', path = 'C:\inetpub\wwwroot')
  command = format_powershell_iis_command("New-WebVirtualDirectory -Name #{@vdir_name} -Site #{@site} -PhysicalPath #{@path}")
  on(default, command) unless has_vdir(vdir_name)
end

def remove_vdir(vdir_name, site = 'foo', path = 'C:\inetpub\wwwroot')
  command = format_powershell_iis_command("Remove-WebVirtualDirectory -Name #{vdir_name} -Site #{@site} -PhysicalPath #{@path}")
  on(default, command) if has_vdir(vdir_name)
end

def stop_vdir(vdir_name)
  command = format_powershell_iis_command("Stop-WebVirtualDirectory -Name #{@vdir_name}")
  on(default, command) if has_vdir(vdir_name)
end
