require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_webhandler).provide(:iis_webhandler, parent: Puppet::Provider::IIS_PowerShell) do
  confine    :iis_version     => ['7.0', '7.5', '8.0', '8.5', '10.0']
  confine    :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  desc <<-EOT
    Manage IIS request handlers.

    Example:
    iis_webhandler {'svc-ISAPI-4.0_32bit':
      path            => '*.svc',
      verb            => '*',
      modules         => 'IsapiModule',
      scriptprocessor => '%windir%\\Microsoft.NET\\Framework\\v4.0.30319\\aspnet_isapi.dll',
    }
  EOT

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
    @convert = {
      :path            => 'Path',
      :verb            => 'Verb',
      :type            => 'Type',
      :modules         => 'Modules',
      :precondition    => 'Precondition',
      :scriptprocessor => 'ScriptProcessor',
      :resourcetype    => 'ResourceType',
      :requireaccess   => 'RequiredAccess',
    }
  end

  def self.get_webhandlers
    cmd = "Get-WebConfiguration -Recurse -Filter /system.webServer/handlers/add | select Name,Path,Verb,Type,Modules,ScriptProcessor,Precondition,ResourceType,RequireAccess,Location,PSPath"
    result = self.class.run(cmd)
    # convert all keys to lowercase symbols and all values to string
    result.to_a.map {|hash| hash.inject({}){|memo,(k,v)| memo[k.downcase.to_sym] = v.to_s; memo}}
  end

  def self.instances
    get_webhandlers.map do |webhandler|
      webhandler[:ensure] = :present
      new(webhandler)
    end
  end

  def self.prefetch(resources)
    # https://tickets.puppetlabs.com/browse/PUP-5302
    catalog = resources.values.first.catalog

    webhandlers = catalog.resources.find_all do |e|
      e.class.to_s.downcase == 'puppet::type::iis_webhandler'
    end

    webhandlers_keys = Hash[webhandlers.map(&:uniqueness_key).zip(webhandlers)]

    webhandler_providers = instances

    webhandlers_keys.keys.each do |resource_location, resource_name, resource_pspath|
      # Accept empty location and pspath and interpret them as default
      if resource_location.nil?
        resource_location = ''
      end
      if resource_pspath.nil?
        resource_pspath = 'MACHINE/WEBROOT/APPHOST'
      end
      provider = webhandler_providers.find do |webhandler|
        webhandler_name = webhandler.name
        webhandler_location = webhandler.location
        webhandler_pspath = webhandler.pspath
        ((resource_name == webhandler_name)&&(resource_location == webhandler_location)&&(resource_pspath == webhandler_pspath))
      end
      if provider
        provider_name = provider.name
        provider_location = provider.location
        provider_pspath = provider.pspath

        resource = webhandlers_keys[[provider_location, provider_name, provider_pspath]]

        resource.provider = provider
      end
    end
  end

  def path=(value)
    @property_flush[:path] = value
  end

  def verb=(value)
    @property_flush[:verb] = value
  end

  def type=(value)
    @property_flush[:type] = value
  end

  def modules=(value)
    @property_flush[:modules] = value
  end

  def scriptprocessor=(value)
    @property_flush[:scriptprocessor] = value
  end

  def precondition=(value)
    @property_flush[:precondition] = value
  end

  def resourcetype=(value)
    @property_flush[:resourcetype] = value
  end

  def requireaccess=(value)
    @property_flush[:requireaccess] = value
  end

  def arguments(resource)
    array_arguments = []
    labels = [:path, :verb, :type, :modules, :scriptprocessor, :precondition, :resourcetype, :requireaccess]
    resource.select{ |key, value| labels.include?(key)}.each do |key,value|
      case key
      when :requireaccess
        array_arguments << '-RequiredAccess'
        array_arguments << value.to_s.capitalize
      else
        array_arguments << "-#{@convert[key]}"
        array_arguments << %Q{"#{value}"}
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

  def set_webhandler
    if @property_flush
      str_address = address(resource.to_hash).join(" ")
      case @property_flush[:ensure]
      when :present
        # create
        if not( resource[:path] and resource[:verb] )
          raise ArgumentError, "path and verb are mandatory for iis_webhandler"
        end
        str_arguments = arguments(resource.to_hash).join(" ")
        powershell("New-WebHandler -Name #{resource[:name]} #{str_address} #{str_arguments}")
      when :absent
        # destroy
        powershell("Remove-WebHandler -Name #{resource[:name]} #{str_address}")
      when nil
        # update
        str_arguments = arguments(@property_flush).join(" ")
        if ! array_arguments.empty?
          powershell("Set-WebHandler -Name #{resource[:name]} #{str_address} #{str_arguments}")
        end
      end
    end
  end

  def flush
    set_webhandler
    @property_hash = self.class.get_webhandlers()
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end
end