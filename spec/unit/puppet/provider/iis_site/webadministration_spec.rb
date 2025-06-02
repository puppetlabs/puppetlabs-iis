# frozen_string_literal: true

require 'spec_helper'
require 'puppet/provider/iis_powershell'

describe Puppet::Type.type(:iis_site).provider(:webadministration) do
  subject(:webadministration) { described_class.new }

  let(:resource) do
    result = Puppet::Type.type(:iis_site).new(name: 'iis_site')
    result.provider = webadministration
    result
  end

  context 'verify provider' do
    it { is_expected.to be_an_instance_of Puppet::Type::Iis_site::ProviderWebadministration }
    it { is_expected.to respond_to(:create)  }
    it { is_expected.to respond_to(:exists?) }
    it { is_expected.to respond_to(:destroy) }
    it { is_expected.to respond_to(:start)   }
    it { is_expected.to respond_to(:stop)    }

    context 'verify ssl? function' do
      it { is_expected.to respond_to(:ssl?) }

      it 'returns true protocol == https' do
        resource[:bindings] = {
          'protocol' => 'https',
          'bindinginformation' => '*:443:',
          'sslflags' => 0,
          'certificatehash' => 'D69B5C3315FF0DA09AF640784622CF20DC51F03E',
          'certificatestorename' => 'My'
        }
        expect(webadministration.ssl?).to be true
      end

      it 'returns true bindings is an array' do
        resource[:bindings] = [{
          'protocol' => 'https',
          'bindinginformation' => '*:443:',
          'sslflags' => 0,
          'certificatehash' => 'D69B5C3315FF0DA09AF640784622CF20DC51F03E',
          'certificatestorename' => 'My'
        },
                               {
                                 'protocol' => 'http',
                                 'bindinginformation' => '*:8080:'
                               }]
        expect(webadministration.ssl?).to be true
      end

      it 'returns false if no https bindings are specified' do
        resource[:bindings] = {
          'protocol' => 'http',
          'bindinginformation' => '*:8080:'
        }
        expect(webadministration.ssl?).to be false
      end
    end
  end

  context 'updating authenticationinfo for IIS_Site' do
    let(:iis_site_resource) do
      result = Puppet::Type.type(:iis_site).new(
        name: 'foo',
        ensure: :present,
        physicalpath: 'C:\inetpub\wwwroot\foo',
        applicationpool: 'MyAppPool',
        enabledprotocols: 'http,https',
        authenticationinfo: {
          'anonymous' => true,
          'basic' => false,
          'clientCertificateMapping' => false,
          'digest' => false,
          'iisClientCertificateMapping' => false,
          'windows' => false,
          'forms' => true
        },
      )
      result.provider = webadministration
      result
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
      cmd = []
      cmd << described_class.ps_script_content('_setwebsite', iis_site_resource)
      cmd << described_class.ps_script_content('trysetitemproperty', iis_site_resource)
      cmd << described_class.ps_script_content('generalproperties', iis_site_resource)
      cmd << described_class.ps_script_content('bindingproperty', iis_site_resource)
      cmd << described_class.ps_script_content('logproperties', iis_site_resource)
      cmd << described_class.ps_script_content('limitsproperty', iis_site_resource)
      cmd << described_class.ps_script_content('serviceautostartprovider', iis_site_resource)
      authenticationinfo.each do |auth, enable|
        args = []
        if auth == 'forms' # Forms authentication requires a different command
          mode_value = enable ? 'Forms' : 'None'
          args << "-Filter 'system.web/authentication'"
          args << "-PSPath 'IIS:\\Sites\\foo'"
          args << "-Name 'mode'"
          args << "-Value '#{mode_value}'"
        else
          args << "-Filter 'system.webserver/security/authentication/#{auth}Authentication'"
          args << "-PSPath 'IIS:\\'"
          args << "-Location 'foo'"
          args << '-Name enabled'
          args << "-Value #{enable}"
        end
        cmd << "Set-WebConfigurationProperty #{args.join(' ')} -ErrorAction Stop\n"
      end
      allow(Puppet::Provider::IIS_PowerShell).to receive(:run).and_return(exitcode: 0)
    end

    it 'updates value' do
      webadministration.authenticationinfo = authenticationinfo
      webadministration.update
    end
  end
end
