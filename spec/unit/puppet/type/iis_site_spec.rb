require 'spec_helper'
require 'puppet/type'
require 'puppet/type/iis_site'

describe Puppet::Type.type(:iis_site) do
  let(:resource) { described_class.new(:name => "iis_site") }
  subject { resource }

  it { is_expected.to be_a_kind_of Puppet::Type::Iis_site }

  describe "parameter :name" do
    subject { resource.parameters[:name] }

    it { is_expected.to be_isnamevar }

    it "should not allow nil" do
      expect {
        resource[:name] = nil
      }.to raise_error(Puppet::Error, /Got nil value for name/)
    end

    it "should not allow empty" do
      expect {
        resource[:name] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty name must/)
    end

    [ 'value', 'value with spaces', 'UPPER CASE', '0123456789_-', 'With.Period' ].each do |value|
      it "should accept '#{value}'" do
        expect { resource[:name] = value }.not_to raise_error
      end
    end

    [ '*', '()', '[]', '!@' ].each do |value|
      it "should reject '#{value}'" do
        expect { resource[:name] = value }.to raise_error(Puppet::ResourceError, /is not a valid name/)
      end
    end
  end

  # TODO: fix tests below
  context "parameter :physicalpath" do
    it "should not allow nil" do
      expect {
        resource[:physicalpath] = nil
      }.to raise_error(Puppet::Error, /Got nil value for physicalpath/)
    end

    it "should not allow empty" do
      expect {
        resource[:physicalpath] = ''
      }.to raise_error(Puppet::Error, /A non-empty physicalpath must be specified./)
    end

    it "should accept any string value" do
      resource[:physicalpath] = "c:/thisstring-location/value/somefile.txt"
      resource[:physicalpath] = "c:\\thisstring-location\\value\\somefile.txt"
    end
  end

  context "property: authenticationinfo" do
    it "requires a hash or array of hashes" do
      expect {
        resource[:authenticationinfo] = "hi"
      }.to raise_error(Puppet::Error, /Hash/)
      expect {
        resource[:authenticationinfo] = ["hi"]
      }.to raise_error(Puppet::Error, /Hash/)
    end
    it "requires any of the schemas" do
      expect {
        resource[:authenticationinfo] = { 'wakka' => 'fdskjfndslk' }
      }.to raise_error(Puppet::Error, /schema/)
    end
    it "allows valid syntax" do
      resource[:authenticationinfo] = {
        'basic' => true,
        'anonymous' => false,
      }
    end
  end

  context "property :bindings" do
    it "requires a hash or array of hashes" do
      expect {
        resource[:bindings] = "hi"
      }.to raise_error(Puppet::Error, /hash/)
      expect {
        resource[:bindings] = ["hi"]
      }.to raise_error(Puppet::Error, /hash/)
    end
    it "requires protocol" do
      expect {
        resource[:bindings] = { 'bindinginformation' => 'a:80:c' }
      }.to raise_error(Puppet::Error, /protocol/)
    end
    it "requires bindinginformation" do
      expect {
        resource[:bindings] = { 'protocol' => 'http' }
      }.to raise_error(Puppet::Error, /bindinginformation/)
    end
    it "requires bindinginformation to be ip:port:hostname" do
      resource[:bindings] = {
        'protocol' => 'http',
        'bindinginformation' => '127.0.0.1:80:hostname',
      }
    end
    it "requires number port" do
      expect {
        resource[:bindings] = {
          'protocol' => 'http',
          'bindinginformation' => '*:a:',
        }
      }.to raise_error(Puppet::Error, /65535/)
    end
    it "allows * for ip" do
      resource[:bindings] = {
        'protocol' => 'http',
        'bindinginformation' => '*:80:hostname',
      }
    end
    it "allows empty hostname" do
      resource[:bindings] = {
        'protocol' => 'http',
        'bindinginformation' => '*:80:',
      }
    end
  end
  context "property :limits" do
    it "requires a hash" do
      expect {
        resource[:limits] = "hi"
      }.to raise_error(Puppet::Error, /Hash/)
      expect {
        resource[:limits] = ["hi"]
      }.to raise_error(Puppet::Error, /Hash/)
    end
    it "accepts only valid limits as keys" do
      expect {
        resource[:limits] = {'invalid' => 'setting'}
    }.to raise_error(Puppet::Error, /Invalid iis site limit key/)
    end
    it "rejects invalid limits values" do
      expect {
        resource[:limits] = { 'maxconnections' => "string"}
      }.to raise_error(Puppet::Error, /integer/)
      expect {
        resource[:limits] = { 'maxbandwidth' => 0 }
      }.to raise_error(Puppet::Error, /Cannot be less than 1 or greater than 4294967295/)
      expect {
        resource[:limits] = { 'maxbandwidth' => 4294967296 }
      }.to raise_error(Puppet::Error, /Cannot be less than 1 or greater than 4294967295/)
    end
  end
  context "parameter :applicationpool" do
    it "should not allow nil" do
      expect {
        resource[:applicationpool] = nil
      }.to raise_error(Puppet::Error, /Got nil value for applicationpool/)
    end

    it "should not allow empty" do
      expect {
        resource[:applicationpool] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty applicationpool name must be specified./)
    end

    it "should accept any string value" do
      resource[:applicationpool] = 'value'
      resource[:applicationpool] = "thisstring-location"
    end
  end

  context "parameter :enabledprotocols" do
    it "should not allow nil" do
      expect {
        resource[:enabledprotocols] = nil
      }.to raise_error(Puppet::Error, /Got nil value for enabledprotocols/)
    end

    it "should not allow empty" do
      expect {
        resource[:enabledprotocols] = ''
      }.to raise_error(Puppet::ResourceError, /Invalid value ''. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname/)
    end

    it "should accept valid string value" do
      resource[:enabledprotocols] = ['http','https','net.pipe','net.tcp','net.msmq','msmq.formatname']
      resource[:enabledprotocols] = 'http'
      resource[:enabledprotocols] = 'https'
      resource[:enabledprotocols] = 'net.pipe'
      resource[:enabledprotocols] = 'net.tcp'
      resource[:enabledprotocols] = 'net.msmq'
      resource[:enabledprotocols] = 'msmq.formatname'
    end

    it "should not accept invalid string value" do
      expect {
        resource[:enabledprotocols] = 'woot'
      }.to raise_error(Puppet::ResourceError, /Invalid protocol 'woot'. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname/)
    end
  end

  context "parameter :serviceautostart" do
    it "should accept :true" do
      resource[:serviceautostart] = :true
    end

    it "should accept :false" do
      resource[:serviceautostart] = :false
    end

    it "should reject non-boolean values" do
      expect {
        resource[:serviceautostart] = :whenever
      }.to raise_error(Puppet::ResourceError, /Invalid value :whenever. Valid values are true, false./)
    end

    it "should not allow nil" do
      expect {
        resource[:serviceautostart] = nil
      }.to raise_error(Puppet::Error, /Got nil value for serviceautostart/)
    end

    it "should not allow empty" do
      expect {
        resource[:serviceautostart] = ''
      }.to raise_error(Puppet::ResourceError, /Invalid value "". Valid values are true, false./)
    end

    it "should not accept invalid string value" do
      expect {
        resource[:serviceautostart] = 'woot'
      }.to raise_error(Puppet::ResourceError, /Invalid value "woot". Valid values are true, false./)
    end
  end

  context "parameter :serviceautostartprovidername" do
    it "should not allow nil" do
      expect {
        resource[:serviceautostartprovidername] = nil
      }.to raise_error(Puppet::Error, /Got nil value for serviceautostartprovidername/)
    end

    it "should not allow empty" do
      expect {
        resource[:serviceautostartprovidername] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty serviceautostartprovidername name must be specified./)
    end

    it "should accept any string value" do
      resource[:serviceautostartprovidername] = 'value'
      resource[:serviceautostartprovidername] = "thisstring-location"
    end
  end

  context "parameter :serviceautostartprovidertype" do
    it "should not allow nil" do
      expect {
        resource[:serviceautostartprovidertype] = nil
      }.to raise_error(Puppet::Error, /Got nil value for serviceautostartprovidertype/)
    end

    it "should not allow empty" do
      expect {
        resource[:serviceautostartprovidertype] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty serviceautostartprovidertype name must be specified./)
    end

    it "should accept any string value" do
      resource[:serviceautostartprovidertype] = 'value'
      resource[:serviceautostartprovidertype] = "thisstring-location"
    end
  end

  context "parameter :preloadenabled" do
    it "should accept :true" do
      resource[:preloadenabled] = :true
    end

    it "should accept :false" do
      resource[:preloadenabled] = :false
    end

    it "should reject non-boolean values" do
      expect {
        resource[:preloadenabled] = :whenever
      }.to raise_error(Puppet::ResourceError, /Invalid value :whenever. Valid values are true, false./)
    end

    it "should not allow nil" do
      expect {
        resource[:preloadenabled] = nil
      }.to raise_error(Puppet::Error, /Got nil value for preloadenabled/)
    end

    it "should not allow empty" do
      expect {
        resource[:preloadenabled] = ''
      }.to raise_error(Puppet::ResourceError, /Invalid value "". Valid values are true, false./)
    end

    it "should not accept invalid string value" do
      expect {
        resource[:preloadenabled] = 'woot'
      }.to raise_error(Puppet::ResourceError, /Invalid value "woot". Valid values are true, false./)
    end
  end

  context "parameter :defaultpage" do
    it "should not allow nil" do
      expect {
        resource[:defaultpage] = nil
      }.to raise_error(Puppet::Error, /Got nil value for defaultpage/)
    end

    it "should not allow empty" do
      expect {
        resource[:defaultpage] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty defaultpage must be specified./)
    end

    it "should accept valid string value and string array" do
      resource[:defaultpage] = ['wakka','foo']
      resource[:defaultpage] = 'default.htm'
    end
  end

  context "parameter :logformat" do
    it "should not allow nil" do
      expect {
        resource[:logformat] = nil
      }.to raise_error(Puppet::Error, /Got nil value for logformat/)
    end

    it "should not allow empty" do
      expect {
        resource[:logformat] = ''
      }.to raise_error(Puppet::ResourceError, /Invalid value ''. Valid values are W3C, IIS, NCSA/)
    end

    it "should accept valid string value" do
      resource[:logformat] = ['W3C','IIS']
      resource[:logformat] = 'W3C'
      resource[:logformat] = 'IIS'
      resource[:logformat] = 'NCSA'
    end

    it "should not accept invalid string value" do
      expect {
        resource[:logformat] = 'woot'
      }.to raise_error(Puppet::ResourceError, /Invalid value 'woot'. Valid values are W3C, IIS, NCSA/)
    end
  end

  context "parameter :logpath" do
    it "should not allow nil" do
      expect {
        resource[:logpath] = nil
      }.to raise_error(Puppet::Error, /Got nil value for logpath/)
    end

    it "should not allow empty" do
      expect {
        resource[:logpath] = ''
      }.to raise_error(Puppet::Error, /A non-empty logpath must be specified./)
    end

    it "should accept any string value" do
      resource[:logpath] = "c:/thisstring-location/value/somefile.txt"
      resource[:logpath] = "c:\\thisstring-location\\value\\somefile.txt"
    end
  end

  context "parameter :logperiod" do
    it "should not allow nil" do
      expect {
        resource[:logperiod] = nil
      }.to raise_error(Puppet::Error, /Got nil value for logperiod/)
    end

    it "should not allow empty" do
      expect {
        resource[:logperiod] = ''
      }.to raise_error(Puppet::ResourceError, /Invalid value ''. Valid values are Hourly, Daily, Weekly, Monthly, MaxSize/)
    end

    it "should accept valid string value" do
      resource[:logperiod] = ['Hourly','Daily']
      resource[:logperiod] = 'Hourly'
      resource[:logperiod] = 'Daily'
      resource[:logperiod] = 'Weekly'
      resource[:logperiod] = 'Monthly'
      resource[:logperiod] = 'MaxSize'
    end

    it "should not accept invalid string value" do
      expect {
        resource[:logperiod] = 'woot'
      }.to raise_error(Puppet::ResourceError, /Invalid value 'woot'. Valid values are Hourly, Daily, Weekly, Monthly, MaxSize/)
    end
  end

  context "parameter :logtruncatesize" do
    it "should not allow nil" do
      expect {
        resource[:logtruncatesize] = nil
      }.to raise_error(Puppet::Error, /Got nil value for logtruncatesize/)
    end

    it "should not allow empty" do
      expect {
        resource[:logtruncatesize] = ''
      }.to raise_error(Puppet::ResourceError, /Invalid value ''. Should be a number/)
    end

    it "should not accept invalid int value" do
      expect {
        resource[:logtruncatesize] = 128576
      }.to raise_error(Puppet::ResourceError, /Invalid value '128576'. Cannot be less than 1048576 or greater than 4294967295/)
      expect {
        resource[:logtruncatesize] = 5298967295
      }.to raise_error(Puppet::ResourceError, /Invalid value '5298967295'. Cannot be less than 1048576 or greater than 4294967295/)
    end

    it "should accept valid int value" do
      resource[:logtruncatesize] = 1048576
      resource[:logtruncatesize] = 4294967295
    end

    it "should not accept invalid string value" do
      expect {
        resource[:logtruncatesize] = 'woot'
      }.to raise_error(Puppet::ResourceError, /Invalid value 'woot'. Should be a number/)
    end
  end

  context "parameter :loglocaltimerollover" do
    it "should accept :true" do
      resource[:loglocaltimerollover] = :true
    end

    it "should accept :false" do
      resource[:loglocaltimerollover] = :false
    end

    it "should reject non-boolean values" do
      expect {
        resource[:loglocaltimerollover] = :whenever
      }.to raise_error(Puppet::ResourceError, /Invalid value :whenever. Valid values are true, false./)
    end

    it "should not allow nil" do
      expect {
        resource[:loglocaltimerollover] = nil
      }.to raise_error(Puppet::Error, /Got nil value for loglocaltimerollover/)
    end

    it "should not allow empty" do
      expect {
        resource[:loglocaltimerollover] = ''
      }.to raise_error(Puppet::ResourceError, /Invalid value "". Valid values are true, false./)
    end

    it "should not accept invalid string value" do
      expect {
        resource[:loglocaltimerollover] = 'woot'
      }.to raise_error(Puppet::ResourceError, /Invalid value "woot". Valid values are true, false./)
    end
  end

  context "parameter :logflags" do
    it "should not allow nil" do
      expect {
        resource[:logflags] = nil
      }.to raise_error(Puppet::Error, /Got nil value for logflags/)
    end

    it "should not allow empty" do
      expect {
        resource[:logflags] = ''
      }.to raise_error(Puppet::ResourceError, /Invalid value ''. Valid values are Date, Time, ClientIP,
             UserName, SiteName, ComputerName, ServerIP,
             Method, UriStem, UriQuery, HttpStatus, Win32Status, BytesSent,
             BytesRecv, TimeTaken, ServerPort, UserAgent, Cookie, Referer,
             ProtocolVersion, Host, HttpSubStatus/)
    end

    it "should accept valid string value" do
      resource[:logflags] = ['Date','Time']
      resource[:logflags] = 'Date'
      resource[:logflags] = 'Time'
      resource[:logflags] = 'ClientIP'
    end

    it "should not accept invalid string value" do
      expect {
        resource[:logflags] = 'woot'
      }.to raise_error(Puppet::ResourceError, /Invalid value 'woot'. Valid values are Date, Time, ClientIP,
             UserName, SiteName, ComputerName, ServerIP,
             Method, UriStem, UriQuery, HttpStatus, Win32Status, BytesSent,
             BytesRecv, TimeTaken, ServerPort, UserAgent, Cookie, Referer,
             ProtocolVersion, Host, HttpSubStatus/)
    end
  end

  context "mulitple parameter validation" do

    it "should not allow logperiod and logtruncatesize to be specified at same time" do
      expect {
        resource[:logperiod] = 'Daily'
        resource[:logtruncatesize] = 1048576
        resource.validate
      }.to raise_error(Puppet::Error, /Cannot specify logperiod and logtruncatesize at the same time/)
    end

    it "should not allow logflags to be used without logformat set to W3C at same time" do
      expect {
        resource[:logflags] = 'Date'
        resource[:logformat] = 'IIS'
        resource.validate
      }.to raise_error(Puppet::Error, /Cannot specify logflags when logformat is not W3C/)
    end

    it "should not allow either serviceautostartprovidername or serviceautostartprovidertype to be specified without the other" do
      expect {
        resource[:serviceautostartprovidername] = 'foo'
        resource.validate
      }.to raise_error(Puppet::Error, /Must specify serviceautostartprovidertype as well as serviceautostartprovidername/)
    end

  end
  # context "parameter :state" do
  #   it "should not allow nil" do
  #     expect {
  #       resource[:state] = nil
  #     }.to raise_error(Puppet::Error, /Got nil value for state/)
  #   end

  #   it "should not allow empty" do
  #     expect {
  #       resource[:state] = ''
  #     }.to raise_error(Puppet::ResourceError, /A non-empty state must be specified./)
  #   end

  #   it "should not allow anything other than stopped|started" do
  #     expect {
  #       resource[:state] = 'foo'
  #     }.to raise_error(Puppet::ResourceError, /Invalid value 'foo'. Valid values are started, stopped/)
  #   end

  #   it "should accept only started|stopped string value" do
  #     resource[:state] = "started"
  #     resource[:state] = "Started"
  #     resource[:state] = "stopped"
  #     resource[:state] = "Stopped"
  #   end
  # end

end

# iis_site{'foobar':
#   ensure          => 'started',
#   path            => 'c:\inetpub\foobar',
#   applicationpool => 'foo',
#   bindinginfo     => [
#     {
#       protocol              => 'http',
#       ipaddress             => '192.168.0.1',
#       port                  => 80,
#       hostname              => '',
#       certificatethumbprint => '',
#       certificatestorename  => '',
#       sslflags              => '',
#     },
#     {
#       protocol              => 'https'
#       binding               => '192.168.0.1:443:foo',
#       certificatethumbprint => '',
#       certificatestorename  => '',
#       sslflags              => '',
#     }
#   ],
#   defaultpage                  => [],
#   enabledprotocols             => '',
#   authenticationinfo           => '',
#   preloadenabled               => '',
#   serviceautostart             => false,
#   serviceautostartprovidername => '',
#   serviceautostartprovidertype => '',
#   preloadenabled               => false,,
#   logpath                      => '',
#   logflags                     => [],
#   logperiod                    => '',
#   logtruncatesize              => '',
#   loglocaltimerollover         => false,
#   logformat                    => '',
# }
