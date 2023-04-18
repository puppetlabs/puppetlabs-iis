# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'iis_site', :suite_b do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites
  end

  context 'when configuring a website' do
    context 'with basic required parameters' do
      before(:all) do
        create_path('C:\inetpub\basic')
      end

      site_name = SecureRandom.hex(10).to_s
      manifest = <<-HERE
        iis_site { '#{site_name}':
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\basic',
          applicationpool => 'DefaultAppPool',
        }
      HERE

      iis_idempotent_apply('create iis site', manifest)

      after(:all) do
        remove_all_sites
      end

      it 'has all properties correctly configured' do
        resource_data = resource('iis_site', site_name)
        [
          'ensure', 'started',
          'physicalpath', 'C:\inetpub\basic',
          'applicationpool', 'DefaultAppPool'
        ].each_slice(2) do |key, value|
          puppet_resource_should_show(key, value, resource_data)
        end
      end
    end

    context 'with all parameters specified' do
      context 'using W3C log format, logflags and logtruncatesize' do
        site_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_path('C:\inetpub\new')
        end

        let(:certificate_hash) { create_selfsigned_cert('www.puppet.local').downcase }

        let(:manifest) do
          <<-HERE
            iis_site { '#{site_name}':
              ensure               => 'started',
              applicationpool      => 'DefaultAppPool',
              enabledprotocols     => 'https',
              bindings             => [
                {
                  'bindinginformation'   => '*:8080:',
                  'protocol'             => 'http',
                },
                {
                  'bindinginformation'   => '*:8084:domain.test',
                  'protocol'             => 'http',
                },
                {
                  'bindinginformation'   => '*:8088:www.puppet.local',
                  'protocol'             => 'http',
                },
                {
                  'bindinginformation'   => '*:443:www.puppet.local',
                  'certificatehash'      => '#{certificate_hash}',
                  'certificatestorename' => 'My',
                  'protocol'             => 'https',
                  'sslflags'             => 1,
                },
              ],
              limits               => {
                connectiontimeout => 120,
                maxbandwidth      => 4294967200,
                maxconnections    => 4294967200,
              },
              logflags             => ['ClientIP', 'Date', 'Time', 'UserName'],
              logformat            => 'W3C',
              loglocaltimerollover => false,
              logpath              => 'C:\\inetpub\\logs\\NewLogFiles',
              logtruncatesize      => 2000000,
              physicalpath         => 'C:\\inetpub\\new',
            }
          HERE
        end

        after(:all) do
          remove_all_sites
        end

        it 'creates a site with SSL bindings' do
          apply_manifest(manifest, catch_failures: true)
        end

        it 'runs the manifest a second time without changes' do
          # SSL Flags not existing on IIS7 causes an idempotency bug in the provider
          # Remove comment if running acceptance tests on 2008 versions
          # pending('ssl flags do not exist on IIS 7 - MODULES-9894') if target_host_facts['os']['release']['major'].match(/2008/)
          apply_manifest(manifest, catch_changes: true)
        end

        it 'has all properties correctly configured' do
          resource_data = resource('iis_site', site_name)
          expect(resource_data.stdout).to match(%r{'bindinginformation' => '\*:443:www.puppet.local'})
          [
            'ensure', 'started',
            'enabledprotocols', 'https',
            'applicationpool', 'DefaultAppPool',
            'logflags', ['ClientIP', 'Date', 'Time', 'UserName'],
            'logformat', 'W3C',
            'loglocaltimerollover', 'false',
            'logpath', 'C:\\inetpub\\logs\\NewLogFiles',
            'logtruncatesize', '2000000',
            'physicalpath', 'C:\\inetpub\\new'
          ].each_slice(2) do |key, value|
            puppet_resource_should_show(key, value, resource_data)
          end
        end

        it 'when capitalization is changed in path parameters' do
          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure               => 'started',
              # Change capitalization to see if it break idempotency
              logpath              => 'C:\\ineTpub\\logs\\NewLogFiles',
              physicalpath         => 'C:\\ineTpub\\new'
            }
          HERE
          apply_manifest(manifest, catch_changes: true)
        end
      end

      context 'using preloadenabled', if: target_host_facts['kernelmajversion'] != '6.1' do
        before(:all) do
          create_path('C:\inetpub\new')
        end

        site_name = SecureRandom.hex(10).to_s

        manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure               => 'started',
            preloadenabled       => true,
            physicalpath         => 'C:\\inetpub\\new',
          }
        HERE

        iis_idempotent_apply('create iis site', manifest)

        after(:all) do
          remove_all_sites
        end

        it 'has all properties correctly configured' do
          resource_data = resource('iis_site', site_name)
          # resource_data = resource('iis_site', site_name)
          [
            'ensure', 'started',
            'preloadenabled', 'true',
            'physicalpath', 'C:\\inetpub\\new'
          ].each_slice(2) do |key, value|
            puppet_resource_should_show(key, value, resource_data)
          end
        end
      end

      context 'using non-W3C log format and logtperiod' do
        before(:all) do
          create_path('C:\inetpub\tmp')
        end

        site_name = SecureRandom.hex(10).to_s

        manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure               => 'started',
            applicationpool      => 'DefaultAppPool',
            enabledprotocols     => 'https',
            logformat            => 'NCSA',
            loglocaltimerollover => false,
            logpath              => 'C:\\inetpub\\logs\\NewLogFiles',
            logperiod            => 'Daily',
            physicalpath         => 'C:\\inetpub\\new',
          }
        HERE

        iis_idempotent_apply('create iis site', manifest)

        after(:all) do
          remove_all_sites
        end

        it 'has all properties correctly configured' do
          resource_data = resource('iis_site', site_name)
          [
            'ensure', 'started',
            'applicationpool', 'DefaultAppPool',
            'enabledprotocols', 'https',
            'logformat', 'NCSA',
            'loglocaltimerollover', 'false',
            'logpath', 'C:\\inetpub\\logs\\NewLogFiles',
            'logperiod', 'Daily',
            'physicalpath', 'C:\inetpub\new'
          ].each_slice(2) do |key, value|
            puppet_resource_should_show(key, value, resource_data)
          end
        end
      end

      context 'setting authenticationinfo' do
        site_name = SecureRandom.hex(10)
        before(:all) do
          create_path('C:\inetpub\tmp')
        end

        manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\tmp',
            applicationpool => 'DefaultAppPool',
            authenticationinfo => {
              'basic'     => true,
              'anonymous' => false,
            },
          }
        HERE

        iis_idempotent_apply('create iis site', manifest)

        after(:all) do
          remove_all_sites
        end
      end

      context 'can change site state from stopped to started' do
        context 'stopped to started' do
          site_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_path('C:\inetpub\tmp')
            create_site(site_name, false)
          end

          manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\tmp',
            applicationpool => 'DefaultAppPool',
          }
          HERE

          iis_idempotent_apply('create iis site', manifest)

          after(:all) do
            remove_all_sites
          end

          it 'has all properties correctly configured' do
            resource_data = resource('iis_site', site_name)
            [
              'ensure', 'started',
              'physicalpath', 'C:\inetpub\tmp',
              'applicationpool', 'DefaultAppPool'
            ].each_slice(2) do |key, value|
              puppet_resource_should_show(key, value, resource_data)
            end
          end
        end

        context 'started to stopped' do
          site_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_path('C:\inetpub\tmp')
            create_site(site_name, true)
          end

          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure          => 'stopped',
              physicalpath    => 'C:\\inetpub\\tmp',
              applicationpool => 'DefaultAppPool',
            }
          HERE

          iis_idempotent_apply('create iis site', manifest)

          after(:all) do
            remove_all_sites
          end

          it 'has all properties correctly configured' do
            resource_data = resource('iis_site', site_name)
            [
              'ensure', 'stopped',
              'physicalpath', 'C:\inetpub\tmp',
              'applicationpool', 'DefaultAppPool'
            ].each_slice(2) do |key, value|
              puppet_resource_should_show(key, value, resource_data)
            end
          end
        end

        context 'started to absent' do
          site_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_site(site_name, true)
          end

          manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure => 'absent'
          }
          HERE

          iis_idempotent_apply('create iis site', manifest)

          after(:all) do
            remove_all_sites
          end

          it 'iis site is absent' do
            resource_data = resource('iis_site', site_name)
            [
              'ensure', 'absent'
            ].each_slice(2) do |key, value|
              puppet_resource_should_show(key, value, resource_data)
            end
          end
        end
      end

      context 'with invalid value for' do
        after(:all) do
          remove_all_sites
        end

        context 'logformat' do
          site_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_path('C:\inetpub\wwwroot')
          end

          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure          => 'started',
              physicalpath    => 'C:\\inetpub\\wwwroot',
              applicationpool => 'DefaultAppPool',
              logformat       => 'splurge'
            }
          HERE

          apply_failing_manifest('apply failed manifest', manifest)
        end

        context 'logperiod' do
          site_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_path('C:\inetpub\wwwroot')
          end

          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure          => 'started',
              physicalpath    => 'C:\\inetpub\\wwwroot',
              applicationpool => 'DefaultAppPool',
              logperiod       => 'shouldibeastring? No.'
            }
          HERE

          apply_failing_manifest('apply failed manifest', manifest)
        end
      end

      context 'can changed previously set value' do
        context 'physicalpath' do
          site_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_path('C:\inetpub\new')
            create_site(site_name, true)
          end

          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure          => 'started',
              physicalpath    => 'C:\\inetpub\\new',
              applicationpool => 'DefaultAppPool',
            }
          HERE

          iis_idempotent_apply('create iis site', manifest)

          after(:all) do
            remove_all_sites
          end

          it 'has physicalpath configured' do
            puppet_resource_should_show('physicalpath', 'C:\\inetpub\\new', resource('iis_site', site_name))
          end
        end

        context 'applicationpool' do
          site_name = SecureRandom.hex(10).to_s
          pool_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_app_pool(pool_name)
            create_site(site_name, true)
          end

          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure          => 'started',
              applicationpool => '#{pool_name}',
            }
          HERE

          iis_idempotent_apply('create iis site', manifest)
          after(:all) do
            remove_all_sites
          end

          it 'has applicationpool configured' do
            puppet_resource_should_show('applicationpool', pool_name, resource('iis_site', site_name))
          end
        end

        context 'bindings' do
          site_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_path('C:\inetpub\new')
            setup_manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure           => 'started',
              physicalpath     => 'C:\\inetpub\\new',
              enabledprotocols => 'http',
              applicationpool  => 'DefaultAppPool',
              bindings             => [
                {
                  'bindinginformation'   => '*:8080:',
                  'protocol'             => 'http',
                },
                {
                  'bindinginformation'   => '*:8084:domain.test',
                  'protocol'             => 'http',
                },
              ],
            }
            HERE
            apply_manifest(setup_manifest, catch_failures: true)
          end

          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure           => 'started',
              physicalpath     => 'C:\\inetpub\\new',
              enabledprotocols => 'http',
              applicationpool  => 'DefaultAppPool',
              bindings             => [
                {
                  'bindinginformation'   => '*:8081:',
                  'protocol'             => 'http',
                },
              ],
            }
          HERE

          iis_idempotent_apply('create iis site', manifest)
          after(:all) do
            remove_all_sites
          end
        end

        context 'enabledprotocols' do
          site_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_path('C:\inetpub\new')
            setup_manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure           => 'started',
              physicalpath     => 'C:\\inetpub\\new',
              enabledprotocols => 'http',
              applicationpool  => 'DefaultAppPool',
            }
            HERE
            apply_manifest(setup_manifest, catch_failures: true)
          end

          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure           => 'started',
              physicalpath     => 'C:\\inetpub\\new',
              enabledprotocols => 'https',
              applicationpool  => 'DefaultAppPool',
            }
          HERE

          iis_idempotent_apply('create iis site', manifest)

          after(:all) do
            remove_all_sites
          end

          it 'has enabledprotocols configured' do
            puppet_resource_should_show('enabledprotocols', 'https', resource('iis_site', site_name))
          end
        end

        context 'logflags' do
          site_name = SecureRandom.hex(10).to_s
          before(:all) do
            create_path('C:\inetpub\new')
            setup_manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure           => 'started',
              physicalpath     => 'C:\\inetpub\\new',
              applicationpool  => 'DefaultAppPool',
              logformat        => 'W3C',
              logflags         => ['ClientIP', 'Date', 'HttpStatus']
            }
            HERE
            apply_manifest(setup_manifest, catch_failures: true)
          end

          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure           => 'started',
              physicalpath     => 'C:\\inetpub\\new',
              applicationpool  => 'DefaultAppPool',
              logformat        => 'W3C',
              logflags         => ['ClientIP', 'Date', 'Method']
            }
          HERE

          iis_idempotent_apply('create iis site', manifest)

          after(:all) do
            remove_all_sites
          end

          it 'has logflags configured' do
            puppet_resource_should_show('logflags', ['ClientIP', 'Date', 'Method'], resource('iis_site', site_name))
          end
        end
      end

      context 'with an existing website' do
        site_name_one = SecureRandom.hex(10).to_s
        site_name_two = SecureRandom.hex(10).to_s
        before(:all) do
          create_site(site_name_one, true)
          create_path('C:\inetpub\basic')
        end

        manifest = <<-HERE
          iis_site { '#{site_name_two}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
          }
        HERE

        apply_failing_manifest('apply failed manifest', manifest)
        after(:all) do
          remove_all_sites
        end
      end

      context 'with conflicting sites on differing ports' do
        site_name = SecureRandom.hex(10).to_s
        second_site_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_path('C:\inetpub\basic')
          create_site(site_name, true)
        end

        manifest = <<-HERE
          iis_site { "#{second_site_name}":
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
            bindings        => [
              {
                'bindinginformation' => "*:8080:#{second_site_name}",
                'protocol'           => 'http',
              }
            ],
          }
        HERE

        iis_idempotent_apply('create iis site', manifest)

        after(:all) do
          remove_all_sites
        end

        it 'runs the first site on port 80' do
          first_site = resource('iis_site', site_name)
          expect(first_site.stdout).to match(%r{ensure(\s*)=> 'started',})
          expect(first_site.stdout).to match(%r{\*:80:})
        end

        it 'runs the second site on port 8080' do
          second_site = resource('iis_site', second_site_name)
          expect(second_site.stdout).to match(%r{ensure(\s*)=> 'started',})
          expect(second_site.stdout).to match(%r{\*:8080:#{second_site_name}})
        end
      end

      context 'with ensure set to present' do
        site_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_path('C:\inetpub\basic')
          create_site(site_name, true)

          setup_manifest = <<-HERE
          iis_site { '#{site_name}':
              ensure           => 'stopped',
              physicalpath     => 'C:\\inetpub\\basic',
              applicationpool  => 'DefaultAppPool',
              logformat        => 'W3C',
              logflags         => ['ClientIP', 'Date', 'HttpStatus']
          }
          HERE

          apply_manifest(setup_manifest, catch_failures: true)
        end

        manifest = <<-HERE
          iis_site { '#{site_name}':
              ensure           => 'present',
              physicalpath     => 'C:\\inetpub\\basic',
              applicationpool  => 'DefaultAppPool',
              logformat        => 'W3C',
              logflags         => ['ClientIP', 'Date', 'HttpStatus']
          }
        HERE

        iis_idempotent_apply('create iis site', manifest)

        it 'resource iis_site is' do
          puppet_resource_should_show('ensure', 'stopped', resource('iis_site', site_name))
        end
      end
    end

    context 'with conflicting sites on port 80 but different host headers' do
      site_name = SecureRandom.hex(10).to_s
      second_site_name = SecureRandom.hex(10).to_s

      before(:all) do
        create_path('C:\inetpub\basic')
        create_site(site_name, true)
      end

      manifest = <<-HERE
        iis_site { "#{second_site_name}":
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\basic',
          applicationpool => 'DefaultAppPool',
          bindings        => [
            {
              'bindinginformation' => "*:80:#{second_site_name}",
              'protocol'           => 'http',
            }
          ],
        }
      HERE

      iis_idempotent_apply('create iis site', manifest)

      after(:all) do
        remove_all_sites
      end

      it 'runs the first site on port 80 with no host header' do
        first_site = resource('iis_site', site_name)
        expect(first_site.stdout).to match(%r{ensure(\s*)=> 'started',})
        expect(first_site.stdout).to match(%r{\*:80:})
      end

      it 'runs the second site on port 80 but a different host header' do
        second_site = resource('iis_site', second_site_name)
        expect(second_site.stdout).to match(%r{ensure(\s*)=> 'started',})
        expect(second_site.stdout).to match(%r{\*:80:#{second_site_name}})
      end
    end
  end
end
