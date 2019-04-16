require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_mimetype).provide(:iis_mimetype, parent: Puppet::Provider::IIS_PowerShell) do
  confine    :iis_version     => ['7.0', '7.5', '8.0', '8.5', '10.0']
  confine    :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  commands :powershell => PuppetX::IIS::PowerShellCommon.powershell_path

  desc <<-EOT
    Manage IIS unique MIME types in the collection of static content types.

    Example:
    iis_mimetype {'.zip':
      mimetype => 'application/x-zip-compressed',
    }
  EOT

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.get_mimetypes
    cmd = "Get-WebConfiguration -Recurse -Filter /system.webServer/staticContent/mimeMap | select fileExtension,mimeType,Location,PSPath | ConvertTo-Json"
    result = run(cmd)

    #cmd = ps_script_content('_getvirtualdirectories', @resource)
    #result   = run(cmd)
    return [] if result.nil?

    json = self.parse_json_result(result[:stdout])
    return [] if json.nil?

    # convert all keys to lowercase symbols and all values to string
    json.to_a.map {|hash| hash.inject({}){|memo,(k,v)| memo[k.downcase.to_sym] = v.to_s; memo}}
  end

  def name
    array_namevars = []
    array_namevars << "#{@property_hash[:fileextension]}"
    array_namevars << "pspath: #{@property_hash[:pspath]}" unless @property_hash[:pspath].nil? || @property_hash[:pspath] == 'MACHINE/WEBROOT/APPHOST'
    array_namevars << "location: #{@property_hash[:location]}" unless @property_hash[:location].nil? || @property_hash[:location] == ''
    array_namevars.join(", ")
  end

  def self.instances
    get_mimetypes.map do |mimetype|
      mimetype[:ensure] = :present
      new(mimetype)
    end
  end

  def self.prefetch(resources)
    # https://tickets.puppetlabs.com/browse/PUP-5302
    catalog = resources.values.first.catalog

    mimetypes = catalog.resources.find_all do |e|
      e.class.to_s.downcase == 'puppet::type::iis_mimetype'
    end

    mimetypes_keys = Hash[mimetypes.map do |mimetype|[mimetype[:fileextension],mimetype[:pspath],mimetype[:location]] end.zip(mimetypes)]

    mimetype_providers = instances

    mimetypes_keys.keys.each do |resource_fileextension, resource_pspath, resource_location|
      # Accept empty location and pspath and interpret them as default
      if resource_location.nil?
        resource_location = ''
      end
      if resource_pspath.nil?
        resource_pspath = 'MACHINE/WEBROOT/APPHOST'
      end
      provider = mimetype_providers.find do |mimetype|
        mimetype_fileextension = mimetype.fileextension
        mimetype_location = mimetype.location
        mimetype_pspath = mimetype.pspath
        ((resource_fileextension == mimetype_fileextension)&&(resource_location == mimetype_location)&&(resource_pspath == mimetype_pspath))
      end
      if provider
        provider_fileextension = provider.fileextension
        provider_location = provider.location
        provider_pspath = provider.pspath

        resource = mimetypes_keys[[provider_fileextension, provider_pspath, provider_location]]

        resource.provider = provider
      end
    end
  end

  def fileextension=(value)
    @property_flush[:fileextension] = value
  end

  def mimetype=(value)
    @property_flush[:mimetype] = value
  end

  def arguments(resource)
    array_arguments = []
    resource.each do |key,value|
      case key
      when :mimetype
        array_arguments << "mimeType=\"#{value}\""
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

  def set_mimetype
    if @property_flush
      str_address = address(resource.to_hash).join(" ")
      case @property_flush[:ensure]
      when :present
        str_arguments = arguments(resource.to_hash).join(";")
        powershell("Add-WebConfiguration -Filter /system.webServer/staticContent #{str_address} -Value @{fileExtension='#{resource[:fileextension]}';#{str_arguments}}")
      when :absent
        powershell("Clear-WebConfiguration -Filter \"/system.webServer/staticContent/mimeMap[@fileExtension='#{resource[:fileextension]}']\" #{str_address}")
      when nil
        str_arguments = arguments(@property_flush).join(";")
        if ! str_arguments.empty?
          powershell("Set-WebConfiguration -Filter \"/system.webServer/staticContent/mimeMap[@fileExtension='#{resource[:fileextension]}']\" #{str_address} -Value @{#{str_arguments}}")
        end
      end
    end
  end

  def flush
    set_mimetype
    @property_hash = self.class.get_mimetypes()
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end
end
