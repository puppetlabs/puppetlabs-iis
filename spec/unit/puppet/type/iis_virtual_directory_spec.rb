require 'spec_helper'

describe 'iis_virtual_directory' do
  let(:type_class) { Puppet::Type.type(:iis_virtual_directory) }

  let :params do
    [
      :name,
    ]
  end

  let :properties do
    [
      :ensure,
      :sitename,
      :application,
      :physicalpath
    ]
  end

  let :minimal_config do
    {
      name: 'Some Virtual Directory',
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

  it 'should default ensure to present' do
    pool = type_class.new(
      name: 'foo',
    )
    expect(pool[:ensure]).to eq(:present)
  end

  context 'with a minimal set of properties' do
    let :config do
      minimal_config
    end

    let :virtual_directory do
      type_class.new(config)
    end

    it 'should be valid' do
      expect { virtual_directory }.not_to raise_error
    end
  end
end
