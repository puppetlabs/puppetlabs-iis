require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_application).provide(:webadministration, parent: Puppet::Provider::IIS_PowerShell) do
  desc "IIS Application provider using the PowerShell WebAdministration module"

  confine    :iis_version     => ['7.5', '8.0', '8.5']
  confine    :operatingsystem => [ :windows ]
  defaultfor :operatingsystem => :windows

  commands :powershell => PuppetX::IIS::PowerShellCommon.powershell_path

  mk_resource_methods

  def initialize(value={})
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
    @property_flush[:authenticationinfo] = value.select do |k,v|
      authenticationinfo.has_key?(k) and authenticationinfo[k] != v
    end
  end

  def create
    check_paths
    if @resource[:virtual_directory]
      args = Array.new
      args << "#{@resource[:virtual_directory]}"
      args << "-ApplicationPool #{@resource[:applicationpool].inspect}" if @resource[:applicationpool]
      inst_cmd = "ConvertTo-WebApplication #{args.join(' ')} -Force -ErrorAction Stop"
    else
      fail "Error creating application: physicalpath is required to create" unless @resource[:physicalpath]
      inst_cmd = self.class.ps_script_content('newapplication', @resource)
    end
    result = self.class.run(inst_cmd)
    fail "Error creating application: #{result[:errormessage]}" unless result[:exitcode] == 0
    fail "Error creating application: #{result[:errormessage]}" unless result[:errormessage].nil?
    @property_hash[:ensure] = :present
  end

  def destroy
    inst_cmd = "Remove-WebApplication -Site \"#{@resource[:sitename]}\" -Name \"#{@resource[:applicationname]}\" -ErrorAction Stop"
    result   = self.class.run(inst_cmd)
    @property_hash.clear
    fail "Error destroying application: #{result[:errormessage]}" unless result[:exitcode] == 0
    fail "Error destroying application: #{result[:errormessage]}" unless result[:errormessage].nil?
  end

  def update
    check_paths
    inst_cmd = []

    inst_cmd << "$webApplication = Get-WebApplication -Site '#{resource[:sitename]}' -Name '#{resource[:applicationname]}'"
    if @property_flush[:physicalpath]
      #XXX Under what conditions would we have other paths?
      inst_cmd << %{Set-WebConfigurationProperty -Filter "$($webApplication.ItemXPath)/virtualDirectory[@path='/']" -Name physicalPath -Value '#{@resource[:physicalpath]}' -ErrorAction Stop}
    end

    if @property_flush[:sslflags]
      flags = @property_flush[:sslflags].join(',')
      inst_cmd << "Set-WebConfigurationProperty -Location '#{@resource[:sitename]}/#{@resource[:applicationname]}' -Filter 'system.webserver/security/access' -Name 'sslFlags' -Value '#{flags}' -ErrorAction Stop"
    end

    if @property_flush[:authenticationinfo]
      @property_flush[:authenticationinfo].each do |auth,enable|
        inst_cmd << "Set-WebConfigurationProperty -Location '#{@resource[:sitename]}/#{@resource[:applicationname]}' -Filter 'system.webserver/security/authentication/#{auth}Authentication' -Name enabled -Value #{@property_flush[:authenticationinfo][auth]} -ErrorAction Stop"
      end
    end

    inst_cmd = inst_cmd.join("\n")
    result   = self.class.run(inst_cmd)
    fail "Error updating application: #{result[:errormessage]}" unless result[:exitcode] == 0
    fail "Error updating application: #{result[:errormessage]}" unless result[:errormessage].nil?
  end

  def self.prefetch(resources)
    apps = instances
    resources.each do |name, resource|
      if provider = apps.find{ |app| app.sitename == resource[:sitename] && app.applicationname == resource[:applicationname] }
        resources[name].provider = provider
      end
    end
  end

  def self.instances
    inst_cmd = ps_script_content('getapps', @resource)
    result   = run(inst_cmd)
    return [] if result.nil?

    app_json = self.parse_json_result(result[:stdout])
    return [] if app_json.nil?

    app_json = [app_json] if app_json.is_a?(Hash)
    app_json.collect do |app|
      app_hash = {}

      app_hash[:ensure]             = :present
      app_hash[:name]               = "#{app['site']}\\#{app['name']}"
      app_hash[:applicationname]    = app['name']
      app_hash[:sitename]           = app['site']
      app_hash[:physicalpath]       = app['physicalpath']
      app_hash[:applicationpool]    = app['applicationpool']
      app_hash[:sslflags]           = app['sslflags']
      app_hash[:authenticationinfo] = app['authenticationinfo']

      new(app_hash)
    end
  end

  private

  def check_paths
    if @resource[:physicalpath] and ! File.exists?(@resource[:physicalpath])
      fail "physicalpath doesn't exist: #{@resource[:physicalpath]}"
    end
    #XXX How do I check for IIS:\ path existence without shelling out to PS?
    #if @resource[:virtual_directory] and ! File.exists?(@resource[:virtual_directory])
    #  fail "virtual_directory doesn't exist: #{@resource[:virtual_directory]}"
    #end
  end
end
