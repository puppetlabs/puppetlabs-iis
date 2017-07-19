require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_virtual_directory).provide(:webadministration, parent: Puppet::Provider::IIS_PowerShell) do
  desc "IIS Virtual Directory provider using the PowerShell WebAdministration module"

  confine    :iis_version     => ['7.5', '8.0', '8.5']
  confine    :operatingsystem => [ :windows ]
  defaultfor :operatingsystem => :windows

  commands :powershell => PuppetX::IIS::PowerShellCommon.powershell_path

  mk_resource_methods

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug "Creating #{@resource[:name]}"

    verify_physicalpath

    cmd = []
    cmd << "New-WebVirtualDirectory -Name \"#{@resource[:name]}\" "
    cmd << "-Site \"#{@resource[:sitename]}\" " if @resource[:sitename]
    cmd << "-Application \"#{@resource[:application]}\" " if @resource[:application]
    cmd << "-PhysicalPath \"#{@resource[:physicalpath]}\" " if is_drive_path(@resource[:physicalpath])
    cmd << "-ErrorAction Stop"
    cmd = cmd.join
    result = self.class.run(cmd)
    Puppet.err "Error creating virtual directory: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)

    # "New-WebVirtualDirectory fails when PhysicalPath is a UNC path that is not available:
    #   "Parameter 'PhysicalPath' should point to existing path."
    # Since networks paths are inherently not always available, use New-Item -Force for PhysicalPath when it is a UNC path.

    if is_unc_path(@resource[:physicalpath])
      cmd = "New-Item 'IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}' -type VirtualDirectory -physicalPath '#{@resource[:physicalpath]}' -Force"
      result = self.class.run(cmd)
      Puppet.err "Error updating virtual directory: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)
    end

    @resource[:ensure] = :present
  end

  def update
    # update() is called after destroy() by flush() in ../iis_powershell.rb
    # New-Item -Force recreates the VirtualDirectory unless we return early.
    return if (@resource[:ensure] == :absent)
    
    Puppet.debug "Updating #{@resource[:name]}"

    verify_physicalpath

    # Set-ItemProperty VirtualDirectory when PhysicalPath is a UNC path that is not available:
    #   "Parameter 'PhysicalPath' should point to existing path."
    # Since networks paths are inherently not always available, use New-Item -Force for PhysicalPath when it is a UNC path.

    if is_drive_path(@resource[:physicalpath])
      cmd = "Set-ItemProperty 'IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}' -Name 'physicalpath' -Value '#{@resource[:physicalpath]}'"
      result = self.class.run(cmd)
      Puppet.err "Error updating virtual directory: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)
    end
    if is_unc_path(@resource[:physicalpath])
      cmd = "New-Item 'IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}' -type VirtualDirectory -physicalPath '#{@resource[:physicalpath]}' -Force"
      result = self.class.run(cmd)
      Puppet.err "Error updating virtual directory: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)
    end
    cmd = []
    cmd << "Set-ItemProperty -Path 'IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}' -Name 'site' -Value '#{@resource[:sitename]}';" if @resource[:sitename]
    cmd << "Set-ItemProperty -Path 'IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}' -Name 'application' -Value '#{@resource[:application]}';" if @resource[:application]
    cmd = cmd.join
    result = self.class.run(cmd)
    Puppet.err "Error updating virtual directory: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)
  end

  def destroy
    Puppet.debug "Destroying #{@resource[:name]}"

    cmd = []
    cmd << "Remove-WebVirtualDirectory -Name \"#{@resource[:name]}\" "
    cmd << "-Site \"#{@resource[:sitename]}\" " if @resource[:sitename]
    if @resource[:application]
      cmd << "-Application \"#{@resource[:application]}\" "
    else
      cmd << "-Application \"/\" "
    end
    cmd << "-ErrorAction Stop"
    cmd = cmd.join
    result = self.class.run(cmd)
    Puppet.err "Error destroying virtual directory: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    virt_dirs = instances
    resources.keys.each do |virt_dir|
      if provider = virt_dirs.find{ |s| virt_dir.casecmp(s.name) == 0 }
        resources[virt_dir].provider = provider
      end
    end
  end

  def self.instances
    cmd = ps_script_content('_getvirtualdirectories', @resource)
    result = run(cmd)
    return [] if result.nil?

    virt_dir_json = self.parse_json_result(result[:stdout])
    return [] if virt_dir_json.nil?

    virt_dir_json = [virt_dir_json] if virt_dir_json.is_a?(Hash)
    return virt_dir_json.collect do |virt_dir|
      virt_dir_hash = {}

      virt_dir_hash[:ensure]       = :present
      virt_dir_hash[:name]         = virt_dir['name']
      virt_dir_hash[:application]  = virt_dir['application']
      virt_dir_hash[:physicalpath] = virt_dir['physicalpath']
      virt_dir_hash[:sitename]     = virt_dir['sitename']

      new(virt_dir_hash)
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

  def is_unc_path(path)
    return (path and path =~ /^\\\\[^\\]+\\[^\\]+/)
  end

end
