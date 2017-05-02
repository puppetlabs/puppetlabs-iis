def create_site(name, started, path = 'C:\inetpub\wwwroot')
  create_path(path)
  # These commands are executed in bash therefore things need to be escaped properly
  on(default, format_powershell_iis_command("\\$params = @{Name = '#{name}'; PhysicalPath = '#{path}'}; If ((Get-ChildItem 'IIS:\\sites' | Measure-Object).Count -eq 0) { \\$params['Id'] = 1 }; New-Website @params"))
  if(started == true)
    command = format_powershell_iis_command("Start-Website -Name '#{name}'")
  else
    command = format_powershell_iis_command("Stop-Website -Name '#{name}'")
  end
  on(default, command)
end

def create_path(path)
  on(default, format_powershell_iis_command("New-Item -ItemType Directory -Force -Path '#{path}'"))
end

def remove_all_sites
  on(default, format_powershell_iis_command("Get-Website | Remove-Website"))
end
