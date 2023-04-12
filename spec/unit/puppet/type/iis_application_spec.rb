# frozen_string_literal: true

require 'spec_helper'

describe 'iis_application' do
  subject(:iis_application_type) do
    Puppet::Type.type(:iis_application).new(params)
  end

  context 'specifying title with sitename' do
    let(:params) do
      {
        title: 'bar',
        sitename: 'foo'
      }
    end

    it { expect(iis_application_type[:sitename]).to eq 'foo' }
    it { expect(iis_application_type[:applicationname]).to eq 'bar' }
  end

  context 'specifying sitename and applicationname' do
    let(:params) do
      {
        title: 'anything else',
        sitename: 'foo',
        applicationname: 'bar'
      }
    end

    it { expect(iis_application_type[:sitename]).to eq 'foo' }
    it { expect(iis_application_type[:applicationname]).to eq 'bar' }
  end

  context 'specifying virtual_directory' do
    let(:params) do
      {
        title: 'foo\bar',
        virtual_directory: 'IIS:\Sites\foo\bar'
      }
    end

    it { expect(iis_application_type[:virtual_directory]).to eq 'IIS:\Sites\foo\bar' }
  end

  context 'specifying virtual_directory with no provider path' do
    let(:params) do
      {
        title: 'foo\bar',
        virtual_directory: 'foo\bar'
      }
    end

    it { expect(iis_application_type[:virtual_directory]).to eq 'IIS:/Sites/foo\bar' }
  end

  context 'specifying authenticationinfo' do
    let(:params) do
      {
        title: 'foo\bar',
        authenticationinfo: {
          'basic' => true,
          'anonymous' => true
        }
      }
    end

    it { expect(iis_application_type[:authenticationinfo]).to eq('basic' => true, 'anonymous' => true) }
  end

  context 'specifying physicalpath' do
    let(:params) do
      {
        title: 'foo\bar',
        physicalpath: 'C:\test'
      }
    end

    it { expect(iis_application_type[:physicalpath]).to eq 'C:\test' }
  end

  describe 'parameter :applicationpool' do
    ['value', 'value with spaces', 'UPPER CASE', '0123456789_-', 'With.Period'].each do |value|
      context "when '#{value}'" do
        let(:params) do
          {
            title: 'foo\bar',
            applicationpool: value
          }
        end

        it { expect { iis_application_type }.not_to raise_error }
      end
    end
    ['*', '()', '[]', '!@'].each do |value|
      context "when '#{value}'" do
        let(:params) do
          {
            title: 'foo\bar',
            applicationpool: value
          }
        end

        it { expect { iis_application_type }.to raise_error(Puppet::ResourceError, %r{is not a valid applicationpool}) }
      end
    end
  end

  describe 'parameter :sitename' do
    ['value', 'value with spaces', 'UPPER CASE', '0123456789_-', 'With.Period'].each do |value|
      context "when '#{value}'" do
        let(:params) do
          {
            title: 'foo\bar',
            sitename: value
          }
        end

        it { expect { iis_application_type }.not_to raise_error }
      end
    end
    ['*', '()', '[]', '!@'].each do |value|
      context "when '#{value}'" do
        let(:params) do
          {
            title: 'foo\bar',
            sitename: value
          }
        end

        it { expect { iis_application_type }.to raise_error(Puppet::ResourceError, %r{is not a valid sitename}) }
      end
    end
  end

  describe 'applicationpool' do
    context 'when empty' do
      let(:params) do
        {
          title: 'foo\bar',
          applicationpool: ''
        }
      end

      it { expect { iis_application_type }.to raise_error(Puppet::Error, %r{applicationpool}) }
    end

    context 'when invalid' do
      let(:params) do
        {
          title: 'foo\bar',
          applicationpool: 'sweet!'
        }
      end

      it { expect { iis_application_type }.to raise_error(Puppet::Error, %r{applicationpool}) }
    end

    context 'when valid' do
      let(:params) do
        {
          title: 'foo\bar',
          applicationpool: 'OtherPool'
        }
      end

      it { expect(iis_application_type[:applicationpool]).to eq 'OtherPool' }
    end
  end

  describe 'sslflags' do
    context 'single item' do
      let(:params) do
        {
          title: 'foo\bar',
          sslflags: 'Ssl'
        }
      end

      it { expect(iis_application_type[:sslflags]).to eq([:Ssl]) }
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

      it { expect(iis_application_type[:sslflags]).to eq([:Ssl, :SslNegotiateCert]) }
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

      it { expect { iis_application_type }.to raise_error(Puppet::Error, %r{sslflags}) }
    end
  end

  describe 'enabledprotocols' do
    context 'should accept valid string value' do
      let(:params) do
        {
          title: 'foo\bar',
          enabledprotocols: 'http,https,net.pipe,net.tcp,net.msmq,msmq.formatname'
        }
      end

      it { expect(iis_application_type[:enabledprotocols]).to eq('http,https,net.pipe,net.tcp,net.msmq,msmq.formatname') }
    end

    context 'should not allow nil' do
      let(:params) do
        {
          title: 'foo\bar',
          enabledprotocols: nil
        }
      end

      it { expect { iis_application_type }.to raise_error(Puppet::Error, %r{Got nil value for enabledprotocols}) }
    end

    context 'should not allow empty' do
      let(:params) do
        {
          title: 'foo\bar',
          enabledprotocols: ''
        }
      end

      it { expect { iis_application_type }.to raise_error(Puppet::ResourceError, %r{Invalid value ''. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname}) }
    end

    context 'should not accept invalid string value' do
      let(:params) do
        {
          title: 'foo\bar',
          enabledprotocols: 'woot'
        }
      end

      it { expect { iis_application_type }.to raise_error(Puppet::ResourceError, %r{Invalid protocol 'woot'. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname}) }
    end
  end
end
