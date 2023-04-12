# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type'
require 'puppet/type/iis_site'

describe Puppet::Type.type(:iis_site) do
  subject { resource }

  let(:resource) { described_class.new(name: 'iis_site') }

  it { is_expected.to be_a Puppet::Type::Iis_site }

  describe 'parameter :name' do
    subject { resource.parameters[:name] }

    it { is_expected.to be_isnamevar }

    it 'does not allow nil' do
      expect {
        resource[:name] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for name})
    end

    it 'does not allow empty' do
      expect {
        resource[:name] = ''
      }.to raise_error(Puppet::ResourceError, %r{A non-empty name must})
    end

    ['value', 'value with spaces', 'UPPER CASE', '0123456789_-', 'With.Period'].each do |value|
      it "accepts '#{value}'" do
        expect { resource[:name] = value }.not_to raise_error
      end
    end

    ['*', '()', '[]', '!@'].each do |value|
      it "rejects '#{value}'" do
        expect { resource[:name] = value }.to raise_error(Puppet::ResourceError, %r{is not a valid name})
      end
    end
  end

  # TODO: fix tests below
  context 'parameter :physicalpath' do
    it 'does not allow nil' do
      expect {
        resource[:physicalpath] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for physicalpath})
    end

    it 'does not allow empty' do
      expect {
        resource[:physicalpath] = ''
      }.to raise_error(Puppet::ResourceError, %r{physicalpath should be a path})
    end

    it 'accepts any string value' do
      resource[:physicalpath] = 'c:/thisstring-location/value/somefile.txt'
      resource[:physicalpath] = 'c:\\thisstring-location\\value\\somefile.txt'
      resource[:physicalpath] = '\\\\server.fqdn\\thisstring-location\\value\\somefile.txt'
    end
  end

  context 'property: authenticationinfo' do
    it 'requires a hash or array of hashes' do
      expect {
        resource[:authenticationinfo] = 'hi'
      }.to raise_error(Puppet::Error, %r{Hash})
      expect {
        resource[:authenticationinfo] = ['hi']
      }.to raise_error(Puppet::Error, %r{Hash})
    end

    it 'requires any of the schemas' do
      expect {
        resource[:authenticationinfo] = { 'wakka' => 'fdskjfndslk' }
      }.to raise_error(Puppet::Error, %r{schema})
    end

    it 'allows valid syntax' do
      resource[:authenticationinfo] = {
        'basic' => true,
        'anonymous' => false
      }
    end
  end

  context 'property :bindings' do
    it 'requires a hash or array of hashes' do
      expect {
        resource[:bindings] = 'hi'
      }.to raise_error(Puppet::Error, %r{hash})
      expect {
        resource[:bindings] = ['hi']
      }.to raise_error(Puppet::Error, %r{hash})
    end

    it 'requires protocol' do
      expect {
        resource[:bindings] = { 'bindinginformation' => 'a:80:c' }
      }.to raise_error(Puppet::Error, %r{protocol})
    end

    it 'requires bindinginformation' do
      expect {
        resource[:bindings] = { 'protocol' => 'http' }
      }.to raise_error(Puppet::Error, %r{bindinginformation})
    end

    it 'requires bindinginformation to be ip:port:hostname' do
      resource[:bindings] = {
        'protocol' => 'http',
        'bindinginformation' => '127.0.0.1:80:hostname'
      }
    end

    it 'requires number port' do
      expect {
        resource[:bindings] = {
          'protocol' => 'http',
          'bindinginformation' => '*:a:'
        }
      }.to raise_error(Puppet::Error, %r{65535})
    end

    it 'allows * for ip' do
      resource[:bindings] = {
        'protocol' => 'http',
        'bindinginformation' => '*:80:hostname'
      }
    end

    it 'allows empty hostname' do
      resource[:bindings] = {
        'protocol' => 'http',
        'bindinginformation' => '*:80:'
      }
    end
  end

  context 'property :limits' do
    it 'requires a hash' do
      expect {
        resource[:limits] = 'hi'
      }.to raise_error(Puppet::Error, %r{Hash})
      expect {
        resource[:limits] = ['hi']
      }.to raise_error(Puppet::Error, %r{Hash})
    end

    it 'accepts only valid limits as keys' do
      expect {
        resource[:limits] = { 'invalid' => 'setting' }
      }.to raise_error(Puppet::Error, %r{Invalid iis site limit key})
    end

    it 'rejects invalid limits values' do
      expect {
        resource[:limits] = { 'maxconnections' => 'string' }
      }.to raise_error(Puppet::Error, %r{integer})
      expect {
        resource[:limits] = { 'maxbandwidth' => 0 }
      }.to raise_error(Puppet::Error, %r{Cannot be less than 1 or greater than 4294967295})
      expect {
        resource[:limits] = { 'maxbandwidth' => 4_294_967_296 }
      }.to raise_error(Puppet::Error, %r{Cannot be less than 1 or greater than 4294967295})
    end
  end

  context 'parameter :applicationpool' do
    it 'does not allow nil' do
      expect {
        resource[:applicationpool] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for applicationpool})
    end

    it 'does not allow empty' do
      expect {
        resource[:applicationpool] = ''
      }.to raise_error(Puppet::ResourceError, %r{A non-empty applicationpool name must be specified.})
    end

    it 'accepts any string value' do
      resource[:applicationpool] = 'value'
      resource[:applicationpool] = 'thisstring-location'
    end
  end

  context 'parameter :enabledprotocols' do
    it 'does not allow nil' do
      expect {
        resource[:enabledprotocols] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for enabledprotocols})
    end

    it 'does not allow empty' do
      expect {
        resource[:enabledprotocols] = ''
      }.to raise_error(Puppet::ResourceError, %r{Invalid value ''. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname})
    end

    it 'accepts valid string value' do
      resource[:enabledprotocols] = ['http', 'https', 'net.pipe', 'net.tcp', 'net.msmq', 'msmq.formatname']
      resource[:enabledprotocols] = 'http'
      resource[:enabledprotocols] = 'https'
      resource[:enabledprotocols] = 'net.pipe'
      resource[:enabledprotocols] = 'net.tcp'
      resource[:enabledprotocols] = 'net.msmq'
      resource[:enabledprotocols] = 'msmq.formatname'
    end

    it 'does not accept invalid string value' do
      expect {
        resource[:enabledprotocols] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid protocol 'woot'. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname})
    end
  end

  context 'parameter :serviceautostart' do
    it 'accepts :true' do
      resource[:serviceautostart] = :true
    end

    it 'accepts :false' do
      resource[:serviceautostart] = :false
    end

    it 'rejects non-boolean values' do
      expect {
        resource[:serviceautostart] = :whenever
      }.to raise_error(Puppet::ResourceError, %r{Invalid value :whenever. Valid values are true, false.})
    end

    it 'does not allow nil' do
      expect {
        resource[:serviceautostart] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for serviceautostart})
    end

    it 'does not allow empty' do
      expect {
        resource[:serviceautostart] = ''
      }.to raise_error(Puppet::ResourceError, %r{Invalid value "". Valid values are true, false.})
    end

    it 'does not accept invalid string value' do
      expect {
        resource[:serviceautostart] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid value "woot". Valid values are true, false.})
    end
  end

  context 'parameter :serviceautostartprovidername' do
    it 'does not allow nil' do
      expect {
        resource[:serviceautostartprovidername] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for serviceautostartprovidername})
    end

    it 'does not allow empty' do
      expect {
        resource[:serviceautostartprovidername] = ''
      }.to raise_error(Puppet::ResourceError, %r{A non-empty serviceautostartprovidername name must be specified.})
    end

    it 'accepts any string value' do
      resource[:serviceautostartprovidername] = 'value'
      resource[:serviceautostartprovidername] = 'thisstring-location'
    end
  end

  context 'parameter :serviceautostartprovidertype' do
    it 'does not allow nil' do
      expect {
        resource[:serviceautostartprovidertype] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for serviceautostartprovidertype})
    end

    it 'does not allow empty' do
      expect {
        resource[:serviceautostartprovidertype] = ''
      }.to raise_error(Puppet::ResourceError, %r{A non-empty serviceautostartprovidertype name must be specified.})
    end

    it 'accepts any string value' do
      resource[:serviceautostartprovidertype] = 'value'
      resource[:serviceautostartprovidertype] = 'thisstring-location'
    end
  end

  context 'parameter :preloadenabled' do
    it 'accepts :true' do
      resource[:preloadenabled] = :true
    end

    it 'accepts :false' do
      resource[:preloadenabled] = :false
    end

    it 'rejects non-boolean values' do
      expect {
        resource[:preloadenabled] = :whenever
      }.to raise_error(Puppet::ResourceError, %r{Invalid value :whenever. Valid values are true, false.})
    end

    it 'does not allow nil' do
      expect {
        resource[:preloadenabled] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for preloadenabled})
    end

    it 'does not allow empty' do
      expect {
        resource[:preloadenabled] = ''
      }.to raise_error(Puppet::ResourceError, %r{Invalid value "". Valid values are true, false.})
    end

    it 'does not accept invalid string value' do
      expect {
        resource[:preloadenabled] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid value "woot". Valid values are true, false.})
    end
  end

  context 'parameter :defaultpage' do
    it 'does not allow nil' do
      expect {
        resource[:defaultpage] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for defaultpage})
    end

    it 'does not allow empty' do
      expect {
        resource[:defaultpage] = ''
      }.to raise_error(Puppet::ResourceError, %r{A non-empty defaultpage must be specified.})
    end

    it 'accepts valid string value and string array' do
      resource[:defaultpage] = ['wakka', 'foo']
      resource[:defaultpage] = 'default.htm'
    end
  end

  context 'parameter :logformat' do
    it 'does not allow nil' do
      expect {
        resource[:logformat] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for logformat})
    end

    it 'does not allow empty' do
      expect {
        resource[:logformat] = ''
      }.to raise_error(Puppet::ResourceError, %r{Invalid value ''. Valid values are W3C, IIS, NCSA})
    end

    it 'accepts valid string value' do
      resource[:logformat] = ['W3C', 'IIS']
      resource[:logformat] = 'W3C'
      resource[:logformat] = 'IIS'
      resource[:logformat] = 'NCSA'
    end

    it 'does not accept invalid string value' do
      expect {
        resource[:logformat] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid value 'woot'. Valid values are W3C, IIS, NCSA})
    end
  end

  context 'parameter :logpath' do
    it 'does not allow nil' do
      expect {
        resource[:logpath] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for logpath})
    end

    it 'does not allow empty' do
      expect {
        resource[:logpath] = ''
      }.to raise_error(Puppet::Error, %r{A non-empty logpath must be specified.})
    end

    it 'accepts any string value' do
      resource[:logpath] = 'c:/thisstring-location/value/somefile.txt'
      resource[:logpath] = 'c:\\thisstring-location\\value\\somefile.txt'
    end
  end

  context 'parameter :logperiod' do
    it 'does not allow nil' do
      expect {
        resource[:logperiod] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for logperiod})
    end

    it 'does not allow empty' do
      expect {
        resource[:logperiod] = ''
      }.to raise_error(Puppet::ResourceError, %r{Invalid value ''. Valid values are Hourly, Daily, Weekly, Monthly, MaxSize})
    end

    it 'accepts valid string value' do
      resource[:logperiod] = ['Hourly', 'Daily']
      resource[:logperiod] = 'Hourly'
      resource[:logperiod] = 'Daily'
      resource[:logperiod] = 'Weekly'
      resource[:logperiod] = 'Monthly'
      resource[:logperiod] = 'MaxSize'
    end

    it 'does not accept invalid string value' do
      expect {
        resource[:logperiod] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid value 'woot'. Valid values are Hourly, Daily, Weekly, Monthly, MaxSize})
    end
  end

  context 'parameter :logtruncatesize' do
    it 'does not allow nil' do
      expect {
        resource[:logtruncatesize] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for logtruncatesize})
    end

    it 'does not allow empty' do
      expect {
        resource[:logtruncatesize] = ''
      }.to raise_error(Puppet::ResourceError, %r{Invalid value ''. Should be a number})
    end

    it 'does not accept invalid int value' do
      expect {
        resource[:logtruncatesize] = 128_576
      }.to raise_error(Puppet::ResourceError, %r{Invalid value '128576'. Cannot be less than 1048576 or greater than 4294967295})
      expect {
        resource[:logtruncatesize] = 5_298_967_295
      }.to raise_error(Puppet::ResourceError, %r{Invalid value '5298967295'. Cannot be less than 1048576 or greater than 4294967295})
    end

    it 'accepts valid int value' do
      resource[:logtruncatesize] = 1_048_576
      resource[:logtruncatesize] = 4_294_967_295
    end

    it 'does not accept invalid string value' do
      expect {
        resource[:logtruncatesize] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid value 'woot'. Should be a number})
    end
  end

  context 'parameter :loglocaltimerollover' do
    it 'accepts :true' do
      resource[:loglocaltimerollover] = :true
    end

    it 'accepts :false' do
      resource[:loglocaltimerollover] = :false
    end

    it 'rejects non-boolean values' do
      expect {
        resource[:loglocaltimerollover] = :whenever
      }.to raise_error(Puppet::ResourceError, %r{Invalid value :whenever. Valid values are true, false.})
    end

    it 'does not allow nil' do
      expect {
        resource[:loglocaltimerollover] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for loglocaltimerollover})
    end

    it 'does not allow empty' do
      expect {
        resource[:loglocaltimerollover] = ''
      }.to raise_error(Puppet::ResourceError, %r{Invalid value "". Valid values are true, false.})
    end

    it 'does not accept invalid string value' do
      expect {
        resource[:loglocaltimerollover] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid value "woot". Valid values are true, false.})
    end
  end

  context 'parameter :logflags' do
    it 'does not allow nil' do
      expect {
        resource[:logflags] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for logflags})
    end

    it 'does not allow empty' do
      expect {
        resource[:logflags] = ''
      }.to raise_error(Puppet::ResourceError, %r{Invalid value ''. Valid values are Date, Time, ClientIP,
             UserName, SiteName, ComputerName, ServerIP,
             Method, UriStem, UriQuery, HttpStatus, Win32Status, BytesSent,
             BytesRecv, TimeTaken, ServerPort, UserAgent, Cookie, Referer,
             ProtocolVersion, Host, HttpSubStatus})
    end

    it 'accepts valid string value' do
      resource[:logflags] = ['Date', 'Time']
      resource[:logflags] = 'Date'
      resource[:logflags] = 'Time'
      resource[:logflags] = 'ClientIP'
    end

    it 'does not accept invalid string value' do
      expect {
        resource[:logflags] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid value 'woot'. Valid values are Date, Time, ClientIP,
             UserName, SiteName, ComputerName, ServerIP,
             Method, UriStem, UriQuery, HttpStatus, Win32Status, BytesSent,
             BytesRecv, TimeTaken, ServerPort, UserAgent, Cookie, Referer,
             ProtocolVersion, Host, HttpSubStatus})
    end
  end

  context 'mulitple parameter validation' do
    it 'does not allow logperiod and logtruncatesize to be specified at same time' do
      expect {
        resource[:logperiod] = 'Daily'
        resource[:logtruncatesize] = 1_048_576
        resource.validate
      }.to raise_error(RuntimeError, %r{Cannot specify logperiod and logtruncatesize at the same time})
    end

    it 'does not allow logflags to be used without logformat set to W3C at same time' do
      expect {
        resource[:logflags] = 'Date'
        resource[:logformat] = 'IIS'
        resource.validate
      }.to raise_error(RuntimeError, %r{Cannot specify logflags when logformat is not W3C})
    end

    it 'does not allow either serviceautostartprovidername or serviceautostartprovidertype to be specified without the other' do
      expect {
        resource[:serviceautostartprovidername] = 'foo'
        resource.validate
      }.to raise_error(RuntimeError, %r{Must specify serviceautostartprovidertype as well as serviceautostartprovidername})
    end
  end
end
