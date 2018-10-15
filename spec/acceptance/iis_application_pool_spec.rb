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
          @result = resource('iis_application_pool', @pool_name)
        end

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
            ensure                  => 'present',
            managed_pipeline_mode   => 'Integrated',
            managed_runtime_version => 'v4.0',
            state                   => 'Stopped'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = resource('iis_application_pool', @pool_name)
        end

        puppet_resource_should_show('ensure', 'present')

        # Properties introduced in IIS 7.0 (Server 2008 - Kernel 6.1)
        puppet_resource_should_show('managed_pipeline_mode', 'Integrated')
        puppet_resource_should_show('managed_runtime_version', 'v4.0')
        puppet_resource_should_show('state', 'Stopped')
        puppet_resource_should_show('auto_start', :true)
        puppet_resource_should_show('enable32_bit_app_on_win64', :false)
        puppet_resource_should_show('enable_configuration_override', :true)
        puppet_resource_should_show('pass_anonymous_token', :true)
        puppet_resource_should_show('start_mode','OnDemand')
        puppet_resource_should_show('queue_length','1000')
        puppet_resource_should_show('cpu_action','NoAction')
        puppet_resource_should_show('cpu_limit','0')
        puppet_resource_should_show('cpu_reset_interval','00:05:00')
        puppet_resource_should_show('cpu_smp_affinitized', :false)
        puppet_resource_should_show('cpu_smp_processor_affinity_mask','4294967295')
        puppet_resource_should_show('cpu_smp_processor_affinity_mask2','4294967295')
        puppet_resource_should_show('identity_type','ApplicationPoolIdentity')
        puppet_resource_should_show('idle_timeout','00:20:00')
        puppet_resource_should_show('load_user_profile', :false)
        puppet_resource_should_show('logon_type','LogonBatch')
        puppet_resource_should_show('manual_group_membership', :false)
        puppet_resource_should_show('max_processes','1')
        puppet_resource_should_show('pinging_enabled', :true)
        puppet_resource_should_show('ping_interval','00:00:30')
        puppet_resource_should_show('ping_response_time','00:01:30')
        puppet_resource_should_show('set_profile_environment', :true)
        puppet_resource_should_show('shutdown_time_limit','00:01:30')
        puppet_resource_should_show('startup_time_limit','00:01:30')

        # Properties introduced in IIS 8.5 (Server 2012R2 - Kernel 6.3)
        unless ['6.2','6.1'].include?(fact('kernelmajversion'))
          puppet_resource_should_show('idle_timeout_action','Terminate')
          puppet_resource_should_show('log_event_on_process_model','IdleTimeout')
        end
      end

      after(:all) do
        remove_app_pool(@pool_name)
      end
    end

    context 'with a password wrapped in Sensitive() defined' do
      if (get_puppet_version.to_i < 5)
        skip 'is skipped due to version being lower than puppet 5'
      else
        before(:all) do
          @pool_name = "#{SecureRandom.hex(10)}"
          @manifest  = <<-HERE
            iis_application_pool { '#{@pool_name}':
              ensure    => 'present',
              user_name => 'user',
              password  => Sensitive('#@\\\'454sdf'),
            }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_application_pool', @pool_name)
          end

          puppet_resource_should_show('ensure', 'present')
          puppet_resource_should_show('user_name', 'user')
          puppet_resource_should_show('password', '#@\\\'454sdf')

          after(:all) do
            remove_app_pool(@pool_name)
          end
        end
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
            @result = resource('iis_application_pool', @pool_name)
          end

          puppet_resource_should_show('ensure', 'absent')
        end

        after(:all) do
          remove_app_pool(@pool_name)
        end
      end

      context 'managed_pipeline_mode parameter defined' do
        before(:all) do
          @pool_name = "#{SecureRandom.hex(10)}"
          @manifest  = <<-HERE
          iis_application_pool { '#{@pool_name}':
            ensure              => 'present',
            managed_pipeline_mode => 'ClassicTypo'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_application_pool', @pool_name)
          end

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
        @result = resource('iis_application_pool', @pool_name)
      end

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
        @result = resource('iis_application_pool', @pool_name)
      end

      puppet_resource_should_show('ensure', 'absent')
    end
  end

  context 'when application pool restart_memory_limit set' do
    before(:all) do
      @pool_name = "#{SecureRandom.hex(10)}"
      create_app_pool(@pool_name)
      stop_app_pool(@pool_name)
      @manifest = <<-HERE
          iis_application_pool { '#{@pool_name}':
            ensure               => 'present',
            state                => 'Started',
            restart_memory_limit => '3500000',
          }
      HERE
    end

    it_behaves_like 'an idempotent resource'

    context 'when puppet resource is run' do
      before(:all) do
        @result = resource('iis_application_pool', @pool_name)
      end

      puppet_resource_should_show('ensure', 'present')
      puppet_resource_should_show('state', 'Started')
      puppet_resource_should_show('restart_memory_limit', '3500000')
    end

    after(:all){
      remove_app_pool(@pool_name)
    }
  end

  context 'when building a kitchen sink' do
    before(:all) do
      @pool_name = "#{SecureRandom.hex(10)}"
      @manifest = <<-HERE
          iis_application_pool { '#{@pool_name}':
            ensure                           => 'present',
            state                            => 'Started',
            restart_memory_limit             => '3500000',
            managed_pipeline_mode            => 'Integrated',
            managed_runtime_version          => 'v4.0',
            auto_start                       => true,
            enable32_bit_app_on_win64        => false,
            enable_configuration_override    => true,
            pass_anonymous_token             => true,
            start_mode                       => 'OnDemand',
            queue_length                     => '1000',
            cpu_action                       => 'NoAction',
            cpu_limit                        => '100000',
            cpu_reset_interval               => '00:05:00',
            cpu_smp_affinitized              => false,
            cpu_smp_processor_affinity_mask  => '4294967295',
            cpu_smp_processor_affinity_mask2 => '4294967295',
            identity_type                    => 'ApplicationPoolIdentity',
            idle_timeout                     => '00:20:00',
            load_user_profile                => false,
            logon_type                       => 'LogonBatch',
            manual_group_membership          => false,
            max_processes                    => '1',
            pinging_enabled                  => true,
            ping_interval                    => '00:00:30',
            ping_response_time               => '00:01:30',
            set_profile_environment          => true,
            shutdown_time_limit              => '00:01:30',
            startup_time_limit               => '00:01:30',
            orphan_action_exe                => 'foo.exe',
            orphan_action_params             => '-wakka',
            orphan_worker_process            => true,
          }
      HERE
    end

    it_behaves_like 'an idempotent resource'

    context 'when puppet resource is run' do
      before(:all) do
        @result = resource('iis_application_pool', @pool_name)
      end

      puppet_resource_should_show('ensure', 'present')
      puppet_resource_should_show('state', 'Started')
      puppet_resource_should_show('restart_memory_limit', '3500000')
      puppet_resource_should_show('managed_pipeline_mode', 'Integrated')
      puppet_resource_should_show('managed_runtime_version', 'v4.0')
      puppet_resource_should_show('auto_start', :true)
      puppet_resource_should_show('enable32_bit_app_on_win64', :false)
      puppet_resource_should_show('enable_configuration_override', :true)
      puppet_resource_should_show('pass_anonymous_token', :true)
      puppet_resource_should_show('start_mode','OnDemand')
      puppet_resource_should_show('queue_length','1000')
      puppet_resource_should_show('cpu_action','NoAction')
      puppet_resource_should_show('cpu_limit','100000')
      puppet_resource_should_show('cpu_reset_interval','00:05:00')
      puppet_resource_should_show('cpu_smp_affinitized', :false)
      puppet_resource_should_show('cpu_smp_processor_affinity_mask','4294967295')
      puppet_resource_should_show('cpu_smp_processor_affinity_mask2','4294967295')
      puppet_resource_should_show('identity_type','ApplicationPoolIdentity')
      puppet_resource_should_show('idle_timeout','00:20:00')
      puppet_resource_should_show('load_user_profile', :false)
      puppet_resource_should_show('logon_type','LogonBatch')
      puppet_resource_should_show('manual_group_membership', :false)
      puppet_resource_should_show('max_processes','1')
      puppet_resource_should_show('pinging_enabled', :true)
      puppet_resource_should_show('ping_interval','00:00:30')
      puppet_resource_should_show('ping_response_time','00:01:30')
      puppet_resource_should_show('set_profile_environment', :true)
      puppet_resource_should_show('shutdown_time_limit','00:01:30')
      puppet_resource_should_show('startup_time_limit','00:01:30')
    end

    after(:all){
      remove_app_pool(@pool_name)
    }
  end
end
