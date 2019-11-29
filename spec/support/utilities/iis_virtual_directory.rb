def has_vdir(_vdir_name)
  command = format_powershell_iis_command("Get-WebVirtualDirectory -Name #{@vdir_name}")
  !(on(default, command).stdout =~ %r{Name}i).nil?
end

def create_vdir(vdir_name, _site = 'foo', _path = 'C:\inetpub\wwwroot')
  command = format_powershell_iis_command("New-WebVirtualDirectory -Name #{@vdir_name} -Site #{@site} -PhysicalPath #{@path}")
  on(default, command) unless has_vdir(vdir_name)
end

def remove_vdir(vdir_name, _site = 'foo', _path = 'C:\inetpub\wwwroot')
  command = format_powershell_iis_command("Remove-Item -Path 'IIS:\\Sites\\#{@site}\\#{@vdir_name}' -Recurse -ErrorAction Stop")
  on(default, command) if has_vdir(vdir_name)
end

def stop_vdir(vdir_name)
  command = format_powershell_iis_command("Stop-WebVirtualDirectory -Name #{@vdir_name}")
  on(default, command) if has_vdir(vdir_name)
end
