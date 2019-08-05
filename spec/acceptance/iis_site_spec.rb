require 'spec_helper_acceptance'

describe 'iis_site' do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites
  end

  context 'when configuring a website' do
    context 'with basic required parameters' do
      before (:all) do
        create_path('C:\inetpub\basic')
      end

      site_name = SecureRandom.hex(10).to_s
      describe "apply manifest twice" do
        manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end

    context 'when puppet resource is run' do
      it 'has all properties correctly configured' do
        resource_data = resource('iis_site', site_name)
        [
          'ensure',            'started',
          'physicalpath',                            'C:\inetpub\basic',
          'applicationpool',                       'DefaultAppPool',
        ].each_slice(2) do | key, value |
          puppet_resource_should_show(key, value, resource_data)
        end
      end
    end

    after(:all) do
      remove_all_sites
    end
    end

    context 'with all parameters specified' do
      context 'using W3C log format, logflags and logtruncatesize' do
        site_name = SecureRandom.hex(10).to_s
        before (:all) do
          create_path('C:\inetpub\new')
          @certificate_hash = create_selfsigned_cert('www.puppet.local').downcase
        end

        describe "test" do
          manifest = <<-HERE
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
                  'bindinginformation'   => '*:443:www.puppet.local',
                  'certificatehash'      => '#{@certificate_hash}',
                  'certificatestorename' => 'MY',
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
        

        # it_behaves_like 'an idempotent resource'

        # Idempotency is broken in this module. Only by the third run will you
        # know if you have an idempotency bug in the module. If on the third
        # run you still have changes happening, that's when there's a problem.
        # This bug will most likely be squashed whenever changes are made to fix
        # MODULES-5561. Even thought that ticket refers to iis_applications and
        # not sites, the issue is with how the module itself handles configuring
        # resources.

        it 'runs without errors' do
          execute_manifest(manifest, catch_failures: true)
        end

        it 'has changes on the second run' do
          execute_manifest(manifest, catch_changes: false)
        end

        it 'runs the third time without errors or changes' do
          execute_manifest(manifest, catch_failures: true)
        end
        end

        context 'when puppet resource is run' do
          let(:resource_data) {resource('iis_site', site_name)}
          it 'has all properties correctly configured' do
            [
              'ensure', 'started',
              'enabledprotocols', 'https',
              'applicationpool', 'DefaultAppPool',
              'logflags', ['ClientIP', 'Date', 'Time', 'UserName'],
              'logformat', 'W3C',
              'loglocaltimerollover', 'false',
              'logpath', 'C:\\inetpub\\logs\\NewLogFiles',
              'logtruncatesize', '2000000',
              'physicalpath', 'C:\\inetpub\\new',
            ].each_slice(2) do | key, value |
              puppet_resource_should_show(key, value, resource_data)
            end
          end

          it 'has a binding to 443' do
            expect(resource('iis_site', site_name).stdout).to match(%r{'bindinginformation' => '\*:443:www.puppet.local'})
          end

          context 'when capitalization is changed in path parameters' do
            manifest = <<-HERE
              iis_site { '#{site_name}':
                ensure               => 'started',
                # Change capitalization to see if it break idempotency
                logpath              => 'C:\\ineTpub\\logs\\NewLogFiles',
                physicalpath         => 'C:\\ineTpub\\new',
              }
            HERE

            it 'runs with no changes' do
              execute_manifest(manifest, catch_changes: true)
            end
          end
        end

        after(:all) do
          remove_all_sites
        end
      end

      context 'using preloadenabled', if: fact('kernelmajversion') != '6.1' do
        before (:all) do
          create_path('C:\inetpub\new')
        end
        site_name = SecureRandom.hex(10).to_s
        describe "apply manifest twice" do
          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure               => 'started',
              preloadenabled       => true,
              physicalpath         => 'C:\\inetpub\\new',
            }
          HERE

          it_behaves_like 'an idempotent resource', manifest
        end

        context 'when puppet resource is run' do
          it "has all properties correctly configured" do
            resource_data = resource('iis_site', site_name)
            [
              'ensure', 'started',
              'preloadenabled', 'true',
              'physicalpath', 'C:\\inetpub\\new',
            ].each_slice(2) do | key, value |
              puppet_resource_should_show(key, value, resource_data)
            end
        end
      end

        after(:all) do
          remove_all_sites
        end
      end

      context 'using non-W3C log format and logtperiod' do
        before (:all) do
          create_path('C:\inetpub\tmp')
        end
        site_name = SecureRandom.hex(10).to_s
        describe "apply manifest twice" do
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

          it_behaves_like 'an idempotent resource', manifest
        end

        context 'when puppet resource is run' do
          it "has all properties correctly configured" do
            resource_data = resource('iis_site', site_name)
            [
              'ensure', 'started',
              'applicationpool', 'DefaultAppPool',
              'enabledprotocols', 'https',
              'logformat', 'NCSA',
              'loglocaltimerollover', 'false',
              'logpath', 'C:\\inetpub\\logs\\NewLogFiles',
              'logperiod', 'Daily',
              'physicalpath', 'C:\inetpub\new',
            ].each_slice(2) do | key, value |
              puppet_resource_should_show(key, value, resource_data)
            end
        end
        after(:all) do
          remove_all_sites
        end
      end
    end

    context 'when setting' do
      describe 'authenticationinfo' do
        site_name = SecureRandom.hex(10)
        before(:all) do
          create_path('C:\inetpub\tmp')
        end
        describe "apply manifest twice" do
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

          it_behaves_like 'an idempotent resource', manifest
        end

        after(:all) do
          remove_all_sites
        end
      end
    end

    context 'can change site state from' do
      context 'stopped to started' do
        site_name = SecureRandom.hex(10).to_s
        before (:all) do
          create_path('C:\inetpub\tmp')
          create_site(site_name, false)
        end
        describe "apply manifest twice" do
          manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\tmp',
            applicationpool => 'DefaultAppPool',
          }
          HERE

          it_behaves_like 'an idempotent resource', manifest
        end

        context 'when puppet resource is run' do
                    it "has all properties correctly configured" do
                      resource_data = resource('iis_site', site_name)
            [
              'ensure', 'started',
              'physicalpath', 'C:\inetpub\tmp',
              'applicationpool', 'DefaultAppPool',
            ].each_slice(2) do | key, value |
              puppet_resource_should_show(key, value, resource_data)
            end
        end
      end

        after(:all) do
          remove_all_sites
        end
      end

      context 'started to stopped' do
        site_name = SecureRandom.hex(10).to_s
        before (:all) do
          create_path('C:\inetpub\tmp')
          create_site(site_name, true)
        end
        describe "apply manifest twice" do
          manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure          => 'stopped',
            physicalpath    => 'C:\\inetpub\\tmp',
            applicationpool => 'DefaultAppPool',
          }
          HERE

          it_behaves_like 'an idempotent resource', manifest
        end

        context 'when puppet resource is run' do
          it "has all properties correctly configured" do
            resource_data = resource('iis_site', site_name)
            [
              'ensure', 'stopped',
              'physicalpath', 'C:\inetpub\tmp',
              'applicationpool', 'DefaultAppPool',
            ].each_slice(2) do | key, value |
              puppet_resource_should_show(key, value, resource_data)
            end
        end
      end

        after(:all) do
          remove_all_sites
        end
      end

      context 'started to absent' do

        site_name = SecureRandom.hex(10).to_s
        before (:all) do
          create_site(site_name, true)
        end
        describe "apply manifest twice" do
          manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure => 'absent'
          }
          HERE

          it_behaves_like 'an idempotent resource', manifest
        end

        context 'when puppet resource is run' do
          it "iis site is absent" do
            resource_data = resource('iis_site', site_name)
            [
              'ensure', 'absent',
            ].each_slice(2) do | key, value |
              puppet_resource_should_show(key, value, resource_data)
            end
          end
          # puppet_resource_should_show('ensure', 'absent',  resource('iis_site', site_name))
        end

        after(:all) do
          remove_all_sites
        end
      end
    end

    context 'with invalid value for' do
      context 'logformat' do
        site_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_path('C:\inetpub\wwwroot')
        end
        describe "apply manifest twice" do
          manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\wwwroot',
            applicationpool => 'DefaultAppPool',
            logformat       => 'splurge'
          }
          HERE

          it_behaves_like 'a failing manifest', manifest
        end
      end

      context 'logperiod' do
        site_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_path('C:\inetpub\wwwroot')
        end
        describe "apply manifest twice" do
          manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\wwwroot',
            applicationpool => 'DefaultAppPool',
            logperiod       => 'shouldibeastring? No.'
          }
          HERE

          it_behaves_like 'a failing manifest', manifest
        end
      end

      after(:all) do
        remove_all_sites
      end
    end

    context 'can changed previously set value' do
      context 'physicalpath' do
        site_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_path('C:\inetpub\new')
          create_site(site_name, true)
        end
        describe "apply manifest twice" do
          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure          => 'started',
              physicalpath    => 'C:\\inetpub\\new',
              applicationpool => 'DefaultAppPool',
            }
            HERE

          it_behaves_like 'an idempotent resource', manifest
        end

        context 'when puppet resource is run' do
        it "has physicalpath configured" do
          puppet_resource_should_show('physicalpath', 'C:\\inetpub\\new', resource('iis_site', site_name))
        end
      end

        after(:all) do
          remove_all_sites
        end
      end

      context 'applicationpool' do
        site_name = SecureRandom.hex(10).to_s
        pool_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_app_pool(pool_name)
          create_site(site_name, true)
        end
        describe "apply manifest twice" do
          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure          => 'started',
              applicationpool => '#{pool_name}',
            }
            HERE

          it_behaves_like 'an idempotent resource', manifest
        end

      context 'when puppet resource is run' do
        it "has applicationpool configured" do
          puppet_resource_should_show('applicationpool', pool_name, resource('iis_site', site_name))
        end
      end

        after(:all) do
          remove_all_sites
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
          execute_manifest(setup_manifest, catch_failures: true)
        end
        describe "apply manifest twice" do
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

          it_behaves_like 'an idempotent resource', manifest
        end

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
          execute_manifest(setup_manifest, catch_failures: true)
        end
        describe "apply manifest twice" do
          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure           => 'started',
              physicalpath     => 'C:\\inetpub\\new',
              enabledprotocols => 'https',
              applicationpool  => 'DefaultAppPool',
            }
            HERE

          it_behaves_like 'an idempotent resource', manifest
        end

      context 'when puppet resource is run' do
        it "has enabledprotocols configured" do
          puppet_resource_should_show('enabledprotocols', 'https', resource('iis_site', site_name))
        end
      end

        after(:all) do
          remove_all_sites
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
          execute_manifest(setup_manifest, catch_failures: true)
        end
        describe "apply manifest twice" do
          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure           => 'started',
              physicalpath     => 'C:\\inetpub\\new',
              applicationpool  => 'DefaultAppPool',
              logformat        => 'W3C',
              logflags         => ['ClientIP', 'Date', 'Method']
            }
            HERE

          it_behaves_like 'an idempotent resource', manifest
        end

      context 'when puppet resource is run' do
        it "has logflags configured" do
          puppet_resource_should_show('logflags', ['ClientIP', 'Date', 'Method'], resource('iis_site', site_name))
        end
      end

        after(:all) do
          remove_all_sites
        end
      end
    end

    context 'with an existing website' do
      site_name_one = SecureRandom.hex(10).to_s
      site_name_two = SecureRandom.hex(10).to_s
      before (:all) do
        create_site(site_name_one, true)
        create_path('C:\inetpub\basic')
      end
      describe "apply failing manifest" do
        manifest = <<-HERE
          iis_site { '#{site_name_two}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
          }
        HERE

        it_behaves_like 'a failing manifest', manifest
      end

      after(:all) do
        remove_all_sites
      end
    end

    context 'with conflicting sites on differing ports' do
      site_name = SecureRandom.hex(10).to_s
      second_site_name = SecureRandom.hex(10).to_s
      before (:all) do
        create_path('C:\inetpub\basic')
        create_site(site_name, true)
      end
      describe "apply manifest twice" do
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

        it_behaves_like 'an idempotent resource', manifest
      end

      context 'when puppet resource is run' do
        let(:first_site) { resource('iis_site', site_name) }
        let(:second_site) { resource('iis_site', second_site_name) }

        it 'runs the first site on port 80' do
          expect(first_site.stdout).to match(%r{ensure(\s*)=> 'started',})
          expect(first_site.stdout).to match(%r{\*\:80\:})
        end

        it 'runs the second site on port 8080' do
          expect(second_site.stdout).to match(%r{ensure(\s*)=> 'started',})
          expect(second_site.stdout).to match(%r{\*\:8080\:#{second_site_name}})
        end
      end

      after(:all) do
        remove_all_sites
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

        execute_manifest(setup_manifest, catch_failures: true)
      end

      describe "apply manifest twice" do
        manifest = <<-HERE
          iis_site { '#{site_name}':
              ensure           => 'present',
              physicalpath     => 'C:\\inetpub\\basic',
              applicationpool  => 'DefaultAppPool',
              logformat        => 'W3C',
              logflags         => ['ClientIP', 'Date', 'HttpStatus']
          }
          HERE

        it_behaves_like 'an idempotent resource', manifest
      end

    context 'when puppet resource is run' do
      it 'resource iis_site is' do
        puppet_resource_should_show('ensure', 'stopped', resource('iis_site', site_name))
      end
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

    describe "apply manifest twice" do
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

      it_behaves_like 'an idempotent resource', manifest
    end

    context 'when puppet resource is run' do
      let(:first_site) { resource('iis_site', site_name) }
      let(:second_site) { resource('iis_site', second_site_name) }

      it 'runs the first site on port 80 with no host header' do
        expect(first_site.stdout).to match(%r{ensure(\s*)=> 'started',})
        expect(first_site.stdout).to match(%r{\*\:80\:})
      end

      it 'runs the second site on port 80 but a different host header' do
        expect(second_site.stdout).to match(%r{ensure(\s*)=> 'started',})
        expect(second_site.stdout).to match(%r{\*\:80\:#{second_site_name}})
      end
    end

    after(:all) do
      remove_all_sites
    end
    end
  end
end
