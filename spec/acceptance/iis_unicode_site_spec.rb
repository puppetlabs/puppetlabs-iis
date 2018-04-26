require 'spec_helper_acceptance'

describe 'iis_site' do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites();
  end

  context 'when configuring a website' do
    context 'with required parameters and UTF-8 site name' do
      before (:all) do
        create_path('C:\inetpub\basic')
        @site_name = "\u4388\u542B\u3D3C\u7F4D\uF961\u4381\u53F4\u79C0\u3AB2\u8EDE" # 䎈含㴼罍率䎁叴秀㪲軞
        @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
          }
        HERE
      end

      it 'should run without errors' do
        expect_failure('Expected to fail due to MODULES-6869') do
          execute_manifest(@manifest, :catch_failures => true)
        end
      end

      def verify_iis_site(iis_site_name)
        <<-powershell
          Import-Module Webadministration 
          (Get-ChildItem -Path IIS:\Sites | Where-Object { $_.Name -match ([regex]::Unescape(\"#{iis_site_name}\")) } | Measure-Object).Count
        powershell
      end

      windows_hosts = hosts.select {|host| host.platform =~ /windows/i}

      windows_hosts.each do |host|
        it 'Verify that IIS site name is present' do
          on(host, powershell(verify_iis_site(@site_name), 'EncodedCommand' => true)) do |result|
            expect_failure('Expected to fail due to MODULES-6869') do
              assert_match(%r{^1$}, result.stdout, 'Expected IIS site was not present!')
            end
          end
        end
      end

      after(:all) do
        remove_all_sites
      end
    end
  end
end
