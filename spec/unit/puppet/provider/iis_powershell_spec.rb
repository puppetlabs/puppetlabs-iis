#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/iis_powershell'

describe Puppet::Provider::IIS_PowerShell do
  let (:subject) { Puppet::Provider::IIS_PowerShell }

  describe "parse_json_result" do

    # Single Object text
    let(:single_rawtext) { <<-HERE
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
    }
    # Same as single_rawtext with CR and LF littered throughout
    let(:single_rawtext_with_crlf) { <<-HERE
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
    }
    # PowerShell 2 representation of single_rawtext
    let(:single_ps2_rawtext) { <<-HERE
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
    }
    # The object representation for single_rawtext
    let(:single_expected_object) {
      [{"enabledprotocols"=>"http",
      "logtruncatesize"=>"20971520",
      "applicationpool"=>"DefaultAppPool",
      "logperiod"=>"Daily",
      "name"=>"Default Web Site",
      "bindings"=>
      [{"certificatestorename"=>"",
        "protocol"=>"http",
        "sslflags"=>0,
        "certificatehash"=>"",
        "bindinginformation"=>"*:80:"}],
      "logformat"=>"W3C",
      "hostheader"=>"",
      "loglocaltimerollover"=>"False"}]
    }
    # Multi Object return
    let(:multi_rawtext) { <<-HERE
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
    }
    # PowerShell 2 representation of multi_rawtext
    let(:multi_ps2_rawtext) { <<-HERE
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
    }
    # The object representation for multi_rawtext
    let(:multi_expected_object) {
      [
        {"enabledprotocols"=>"http",
        "logtruncatesize"=>"20971520",
        "applicationpool"=>"DefaultAppPool",
        "logperiod"=>"Daily",
        "name"=>"Default Web Site",
        "bindings"=>
        [{"certificatestorename"=>"",
          "protocol"=>"http",
          "sslflags"=>0,
          "certificatehash"=>"",
          "bindinginformation"=>"*:80:"}
        ],
        "logformat"=>"W3C",
        "hostheader"=>"",
        "loglocaltimerollover"=>"False"
        },
        {"enabledprotocols"=>"http",
        "logtruncatesize"=>"20971520",
        "applicationpool"=>"AppPool2",
        "logperiod"=>"Daily",
        "name"=>"Default Web Site",
        "bindings"=>
        [{"certificatestorename"=>"",
          "protocol"=>"http",
          "sslflags"=>0,
          "certificatehash"=>"",
          "bindinginformation"=>"*:80:"},
         {"certificatestorename"=>"",
          "protocol"=>"http",
          "sslflags"=>0,
          "certificatehash"=>"",
          "bindinginformation"=>"*:8080:"}
        ],
        "logformat"=>"W3C",
        "hostheader"=>"header",
        "loglocaltimerollover"=>"False"
        }
      ]
    }

    describe "When given invalid raw text" do
      it "should return nil when given nil" do
        expect(subject.parse_json_result(nil)).to be_nil
      end

      it "should raise when given invalid JSON" do
        expect{ subject.parse_json_result("invalid json") }.to raise_error(JSON::ParserError)
      end

      it "should raise when given an empty string" do
        expect{ subject.parse_json_result("") }.to raise_error(JSON::ParserError)
      end
    end

    describe "When given valid JSON from PowerShell 3+" do
      it "should return a Ruby representation of the JSON text for a single object" do
        result = subject.parse_json_result(single_rawtext)
        expect(result).to eq(single_expected_object)
      end

      it "should return a Ruby representation of the JSON text for multiple objects" do
        result = subject.parse_json_result(multi_rawtext)
        expect(result).to eq(multi_expected_object)
      end

      it "should should ignore CR and LF characters" do
        result = subject.parse_json_result(single_rawtext_with_crlf)
        expect(result).to eq(single_expected_object)
      end
    end

    describe "When given JSON from PowerShell 2" do
      it "should return a Ruby representation of the JSON text" do
        result = subject.parse_json_result(single_ps2_rawtext)
        expect(result).to eq(single_expected_object)
      end

      it "should return a Ruby representation of the JSON text for multiple objects" do
        result = subject.parse_json_result(multi_ps2_rawtext)
        expect(result).to eq(multi_expected_object)
      end

      describe "When given Unknown PowerShell encoding" do
        let(:raw_text) {
          '{ "Objects": "NotAHashOrArray" }'
        }
        it "should raise an error" do
          expect{ subject.parse_json_result(raw_text) }.to raise_error(/JSON encoding/)
        end
      end
    end
  end
end
