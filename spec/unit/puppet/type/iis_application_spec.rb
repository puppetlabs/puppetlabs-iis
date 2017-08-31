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
  describe 'enabledprotocols' do
    context 'should accept valid string value' do
      let(:params) do
        {
          title: 'foo\bar',
          enabledprotocols: 'http,https,net.pipe',
        }
      end
      it { expect(subject[:enabledprotocols]).to eq('http,https,net.pipe') }
    end
    context 'should not allow nil' do
      let(:params) do 
        {
          title: 'foo\bar',
          enabledprotocols: nil,
        }
      end
      it { expect{subject}.to raise_error(Puppet::Error, /Got nil value for enabledprotocols/) }
    end
    context 'should not allow empty' do
      let(:params) do 
        {
          title: 'foo\bar',
          enabledprotocols: '',
        }
      end
      it { expect{subject}.to raise_error(Puppet::ResourceError, /Invalid value ''. Valid values are http, https, net.pipe/) }
    end
    context 'should not accept invalid string value' do
      let(:params) do 
        {
          title: 'foo\bar',
          enabledprotocols: 'woot',
        }
      end
      it { expect{subject}.to raise_error(Puppet::ResourceError, /Invalid protocol 'woot'. Valid values are http, https, net.pipe/) }
    end
  end
end
