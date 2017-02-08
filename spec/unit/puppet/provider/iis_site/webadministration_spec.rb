require 'spec_helper'

describe Puppet::Type.type(:iis_site).provider(:webadministration) do
  let(:resource) {
    result = Puppet::Type.type(:iis_site).new(:name => "iis_site")
    result.provider = subject
    result
  }

  context "verify provider" do
    it { is_expected.to be_an_instance_of Puppet::Type::Iis_site::ProviderWebadministration }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:exists?) }
    it { is_expected.to respond_to(:destroy) }
    it { is_expected.to respond_to(:start) }
    it { is_expected.to respond_to(:stop) }
  end
end
