require 'spec_helper'
require 'puppet_x/puppetlabs/iis/powershell_manager'

describe 'iis_application provider' do
  before :each do
    expect(PuppetX::IIS::PowerShellManager).to_not receive(:new)
  end
  subject do
    resource = Puppet::Type.type(:iis_application).new(params)
    resource.provider = Puppet::Type.type(:iis_application).provider(:webadministration).new
    resource.provider
  end
  let(:facts) {{
    iis_version: '8.0',
    operatingsystem: 'Windows'
  }}

  describe 'creating from scratch' do
    context 'without physicalpath' do
      let(:params) do
        { title: 'foo\bar', }
      end
      it { expect{subject.create}.to raise_error(Puppet::Error, /physicalpath/) }
    end
    context 'with nonexistent physicalpath' do
      let(:params) do
        {
          title: 'foo\bar',
          physicalpath: 'C:\noexist',
        }
      end
      before :each do
        expect(File).to receive(:exists?).with('C:\noexist').and_return(false)
      end
      it { expect{subject.create}.to raise_error(Puppet::Error, /doesn't exist/) }
    end
    context 'with existent physicalpath' do
      let(:params) do
        {
          title: 'foo\bar',
          physicalpath: 'C:\exist',
          sitename: 'foo',
        }
      end
      before :each do
        expect(File).to receive(:exists?).with('C:\exist').and_return(true)
        expect(Puppet::Provider::IIS_PowerShell).to receive(:run).with(/New-WebApplication/).and_return({exitcode: 0})
      end
      it { subject.create }
    end
  end
  describe 'converting virtual_directory' do
    let(:params) do
      {
        title: 'foo\bar',
        virtual_directory: 'IIS:\Sites\exists\vdir',
      }
    end
    before :each do
      expect(Puppet::Provider::IIS_PowerShell).to receive(:run).with(/ConvertTo-WebApplication/).and_return({exitcode: 0})
    end
    it { subject.create }
  end
  describe 'updating physicalpath'
  describe 'updating sslflags'
  describe 'updating authenticationinfo'
end
