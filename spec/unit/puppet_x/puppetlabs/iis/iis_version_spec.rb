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

    it 'detects a iis version' do
      expect_any_instance_of(Win32::Registry).to receive(:open)
        .with('SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100)
        .and_yield('MajorVersion' => 10, 'MinorVersion' => 0)
      version = ps.installed_version

      expect(version).not_to be_nil
    end

    it 'reports true if iis supported version installed' do
      expect_any_instance_of(Win32::Registry).to receive(:open)
        .with('SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100)
        .and_yield('MajorVersion' => 10, 'MinorVersion' => 0)

      result = ps.supported_version_installed?

      expect(result).to be_truthy
    end

    it 'reports false if no iis supported version installed' do
      expect_any_instance_of(Win32::Registry).to receive(:open)
        .with('SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100)
        .and_yield('MajorVersion' => 6, 'MinorVersion' => 0)

      result = ps.supported_version_installed?

      expect(result).to be_falsey
    end
  end

  describe 'when iis is not installed' do
    let(:ps) { PuppetX::PuppetLabs::IIS::IISVersion }

    it 'returns nil and not throw' do
      expect_any_instance_of(Win32::Registry).to receive(:open)
        .with('SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100)
        .and_raise(Win32::Registry::Error.new(2), 'nope')

      version = ps.installed_version

      expect(version).to be_nil
    end
  end
end
