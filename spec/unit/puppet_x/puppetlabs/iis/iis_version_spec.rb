require 'spec_helper'
require 'puppet/type'
require 'puppet_x/puppetlabs/iis/iis_version'

describe PuppetX::PuppetLabs::IIS::IISVersion, :if => Puppet::Util::Platform.windows? do
  before(:each) do
    @ps = PuppetX::PuppetLabs::IIS::IISVersion
  end

  describe "when iis is installed" do
    it "should detect a iis version" do
      expect_any_instance_of(Win32::Registry).to receive(:open)
        .with('SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100)
        .and_yield({ 'MajorVersion' => 10, 'MinorVersion' => 0 })
      version = @ps.installed_version

      expect(version).not_to be_nil
    end

    it "should report true if iis supported version installed" do
      expect_any_instance_of(Win32::Registry).to receive(:open)
        .with('SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100)
        .and_yield({ 'MajorVersion' => 10, 'MinorVersion' => 0 })

      result = @ps.supported_version_installed?

      expect(result).to be_truthy
    end

    it "should report false if no iis supported version installed" do
      expect_any_instance_of(Win32::Registry).to receive(:open)
        .with('SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100)
        .and_yield({ 'MajorVersion' => 6, 'MinorVersion' => 0 })

      result = @ps.supported_version_installed?

      expect(result).to be_falsey
    end
  end

  describe "when iis is not installed" do
    it "should return nil and not throw" do
      expect_any_instance_of(Win32::Registry).to receive(:open)
        .with('SOFTWARE\Microsoft\InetStp', Win32::Registry::KEY_READ | 0x100)
        .and_raise(Win32::Registry::Error.new(2), 'nope')

      version = @ps.installed_version

      expect(version).to eq nil
    end

  end
end