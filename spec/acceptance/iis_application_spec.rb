# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'iis_application', :suite_a do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites
  end

  context 'when creating an application' do
    context 'with normal parameters' do
      site_name = SecureRandom.hex(10).to_s
      app_name = SecureRandom.hex(10).to_s
      before(:all) do
        create_path('C:\inetpub\basic')
      end

      manifest = <<-HERE
        iis_site { '#{site_name}':
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\basic',
          applicationpool => 'DefaultAppPool',
        }
        iis_application { '#{app_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          physicalpath => 'C:\\inetpub\\basic',
        }
      HERE
      iis_idempotent_apply('create app', manifest)

      # include_context 'with a puppet resource run'# do
      after(:all) do
        remove_app(app_name)
        remove_all_sites
      end

      it 'iis_application is absent' do
        result = resource('iis_application', "#{site_name}\\#{app_name}")
        [
          'physicalpath', 'C:\inetpub\basic',
          'applicationpool', 'DefaultAppPool'
        ].each_slice(2) do |key, value|
          puppet_resource_should_show(key, value, result)
        end
      end

      manifest = <<-HERE
        iis_application { '#{app_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          # Change the capitalization of the T to see if it breaks.
          physicalpath => 'C:\\ineTpub\\basic',
        }
      HERE

      it 'runs with no changes' do
        apply_manifest(manifest, catch_changes: true)
      end
    end

    context 'with virtual_directory' do
      site_name = SecureRandom.hex(10).to_s
      app_name = SecureRandom.hex(10).to_s
      before(:all) do
        create_site(site_name, true)
        create_path('C:\inetpub\vdir')
        create_virtual_directory(site_name, app_name, 'C:\inetpub\vdir')
      end

      manifest = <<-HERE
        iis_application { '#{site_name}\\#{app_name}':
          ensure            => 'present',
          virtual_directory => 'IIS:\\Sites\\#{site_name}\\#{app_name}',
        }
      HERE

      iis_idempotent_apply('create app', manifest)

      after(:all) do
        remove_app(app_name)
        remove_all_sites
      end

      it 'iis_application is absent' do
        result = resource('iis_application', "#{site_name}\\#{app_name}")
        [
          'physicalpath', 'C:\inetpub\vdir',
          'applicationpool', 'DefaultAppPool'
        ].each_slice(2) do |key, value|
          puppet_resource_should_show(key, value, result)
        end
      end
    end

    context 'with nested virtual directory' do
      site_name = SecureRandom.hex(10).to_s
      app_name = SecureRandom.hex(10).to_s
      before(:all) do
        create_site(site_name, true)
        create_path("c:\\inetpub\\wwwroot\\subFolder\\#{app_name}")
      end

      manifest = <<-HERE
        iis_application{'subFolder/#{app_name}':
          ensure => 'present',
          applicationname => 'subFolder/#{app_name}',
          physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{app_name}',
          sitename => '#{site_name}'
        }
      HERE

      iis_idempotent_apply('create app', manifest)

      after(:all) do
        remove_app(app_name)
        remove_all_sites
      end

      it 'creates the correct application' do
        result = resource('iis_application', "#{site_name}\\subFolder/#{app_name}")
        expect(result.stdout).to match(/iis_application { '#{site_name}\\subFolder\/#{app_name}':/) # rubocop:disable Style/RegexpLiteral
        expect(result.stdout).to match(%r{ensure\s*=> 'present',})
      end
    end

    context 'with nested virtual directory and single namevar' do
      site_name = SecureRandom.hex(10).to_s
      app_name = SecureRandom.hex(10).to_s
      before(:all) do
        create_site(site_name, true)
        create_path("c:\\inetpub\\wwwroot\\subFolder\\#{app_name}")
      end

      manifest = <<-HERE
        iis_application{'subFolder/#{app_name}':
          ensure => 'present',
          physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{app_name}',
          sitename => '#{site_name}'
        }
      HERE

      iis_idempotent_apply('create app', manifest)

      after(:all) do
        remove_app(app_name)
        remove_all_sites
      end

      it 'creates the correct application' do
        result = resource('iis_application', "#{site_name}\\subFolder/#{app_name}")
        expect(result.stdout).to match(/iis_application { '#{site_name}\\subFolder\/#{app_name}':/) # rubocop:disable Style/RegexpLiteral
        expect(result.stdout).to match(%r{ensure\s*=> 'present',})
      end
    end

    context 'with forward slash virtual directory name format' do
      context 'with a leading slash' do
        site_name = SecureRandom.hex(10).to_s
        app_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_site(site_name, true)
          create_path("c:\\inetpub\\wwwroot\\subFolder\\#{app_name}")
        end

        manifest = <<-HERE
          iis_application{'subFolder/#{app_name}':
            ensure => 'present',
            applicationname => '/subFolder/#{app_name}',
            physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{app_name}',
            sitename => '#{site_name}'
          }
        HERE

        iis_idempotent_apply('create app', manifest)

        after(:all) do
          remove_app(app_name)
          remove_all_sites
        end
      end
    end

    context 'with a physcail path ending in a forward slash' do
      context 'with a ending forward slash' do
        site_name = SecureRandom.hex(10).to_s
        app_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_site(site_name, true)
          create_path("c:\\inetpub\\wwwroot\\subFolder\\#{app_name}")
        end

        manifest = <<-HERE
          iis_application{'subFolder/#{app_name}':
            ensure => 'present',
            applicationname => '/subFolder/#{app_name}',
            physicalpath => 'c:/inetpub/wwwroot/subFolder/#{app_name}/',
            sitename => '#{site_name}'
          }
        HERE

        iis_idempotent_apply('create app', manifest)

        after(:all) do
          remove_app(app_name)
          remove_all_sites
        end
      end
    end

    context 'with backward slash virtual directory name format' do
      site_name = SecureRandom.hex(10).to_s
      app_name = SecureRandom.hex(10).to_s
      before(:all) do
        create_site(site_name, true)
        create_path("c:\\inetpub\\wwwroot\\subFolder\\#{app_name}")
      end

      manifest = <<-HERE
          iis_application{'subFolder\\#{app_name}':
            ensure => 'present',
            applicationname => 'subFolder/#{app_name}',
            physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{app_name}',
            sitename => '#{site_name}'
          }
      HERE

      iis_idempotent_apply('create app', manifest)

      after(:all) do
        remove_app(app_name)
        remove_all_sites
      end
    end

    context 'with two level nested virtual directory' do
      site_name = SecureRandom.hex(10).to_s
      app_name = SecureRandom.hex(10).to_s
      before(:all) do
        create_site(site_name, true)
        create_path("c:\\inetpub\\wwwroot\\subFolder\\sub2\\#{app_name}")
      end

      manifest = <<-HERE
        iis_application{'subFolder/sub2/#{app_name}':
          ensure => 'present',
          applicationname => 'subFolder/sub2/#{app_name}',
          physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\sub2\\#{app_name}',
          sitename => '#{site_name}'
        }
      HERE

      iis_idempotent_apply('create app', manifest)

      after(:all) do
        remove_app(app_name)
        remove_all_sites
      end

      it 'creates the correct application' do
        result = resource('iis_application', "#{site_name}\\subFolder/sub2/#{app_name}")
        expect(result.stdout).to match(/iis_application { '#{site_name}\\subFolder\/sub2\/#{app_name}':/) # rubocop:disable Style/RegexpLiteral
        expect(result.stdout).to match(%r{ensure\s*=> 'present',})
      end
    end
  end

  context 'when setting' do
    it 'sslflags', skip: 'blocked by MODULES-5561' do
      site_name = SecureRandom.hex(10).to_s
      app_name = SecureRandom.hex(10).to_s
      site_hostname = 'www.puppet.local'
      before(:all) do
        create_site(site_name, true)
        create_path('C:\inetpub\wwwroot')
        create_path('C:\inetpub\modify')
        create_app(site_name, app_name, 'C:\inetpub\wwwroot')
        @certificate_hash = create_selfsigned_cert('www.puppet.local').downcase
      end

      manifest = <<-HERE
        iis_site { '#{site_name}':
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\wwwroot',
          applicationpool => 'DefaultAppPool',
          bindings        => [
            {
              'bindinginformation'   => '*:80:#{site_hostname}',
              'protocol'             => 'http',
            },
            {
              'bindinginformation'   => '*:443:#{site_hostname}',
              'protocol'             => 'https',
              'certificatestorename' => 'MY',
              'certificatehash'      => '#{@certificate_hash}',
              'sslflags'             => 0,
            },
          ],
        }
        iis_application { '#{app_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          physicalpath => 'C:\\inetpub\\modify',
          sslflags     => ['Ssl','SslRequireCert'],
        }
      HERE

      iis_idempotent_apply('create app', manifest)
    end

    describe 'authentication info' do
      site_name = SecureRandom.hex(10).to_s
      app_name = SecureRandom.hex(10).to_s
      before(:all) do
        create_path('C:\inetpub\wwwroot')
        create_path('C:\inetpub\auth')
        create_site(site_name, true)
        create_app(site_name, app_name, 'C:\inetpub\auth')
      end

      manifest = <<-HERE
        iis_application { '#{app_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          physicalpath => 'C:\\inetpub\\auth',
          authenticationinfo => {
            'basic'     => true,
            'anonymous' => false,
          },
        }
      HERE

      iis_idempotent_apply('create app', manifest)
      after(:all) do
        remove_app(app_name)
        remove_all_sites
      end
    end

    describe 'applicationpool' do
      site_name = SecureRandom.hex(10).to_s
      app_name = SecureRandom.hex(10).to_s
      before(:all) do
        create_path('C:\inetpub\wwwroot')
        create_path('C:\inetpub\auth')
        create_site(site_name, true)
        create_app(site_name, app_name, 'C:\inetpub\auth')
        create_app_pool('foo_pool')
      end

      manifest = <<-HERE
        iis_application { '#{app_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          physicalpath => 'C:\\inetpub\\auth',
          applicationpool => 'foo_pool'
        }
      HERE

      iis_idempotent_apply('create app', manifest)
      after(:all) do
        remove_app(app_name)
        remove_all_sites
      end
    end
  end

  context 'when removing an application' do
    site_name = SecureRandom.hex(10).to_s
    app_name = SecureRandom.hex(10).to_s
    before(:all) do
      create_site(site_name, true)
      create_path('C:\inetpub\remove')
      create_virtual_directory(site_name, app_name, 'C:\inetpub\remove')
      create_app(site_name, app_name, 'C:\inetpub\remove')
    end

    manifest = <<-HERE
      iis_application { '#{app_name}':
        ensure       => 'absent',
        sitename     => '#{site_name}',
        physicalpath => 'C:\\inetpub\\remove',
      }
    HERE

    iis_idempotent_apply('create app', manifest)

    after(:all) do
      remove_app(app_name)
      remove_all_sites
    end

    it 'iis_application is absent' do
      result = resource('iis_application', "#{site_name}\\#{app_name}")
      puppet_resource_should_show('ensure', 'absent', result)
    end
  end

  context 'physicalpath is not set' do
    site_name = SecureRandom.hex(10).to_s
    app_name = SecureRandom.hex(10).to_s
    before(:all) do
      create_site(site_name, true)
      create_path('C:\inetpub\basic')
      create_virtual_directory(site_name, app_name, 'C:\inetpub\basic')
      create_app(site_name, app_name)
    end

    manifest = <<-HERE
        iis_site { '#{site_name}':
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\basic',
          applicationpool => 'DefaultAppPool',
        }
        iis_application { '#{app_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
        }
    HERE
    iis_idempotent_apply('create app', manifest)

    after(:all) do
      remove_app(app_name)
      remove_all_sites
    end
  end

  context 'with multiple sites with same application name' do
    site_name = SecureRandom.hex(10).to_s
    site_name2 = SecureRandom.hex(10).to_s
    app_name = SecureRandom.hex(10).to_s
    before(:all) do
      remove_all_sites
      create_path("C:\\inetpub\\#{site_name}\\#{app_name}")
      create_path("C:\\inetpub\\#{site_name2}\\#{app_name}")
    end

    manifest = <<-HERE
      iis_site { '#{site_name}':
        ensure          => 'started',
        physicalpath    => 'C:\\inetpub\\#{site_name}',
        applicationpool => 'DefaultAppPool',
        bindings        => [
        {
          'bindinginformation' => '*:8081:',
          'protocol'           => 'http',
        }]
      }
      iis_application { '#{site_name}\\#{app_name}':
        ensure            => 'present',
        sitename        => '#{site_name}',
        physicalpath => 'C:\\inetpub\\#{site_name}\\#{app_name}',
      }
      iis_site { '#{site_name2}':
        ensure          => 'started',
        physicalpath    => 'C:\\inetpub\\#{site_name2}',
        applicationpool => 'DefaultAppPool',
      }
      iis_application { '#{site_name2}\\#{app_name}':
        ensure            => 'present',
        sitename        => '#{site_name2}',
        physicalpath => 'C:\\inetpub\\#{site_name2}\\#{app_name}',
      }
    HERE

    iis_idempotent_apply('create app', manifest)

    after(:all) do
      remove_app(app_name)
      remove_all_sites
    end

    it 'contains the first site with the same app name' do
      result = resource('iis_application', "#{site_name}\\#{app_name}")
      expect(result.stdout).to match(%r{#{site_name}\\#{app_name}})
      expect(result.stdout).to match(%r{ensure\s*=> 'present',})
      expect(result.stdout).to match %r{C:\\inetpub\\#{site_name}\\#{app_name}}
      expect(result.stdout).to match %r{applicationpool\s*=> 'DefaultAppPool'}
    end

    it 'contains the second site with the same app name' do
      result2 = resource('iis_application', "#{site_name2}\\#{app_name}")
      expect(result2.stdout).to match(%r{#{site_name2}\\#{app_name}})
      expect(result2.stdout).to match(%r{ensure\s*=> 'present',})
      expect(result2.stdout).to match %r{C:\\inetpub\\#{site_name2}\\#{app_name}}
      expect(result2.stdout).to match %r{applicationpool\s*=> 'DefaultAppPool'}
    end
  end
end
