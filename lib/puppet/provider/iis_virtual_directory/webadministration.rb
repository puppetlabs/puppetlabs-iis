require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_common')
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

    # New-WebVirtualDirectory fails when PhysicalPath is a UNC path that is not available:
    #   "Parameter 'PhysicalPath' should point to existing path."

    if is_drive_path(@resource[:physicalpath])
      cmd = []
      cmd << "New-WebVirtualDirectory -Name \"#{@resource[:name]}\" "
      cmd << "-Site \"#{@resource[:sitename]}\" " if @resource[:sitename]
      cmd << "-Application \"#{@resource[:application]}\" " if @resource[:application]
      cmd << "-PhysicalPath \"#{@resource[:physicalpath]}\" "
      cmd << "-ErrorAction Stop"
      cmd = cmd.join

      result   = self.class.run(cmd)
      Puppet.err "Error creating virtual directory: #{result[:errormessage]}" unless result[:exitcode] == 0
      @resource[:ensure] = :present
    end
    if is_unc_path(@resource[:physicalpath])
      cmd = []
      cmd << "New-Item -type VirtualDirectory \"IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}\" "
      cmd << "-Application \"#{@resource[:application]}\" " if @resource[:application]
      cmd << "-PhysicalPath \"#{@resource[:physicalpath]}\" "
      cmd = cmd.join

      result = self.class.run(cmd)
      Puppet.err "Error creating virtual directory: #{result[:errormessage]}" unless result[:exitcode] == 0
      @resource[:ensure] = :present
    end
  end

  def update
    # WORKAROUND: update() is called after destroy() by flush() in ../iis_powershell.rb
    # New-Item -Force recreates the VirtualDirectory unless we return early.
    return if (@resource[:ensure] == :absent)

    Puppet.debug "Updating #{@resource[:name]}"

    verify_physicalpath

    # Set-ItemProperty fails when PhysicalPath is a UNC path that is not available:
    #   "Parameter 'PhysicalPath' should point to existing path."

    if is_drive_path(@resource[:physicalpath])
      cmd = "Set-ItemProperty 'IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}' -Name 'PhysicalPath' -Value '#{@resource[:physicalpath]}'"
      result = self.class.run(cmd)
      Puppet.err "Error updating virtual directory: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)
    end
    if is_unc_path(@resource[:physicalpath])
      cmd = "Set-Item 'IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}' -type VirtualDirectory -PhysicalPath '#{@resource[:physicalpath]}' -Force"
      result = self.class.run(cmd)
      Puppet.err "Error updating virtual directory: #{result[:errormessage]}" unless (result[:exitcode] == 0 && result[:errormessage].nil?)
    end

    cmd = []
    cmd << "Set-ItemProperty -Path 'IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}' -Name 'Site' -Value '#{@resource[:sitename]}'" if @resource[:sitename]
    cmd << "Set-ItemProperty -Path 'IIS:\\Sites\\#{@resource[:sitename]}\\#{@resource[:name]}' -Name 'Application' -Value '#{@resource[:application]}'" if @resource[:application]
    cmd = cmd.join("\n")

    result   = self.class.run(cmd)
    Puppet.err "Error updating virtual directory: #{result[:errormessage]}" unless result[:exitcode] == 0
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

    result   = self.class.run(cmd)
    Puppet.err "Error destroying virtual directory: #{result[:errormessage]}" unless result[:exitcode] == 0
    
    @resource[:ensure]  = :absent
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
    result   = run(cmd)
    return [] if result.nil?

    virt_dir_json = self.parse_json_result(result[:stdout])
    return [] if virt_dir_json.nil?

    virt_dir_json.collect do |virt_dir|
      virt_dir_hash = {}

      virt_dir_hash[:ensure]       = :present
      virt_dir_hash[:name]         = virt_dir['name']
      virt_dir_hash[:physicalpath] = virt_dir['physicalpath']
      virt_dir_hash[:application]  = virt_dir['application']
      virt_dir_hash[:sitename]     = virt_dir['sitename']

      new(virt_dir_hash)
    end
  end
end