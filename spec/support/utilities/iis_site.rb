def create_site(name, started, path = 'C:\inetpub\wwwroot')
  create_path(path)
  on(default, format_powershell_iis_command("New-Website -Name '#{name}' -PhysicalPath '#{path}'"))
  if(started == true)
    command = format_powershell_iis_command("Start-Website -Name '#{name}'}")
  else
    command = format_powershell_iis_command("Stop-Website -Name '#{name}'}")
  end
  on(default, command)
end

def create_path(path)
  on(default, format_powershell_iis_command("New-Item -ItemType Directory -Force -Path '#{path}'"))
end

def remove_all_sites
  on(default, format_powershell_iis_command("Get-Website | Remove-Website"))
end
