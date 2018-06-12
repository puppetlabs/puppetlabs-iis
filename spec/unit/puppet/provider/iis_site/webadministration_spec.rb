require 'spec_helper'

describe Puppet::Type.type(:iis_site).provider(:webadministration) do
  let(:resource) {
    result = Puppet::Type.type(:iis_site).new(:name => "iis_site")
    result.provider = subject
    result
  }

  context "verify provider" do
    it { is_expected.to be_an_instance_of Puppet::Type::Iis_site::ProviderWebadministration }
    it { is_expected.to respond_to(:create)  }
    it { is_expected.to respond_to(:exists?) }
    it { is_expected.to respond_to(:destroy) }
    it { is_expected.to respond_to(:start)   }
    it { is_expected.to respond_to(:stop)    }

    context "verify ssl? function" do
      it {is_expected.to respond_to(:ssl?)}

      it "should return true protocol == https" do
        resource[:bindings] = {
          'protocol'             => 'https',
          'bindinginformation'   => '*:443:',
          'sslflags'             => 0,
          'certificatehash'      => 'D69B5C3315FF0DA09AF640784622CF20DC51F03E',
          'certificatestorename' => 'My'
        }
        expect(subject.ssl?).to be true
      end

      it "should return true bindings is an array" do
        resource[:bindings] = [{
          'protocol'             => 'https',
          'bindinginformation'   => '*:443:',
          'sslflags'             => 0,
          'certificatehash'      => 'D69B5C3315FF0DA09AF640784622CF20DC51F03E',
          'certificatestorename' => 'My'
        },
        {
          'protocol'             => 'http',
          'bindinginformation'   => '*:8080:'
        }]
        expect(subject.ssl?).to be true
      end

      it "should return false if no https bindings are specified" do
        resource[:bindings] = {
          'protocol'             => 'http',
          'bindinginformation'   => '*:8080:'
        }
        expect(subject.ssl?).to be false
      end
    end
  end
end
