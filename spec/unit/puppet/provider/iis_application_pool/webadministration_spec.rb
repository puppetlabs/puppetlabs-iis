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
end
