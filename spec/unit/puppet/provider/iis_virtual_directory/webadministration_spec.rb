require 'spec_helper'
require 'puppet/type'
require 'puppet/type/iis_virtual_directory'

describe Puppet::Type.type(:iis_virtual_directory) do
  let(:resource) { described_class.new(:name => "iis_virtual_directory") }
  subject { resource }

  it { is_expected.to be_a_kind_of Puppet::Type::Iis_virtual_directory }

  describe "parameter :name" do
    subject { resource.parameters[:name] }

    it { is_expected.to be_isnamevar }

    [ 'value', 'value\with\slashes', '0123456789_-' ].each do |value|
      it "should accept '#{value}'" do
        expect { resource[:name] = value }.not_to raise_error
      end
    end
  end

  context "parameter :sitename" do
    it "should not allow nil" do
      expect {
        resource[:sitename] = nil
      }.to raise_error(Puppet::Error, /Got nil value for sitename/)
    end

    it "should not allow empty" do
      expect {
        resource[:sitename] = ''
      }.to raise_error(Puppet::Error, /A non-empty sitename must be specified/)
    end
  end

  context "parameter :application" do
    it "should not allow nil" do
      expect {
        resource[:application] = nil
      }.to raise_error(Puppet::Error, /Got nil value for application/)
    end

    it "should not allow empty" do
      expect {
        resource[:application] = ''
      }.to raise_error(Puppet::Error, /A non-empty application must be specified/)
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

    it "should accept forward and back slashes" do
      resource[:physicalpath] = "c:/thisstring-location/value/somefile.txt"
      resource[:physicalpath] = "c:\\thisstring-location\\value\\somefile.txt"
    end
  end

end
