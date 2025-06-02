# frozen_string_literal: true

require 'spec_helper'
require 'puppet/provider/iis_powershell'

describe 'iis_application provider' do
  subject(:iis_application_provider) do
    resource = Puppet::Type.type(:iis_application).new(params)
    resource.provider = Puppet::Type.type(:iis_application).provider(:webadministration).new
    resource.provider
  end

  let(:facts) do
    {
      iis_version: '8.0',
      operatingsystem: 'Windows'
    }
  end

  describe 'creating from scratch' do
    context 'without physicalpath' do
      let(:params) do
        { title: 'foo\bar' }
      end

      before :each do
        allow(Puppet::Provider::IIS_PowerShell).to receive(:run).with(%r{New-WebApplication}).and_return(exitcode: 0)
      end

      it { iis_application_provider.create }
    end

    context 'with nonexistent physicalpath' do
      let(:params) do
        {
          title: 'foo\bar',
          physicalpath: 'C:\noexist'
        }
      end

      before :each do
        allow(File).to receive(:exists?).with('C:\noexist').and_return(false)
      end

      it { expect { iis_application_provider.create }.to raise_error(RuntimeError, %r{doesn't exist}) }
    end

    context 'with existent physicalpath' do
      let(:params) do
        {
          title: 'foo\bar',
          physicalpath: 'C:\exist',
          sitename: 'foo'
        }
      end

      before :each do
        allow(File).to receive(:exist?).with('C:\exist').and_return(true)
        allow(Puppet::Provider::IIS_PowerShell).to receive(:run).with(%r{New-WebApplication}).and_return(exitcode: 0)
      end

      it { iis_application_provider.create }
    end
  end

  describe 'converting virtual_directory' do
    let(:params) do
      {
        title: 'foo\bar',
        virtual_directory: 'IIS:\Sites\exists\vdir'
      }
    end

    before :each do
      allow(Puppet::Provider::IIS_PowerShell).to receive(:run).with(%r{ConvertTo-WebApplication}).and_return(exitcode: 0)
    end

    it { iis_application_provider.create }
  end

  describe 'updating physicalpath'
  describe 'updating sslflags'
  describe 'updating authenticationinfo for IIS_Application' do
    let(:params) do
      {
        title: 'foo\bar',
        name: 'foo\bar',
        ensure: :present,
        sitename: 'foo',
        applicationname: 'bar',
        applicationpool: 'DefaultAppPool',
        enabledprotocols: 'http,https',
        authenticationinfo: {
          'anonymous' => true,
          'basic' => false,
          'clientCertificateMapping' => false,
          'digest' => false,
          'iisClientCertificateMapping' => false,
          'windows' => true,
          'forms' => false
        },
      }
    end
    let(:authenticationinfo) do
      {
        'anonymous' => true,
        'basic' => false,
        'clientCertificateMapping' => false,
        'digest' => false,
        'iisClientCertificateMapping' => false,
        'windows' => false,
        'forms' => true
      }
    end

    before :each do
      cmdtext = "$webApplication = Get-WebApplication -Site 'foo' -Name 'bar'"
      cmdtext += "\n"
      authenticationinfo.each do |auth, enable|
        if auth == 'forms' # Forms authentication requires a different command
          mode_value = enable ? 'Forms' : 'None'
          cmdtext += "Set-WebConfigurationProperty -PSPath 'IIS:/Sites/foo/bar' " \
                      "-Filter 'system.web/authentication' -Name 'mode' -Value '#{mode_value}' -ErrorAction Stop\n"
        else
          cmdtext += "Set-WebConfigurationProperty -Location 'foo/bar' " \
                    "-Filter 'system.webserver/security/authentication/#{auth}Authentication' -Name enabled -Value #{enable} -ErrorAction Stop\n"
        end
      end
      allow(Puppet::Provider::IIS_PowerShell).to receive(:run).and_return(exitcode: 0)
    end

    it 'updates value' do
      iis_application_provider.authenticationinfo = authenticationinfo
      iis_application_provider.update
    end
  end

  describe 'updating enabledprotocols' do
    let(:params) do
      {
        title: 'foo\bar'
      }
    end

    before :each do
      cmdtext = "$webApplication = Get-WebApplication -Site 'foo' -Name 'bar'"
      cmdtext += "\n"
      cmdtext += "Set-WebConfigurationProperty -Filter 'system.applicationHost/sites/site[@name=\"foo\"]/application[@path=\"/bar\"]' -Name enabledProtocols -Value 'http,https,net.tcp'"
      allow(Puppet::Provider::IIS_PowerShell).to receive(:run) \
        .with(cmdtext) \
        .and_return(exitcode: 0)
    end

    it 'updates value' do
      iis_application_provider.enabledprotocols = 'http,https,net.tcp'
      iis_application_provider.update
    end
  end
end
