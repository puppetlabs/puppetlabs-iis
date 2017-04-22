def format_powershell_iis_command(ps_command)
  command = []
  command << "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -noninteractive -noprofile -executionpolicy bypass -command "
  command << "\"& {"
  command << "Import-Module WebAdministration -ErrorAction Stop;"
  command << "cd iis: ;"
  command << ps_command
  command << "}\" < /dev/null"
  return command.join
end
