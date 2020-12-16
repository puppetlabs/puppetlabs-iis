# frozen_string_literal: true

def has_app(app_name)
  command = format_powershell_iis_command("Get-WebApplication -Name #{app_name}")
  !(run_shell(command).stdout =~ %r{Started}i).nil?
end

def create_app(site_name, app_name, directory = nil)
  physicalpath_dash = directory ? "-PhysicalPath #{directory}" : ''
  command = format_powershell_iis_command("New-WebApplication -Site #{site_name} -Name #{app_name} #{physicalpath_dash} -Force -ErrorAction Stop")
  run_shell(command) unless has_app(app_name)
end

def remove_app(app_name)
  command = format_powershell_iis_command("Remove-WebApplication -Name #{app_name}")
  run_shell(command) if has_app(app_name)
end

def create_virtual_directory(site, name, directory)
  command = format_powershell_iis_command("New-WebVirtualDirectory -Site #{site} -Name #{name} -physicalPath #{directory} -Force -ErrorAction Stop")
  run_shell(command)
end
