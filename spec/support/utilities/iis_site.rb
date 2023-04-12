# frozen_string_literal: true

def create_site(name, started, path = 'C:\inetpub\wwwroot')
  create_path(path)
  # These commands are executed in bash therefore things need to be escaped properly
  run_shell(format_powershell_iis_command("$params = @{Name = '#{name}'; PhysicalPath = '#{path}'}; " \
                                          "If ((Get-ChildItem 'IIS:\\sites' | Measure-Object).Count -eq 0) { $params['Id'] = 1 }; New-Website @params"))
  command = if started == true
              format_powershell_iis_command("Start-Website -Name '#{name}'")
            else
              format_powershell_iis_command("Stop-Website -Name '#{name}'")
            end
  run_shell(command)
end

def create_path(path)
  run_shell(interpolate_powershell("New-Item -ItemType Directory -Force -Path '#{path}'"))
end

def remove_all_sites
  run_shell(format_powershell_iis_command('Get-Website | Remove-Website'))
end
