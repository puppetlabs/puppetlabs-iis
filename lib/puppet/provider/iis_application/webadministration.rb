require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_application).provide(:webadministration, parent: Puppet::Provider::IIS_PowerShell) do
  desc 'IIS Application provider using the PowerShell WebAdministration module'

  confine     feature: :pwshlib
  confine     feature: :iis_web_server
  confine     operatingsystem: [:windows]
  defaultfor  operatingsystem: :windows

  def self.powershell_path
    require 'ruby-pwsh'
    Pwsh::Manager.powershell_path
  rescue
    nil
  end

  commands powershell: powershell_path

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def physicalpath=(value)
    @property_flush[:physicalpath] = value
  end

  def sslflags=(value)
    @property_flush[:sslflags] = value
  end

  def authenticationinfo=(value)
    # Using property flush to find just the changed values, for speed
    @property_flush[:authenticationinfo] = value.select do |k, v|
      authenticationinfo.key?(k) && authenticationinfo[k] != v
    end
  end

  def enabledprotocols=(value)
    @property_flush[:enabledprotocols] = value
  end

  def applicationpool=(value)
    @property_flush[:applicationpool] = value
  end

  def create
    check_paths
    if @resource[:virtual_directory]
      args = []
      args << (@resource[:virtual_directory]).to_s
      args << "-ApplicationPool #{@resource[:applicationpool].inspect}" if @resource[:applicationpool]
      inst_cmd = "ConvertTo-WebApplication #{args.join(' ')} -Force -ErrorAction Stop"
    else
      inst_cmd = self.class.ps_script_content('newapplication', @resource)
    end
    result = self.class.run(inst_cmd)
    raise "Error creating application: #{result[:errormessage]}" unless (result[:exitcode]).zero?
    raise "Error creating application: #{result[:errormessage]}" unless result[:errormessage].nil?
    @property_hash[:ensure] = :present
  end

  def destroy
    inst_cmd = "Remove-WebApplication -Site \"#{self.class.find_sitename(resource)}\" -Name \"#{app_name}\" -ErrorAction Stop"
    result   = self.class.run(inst_cmd)
    @property_hash.clear
    raise "Error destroying application: #{result[:errormessage]}" unless (result[:exitcode]).zero?
    raise "Error destroying application: #{result[:errormessage]}" unless result[:errormessage].nil?
  end

  def update
    check_paths
    inst_cmd = []

    inst_cmd << "$webApplication = Get-WebApplication -Site '#{self.class.find_sitename(resource)}' -Name '#{app_name}'"
    if @property_flush[:physicalpath]
      # XXX Under what conditions would we have other paths?
      inst_cmd << %{Set-WebConfigurationProperty -Filter "$($webApplication.ItemXPath)/virtualDirectory[@path='/']" -Name physicalPath -Value '#{@resource[:physicalpath]}' -ErrorAction Stop}
    end

    if @property_flush[:sslflags]
      flags = @property_flush[:sslflags].join(',')
      inst_cmd << "Set-WebConfigurationProperty -Location '#{self.class.find_sitename(resource)}/#{app_name}'"\
      " -Filter 'system.webserver/security/access' -Name 'sslFlags' -Value '#{flags}' -ErrorAction Stop"
    end

    if @property_flush[:authenticationinfo]
      @property_flush[:authenticationinfo].each do |auth, _enable|
        inst_cmd << "Set-WebConfigurationProperty -Location '#{self.class.find_sitename(resource)}/#{app_name}'"\
        " -Filter 'system.webserver/security/authentication/#{auth}Authentication' -Name enabled -Value #{@property_flush[:authenticationinfo][auth]} -ErrorAction Stop"
      end
    end

    if @property_flush[:enabledprotocols]
      inst_cmd << "Set-WebConfigurationProperty -Filter 'system.applicationHost/sites/site[@name=\"#{self.class.find_sitename(resource)}\"]/application[@path=\"/#{app_name}\"]'" \
      " -Name enabledProtocols -Value '#{@property_flush[:enabledprotocols]}'"
    end

    if @property_flush[:applicationpool]
      inst_cmd << "Set-ItemProperty -Path 'IIS:/Sites/#{self.class.find_sitename(resource)}/#{app_name}' -Name applicationPool -Value '#{resource[:applicationpool]}'"
    end

    inst_cmd = inst_cmd.join("\n")
    result   = self.class.run(inst_cmd)
    raise "Error updating application: #{result[:errormessage]}" unless (result[:exitcode]).zero?
    raise "Error updating application: #{result[:errormessage]}" unless result[:errormessage].nil?
  end

  def self.prefetch(resources)
    apps = instances
    resources.each do |name, resource|
      if provider = apps.find { |app| compare_app_names(app, resource) && app.sitename == find_sitename(resource) }
        resources[name].provider = provider
      end
    end
  end

  def self.instances
    inst_cmd = ps_script_content('getapps', @resource)
    result   = run(inst_cmd)
    return [] if result.nil?

    app_json = parse_json_result(result[:stdout])
    return [] if app_json.nil?

    app_json = [app_json] if app_json.is_a?(Hash)
    app_json.map do |app|
      app_hash = {}

      app_hash[:ensure]             = :present
      app_hash[:name]               = "#{app['site']}\\#{app['name']}"
      app_hash[:applicationname]    = "#{app['site']}\\#{app['name']}" # app['name']
      app_hash[:sitename]           = app['site']
      app_hash[:physicalpath]       = app['physicalpath']
      app_hash[:applicationpool]    = app['applicationpool']
      app_hash[:sslflags]           = app['sslflags']
      app_hash[:authenticationinfo] = app['authenticationinfo']
      app_hash[:enabledprotocols]   = app['enabledprotocols']

      new(app_hash)
    end
  end

  def self.compare_app_names(app, resource)
    app_appname      =  app.applicationname.split(/[\\\/]/) - Array(app.sitename)
    resource_appname =  resource[:applicationname].split(/[\\\/]/).reject(&:empty?) - Array(find_sitename(resource))
    app_appname == resource_appname
  end

  def self.find_sitename(resource)
    sitename = if resource.parameters.key?(:virtual_directory)
                 resource[:virtual_directory].gsub('IIS:\\Sites\\', '').split(/[\\\/]/)[0]
               elsif !resource.parameters.key?(:sitename)
                 resource[:applicationname].split(/[\\\/]/)[0]
               else
                 resource[:sitename]
               end

    sitename
  end

  def app_name
    name_segments = @resource[:applicationname].split(/[\\\/]/)
    if @resource[:sitename] && name_segments.count > 1 && name_segments[0] == @resource[:sitename]
      name_segments[1..-1].join('/')
    elsif @resource[:sitename].nil?
      name_segments[1..-1].join('/')
    else
      name_segments.join('/')
    end
  end

  private

  def check_paths
    if @resource[:physicalpath] && !File.exist?(@resource[:physicalpath])
      raise "physicalpath doesn't exist: #{@resource[:physicalpath]}"
    end
    # XXX How do I check for IIS:\ path existence without shelling out to PS?
    # if @resource[:virtual_directory] and ! File.exists?(@resource[:virtual_directory])
    #  fail "virtual_directory doesn't exist: #{@resource[:virtual_directory]}"
    # end
  end
end
