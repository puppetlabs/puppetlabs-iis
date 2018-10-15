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
        @manifest = <<-HERE
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

      context 'when puppet resource is run' do
        before(:all) do
          @result = on(default, puppet('resource', 'iis_application', "#{@site_name}\\\\#{@app_name}"))
        end

        include_context 'with a puppet resource run'
        puppet_resource_should_show('physicalpath', 'C:\inetpub\basic')
        puppet_resource_should_show('applicationpool', 'DefaultAppPool')
      end

      after(:all) do
        remove_app(@app_name)
        remove_all_sites
      end
    end

    context 'with virtual_directory' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path('C:\inetpub\vdir')
        create_virtual_directory(@site_name, @app_name, 'C:\inetpub\vdir')
        @manifest = <<-HERE
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
        puppet_resource_should_show('physicalpath', 'C:\inetpub\vdir')
        puppet_resource_should_show('applicationpool', 'DefaultAppPool')
      end

      after(:all) do
        remove_app(@app_name)
        remove_all_sites
      end
    end

    context 'with nested virtual directory' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path("c:\\inetpub\\wwwroot\\subFolder\\#{@app_name}")
        @manifest = <<-HERE
          iis_application{'subFolder/#{@app_name}':
            ensure => 'present',
            applicationname => 'subFolder/#{@app_name}',
            physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{@app_name}',
            sitename => '#{@site_name}'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      describe "application validation" do
        it "should create the correct application" do
          @result = on(default, puppet('resource', 'iis_application', "#{@site_name}\\\\subFolder/#{@app_name}"))
          expect(@result.stdout).to match(/iis_application { '#{@site_name}\\subFolder\/#{@app_name}':/)
          expect(@result.stdout).to match(/ensure\s*=> 'present',/)
        end
      end

      after(:all) do
        remove_app(@app_name)
        remove_all_sites
      end
    end

    context 'with nested virtual directory and single namevar' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path("c:\\inetpub\\wwwroot\\subFolder\\#{@app_name}")
        @manifest = <<-HERE
          iis_application{'subFolder/#{@app_name}':
            ensure => 'present',
            physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{@app_name}',
            sitename => '#{@site_name}'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      describe "application validation" do
        it "should create the correct application" do
          @result = on(default, puppet('resource', 'iis_application', "#{@site_name}\\\\subFolder/#{@app_name}"))
          expect(@result.stdout).to match(/iis_application { '#{@site_name}\\subFolder\/#{@app_name}':/)
          expect(@result.stdout).to match(/ensure\s*=> 'present',/)
        end
      end

      after(:all) do
        remove_app(@app_name)
        remove_all_sites
      end
    end

    context 'with forward slash virtual directory name format' do
      context 'with a leading slash' do
        before(:all) do
          @site_name = SecureRandom.hex(10)
          @app_name = SecureRandom.hex(10)
          create_site(@site_name, true)
          create_path("c:\\inetpub\\wwwroot\\subFolder\\#{@app_name}")
          @manifest = <<-HERE
            iis_application{'subFolder/#{@app_name}':
              ensure => 'present',
              applicationname => '/subFolder/#{@app_name}',
              physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{@app_name}',
              sitename => '#{@site_name}'
            }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        after(:all) do
          remove_app(@app_name)
          remove_all_sites
        end
      end
    end

    context 'with backward slash virtual directory name format' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path("c:\\inetpub\\wwwroot\\subFolder\\#{@app_name}")
        @manifest = <<-HERE
            iis_application{'subFolder\\#{@app_name}':
              ensure => 'present',
              applicationname => 'subFolder/#{@app_name}',
              physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{@app_name}',
              sitename => '#{@site_name}'
            }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      after(:all) do
        remove_app(@app_name)
        remove_all_sites
      end
    end

    context 'with two level nested virtual directory' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path("c:\\inetpub\\wwwroot\\subFolder\\sub2\\#{@app_name}")
        @manifest = <<-HERE
          iis_application{'subFolder/sub2/#{@app_name}':
            ensure => 'present',
            applicationname => 'subFolder/sub2/#{@app_name}',
            physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\sub2\\#{@app_name}',
            sitename => '#{@site_name}'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      describe "application validation" do
        it "should create the correct application" do
          @result = on(default, puppet('resource', 'iis_application', "#{@site_name}\\\\subFolder/sub2/#{@app_name}"))
          expect(@result.stdout).to match(/iis_application { '#{@site_name}\\subFolder\/sub2\/#{@app_name}':/)
          expect(@result.stdout).to match(/ensure\s*=> 'present',/)
        end
      end

      after(:all) do
        remove_app(@app_name)
        remove_all_sites
      end
    end
  end

  context 'when setting' do
    skip 'sslflags - blocked by MODULES-5561' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path('C:\inetpub\wwwroot')
        create_path('C:\inetpub\modify')
        site_hostname = 'www.puppet.local'
        thumbprint = create_selfsigned_cert(site_hostname)
        create_app(@site_name, @app_name, 'C:\inetpub\wwwroot')
        @manifest = <<-HERE
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
                'certificatehash'      => '#{thumbprint.downcase}',
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
        @manifest = <<-HERE
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

    describe 'applicationpool' do
      before(:all) do
        @site_name = SecureRandom.hex(10)
        @app_name = SecureRandom.hex(10)
        create_site(@site_name, true)
        create_path('C:\inetpub\wwwroot')
        create_path('C:\inetpub\auth')
        create_app(@site_name, @app_name, 'C:\inetpub\auth')
        create_app_pool('foo_pool')
        @manifest = <<-HERE
          iis_application { '#{@app_name}':
            ensure       => 'present',
            sitename     => '#{@site_name}',
            physicalpath => 'C:\\inetpub\\auth',
            applicationpool => 'foo_pool'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'
    end
  end

  context 'when removing an application' do
    before(:all) do
      @site_name = SecureRandom.hex(10)
      @app_name = SecureRandom.hex(10)
      create_site(@site_name, true)
      create_path('C:\inetpub\remove')
      create_virtual_directory(@site_name, @app_name, 'C:\inetpub\remove')
      create_app(@site_name, @app_name, 'C:\inetpub\remove')
      @manifest = <<-HERE
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


  context 'with multiple sites with same application name' do
    before(:all) do
      remove_all_sites
      @site_name = SecureRandom.hex(10)
      @site_name2 = SecureRandom.hex(10)
      @app_name = SecureRandom.hex(10)
      create_path("C:\\inetpub\\#{@site_name}\\#{@app_name}")
      create_path("C:\\inetpub\\#{@site_name2}\\#{@app_name}")
      @manifest = <<-HERE
          iis_site { '#{@site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\#{@site_name}',
            applicationpool => 'DefaultAppPool',
            bindings        => [
            {
              'bindinginformation' => '*:8081:',
              'protocol'           => 'http',
            }]
          }
          iis_application { '#{@site_name}\\#{@app_name}':
            ensure            => 'present',
            sitename        => '#{@site_name}',
            physicalpath => 'C:\\inetpub\\#{@site_name}\\#{@app_name}',
          }
          iis_site { '#{@site_name2}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\#{@site_name2}',
            applicationpool => 'DefaultAppPool',
          }
          iis_application { '#{@site_name2}\\#{@app_name}':
            ensure            => 'present',
            sitename        => '#{@site_name2}',
            physicalpath => 'C:\\inetpub\\#{@site_name2}\\#{@app_name}',
          }
      HERE
    end

    it 'should run without errors' do
      execute_manifest(@manifest, :catch_failures => true)
    end

    it 'should run a second time without changes' do
      execute_manifest(@manifest, :catch_changes => true)
    end


    it 'contains two sites with the same app name' do
      on(default, puppet('resource', 'iis_application', "#{@site_name}\\\\#{@app_name}")) do |result|
        expect(result.stdout).to match(/#{@site_name}\\#{@app_name}/)
        expect(result.stdout).to match(/ensure\s*=> 'present',/)
        expect(result.stdout).to match (/C:\\inetpub\\#{@site_name}\\#{@app_name}/)
        expect(result.stdout).to match (/applicationpool\s*=> 'DefaultAppPool'/)
      end
      on(default, puppet('resource', 'iis_application', "#{@site_name2}\\\\#{@app_name}")) do |result|
        expect(result.stdout).to match(/#{@site_name2}\\#{@app_name}/)
        expect(result.stdout).to match(/ensure\s*=> 'present',/)
        expect(result.stdout).to match (/C:\\inetpub\\#{@site_name2}\\#{@app_name}/)
        expect(result.stdout).to match (/applicationpool\s*=> 'DefaultAppPool'/)
      end
    end

    after(:all) do
      remove_app(@app_name)
      remove_all_sites
    end
  end
end
