require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_application).provide(:webadministration, parent: Puppet::Provider::IIS_PowerShell) do
  desc "IIS Application provider using the PowerShell WebAdministration module"

  confine    :iis_version     => ['7.5', '8.0', '8.5']
  confine    :operatingsystem => [ :windows ]
  defaultfor :operatingsystem => :windows

  commands :powershell => PuppetX::IIS::PowerShellCommon.powershell_path

  mk_resource_methods

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
    Puppet.debug "Creating #{@resource[:name]}"

    verify_physicalpath

    if @resource[:virtual_directory]
      args = []
      args << "#{@resource[:virtual_directory]}"
      args << "-ApplicationPool #{@resource[:applicationpool].inspect}" if @resource[:applicationpool]
      cmd = "ConvertTo-WebApplication #{args.join(' ')} -Force -ErrorAction Stop"
    else
      fail "Error creating application: physicalpath is required to create" unless @resource[:physicalpath]
      cmd = self.class.ps_script_content('newapplication', @resource)
    end
    result = self.class.run(cmd)
    Puppet.err "Error creating application: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)

    @property_hash[:ensure] = :present
  end

  def update
    Puppet.debug "Updating #{@resource[:name]}"

    verify_physicalpath

    cmd = []
    cmd << "$webApplication = Get-WebApplication -Site '#{resource[:sitename]}' -Name '#{resource[:applicationname]}'"
    if @property_flush[:physicalpath]
      cmd << %{Set-WebConfigurationProperty -Filter "$($webApplication.ItemXPath)/virtualDirectory[@path='/']" -Name physicalPath -Value '#{@resource[:physicalpath]}' -ErrorAction Stop}
    end
    if @property_flush[:sslflags]
      flags = @property_flush[:sslflags].join(',')
      cmd << "Set-WebConfigurationProperty -Location '#{@resource[:sitename]}/#{@resource[:applicationname]}' -Filter 'system.webserver/security/access' -Name 'sslFlags' -Value '#{flags}' -ErrorAction Stop"
    end
    if @property_flush[:authenticationinfo]
      @property_flush[:authenticationinfo].each do |auth,enable|
        cmd << "Set-WebConfigurationProperty -Location '#{@resource[:sitename]}/#{@resource[:applicationname]}' -Filter 'system.webserver/security/authentication/#{auth}Authentication' -Name enabled -Value #{@property_flush[:authenticationinfo][auth]} -ErrorAction Stop"
      end
    end
    cmd = cmd.join("\n")
    result = self.class.run(cmd)
    Puppet.err "Error updating application: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)
  end

  def destroy
    Puppet.debug "Destroying #{@resource[:name]}"

    cmd = "Remove-WebApplication -Site \"#{@resource[:sitename]}\" -Name \"#{@resource[:applicationname]}\" -ErrorAction Stop"
    result = self.class.run(cmd)
    Puppet.err "Error destroying application: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)

    @property_hash.clear
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
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
    cmd = ps_script_content('getapps', @resource)
    result   = run(cmd)
    return [] if result.nil?

    app_json = self.parse_json_result(result[:stdout])
    return [] if app_json.nil?

    app_json = [app_json] if app_json.is_a?(Hash)
    return app_json.collect do |app|
      app_hash = {}

      app_hash[:ensure]             = :present
      app_hash[:name]               = "#{app['site']}\\#{app['name']}"
      app_hash[:applicationname]    = app['name']
      app_hash[:applicationpool]    = app['applicationpool']
      app_hash[:authenticationinfo] = app['authenticationinfo']
      app_hash[:physicalpath]       = app['physicalpath']
      app_hash[:sitename]           = app['site']
      app_hash[:sslflags]           = app['sslflags']

      new(app_hash)
    end
  end

  private

  def verify_physicalpath
    if is_drive_path(@resource[:physicalpath])
      if ! File.exists?(@resource[:physicalpath])
        fail "physicalpath doesn't exist: #{@resource[:physicalpath]}"
      end
    end
  end

  def is_drive_path(path)
    return (path and path =~ /^.:(\/|\\)/)
  end
end
