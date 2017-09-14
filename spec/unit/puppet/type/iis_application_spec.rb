require 'spec_helper'

describe 'iis_application' do
  subject do
    Puppet::Type.type(:iis_application).new(params)
  end
  context 'specifying compound title' do
    let(:params) do
      { title: 'foo\bar' }
    end
    it { expect(subject[:sitename]).to eq 'foo' }
    it { expect(subject[:applicationname]).to eq 'bar' }
  end
  context 'specifying title without sitename' do
    let(:params) do
      { title: 'bar' }
    end
    it { expect{subject}.to raise_error(Puppet::Error, /sitename/) }
  end
  context 'specifying title with sitename' do
    let(:params) do
      {
        title: 'bar',
        sitename: 'foo',
      }
    end
    it { expect(subject[:sitename]).to eq 'foo' }
    it { expect(subject[:applicationname]).to eq 'bar' }
  end
  context 'specifying sitename and applicationname' do
    let(:params) do
      {
        title: 'anything else',
        sitename: 'foo',
        applicationname: 'bar',
      }
    end
    it { expect(subject[:sitename]).to eq 'foo' }
    it { expect(subject[:applicationname]).to eq 'bar' }
  end
  context 'specifying virtual_directory' do
    let(:params) do
      {
        title: 'foo\bar',
        virtual_directory: 'IIS:\Sites\foo\bar',
      }
    end
    it { expect(subject[:virtual_directory]).to eq 'IIS:\Sites\foo\bar' }
  end
  context 'specifying authenticationinfo' do
    let(:params) do
      {
        title: 'foo\bar',
        authenticationinfo: {
          'basic'     => true,
          'anonymous' => true,
        },
      }
    end
    it { expect(subject[:authenticationinfo]).to eq({ 'basic' => true, 'anonymous' => true }) }
  end
  context 'specifying physicalpath' do
    let(:params) do
      {
        title: 'foo\bar',
        physicalpath: 'C:\test',
      }
    end
    it { expect(subject[:physicalpath]).to eq 'C:\test' }
  end
  describe 'applicationpool' do
    context 'when empty' do
      let(:params) do
        {
          title: 'foo\bar',
          applicationpool: '',
        }
      end
      it { expect{subject}.to raise_error(Puppet::Error, /applicationpool/) }
    end
    context 'when invalid' do
      let(:params) do
        {
          title: 'foo\bar',
          applicationpool: 'sweet!',
        }
      end
      it { expect{subject}.to raise_error(Puppet::Error, /applicationpool/) }
    end
    context 'when valid' do
      let(:params) do
        {
          title: 'foo\bar',
          applicationpool: 'OtherPool',
        }
      end
      it { expect(subject[:applicationpool]).to eq 'OtherPool' }
    end
  end
  describe 'sslflags' do
    context 'single item' do
      let(:params) do
        {
          title: 'foo\bar',
          sslflags: 'Ssl',
        }
      end
      it { expect(subject[:sslflags]).to eq([:Ssl]) }
    end
    context 'array of items' do
      let(:params) do
        {
          title: 'foo\bar',
          sslflags: [
            'Ssl',
            'SslNegotiateCert',
          ]
        }
      end
      it { expect(subject[:sslflags]).to eq([:Ssl, :SslNegotiateCert]) }
    end
    context 'array with invalid items' do
      let(:params) do
        {
          title: 'foo\bar',
          sslflags: [
            'SslOn',
            'SslNegotiateCert',
          ]
        }
      end
      it { expect{subject}.to raise_error(Puppet::Error, /sslflags/) }
    end
  end
end

describe Puppet::Type.type(:iis_application) do
  let(:resource) { described_class.new(:applicationname => "test_application", :sitename => 'test_site', :applicationpool => 'test_site') }
  subject { resource }

  describe "parameter :applicationname" do
    subject { resource.parameters[:applicationname] }

    it { is_expected.to be_isnamevar }
  end

  describe "parameter :sitename" do
    subject { resource.parameters[:sitename] }

    [ 'values', 'UPPERCASEVALUES', '0123456789', 'values with spaces', "values with . - _ '" ].each do |value|
      it "should accept '#{value}'" do
        expect { resource[:sitename] = value }.not_to raise_error
      end
    end

    [ '*', '()', '[]', '!@' ].each do |value|
      it "should reject '#{value}'" do
        expect { resource[:sitename] = value }.to raise_error(Puppet::ResourceError, /is not a valid sitename/)
      end
    end
  end

  describe "parameter :applicationpool" do
    subject { resource.parameters[:applicationpool] }

    it "should not allow nil" do
      expect {
        resource[:applicationpool] = nil
      }.to raise_error(Puppet::Error, /Got nil value for applicationpool/)
    end

    it "should not allow empty" do
      expect {
        resource[:applicationpool] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty applicationpool must/)
    end

    [ 'values', 'UPPERCASEVALUES', '0123456789', 'values with spaces', "values with . - _ '" ].each do |value|
      it "should accept '#{value}'" do
        expect { resource[:applicationpool] = value }.not_to raise_error
      end
    end

    [ '*', '()', '[]', '!@' ].each do |value|
      it "should reject '#{value}'" do
        expect { resource[:applicationpool] = value }.to raise_error(Puppet::ResourceError, /is not a valid applicationpool/)
      end
    end

    it "should not allow values with more than 64 characters" do
      expect {
        resource[:applicationpool] = '01234567890123456789012345678901234567890123456789012345678901234'
      }.to raise_error(Puppet::Error, /The applicationpool must be less than 64 characters/)
    end
  end
end
