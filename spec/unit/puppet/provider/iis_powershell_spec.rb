# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/iis_powershell'

# describe Puppet::Provider::IIS_PowerShell do
describe 'test' do
  describe 'run' do
    subject(:iis_powershell_type) { Puppet::Provider::IIS_PowerShell }

    let(:ps_manager) { instance_double(Puppet::Provider::IIS_PowerShell) }
    let(:command) { 'command' }
    let(:execute_response) do
      {
        stdout: nil, stderr: nil, exitcode: 0
      }
    end

    before(:each) do
      allow(Puppet::Provider::IIS_PowerShell).to receive(:ps_manager).and_return(ps_manager)
      allow(ps_manager).to receive(:execute).and_return(execute_response)
    end

    [3, 4, 5, 6].each do |testcase|
      describe "When on PowerShell #{testcase}.0" do
        before(:each) do
          allow(Puppet::Provider::IIS_PowerShell).to receive(:ps_major_version).and_return(testcase)
        end

        it 'does not modify the command' do
          expect(ps_manager).to receive(:execute).with(command).and_return(execute_response)
          iis_powershell_type.run(command)
        end
      end
    end
  end

  describe 'parse_json_result' do
    # Single Object text
    subject(:iis_powershell_type) { Puppet::Provider::IIS_PowerShell }

    let(:single_rawtext) do
      <<~HERE
        {
            "enabledprotocols":  "http",
            "logtruncatesize":  "20971520",
            "applicationpool":  "DefaultAppPool",
            "logperiod":  "Daily",
            "name":  "Default Web Site",
            "bindings":  [
                            {
                                "certificatestorename":  "",
                                "protocol":  "http",
                                "sslflags":  0,
                                "certificatehash":  "",
                                "bindinginformation":  "*:80:"
                            }
                        ],
            "logformat":  "W3C",
            "hostheader":  "",
            "loglocaltimerollover":  "False"
        }
      HERE
    end
    # Same as single_rawtext with CR and LF littered throughout
    let(:single_rawtext_with_crlf) do
      <<~HERE
        {
            "enabledprotocols":  "http",
            "logtruncatesize":  "20971520",
            "applicat\r
        ionpool":  "DefaultAppPool",
            "logperiod":  "Daily",
            "name":  "Default Web Site",
            "bindings":  [
                            {
                                "certificatestorename":  "",
                                "protocol":  "http",
                                "ssl
        flags":  0,
                                "certificatehash":  \r
        "",
                                "bindinginformation":  "*:80:"
                            }
                        ],
            "logformat":  "W3\r
        C",
            "hostheader":  "",
            "loglocaltimerollover":  "False"
        }
      HERE
    end
    # PowerShell 2 representation of single_rawtext
    let(:single_ps2_rawtext) do
      <<~HERE
        { "Objects": { "Object":
        {
            "enabledprotocols":  "http",
            "logtruncatesize":  "20971520",
            "applicationpool":  "DefaultAppPool",
            "logperiod":  "Daily",
            "name":  "Default Web Site",
            "bindings":  [
                            {
                                "certificatestorename":  "",
                                "protocol":  "http",
                                "sslflags":  0,
                                "certificatehash":  "",
                                "bindinginformation":  "*:80:"
                            }
                        ],
            "logformat":  "W3C",
            "hostheader":  "",
            "loglocaltimerollover":  "False"
        }
        }}
      HERE
    end
    # The object representation for single_rawtext
    let(:single_expected_object) do
      [{ 'enabledprotocols' => 'http',
         'logtruncatesize' => '20971520',
         'applicationpool' => 'DefaultAppPool',
         'logperiod' => 'Daily',
         'name' => 'Default Web Site',
         'bindings' =>
      [{ 'certificatestorename' => '',
         'protocol' => 'http',
         'sslflags' => 0,
         'certificatehash' => '',
         'bindinginformation' => '*:80:' }],
         'logformat' => 'W3C',
         'hostheader' => '',
         'loglocaltimerollover' => 'False' }]
    end
    # Multi Object return
    let(:multi_rawtext) do
      <<~HERE
        [{
            "enabledprotocols":  "http",
            "logtruncatesize":  "20971520",
            "applicationpool":  "DefaultAppPool",
            "logperiod":  "Daily",
            "name":  "Default Web Site",
            "bindings":  [
                            {
                                "certificatestorename":  "",
                                "protocol":  "http",
                                "sslflags":  0,
                                "certificatehash":  "",
                                "bindinginformation":  "*:80:"
                            }
                        ],
            "logformat":  "W3C",
            "hostheader":  "",
            "loglocaltimerollover":  "False"
        },
        {
            "enabledprotocols":  "http",
            "logtruncatesize":  "20971520",
            "applicationpool":  "AppPool2",
            "logperiod":  "Daily",
            "name":  "Default Web Site",
            "bindings":  [
                            {
                                "certificatestorename":  "",
                                "protocol":  "http",
                                "sslflags":  0,
                                "certificatehash":  "",
                                "bindinginformation":  "*:80:"
                            },
                            {
                                "certificatestorename":  "",
                                "protocol":  "http",
                                "sslflags":  0,
                                "certificatehash":  "",
                                "bindinginformation":  "*:8080:"
                            }
                        ],
            "logformat":  "W3C",
            "hostheader":  "header",
            "loglocaltimerollover":  "False"
        }]
      HERE
    end
    # PowerShell 2 representation of multi_rawtext
    let(:multi_ps2_rawtext) do
      <<~HERE
        { "Objects":
        [{
            "enabledprotocols":  "http",
            "logtruncatesize":  "20971520",
            "applicationpool":  "DefaultAppPool",
            "logperiod":  "Daily",
            "name":  "Default Web Site",
            "bindings":  [
                            {
                                "certificatestorename":  "",
                                "protocol":  "http",
                                "sslflags":  0,
                                "certificatehash":  "",
                                "bindinginformation":  "*:80:"
                            }
                        ],
            "logformat":  "W3C",
            "hostheader":  "",
            "loglocaltimerollover":  "False"
        },
        {
            "enabledprotocols":  "http",
            "logtruncatesize":  "20971520",
            "applicationpool":  "AppPool2",
            "logperiod":  "Daily",
            "name":  "Default Web Site",
            "bindings":  [
                            {
                                "certificatestorename":  "",
                                "protocol":  "http",
                                "sslflags":  0,
                                "certificatehash":  "",
                                "bindinginformation":  "*:80:"
                            },
                            {
                                "certificatestorename":  "",
                                "protocol":  "http",
                                "sslflags":  0,
                                "certificatehash":  "",
                                "bindinginformation":  "*:8080:"
                            }
                        ],
            "logformat":  "W3C",
            "hostheader":  "header",
            "loglocaltimerollover":  "False"
        }]
        }
      HERE
    end
    # The object representation for multi_rawtext
    let(:multi_expected_object) do
      [
        { 'enabledprotocols' => 'http',
          'logtruncatesize' => '20971520',
          'applicationpool' => 'DefaultAppPool',
          'logperiod' => 'Daily',
          'name' => 'Default Web Site',
          'bindings' =>
        [{ 'certificatestorename' => '',
           'protocol' => 'http',
           'sslflags' => 0,
           'certificatehash' => '',
           'bindinginformation' => '*:80:' }],
          'logformat' => 'W3C',
          'hostheader' => '',
          'loglocaltimerollover' => 'False' },
        { 'enabledprotocols' => 'http',
          'logtruncatesize' => '20971520',
          'applicationpool' => 'AppPool2',
          'logperiod' => 'Daily',
          'name' => 'Default Web Site',
          'bindings' =>
        [{ 'certificatestorename' => '',
           'protocol' => 'http',
           'sslflags' => 0,
           'certificatehash' => '',
           'bindinginformation' => '*:80:' },
         { 'certificatestorename' => '',
           'protocol' => 'http',
           'sslflags' => 0,
           'certificatehash' => '',
           'bindinginformation' => '*:8080:' }],
          'logformat' => 'W3C',
          'hostheader' => 'header',
          'loglocaltimerollover' => 'False' },
      ]
    end

    describe 'When given invalid raw text' do
      it 'returns nil when given nil' do
        expect(iis_powershell_type.parse_json_result(nil)).to be_nil
      end

      it 'raises when given invalid JSON' do
        expect { iis_powershell_type.parse_json_result('invalid json') }.to raise_error(JSON::ParserError)
      end

      it 'raises when given an empty string' do
        expect { iis_powershell_type.parse_json_result('') }.to raise_error(JSON::ParserError)
      end
    end

    describe 'When given valid JSON from PowerShell 3+' do
      it 'returns a Ruby representation of the JSON text for a single object' do
        result = iis_powershell_type.parse_json_result(single_rawtext)
        expect(result).to eq(single_expected_object)
      end

      it 'returns a Ruby representation of the JSON text for multiple objects' do
        result = iis_powershell_type.parse_json_result(multi_rawtext)
        expect(result).to eq(multi_expected_object)
      end

      it 'shoulds ignore CR and LF characters' do
        result = iis_powershell_type.parse_json_result(single_rawtext_with_crlf)
        expect(result).to eq(single_expected_object)
      end
    end

    describe 'When given JSON from PowerShell 2' do
      it 'returns a Ruby representation of the JSON text' do
        result = iis_powershell_type.parse_json_result(single_ps2_rawtext)
        expect(result).to eq(single_expected_object)
      end

      it 'returns a Ruby representation of the JSON text for multiple objects' do
        result = iis_powershell_type.parse_json_result(multi_ps2_rawtext)
        expect(result).to eq(multi_expected_object)
      end

      describe 'When given Unknown PowerShell encoding' do
        let(:raw_text) do
          '{ "Objects": "NotAHashOrArray" }'
        end

        it 'raises an error' do
          expect { iis_powershell_type.parse_json_result(raw_text) }.to raise_error(%r{JSON encoding})
        end
      end
    end
  end
end
