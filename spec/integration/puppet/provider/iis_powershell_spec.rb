#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/iis_powershell'

describe Puppet::Provider::IIS_PowerShell, :if => Puppet::Util::Platform.windows? do
  let (:subject) { Puppet::Provider::IIS_PowerShell }

  describe "when powershell is installed" do

    describe "when powershell version is greater than three" do

      it "should detect a powershell version" do
        Win32::Registry.any_instance.expects(:[]).with('PowerShellVersion').returns('5.0.10514.6')

        version = subject.powershell_version

        expect(version).to eq '5.0.10514.6'
      end

      it "should call the powershell three registry path" do
        reg_key = mock('bob')
        reg_key.expects(:[]).with('PowerShellVersion').returns('5.0.10514.6')
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).yields(reg_key).once

        subject.powershell_version
      end

      it "should not call powershell one registry path" do
        reg_key = mock('bob')
        reg_key.expects(:[]).with('PowerShellVersion').returns('5.0.10514.6')
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).yields(reg_key)
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).times(0)

        subject.powershell_version
      end

      it 'should return the major version of powershell' do
        Win32::Registry.any_instance.expects(:[]).with('PowerShellVersion').returns('5.0.10514.6')

        version = subject.ps_major_version(true)

        expect(version).to eq 5
      end
    end

    describe "when powershell version is less than three" do
      it "should detect a powershell version" do
        Win32::Registry.any_instance.expects(:[]).with('PowerShellVersion').returns('2.0')

        version = subject.powershell_version

        expect(version).to eq '2.0'
      end

      it "should call powershell one registry path" do
        reg_key = mock('bob')
        reg_key.expects(:[]).with('PowerShellVersion').returns('2.0')
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).raises(Win32::Registry::Error.new(2), 'nope').once
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).yields(reg_key).once

        version = subject.powershell_version

        expect(version).to eq '2.0'
      end

      it 'should return the major version of powershell' do
        Win32::Registry.any_instance.expects(:[]).with('PowerShellVersion').returns('2.0')
        version = subject.ps_major_version(true)

        expect(version).to eq 2
      end
    end
  end

  describe "when powershell is not installed" do
    before do
      Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).raises(Win32::Registry::Error.new(2), 'nope').once
      Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).raises(Win32::Registry::Error.new(2), 'nope').once
    end

    it "should return nil and not throw" do
      version = subject.powershell_version

      expect(version).to eq nil
    end

    it 'should return the major version as nil and not throw' do
      version = subject.ps_major_version(true)

      expect(version).to eq nil
    end
  end
end