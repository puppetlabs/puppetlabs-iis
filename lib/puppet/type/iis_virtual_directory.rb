require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/path'

Puppet::Type.newtype(:iis_virtual_directory) do
  @doc = "Manage an IIS virtual directory."

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'The name of the virtual directory to manage'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty name must be specified."
      end
    end
  end

  newproperty(:sitename) do
    desc 'The site name under which the virtual directory is created'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty sitename must be specified."
      end
    end
  end

  newproperty(:application) do
    desc 'The application under which the virtual directory is created'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty application must be specified."
      end
    end
  end

  newproperty(:physicalpath, :parent => PuppetX::PuppetLabs::IIS::Property::Path) do
    desc 'The physical path to the virtual directory'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty physicalpath must be specified."
      end
    end
  end

  autorequire(:iis_application) { self[:application] }
  autorequire(:iis_site) { self[:sitename] }

end
