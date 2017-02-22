require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/string'
require_relative '../../puppet_x/puppetlabs/iis/property/positive_integer'
require_relative '../../puppet_x/puppetlabs/iis/property/timeformat'

Puppet::Type.newtype(:iis_feature) do
  @doc = "Manage an IIS installed features."
  
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name, :namevar => true, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The unique name of the feature to manage."
    validate do |value|
      super value
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty #{self.name.to_s} must be specified."
      end
    end
  end

  newparam(:include_all_subfeatures, :boolean => true) do
  end

  newparam(:restart, :boolean => true) do
  end

  newparam(:include_management_tools, :boolean => true) do
  end

  newparam(:source, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
  end

end
