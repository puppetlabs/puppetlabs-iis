Puppet::Type.type(:iis_webconfigurationproperty).provide(:iis_webconfigurationproperty) do
	confine :operatingsystem => :windows
	defaultfor :operatingsystem => :windows

	commands :powershell =>
		if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
			"#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
		elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
			"#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
		else
			'powershell.exe'
		end

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
		powershell("(Get-WebConfigurationProperty #{str_address}).Value").strip
	end

	def value=(value)
		str_address = address(resource.to_hash).join(" ")
		powershell("Set-WebConfigurationProperty #{str_address} -Value \"#{value}\"")
	end
end