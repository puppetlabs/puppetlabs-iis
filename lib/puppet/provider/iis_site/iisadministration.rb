require 'pathname'
require 'ruby-pwsh'

Puppet::Type.type(:iis_site).provide(:iisadministration) do
  desc 'IIS Provider using the PowerShell IISAdministration module'

  confine    feature: :pwshlib
  confine    iis_version: ['10']
  confine    operatingsystem: [:windows]
  confine    kernelmajversion: 10.0
  defaultfor operatingsystem: :windows

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
end
