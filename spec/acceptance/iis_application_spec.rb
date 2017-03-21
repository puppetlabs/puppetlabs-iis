require 'spec_helper_acceptance'

describe 'iis_application' do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites();
  end

  context 'when creating an application' do
    context 'with normal parameters' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_path('C:\inetpub\basic')
        @manifest  = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
          }
          iis_application { '#{@app_name}':
            ensure       => 'present',
            sitename     => '#{@site_name}',
            physicalpath => 'C:\\inetpub\\basic',
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      # TestRail ID: C100060
      context 'when puppet resource is run' do
        before(:all) do
          @result = on(default, puppet('resource', 'iis_application', "#{@site_name}\\\\#{@app_name}"))
        end

        include_context 'with a puppet resource run'
        puppet_resource_should_show('sitename', @site_name)
        puppet_resource_should_show('physicalpath', 'C:\inetpub\basic')
        puppet_resource_should_show('applicationpool', 'DefaultAppPool')
      end

      after(:all) do
        remove_app(@app_name)
        remove_all_sites
      end
    end

    # TestRail ID: C100061
    context 'with virtual_directory' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path('C:\inetpub\vdir')
        create_virtual_directory(@site_name, @app_name, 'C:\inetpub\vdir')
        @manifest  = <<-HERE
          iis_application { '#{@site_name}\\#{@app_name}':
            ensure            => 'present',
            virtual_directory => 'IIS:\\Sites\\#{@site_name}\\#{@app_name}',
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = on(default, puppet('resource', 'iis_application', "#{@site_name}\\\\#{@app_name}"))
        end

        include_context 'with a puppet resource run'
        puppet_resource_should_show('sitename', @site_name)
        puppet_resource_should_show('physicalpath', 'C:\inetpub\vdir')
        puppet_resource_should_show('applicationpool', 'DefaultAppPool')
      end

      after(:all) do
        remove_app(@app_name)
        remove_all_sites
      end
    end
  end

  # TestRail ID: C100062
  context 'when setting' do
    describe 'sslflags' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path('C:\inetpub\wwwroot')
        create_path('C:\inetpub\modify')
        site_hostname = 'www.puppet.local'
        thumbprint = create_selfsigned_cert(site_hostname)
        create_app(@site_name, @app_name, 'C:\inetpub\wwwroot')
        @manifest  = <<-HERE
          iis_site { '#{@site_name}':
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
                'certificatehash'      => '#{thumbprint}',
                'sslflags'             => 0,
              },
            ],
          }
          iis_application { '#{@app_name}':
            ensure       => 'present',
            sitename     => '#{@site_name}',
            physicalpath => 'C:\\inetpub\\modify',
            sslflags     => ['Ssl','SslRequireCert'],
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'
    end

    describe 'authenticationinfo' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path('C:\inetpub\wwwroot')
        create_path('C:\inetpub\auth')
        create_app(@site_name, @app_name, 'C:\inetpub\auth')
        @manifest  = <<-HERE
          iis_application { '#{@app_name}':
            ensure       => 'present',
            sitename     => '#{@site_name}',
            physicalpath => 'C:\\inetpub\\auth',
            authenticationinfo => {
              'basic'     => true,
              'anonymous' => false,
            },
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'
    end
  end

  # TestRail ID: C100063
  context 'when removing an application' do
    before(:all) do
      @site_name = SecureRandom.hex(10)
      @app_name = SecureRandom.hex(10)
      create_site(@site_name, true)
      create_path('C:\inetpub\remove')
      create_virtual_directory(@site_name, @app_name, 'C:\inetpub\remove')
      create_app(@site_name, @app_name, 'C:\inetpub\remove')
      @manifest  = <<-HERE
          iis_application { '#{@app_name}':
            ensure       => 'absent',
            sitename     => '#{@site_name}',
            physicalpath => 'C:\\inetpub\\remove',
          }
      HERE
    end

    it_behaves_like 'an idempotent resource'

    context 'when puppet resource is run' do
      before(:all) do
        @result = on(default, puppet('resource', 'iis_application', "#{@site_name}\\\\#{@app_name}"))
      end

      include_context 'with a puppet resource run'
      puppet_resource_should_show('ensure', 'absent')
    end

    after(:all) do
      remove_app(@app_name)
    end
  end
end
