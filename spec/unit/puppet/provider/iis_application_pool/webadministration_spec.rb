require 'spec_helper'

provider_class = Puppet::Type.type(:iis_app_pool).provider(:webadministration)

describe provider_class do
  let(:facts) {{
    iis_version: '8.0',
    operatingsystem: 'Windows'
  }}

  let(:resource) do
    Puppet::Type.type(:iis_app_pool).new(
      name: 'Test Pool',
    )
  end

  let(:provider) { resource.provider }

  it 'should be an instance of the correct provider' do
    expect(provider).to be_an_instance_of Puppet::Type::Iis_app_pool::ProviderWebadministration
  end

  [:name].each do |method|
    it "should respond to the class method #{method}" do
      expect(provider_class).to respond_to(method)
    end
  end

  [:exists?, :create, :destroy, :update].each do |method|
    it "should respond to the instance method #{method}" do
      expect(provider_class.new).to respond_to(method)
    end
  end
end
