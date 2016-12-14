require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/string'

Puppet::Type.newtype(:iis_application_pool) do
  @doc = "Manage an IIS application pool."

  ensurable

  newparam(:name, :namevar => true, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The name of the ApplicationPool."
  end
  
  newparam(:state, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The state of the ApplicationPool."
  end
  
  newparam(:managedpipelinemode, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The managedPipelineMode of the ApplicationPool."
  end
  
  newparam(:managedruntimeversion, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The managedRuntimeVersion of the ApplicationPool."
  end
end
