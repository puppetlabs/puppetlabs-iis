require 'spec_helper'

describe 'iis_application_pool' do
  let(:type_class) { Puppet::Type.type(:iis_application_pool) }

  let :params do
    [
      :name,
      :state,
      :managedpipelinemode,
      :managedruntimeversion,
    ]
  end

  let :properties do
    [
      :ensure,
    ]
  end

  let :minimal_config do
    {
      name: 'Some App Pool',
    }
  end

  let :optional_config do
    {
    }
  end

  let :default_config do
     minimal_config.merge(optional_config)
  end

  it 'should have expected properties' do
    expect(type_class.properties.map(&:name)).to include(*properties)
  end

  it 'should have expected parameters' do
    expect(type_class.parameters).to include(*params)
  end

  it 'should not have unexpected properties' do
    expect(properties).to include(*type_class.properties.map(&:name))
  end

  it 'should not have unexpected parameters' do
    expect(params + [:provider]).to include(*type_class.parameters)
  end

  [
    :name,
  ].each do |property|
    it "should require #{property} to be a string" do
      expect(type_class).to require_string_for(property)
    end
  end

  context 'with a minimal set of properties' do
    let :config do
      minimal_config
    end

    let :app_pool do
      type_class.new(config)
    end

    it 'should be valid' do
      expect { app_pool }.not_to raise_error
    end
  end

  # See https://github.com/puppetlabs/puppetlabs-azure/blob/master/spec/unit/type/azure_vm_spec.rb for more examples
end
