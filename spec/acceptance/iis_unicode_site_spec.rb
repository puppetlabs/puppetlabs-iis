# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'iis_site', :suite_b do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites
  end

  context 'when configuring a website' do
    context 'with required parameters and UTF-8 site name' do
      before(:all) do
        create_path('C:\inetpub\basic')
      end

      site_name = "\u4388\u542B\u3D3C\u7F4D\uF961\u4381\u53F4\u79C0\u3AB2\u8EDE" # 䎈含㴼罍率䎁叴秀㪲軞
      manifest = <<-HERE
        iis_site { '#{site_name}':
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\basic',
          applicationpool => 'DefaultAppPool',
        }
      HERE

      after(:all) do
        remove_all_sites
      end

      it 'runs without errors' do
        # Expected to fail due to MODULES-6869
        expect { apply_manifest(manifest, catch_failures: true) }.to raise_exception
      end

      def verify_iis_site(iis_site_name)
        <<-POWERSHELL
          Import-Module Webadministration
          (Get-ChildItem -Path IIS:\Sites | Where-Object { $_.Name -match ([regex]::Unescape("#{iis_site_name}")) } | Measure-Object).Count
        POWERSHELL
      end

      it 'Verify that IIS site name is present' do
        result = run_shell(interpolate_powershell(verify_iis_site(site_name)))
        # Expected to fail due to MODULES-6869'
        expect { assert_match(%r{^1$}, result.stdout, 'Expected IIS site was not present!') }.to raise_exception
      end
    end
  end
end
