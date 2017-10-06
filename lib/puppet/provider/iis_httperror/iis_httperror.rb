require 'json'

Puppet::Type.type(:iis_httperror).provide(:iis_httperror) do
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
		Manage IIS HTTP error responses.

		Example:
		iis_httperror {'402':
			prefixlanguagefilepath => '%SystemDrive%\\inetpub\\custerr',
			path                   => '402.htm',
			responsemode           => 'file',
		}
	EOT

	mk_resource_methods

	def initialize(value={})
		super(value)
		@property_flush = {}
	end

	def exists?
		@property_hash[:ensure] == :present
	end

	def self.get_httperrors
		output = powershell("Get-WebConfiguration -Recurse -Filter /system.webServer/httpErrors/error | select statusCode,subStatusCode,prefixLanguageFilePath,path,responseMode,Location,PSPath | ConvertTo-Json")
		json = (output.nil? || output.empty?) ? Array.new : JSON.parse(output).to_a
		json.map {|hash| hash.inject({}){|memo,(k,v)| memo[k.downcase.to_sym] = v.to_s; memo}}
	end

	def self.instances
		get_httperrors.map do |httperror|
			if httperror[:substatuscode].to_s == '-1'
				httperror[:name] = httperror[:statuscode]
			else
				httperror[:name] = "#{httperror[:statuscode]}\.#{httperror[:substatuscode]}"
			end
			httperror.delete(:statuscode)
			httperror.delete(:substatuscode)
			httperror[:ensure] = :present
			httperror[:provider] = :iis_httperror
			new(httperror)
		end
	end

	def self.prefetch(resources)
		# https://tickets.puppetlabs.com/browse/PUP-5302
		catalog = resources.values.first.catalog

		httperrors = catalog.resources.find_all do |e|
			e.class.to_s.downcase == 'puppet::type::iis_httperror'
		end

		httperrors_keys = Hash[httperrors.map(&:uniqueness_key).zip(httperrors)]

		httperror_providers = instances

		httperrors_keys.keys.each do |resource_location, resource_name, resource_pspath|
			# Accept empty location and pspath and interpret them as default
			if resource_location.nil?
				resource_location = ''
			end
			if resource_pspath.nil?
				resource_pspath = 'MACHINE/WEBROOT/APPHOST'
			end
			provider = httperror_providers.find do |httperror|
				httperror_name = httperror.name
				httperror_location = httperror.location
				httperror_pspath = httperror.pspath
				((resource_name == httperror_name)&&(resource_location == httperror_location)&&(resource_pspath == httperror_pspath))
			end
			if provider
				provider_name = provider.name
				provider_location = provider.location
				provider_pspath = provider.pspath

				resource = httperrors_keys[[provider_location, provider_name, provider_pspath]]

				resource.provider = provider
			end
		end
	end

	def prefixlanguagefilepath=(value)
		@property_flush[:prefixlanguagefilepath] = value
	end

	def path=(value)
		@property_flush[:path] = value
	end

	def responsemode=(value)
		@property_flush[:responsemode] = value
	end

	def arguments(resource)
		array_arguments = []
		resource.each do |key,value|
			case key
			when :path
				array_arguments << "#{key.to_s.capitalize}=\"#{value}\""
			when :prefixlanguagefilepath
				array_arguments << "prefixLanguageFilePath=\"#{value}\""
			when :responsemode
				case value.to_s.downcase
				when 'file'
					array_arguments << "responseMode=\"File\""
				when 'executeurl'
					array_arguments << "responseMode=\"ExecuteURL\""
				when 'redirect'
					array_arguments << "responseMode=\"Redirect\""
				end
			end
		end
		array_arguments
	end

	def address(resource)
		array_address = []
		resource.each do |key,value|
			case key
			when :pspath
				array_address << "-PSPath \"#{value}\"" unless value == 'MACHINE/WEBROOT/APPHOST'
			when :location
				array_address << "-Location \"#{value}\"" unless value == ''
			end
		end
		array_address
	end

	def set_httperror
		/^((?<statuscode>[4-9][0-9]{2})|(?<statuscode>[4-9][0-9]{2})\.(?<substatuscode>[0-9]{1,3}))$/ =~ resource[:name]
		substatuscode = '-1' unless substatuscode
		if @property_flush
			str_address = address(resource.to_hash).join(" ")
			case @property_flush[:ensure]
			when :present
				str_arguments = arguments(resource.to_hash).join(";")
				powershell("Add-WebConfiguration -Filter /system.webServer/httpErrors #{str_address} -Value @{statusCode=#{statuscode};subStatusCode=#{substatuscode};#{str_arguments}}")
			when :absent
				powershell("Clear-WebConfiguration -Filter /system.webServer/httpErrors/error[@statusCode='#{statuscode}'][@subStatusCode='#{substatuscode}'] #{str_address}")
			when nil
				str_arguments = arguments(@property_flush).join(";")
				Puppet.debug "Args: #{@property_flush}"
				if ! str_arguments.empty?
					powershell("Set-WebConfiguration -Filter /system.webServer/httpErrors/error[@statusCode='#{statuscode}'][@subStatusCode='#{substatuscode}'] #{str_address} -Value @{#{str_arguments}}")
				end
			end
		end
	end

	def flush
		set_httperror
		@property_hash = self.class.get_httperrors()
	end

	def create
		@property_flush[:ensure] = :present
	end

	def destroy
		@property_flush[:ensure] = :absent
	end
end