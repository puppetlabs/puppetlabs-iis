# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type'
require 'puppet_x/puppetlabs/iis/iis_version'

describe 'iis_version' do
  before(:each) do
    skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
  end

  describe 'when iis is installed' do
    let(:ps) { PuppetX::PuppetLabs::IIS::IISVersion }
    let(:registry_key) { ['SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100] }

    it 'detects a iis version' do
      allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open).with(*registry_key).and_yield('MajorVersion' => 10, 'MinorVersion' => 0)
      expect(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open).with(*registry_key)
      version = ps.installed_version

      expect(version).not_to be_nil
    end

    it 'reports true if iis supported version installed' do
      allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open).with(*registry_key).and_yield('MajorVersion' => 10, 'MinorVersion' => 0)
      expect(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open).with(*registry_key)

      result = ps.supported_version_installed?

      expect(result).to be_truthy
    end

    it 'reports false if no iis supported version installed' do
      allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open).with(*registry_key).and_yield('MajorVersion' => 6, 'MinorVersion' => 0)
      expect(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open).with(*registry_key)

      result = ps.supported_version_installed?

      expect(result).to be_falsey
    end
  end

  describe 'when iis is not installed' do
    let(:ps) { PuppetX::PuppetLabs::IIS::IISVersion }
    let(:registry_key) { ['SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100] }

    it 'returns nil and not throw' do
      allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open).with(*registry_key).and_raise(Win32::Registry::Error.new(2), 'nope')
      expect(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open).with(*registry_key)

      version = ps.installed_version

      expect(version).to be_nil
    end
  end
end
