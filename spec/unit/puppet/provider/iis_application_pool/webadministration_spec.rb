# frozen_string_literal: true

require 'spec_helper'

provider_class = Puppet::Type.type(:iis_application_pool).provider(:webadministration)

describe provider_class do
  let(:facts) do
    {
      iis_version: '8.0',
      operatingsystem: 'Windows'
    }
  end

  let(:resource) do
    result = Puppet::Type.type(:iis_application_pool).new(name: 'iis_application_pool')
    result.provider = subject
    result
  end

  it 'is an instance of the correct provider' do
    expect(resource.provider).to be_an_instance_of Puppet::Type::Iis_application_pool::ProviderWebadministration
  end

  [:name].each do |method|
    it "responds to the class method #{method}" do
      expect(provider_class).to respond_to(method)
    end
  end

  [:exists?, :create, :destroy, :update].each do |method|
    it "responds to the instance method #{method}" do
      expect(provider_class.new).to respond_to(method)
    end
  end

  describe '#update' do
    let(:resource) do
      Puppet::Type.type(:iis_application_pool).new(
        name: 'iis_application_pool',
        password: 'Sup3r$ecret!',
      )
    end
    let(:provider) { described_class.new(resource) }

    it 'passes the password directly in the PowerShell command' do
      expect(described_class).to receive(:run)
        .with(a_string_including('processModel.password', 'Sup3r$ecret!'))
        .and_return({ exitcode: 0, errormessage: '' })

      provider.update
    end

    it 'redacts password in Puppet logs' do
      prop = resource.property(:password)
      expect(prop.should_to_s('Sup3r$ecret!')).to eq('[redacted sensitive information]')
      expect(prop.is_to_s('Sup3r$ecret!')).to eq('[redacted sensitive information]')
    end
  end
end
