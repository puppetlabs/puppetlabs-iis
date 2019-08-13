require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/string'

Puppet::Type.newtype(:iis_feature) do
  @doc = 'Allows installation and removal of IIS Features.'

  ensurable do
    desc 'Manage the state of this rule.'
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'The unique name of the feature to manage.'
  end

  newparam(:include_all_subfeatures, boolean: true) do
    desc "Indicates whether to install all sub features of a parent IIS feature.
          For instance, ASP.NET as well as the IIS Web Server"
  end

  newparam(:restart, boolean: true) do
    desc "Indicates whether to allow a restart if the IIS feature installation
          requests one"
  end

  newparam(:include_management_tools, boolean: true) do
    desc "Indicates whether to automatically install all managment tools for a
          given IIS feature"
  end

  newparam(:source, parent: PuppetX::PuppetLabs::IIS::Property::String) do
    desc "Optionally include a source path for the installation media for an IIS
          feature"
  end
end
