def create_site(name, started, path = 'C:\inetpub\wwwroot')
  create_path(path)
  on(default, "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command \"& {New-Website -Name '#{name}' -PhysicalPath '#{path}'}\"")
  if(started == true)
    on(default, "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command \"& {Start-Website -Name '#{name}'}\"")
  else
    on(default, "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command \"& {Stop-Website -Name '#{name}'}\"")
  end
end

def create_path(path)
  on(default, "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command \"& { New-Item -ItemType Directory -Force -Path '#{path}' }\"")
end

def remove_all_sites
  on(default, "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command \"& {Get-Website | Remove-Website}\"")
end
