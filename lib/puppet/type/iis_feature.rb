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
    desc "Indicates whether to install all sub features of a parent IIS feature. For instance, ASP.NET as well as the IIS Web Server"
  end

  newparam(:restart, :boolean => true) do
    desc "Indicates whether to allow a restart if the IIS feature installationrequests one"
  end

  newparam(:include_management_tools, :boolean => true) do
    desc "Indicates whether to automatically install all managment tools for a given IIS feature"
  end

  newparam(:source, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "Optionally include a source path for the installation media for an IIS feature"
  end

end
