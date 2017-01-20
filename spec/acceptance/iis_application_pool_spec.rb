require 'spec_helper_acceptance'

describe 'iis_application_pool' do
  context 'when configuring an application pool' do
    context 'with default parameters' do
      before(:all) do
        @pool_name = "#{SecureRandom.hex(10)}"
        @manifest  = <<-HERE
          iis_application_pool { '#{@pool_name}':
            ensure => 'present'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = on(default, puppet('resource', 'iis_application_pool', "#{@pool_name}"))
        end

        include_context 'with a puppet resource run'
        puppet_resource_should_show('ensure', 'present')
      end

      after(:all) do
        remove_app_pool(@pool_name)
      end
    end

    context 'with valid parameters defined' do
      before(:all) do
        @pool_name = "#{SecureRandom.hex(10)}"
        @manifest  = <<-HERE
          iis_application_pool { '#{@pool_name}':
            ensure                => 'present',
            managedpipelinemode   => 'Classic',
            managedruntimeversion => 'v4.0',
            state                 => 'Stopped'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = on(default, puppet('resource', 'iis_application_pool', "#{@pool_name}"))
        end
        
        include_context 'with a puppet resource run'
        puppet_resource_should_show('ensure', 'present')
        puppet_resource_should_show('managedpipelinemode', 'Classic')
        puppet_resource_should_show('managedruntimeversion', 'v4.0')
        puppet_resource_should_show('state', 'Stopped')
      end

      after(:all) do
        remove_app_pool(@pool_name)
      end
    end

    context 'with invalid' do
      context 'state parameter defined' do
        before(:all) do
          @pool_name = "#{SecureRandom.hex(10)}"
          @manifest  = <<-HERE
          iis_application_pool { '#{@pool_name}':
            ensure  => 'present',
            state   => 'AnotherTypo'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'

        context 'when puppet resource is run' do
          before(:all) do
            @result = on(default, puppet('resource', 'iis_application_pool', "#{@pool_name}"))
          end
          include_context 'with a puppet resource run'
          puppet_resource_should_show('ensure', 'absent')
        end

        after(:all) do
          remove_app_pool(@pool_name)
        end
      end

      context 'managedpipelinemode parameter defined' do
        before(:all) do
          @pool_name = "#{SecureRandom.hex(10)}"
          @manifest  = <<-HERE
          iis_application_pool { '#{@pool_name}':
            ensure              => 'present',
            managedpipelinemode => 'ClassicTypo'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'

        context 'when puppet resource is run' do
          before(:all) do
            @result = on(default, puppet('resource', 'iis_application_pool', "#{@pool_name}"))
          end
          include_context 'with a puppet resource run'
          puppet_resource_should_show('ensure', 'absent')
        end

        after(:all) do
          remove_app_pool(@pool_name)
        end
      end
    end
  end

  context 'when starting a stopped application pool' do
    before(:all) do
      @pool_name = "#{SecureRandom.hex(10)}"
      create_app_pool(@pool_name)
      stop_app_pool(@pool_name)
      @manifest = <<-HERE
          iis_application_pool { '#{@pool_name}':
            ensure  => 'present',
            state   => 'Started'
          }
      HERE
    end

    it_behaves_like 'an idempotent resource'

    context 'when puppet resource is run' do
      before(:all) do
        @result = on(default, puppet('resource', 'iis_application_pool', "#{@pool_name}"))
      end

      include_context 'with a puppet resource run'
      puppet_resource_should_show('ensure', 'present')
      puppet_resource_should_show('state', 'Started')
    end

    after(:all){
      remove_app_pool(@pool_name)
    }
  end

  context 'when removing an application pool' do
    before(:all) do
      @pool_name = "#{SecureRandom.hex(10)}"
      
      create_app_pool(@pool_name)
      
      @manifest = <<-HERE
          iis_application_pool { '#{@pool_name}':
            ensure => 'absent'
          }
      HERE
    end

    it_behaves_like 'an idempotent resource'

    context 'when puppet resource is run' do
      before(:all) do
        @result = on(default, puppet('resource', 'iis_application_pool', "#{@pool_name}"))
      end

      include_context 'with a puppet resource run'
      puppet_resource_should_show('ensure', 'absent')
    end
  end
end
