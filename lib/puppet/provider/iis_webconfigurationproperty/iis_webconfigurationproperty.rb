require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_webconfigurationproperty).provide(:iis_webconfigurationproperty, parent: Puppet::Provider::IIS_PowerShell) do
  confine    :iis_version     => ['7.0', '7.5', '8.0', '8.5', '10.0']
  confine    :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  desc <<-EOT
    Manage IIS web configuration properties.

    Example:

    iis_webconfigurationproperty {'Config History on D drive':
      filter => '/system.applicationHost/configHistory',
      name   => 'path',
      value  => 'D:\inetpub\History',
    }
  EOT

  def address(resource)
    array_address = []
    resource.each do |key,value|
      case key
      when :pspath
        array_address << "-PSPath \"#{value}\"" unless value == 'MACHINE/WEBROOT/APPHOST'
      when :location
        array_address << "-Location \"#{value}\"" unless value == ''
      when :filter
        array_address << "-Filter \"#{value}\""
      when :name
        array_address << "-Name \"#{value}\""
      end
    end
    array_address
  end

  def value
    str_address = address(resource.to_hash).join(" ")
    cmd = "(Get-WebConfigurationProperty #{str_address}).Value"
    self.class.run(cmd).strip
  end

  def value=(value)
    str_address = address(resource.to_hash).join(" ")
    cmd = "Set-WebConfigurationProperty #{str_address} -Value \"#{value}\""
    self.class.run(cmd)
  end
end
