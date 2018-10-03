require 'spec_helper_acceptance'

describe 'iis_site' do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites();
  end

  context 'when configuring a website' do
    context 'with basic required parameters' do
      before (:all) do
        create_path('C:\inetpub\basic')
        @site_name = "#{SecureRandom.hex(10)}"
        @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = resource('iis_site', @site_name)
        end
        puppet_resource_should_show('ensure', 'started')
        puppet_resource_should_show('physicalpath', 'C:\inetpub\basic')
        puppet_resource_should_show('applicationpool', 'DefaultAppPool')
      end

      after(:all) do
        remove_all_sites
      end
    end

    context 'with all parameters specified' do
      context 'using W3C log format, logflags and logtruncatesize' do
        before (:all) do
          create_path('C:\inetpub\new')
          @site_name = "#{SecureRandom.hex(10)}"
          thumbprint = create_selfsigned_cert('www.puppet.local')
          @manifest = <<-HERE
            iis_site { '#{@site_name}':
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
                  'certificatehash'      => '#{thumbprint}',
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
        end

        #it_behaves_like 'an idempotent resource'

        # Idempotency is broken in this module. Only by the third run will you
        # know if you have an idempotency bug in the module. If on the third
        # run you still have changes happening, that's when there's a problem.
        # This bug will most likely be squashed whenever changes are made to fix
        # MODULES-5561. Even thought that ticket refers to iis_applications and
        # not sites, the issue is with how the module itself handles configuring
        # resources.

        it 'should run without errors' do
          execute_manifest(@manifest, :catch_failures => true)
        end

        it 'should have changes on the second run' do
          execute_manifest(@manifest, :catch_changes => false)
        end

        it 'should run the third time without errors or changes' do
          execute_manifest(@manifest, :catch_failures => true)
        end

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('ensure',               'started')
          puppet_resource_should_show('applicationpool',      'DefaultAppPool')
          puppet_resource_should_show('enabledprotocols',     'https')
          #puppet_resource_should_show('bindings',             [
          #    {
          #      'bindinginformation'   => '*:8080:',
          #      'certificatehash'      => '',
          #      'certificatestorename' => '',
          #      'protocol'             => 'http',
          #      'sslflags'             => '0',
          #    },
          #    {
          #      'bindinginformation'   => '*:8084:domain.test',
          #      'certificatehash'      => '',
          #      'certificatestorename' => '',
          #      'protocol'             => 'http',
          #      'sslflags'             => '0',
          #    }
          #  ]
          #)
          puppet_resource_should_show('logflags',             ['ClientIP', 'Date', 'Time', 'UserName'])
          puppet_resource_should_show('logformat',            'W3C')
          puppet_resource_should_show('loglocaltimerollover', 'false')
          puppet_resource_should_show('logpath',              "C:\\inetpub\\logs\\NewLogFiles")
          puppet_resource_should_show('logtruncatesize',      '2000000')
          puppet_resource_should_show('physicalpath',         "C:\\inetpub\\new")
          it 'should have a binding to 443' do
            expect(@result.stdout).to match(/'bindinginformation' => '\*:443:www.puppet.local'/)
          end
        end

        after(:all) do
          remove_all_sites
        end
      end

      context 'using preloadenabled', :if => fact('kernelmajversion') != '6.1' do
        before (:all) do
          create_path('C:\inetpub\new')
          @site_name = "#{SecureRandom.hex(10)}"
          @manifest = <<-HERE
            iis_site { '#{@site_name}':
              ensure               => 'started',
              preloadenabled       => true,
              physicalpath         => 'C:\\inetpub\\new',
            }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('ensure',               'started')
          puppet_resource_should_show('preloadenabled',       'true')
          puppet_resource_should_show('physicalpath',         "C:\\inetpub\\new")
        end

        after(:all) do
          remove_all_sites
        end
      end

      context 'using non-W3C log format and logtperiod' do
        before (:all) do
          create_path('C:\inetpub\tmp')
          @site_name = "#{SecureRandom.hex(10)}"
          @manifest = <<-HERE
            iis_site { '#{@site_name}':
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
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('ensure',               'started')
          puppet_resource_should_show('applicationpool',      'DefaultAppPool')
          puppet_resource_should_show('enabledprotocols',     'https')
          puppet_resource_should_show('logformat',            'NCSA')
          puppet_resource_should_show('loglocaltimerollover', 'false')
          puppet_resource_should_show('logpath',              "C:\\inetpub\\logs\\NewLogFiles")
          puppet_resource_should_show('logperiod',            'Daily')
          puppet_resource_should_show('physicalpath',         'C:\inetpub\new')
        end

        after(:all) do
          remove_all_sites
        end
      end
    end

    context 'when setting' do
      describe 'authenticationinfo' do
        before(:all) do
          @site_name = SecureRandom.hex(10)
          create_path('C:\inetpub\tmp')
          @manifest  = <<-HERE
            iis_site { '#{@site_name}':
              ensure          => 'started',
              physicalpath    => 'C:\\inetpub\\tmp',
              applicationpool => 'DefaultAppPool',
              authenticationinfo => {
                'basic'     => true,
                'anonymous' => false,
              },
            }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        after(:all) do
          remove_all_sites
        end
      end
    end

    context 'can change site state from' do
      context 'stopped to started' do
        before (:all) do
          create_path('C:\inetpub\tmp')
          create_site(@site_name, false)
          @site_name = "#{SecureRandom.hex(10)}"
          @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\tmp',
            applicationpool => 'DefaultAppPool',
          }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('ensure', 'started')
          puppet_resource_should_show('physicalpath', 'C:\inetpub\tmp')
          puppet_resource_should_show('applicationpool', 'DefaultAppPool')
        end

        after(:all) do
          remove_all_sites
        end
      end

      context 'started to stopped' do
        before (:all) do
          create_path('C:\inetpub\tmp')
          create_site(@site_name, true)
          @site_name = "#{SecureRandom.hex(10)}"
          @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'stopped',
            physicalpath    => 'C:\\inetpub\\tmp',
            applicationpool => 'DefaultAppPool',
          }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('ensure', 'stopped')
          puppet_resource_should_show('physicalpath', 'C:\inetpub\tmp')
          puppet_resource_should_show('applicationpool', 'DefaultAppPool')
        end

        after(:all) do
          remove_all_sites
        end
      end

      context 'started to absent' do
        before (:all) do
          @site_name = "#{SecureRandom.hex(10)}"
          create_site(@site_name, true)
          @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure => 'absent'
          }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('ensure', 'absent')
        end

        after(:all) do
          remove_all_sites
        end
      end

    end

    context 'with invalid value for' do
      context 'logformat' do
        before(:all) do
          create_path('C:\inetpub\wwwroot')
          @site_name = "#{SecureRandom.hex(10)}"
          @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\wwwroot',
            applicationpool => 'DefaultAppPool',
            logformat       => 'splurge'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'
      end

      context 'logperiod' do
        before(:all) do
          create_path('C:\inetpub\wwwroot')
          @site_name = "#{SecureRandom.hex(10)}"
          @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\wwwroot',
            applicationpool => 'DefaultAppPool',
            logperiod       => 'shouldibeastring? No.'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'
      end

      after(:all) do
        remove_all_sites
      end
    end

    context 'can changed previously set value' do
      context 'physicalpath' do
        before(:all) do
          @site_name = "#{SecureRandom.hex(10)}"
          create_path('C:\inetpub\new')
          create_site(@site_name, true)
          @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\new',
            applicationpool => 'DefaultAppPool',
          }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('physicalpath', 'C:\\inetpub\\new')
        end

        after(:all) do
          remove_all_sites
        end
      end

      context 'applicationpool' do
        before(:all) do
          @site_name = "#{SecureRandom.hex(10)}"
          @pool_name = "#{SecureRandom.hex(10)}"
          create_app_pool(@pool_name)
          create_site(@site_name, true)
          @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'started',
            applicationpool => '#{@pool_name}',
          }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('applicationpool', @pool_name)
        end

        after(:all) do
          remove_all_sites
        end
      end

      context 'bindings' do
        before(:all) do
          create_path('C:\inetpub\new')
          @site_name = "#{SecureRandom.hex(10)}"
          setup_manifest = <<-HERE
          iis_site { '#{@site_name}':
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
          execute_manifest(setup_manifest, :catch_failures => true)

          @manifest = <<-HERE
          iis_site { '#{@site_name}':
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
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          #puppet_resource_should_show('bindings', [
          #  {
          #    "protocol"             => "http",
          #    "bindinginformation"   => "*:8081:",
          #    "sslflags"             => 0,
          #    "certificatehash"      => "",
          #    "certificatestorename" => "",
          #  }
          #])
        end

        after(:all) do
          remove_all_sites
        end
      end

      context 'enabledprotocols' do
        before(:all) do
          create_path('C:\inetpub\new')
          @site_name = "#{SecureRandom.hex(10)}"
          setup_manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure           => 'started',
            physicalpath     => 'C:\\inetpub\\new',
            enabledprotocols => 'http',
            applicationpool  => 'DefaultAppPool',
          }
          HERE
          execute_manifest(setup_manifest, :catch_failures => true)

          @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure           => 'started',
            physicalpath     => 'C:\\inetpub\\new',
            enabledprotocols => 'https',
            applicationpool  => 'DefaultAppPool',
          }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('enabledprotocols', 'https')
        end

        after(:all) do
          remove_all_sites
        end
      end

      context 'logflags' do
        before(:all) do
          create_path('C:\inetpub\new')
          @site_name = "#{SecureRandom.hex(10)}"
          setup_manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure           => 'started',
            physicalpath     => 'C:\\inetpub\\new',
            applicationpool  => 'DefaultAppPool',
            logformat        => 'W3C',
            logflags         => ['ClientIP', 'Date', 'HttpStatus']
          }
          HERE
          execute_manifest(setup_manifest, :catch_failures => true)

          @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure           => 'started',
            physicalpath     => 'C:\\inetpub\\new',
            applicationpool  => 'DefaultAppPool',
            logformat        => 'W3C',
            logflags         => ['ClientIP', 'Date', 'Method']
          }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_site', @site_name)
          end
          puppet_resource_should_show('logflags', ['ClientIP', 'Date', 'Method'])
        end

        after(:all) do
          remove_all_sites
        end
      end
    end

    context 'with an existing website' do
      before (:all) do
        @site_name_one = "#{SecureRandom.hex(10)}"
        @site_name_two = "#{SecureRandom.hex(10)}"
        create_site(@site_name_one, true)
        create_path('C:\inetpub\basic')
        @manifest = <<-HERE
          iis_site { '#{@site_name_two}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
          }
        HERE
      end

      it_behaves_like 'a failing manifest'

      after(:all) do
        remove_all_sites
      end
    end

    context 'with conflicting sites on differing ports' do
      before (:all) do
        create_path('C:\inetpub\basic')
        @site_name = "#{SecureRandom.hex(10)}"
        @second_site_name = "#{SecureRandom.hex(10)}"
        create_site(@site_name, true)

        @manifest = <<-HERE
          iis_site { "#{@second_site_name}":
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
            bindings        => [
              {
                'bindinginformation' => "*:8080:#{@second_site_name}",
                'protocol'           => 'http',
              }
            ],
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @first_site = resource('iis_site', @site_name)
          @second_site = resource('iis_site', @second_site_name)
        end

        it "should run the first site on port 80" do
          expect(@first_site.stdout).to match(/ensure(\s*)=> 'started',/)
          expect(@first_site.stdout).to match(/\*\:80\:/)
        end

        it "should run the second site on port 8080" do
          expect(@second_site.stdout).to match(/ensure(\s*)=> 'started',/)
          expect(@second_site.stdout).to match(/\*\:8080\:#{@second_site_name}/)
        end
      end

      after(:all) do
        remove_all_sites
      end
    end

    context 'with ensure set to present' do
      before(:all) do
        create_path('C:\inetpub\basic')
        @site_name = "#{SecureRandom.hex(10)}"
        create_site(@site_name, true)

        setup_manifest = <<-HERE
        iis_site { '#{@site_name}':
            ensure           => 'stopped',
            physicalpath     => 'C:\\inetpub\\basic',
            applicationpool  => 'DefaultAppPool',
            logformat        => 'W3C',
            logflags         => ['ClientIP', 'Date', 'HttpStatus']
        }
        HERE

        @manifest = <<-HERE
        iis_site { '#{@site_name}':
            ensure           => 'present',
            physicalpath     => 'C:\\inetpub\\basic',
            applicationpool  => 'DefaultAppPool',
            logformat        => 'W3C',
            logflags         => ['ClientIP', 'Date', 'HttpStatus']
        }
        HERE

        execute_manifest(setup_manifest, :catch_failures => true)

      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = resource('iis_site', @site_name)
        end

        puppet_resource_should_show('ensure', 'stopped')
      end
    end
  end

  context 'with conflicting sites on port 80 but different host headers' do
    before(:all) do
      create_path('C:\inetpub\basic')
      @site_name = "#{SecureRandom.hex(10)}"
      @second_site_name = "#{SecureRandom.hex(10)}"
      create_site(@site_name, true)

      @manifest = <<-HERE
        iis_site { "#{@second_site_name}":
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\basic',
          applicationpool => 'DefaultAppPool',
          bindings        => [
            {
              'bindinginformation' => "*:80:#{@second_site_name}",
              'protocol'           => 'http',
            }
          ],
        }
      HERE
    end

    it_behaves_like 'an idempotent resource'

    context 'when puppet resource is run' do
      before(:all) do
        @first_site = resource('iis_site', @site_name)
        @second_site = resource('iis_site', @second_site_name)
      end

      it 'should run the first site on port 80 with no host header' do
        expect(@first_site.stdout).to match(/ensure(\s*)=> 'started',/)
        expect(@first_site.stdout).to match(/\*\:80\:/)
      end

      it 'should run the second site on port 80 but a different host header' do
        expect(@second_site.stdout).to match(/ensure(\s*)=> 'started',/)
        expect(@second_site.stdout).to match(/\*\:80\:#{@second_site_name}/)
      end
    end

    after(:all) do
      remove_all_sites
    end
  end
end
