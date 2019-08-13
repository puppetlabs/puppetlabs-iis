require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/path'
require_relative '../../puppet_x/puppetlabs/iis/property/string'

Puppet::Type.newtype(:iis_virtual_directory) do
  @doc = 'Allows creation of a new IIS Virtual Directory and configuration of virtual directory parameters.'

  ensurable do
    desc 'Manage the state of this rule.'
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'The name of the virtual directory to manage'
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'A non-empty name must be specified.'
      end
    end
  end

  newproperty(:sitename) do
    desc 'The site name under which the virtual directory is created'
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'A non-empty sitename must be specified.'
      end
    end
  end

  newproperty(:application) do
    desc 'The application under which the virtual directory is created'
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'A non-empty application must be specified.'
      end
    end
  end

  newproperty(:physicalpath, parent: PuppetX::PuppetLabs::IIS::Property::Path) do
    desc "The physical path to the virtual directory. This path must be fully
          qualified. Though not recommended, this can be a UNC style path.
          Supply credentials for access to the UNC path with the `user_name` and
          `password` properties."
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'A non-empty physicalpath must be specified.'
      end
      super value
    end
  end

  newproperty(:user_name, parent: PuppetX::PuppetLabs::IIS::Property::String) do
    desc "Specifies the identity that should be impersonated when accessing the
          physical path."
  end

  newproperty(:password, parent: PuppetX::PuppetLabs::IIS::Property::String) do
    desc 'Specifies the password associated with the user_name property.'
  end

  autorequire(:iis_application) { self[:application] }
  autorequire(:iis_site) { self[:sitename] }

  validate do
    unless self[:user_name].to_s.empty? && self[:password].to_s.empty?
      raise ArgumentError, 'A user_name is required when specifying password.' if self[:user_name].to_s.empty?
      raise ArgumentError, 'A password is required when specifying user_name.' if self[:password].to_s.empty?
    end
  end
end
