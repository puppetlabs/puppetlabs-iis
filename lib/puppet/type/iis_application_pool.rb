require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/string'

Puppet::Type.newtype(:iis_application_pool) do
  @doc = "Manage an IIS application pool."

  ensurable

  newparam(:name, :namevar => true, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The name of the ApplicationPool."
  end
  
  newproperty(:state, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The state of the ApplicationPool."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Started','started','Stopped','stopped'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Started or Stopped")
      end
    end
  end
  
  newproperty(:managedpipelinemode, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The managedPipelineMode of the ApplicationPool. First letter has to be capitalized."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Integrated','Classic'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Integrated or Classic")
      end
    end
  end
  
  newproperty(:managedruntimeversion, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The managedRuntimeVersion of the ApplicationPool."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['v4.0','v2.0'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Integrated or Classic")
      end
    end
  end
end
