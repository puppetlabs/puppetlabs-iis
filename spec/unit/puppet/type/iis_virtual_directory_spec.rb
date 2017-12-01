require 'spec_helper'

describe Puppet::Type.type(:iis_virtual_directory) do
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
      :physicalpath,
      :user_name,
      :password
    ]
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

  let(:resource) { described_class.new(:name => "iis_virtual_directory") }
  subject { resource }

  describe "parameter :name" do
    subject { resource.parameters[:name] }

    it { is_expected.to be_isnamevar }

    it "should not allow nil" do
      expect {
        resource[:name] = nil
      }.to raise_error(Puppet::Error, /Got nil value for name/)
    end

    it "should not allow empty" do
      expect {
        resource[:name] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty name must be specified/)
    end
  end

  describe "parameter :sitename" do
    subject { resource.parameters[:name] }

    it "should not allow nil" do
      expect {
        resource[:sitename] = nil
      }.to raise_error(Puppet::Error, /Got nil value for sitename/)
    end

    it "should not allow empty" do
      expect {
        resource[:sitename] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty sitename must be specified/)
    end
  end

  describe "parameter :application" do
    subject { resource.parameters[:name] }

    it "should not allow nil" do
      expect {
        resource[:application] = nil
      }.to raise_error(Puppet::Error, /Got nil value for application/)
    end

    it "should not allow empty" do
      expect {
        resource[:application] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty application must be specified/)
    end
  end

  context "parameter :physicalpath" do
    it "should not allow nil" do
      expect {
        resource[:physicalpath] = nil
      }.to raise_error(Puppet::Error, /Got nil value for physicalpath/)
    end

    it "should not allow empty" do
      expect {
        resource[:physicalpath] = ''
      }.to raise_error(Puppet::Error, /A non-empty physicalpath must be specified/)
    end

    it "should accept forward-slash and backslash paths" do
      resource[:physicalpath] = "c:/directory/subdirectory"
      resource[:physicalpath] = "c:\\directory\\subdirectory"
    end
  end

  context "parameter :user_name" do
    it "should require it to be a string" do
      expect(type_class).to require_string_for(:user_name)
    end
  end

  context "parameter :password" do
    it "should require it to be a string" do
      expect(type_class).to require_string_for(:password)
    end
  end
end
