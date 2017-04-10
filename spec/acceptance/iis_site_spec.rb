require 'spec_helper_acceptance'

describe 'iis_site' do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites();
  end

  context 'when configuring a website' do
    # TestRail ID: C100068
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

    # TestRail ID: C100069
    context 'with all parameters specified' do
      context 'using W3C log format, logflags and logtruncatesize' do
        before (:all) do
          create_path('C:\inetpub\new')
          @site_name = "#{SecureRandom.hex(10)}"
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
              # {
              #   'bindinginformation'   => '10.32.126.39:443:domain.test',
              #   'certificatehash'      => '3598FAE5ADDB8BA32A061C5579829B359409856F',
              #   'certificatestorename' => 'MY',
              #   'protocol'             => 'https',
              #   'sslflags'             => 1,
              # },
              ],
              logflags             => ['ClientIP', 'Date', 'Time', 'UserName'],
              logformat            => 'W3C',
              loglocaltimerollover => false,
              logpath              => 'C:\\inetpub\\logs\\NewLogFiles',
              logtruncatesize      => 2000000,
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
        end

        after(:all) do
          remove_all_sites
        end
      end

      # TestRail ID: C100070
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

    # TestRail ID: C100071
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

      # TestRail ID: C100072
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

      # TestRail ID: C100073
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
      # TestRail ID: C100074
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

      # TestRail ID: C100075
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
      # TestRail ID: C100076
      context 'physicalpath' do
        before(:all) do
          create_path('C:\inetpub\new')
          create_site(@site_name, true)
          @site_name = "#{SecureRandom.hex(10)}"
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

      # TestRail ID: C100077
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

      # TestRail ID: C100078
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

      # TestRail ID: C100079
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
  end
end
