#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/iis_powershell'

describe Puppet::Provider::IIS_PowerShell, :if => Puppet::Util::Platform.windows? do
  let (:subject) { Puppet::Provider::IIS_PowerShell }

  describe "when powershell is installed" do

    describe "when powershell version is greater than three" do

      it "should detect a powershell version" do
        expect_any_instance_of(Win32::Registry).to receive(:[]).with('PowerShellVersion').and_return('5.0.10514.6')

        version = subject.powershell_version

        expect(version).to eq '5.0.10514.6'
      end

      it "should call the powershell three registry path" do
        reg_key = double('bob')
        expect(reg_key).to receive(:[]).with('PowerShellVersion').and_return('5.0.10514.6')
        expect_any_instance_of(Win32::Registry).to receive(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).once.and_yield(reg_key)
        expect_any_instance_of(Win32::Registry).to receive(:open).with('SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).never

        subject.powershell_version
      end

      it 'should return the major version of powershell' do
        expect_any_instance_of(Win32::Registry).to receive(:[]).with('PowerShellVersion').and_return('5.0.10514.6')

        version = subject.ps_major_version(true)

        expect(version).to eq 5
      end
    end

    describe "when powershell version is less than three" do
      it "should detect a powershell version" do
        expect_any_instance_of(Win32::Registry).to receive(:[]).with('PowerShellVersion').and_return('2.0')

        version = subject.powershell_version

        expect(version).to eq '2.0'
      end

      it "should call powershell one registry path" do
        reg_key = double('bob')
        expect(reg_key).to receive(:[]).with('PowerShellVersion').and_return('2.0')
        expect_any_instance_of(Win32::Registry).to receive(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).once.and_raise(Win32::Registry::Error.new(2), 'nope')
        expect_any_instance_of(Win32::Registry).to receive(:open).with('SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).once.and_yield(reg_key)

        version = subject.powershell_version

        expect(version).to eq '2.0'
      end

      it 'should return the major version of powershell' do
        expect_any_instance_of(Win32::Registry).to receive(:[]).with('PowerShellVersion').and_return('2.0')
        version = subject.ps_major_version(true)

        expect(version).to eq 2
      end
    end
  end

  describe "when powershell is not installed" do
    before do
      expect_any_instance_of(Win32::Registry).to receive(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).once.and_raise(Win32::Registry::Error.new(2), 'nope')
      expect_any_instance_of(Win32::Registry).to receive(:open).with('SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).once.and_raise(Win32::Registry::Error.new(2), 'nope')
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
