require 'pathname'

Puppet::Type.type(:iis_site).provide(:iisadministration) do
  desc "IIS Provider using the PowerShell IISAdministration module"
  
  require_relative File.join(File.dirname(__FILE__), '../../../puppet_x/puppetlabs/iis/powershell_manager')
  require Pathname.new(__FILE__).dirname + '../../../' + 'puppet_x/puppetlabs/iis/powershell_common'
  include PuppetX::IIS::PowerShellCommon
  
  confine    :iis_version      => ['10']
  confine    :operatingsystem  => [:windows ]
  confine    :kernelmajversion => 10.0
  defaultfor :operatingsystem  => :windows

  commands :powershell => PuppetX::IIS::PowerShellCommon.powershell_path

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end
end
