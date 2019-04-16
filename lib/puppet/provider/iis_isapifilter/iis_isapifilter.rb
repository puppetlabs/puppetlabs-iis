require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_isapifilter).provide(:iis_isapifilter, parent: Puppet::Provider::IIS_PowerShell) do
  confine    :iis_version     => ['7.0', '7.5', '8.0', '8.5', '10.0']
  confine    :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  desc <<-EOT
    Manage IIS HTTP error responses.

    Example:
    iis_isapifilter {'ASP.Net_4.0_32bit':
      enabled                => true,
      enablecache            => true,
      path                   => '%windir%\\Microsoft.NET\\Framework\\v4.0.30319\\aspnet_filter.dll',
      precondition           => 'runtimeVersionv4.0,bitness32',
    }
  EOT

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.get_isapifilters
    cmd = "Get-WebConfiguration -Recurse -Filter /system.webServer/isapiFilters/filter | select name,enableCache,enabled,path,preCondition,Location,PSPath"
    result = self.class.run(cmd)
    # convert all keys to lowercase symbols and all values to string
    result.to_a.map {|hash| hash.inject({}){|memo,(k,v)| memo[k.downcase.to_sym] = v.to_s; memo}}
  end

  def self.instances
    get_isapifilters.map do |isapifilter|
      case isapifilter[:enabled]
      when true, "true", :true
        isapifilter[:enabled] = :true
      when false, "false", :false
        isapifilter[:enabled] = :false
      end
      case isapifilter[:enablecache]
      when true, "true", :true
        isapifilter[:enablecache] = :true
      when false, "false", :false
        isapifilter[:enablecache] = :false
      end
      isapifilter[:ensure] = :present
      isapifilter[:provider] = :iis_isapifilter
      new(isapifilter)
    end
  end

  def self.prefetch(resources)
    # https://tickets.puppetlabs.com/browse/PUP-5302
    catalog = resources.values.first.catalog

    isapifilters = catalog.resources.find_all do |e|
      e.class.to_s.downcase == 'puppet::type::iis_isapifilter'
    end

    isapifilters_keys = Hash[isapifilters.map(&:uniqueness_key).zip(isapifilters)]

    isapifilter_providers = instances

    isapifilters_keys.keys.each do |resource_location, resource_name, resource_pspath|
      # Accept empty location and pspath and interpret them as default
      if resource_location.nil?
        resource_location = ''
      end
      if resource_pspath.nil?
        resource_pspath = 'MACHINE/WEBROOT/APPHOST'
      end
      provider = isapifilter_providers.find do |isapifilter|
        isapifilter_name = isapifilter.name
        isapifilter_location = isapifilter.location
        isapifilter_pspath = isapifilter.pspath
        ((resource_name == isapifilter_name)&&(resource_location == isapifilter_location)&&(resource_pspath == isapifilter_pspath))
      end
      if provider
        provider_name = provider.name
        provider_location = provider.location
        provider_pspath = provider.pspath

        resource = isapifilters_keys[[provider_location, provider_name, provider_pspath]]

        resource.provider = provider
      end
    end
  end

  def enablecache=(value)
    @property_flush[:enablecache] = value
  end

  def enabled=(value)
    @property_flush[:enabled] = value
  end

  def path=(value)
    @property_flush[:path] = value
  end

  def precondition=(value)
    @property_flush[:precondition] = value
  end

  def arguments(resource)
    array_arguments = []
    resource.each do |key,value|
      case key
      when :path
        array_arguments << "#{key.to_s}=\"#{value}\""
      when :precondition
        array_arguments << "preCondition=\"#{value}\""
      when :enabled
        case value
        when :true
          array_arguments << "enabled=\"true\""
        when :false
          array_arguments << "enabled=\"false\""
        end
      when :enablecache
        case value
        when :true
          array_arguments << "enableCache=\"true\""
        when :false
          array_arguments << "enableCache=\"false\""
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

  def set_isapifilter
    if @property_flush
      str_address = address(resource.to_hash).join(" ")
      case @property_flush[:ensure]
      when :present
        str_arguments = arguments(resource.to_hash).join(";")
        powershell("Add-WebConfiguration -Filter /system.webServer/isapiFilters #{str_address} -Value @{name=\"#{resource[:name]}\";#{str_arguments}}")
      when :absent
        powershell("Clear-WebConfiguration -Filter \"/system.webServer/isapiFilters/filter[@name='#{resource[:name]}']\" #{str_address}")
      when nil
        str_arguments = arguments(@property_flush).join(";")
        if ! str_arguments.empty?
          powershell("Set-WebConfiguration -Filter \"/system.webServer/isapiFilters/filter[@name='#{resource[:name]}']\" #{str_address} -Value @{#{str_arguments}}")
        end
      end
    end
  end

  def flush
    set_isapifilter
    @property_hash = self.class.get_isapifilters()
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end
end
