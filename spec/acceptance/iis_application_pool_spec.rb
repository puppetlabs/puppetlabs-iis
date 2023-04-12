# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'iis_application_pool', :suite_a do
  context 'when configuring an application pool' do
    context 'with default parameters' do
      pool_name = SecureRandom.hex(10).to_s
      manifest  = <<-HERE
        iis_application_pool { '#{pool_name}':
          ensure => 'present'
        }
      HERE

      iis_idempotent_apply('create app pool', manifest)

      after(:all) do
        remove_app_pool(pool_name)
      end

      it 'resource iis_application_pool is present' do
        puppet_resource_should_show('ensure', 'present', resource('iis_application_pool', pool_name))
      end
    end

    context 'with valid parameters defined' do
      pool_name = SecureRandom.hex(10).to_s

      manifest  = <<-HERE
        iis_application_pool { '#{pool_name}':
          ensure                  => 'present',
          managed_pipeline_mode   => 'Integrated',
          managed_runtime_version => '',
          state                   => 'stopped'
        }
      HERE

      iis_idempotent_apply('create app pool', manifest)

      after(:all) do
        remove_app_pool(pool_name)
      end

      it 'has all properties correctly configured for IIS 7.0' do
        # Properties introduced in IIS 7.0 (Server 2008 - Kernel 6.1)
        resource_data = resource('iis_application_pool', pool_name)
        [
          'ensure', 'present',
          'managed_pipeline_mode', 'Integrated',
          'state', 'stopped',
          'auto_start', :true,
          'enable32_bit_app_on_win64', :false,
          'enable_configuration_override', :true,
          'pass_anonymous_token', :true,
          'start_mode', 'OnDemand',
          'queue_length', '1000',
          'cpu_action', 'NoAction',
          'cpu_limit', '0',
          'cpu_reset_interval', '00:05:00',
          'cpu_smp_affinitized', :false,
          'cpu_smp_processor_affinity_mask', '4294967295',
          'cpu_smp_processor_affinity_mask2', '4294967295',
          'identity_type', 'ApplicationPoolIdentity',
          'idle_timeout', '00:20:00',
          'load_user_profile', :false,
          'logon_type', 'LogonBatch',
          'manual_group_membership', :false,
          'max_processes', '1',
          'pinging_enabled', :true,
          'ping_interval', '00:00:30',
          'ping_response_time', '00:01:30',
          'set_profile_environment', :true,
          'shutdown_time_limit', '00:01:30',
          'startup_time_limit', '00:01:30'
        ].each_slice(2) do |key, value|
          puppet_resource_should_show(key, value, resource_data)
        end
      end

      # Properties introduced in IIS 8.5 (Server 2012R2 - Kernel 6.3)
      unless ['6.2', '6.1'].include?(target_host_facts['kernelmajversion'])
        it 'has all properties correctly configured for IIS 8.5' do
          resource_data = resource('iis_application_pool', pool_name)
          [
            'idle_timeout_action', 'Terminate',
            'log_event_on_process_model', 'IdleTimeout'
          ].each_slice(2) do |key, value|
            puppet_resource_should_show(key, value, resource_data)
          end
        end
      end
    end

    context 'with a password wrapped in Sensitive() defined' do
      pool_name = SecureRandom.hex(10).to_s
      manifest  = <<-HERE
        iis_application_pool { '#{pool_name}':
          ensure    => 'present',
          user_name => 'user',
          password  => Sensitive('#@\\'454sdf'),
        }
      HERE

      iis_idempotent_apply('create app pool', manifest)

      after(:all) do
        remove_app_pool(pool_name)
      end

      it 'has all properties correctly configured' do
        resource_data = resource('iis_application_pool', pool_name)
        [
          'ensure', 'present',
          'user_name', 'user',
          'password', '#@\\\'454sdf'
        ].each_slice(2) do |key, value|
          puppet_resource_should_show(key, value, resource_data)
        end
      end
    end

    context 'with invalid' do
      context 'state parameter defined' do
        pool_name = SecureRandom.hex(10).to_s
        manifest  = <<-HERE
        iis_application_pool { '#{pool_name}':
          ensure  => 'present',
          state   => 'AnotherTypo'
        }
        HERE

        apply_failing_manifest('apply failing manifest', manifest)

        after(:all) do
          remove_app_pool(pool_name)
        end

        it 'iis_application_pool is absent' do
          puppet_resource_should_show('ensure', 'absent', resource('iis_application_pool', pool_name))
        end
      end

      context 'managed_pipeline_mode parameter defined' do
        pool_name = SecureRandom.hex(10).to_s
        manifest  = <<-HERE
        iis_application_pool { '#{pool_name}':
          ensure              => 'present',
          managed_pipeline_mode => 'ClassicTypo'
        }
        HERE

        apply_failing_manifest('create app pool', manifest)

        after(:all) do
          remove_app_pool(pool_name)
        end

        it 'iis_application_pool is absent' do
          puppet_resource_should_show('ensure', 'absent', resource('iis_application_pool', pool_name))
        end
      end
    end
  end

  context 'when starting a stopped application pool' do
    pool_name = SecureRandom.hex(10).to_s
    manifest = <<-HERE
      iis_application_pool { '#{pool_name}':
        ensure  => 'present',
        state   => 'started'
      }
    HERE

    before(:all) do
      create_app_pool(pool_name)
      stop_app_pool(pool_name)
    end

    iis_idempotent_apply('start the app pool', manifest)

    after(:all) do
      remove_app_pool(pool_name)
    end

    it 'iis_application_pool is present and has the correct state' do
      resource_data = resource('iis_application_pool', pool_name)
      [
        'ensure', 'present',
        'state', 'started'
      ].each_slice(2) do |key, value|
        puppet_resource_should_show(key, value, resource_data)
      end
    end
  end

  context 'when removing an application pool' do
    pool_name = SecureRandom.hex(10).to_s
    manifest = <<-HERE
      iis_application_pool { '#{pool_name}':
        ensure => 'absent'
      }
    HERE

    before(:all) do
      create_app_pool(pool_name)
    end

    iis_idempotent_apply('remove the app pool', manifest)

    it 'iis_application_pool is absent' do
      puppet_resource_should_show('ensure', 'absent', resource('iis_application_pool', pool_name))
    end
  end

  context 'when application pool restart_memory_limit set to 3500000' do
    pool_name = SecureRandom.hex(10).to_s
    manifest = <<-HERE
      iis_application_pool { '#{pool_name}':
        ensure               => 'present',
        state                => 'started',
        restart_memory_limit => '3500000',
      }
    HERE

    before(:all) do
      create_app_pool(pool_name)
      stop_app_pool(pool_name)
    end

    iis_idempotent_apply('set memory limit', manifest)

    after(:all) do
      remove_app_pool(pool_name)
    end

    it 'has all properties correctly configured' do
      resource_data = resource('iis_application_pool', pool_name)
      [
        'ensure', 'present',
        'state', 'started',
        'restart_memory_limit', '3500000'
      ].each_slice(2) do |key, value|
        puppet_resource_should_show(key, value, resource_data)
      end
    end
  end

  context 'when application pool restart_memory_limit set to 0' do
    pool_name = SecureRandom.hex(10).to_s
    manifest = <<-HERE
      iis_application_pool { '#{pool_name}':
        ensure                       => 'present',
        state                        => 'started',
        cpu_limit                    => '0',
        max_processes                => '0',
        restart_memory_limit         => '0',
        restart_private_memory_limit => '0',
        restart_requests_limit       => '0'

      }
    HERE

    before(:all) do
      create_app_pool(pool_name)
      stop_app_pool(pool_name)
    end

    iis_idempotent_apply('set values to 0', manifest)

    after(:all) do
      remove_app_pool(pool_name)
    end

    it 'has all properties correctly configured' do
      resource_data = resource('iis_application_pool', pool_name)
      [
        'ensure', 'present',
        'state', 'started',
        'cpu_limit', '0',
        'max_processes', '0',
        'restart_memory_limit', '0',
        'restart_private_memory_limit', '0',
        'restart_requests_limit', '0'
      ].each_slice(2) do |key, value|
        puppet_resource_should_show(key, value, resource_data)
      end
    end
  end

  context 'when building a kitchen sink' do
    pool_name = SecureRandom.hex(10).to_s
    manifest = <<-HERE
      iis_application_pool { '#{pool_name}':
        ensure                           => 'present',
        state                            => 'started',
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

    iis_idempotent_apply('create app pool', manifest)

    after(:all) do
      remove_app_pool(pool_name)
    end

    it 'has all properties correctly configured' do
      resource_data = resource('iis_application_pool', pool_name)
      [
        'ensure', 'present',
        'state', 'started',
        'restart_memory_limit', '3500000',
        'managed_pipeline_mode', 'Integrated',
        'managed_runtime_version', 'v4.0',
        'auto_start', :true,
        'enable32_bit_app_on_win64', :false,
        'enable_configuration_override', :true,
        'pass_anonymous_token', :true,
        'start_mode', 'OnDemand',
        'queue_length', '1000',
        'cpu_action', 'NoAction',
        'cpu_limit', '100000',
        'cpu_reset_interval', '00:05:00',
        'cpu_smp_affinitized', :false,
        'cpu_smp_processor_affinity_mask', '4294967295',
        'cpu_smp_processor_affinity_mask2', '4294967295',
        'identity_type', 'ApplicationPoolIdentity',
        'idle_timeout', '00:20:00',
        'load_user_profile', :false,
        'logon_type', 'LogonBatch',
        'manual_group_membership', :false,
        'max_processes', '1',
        'pinging_enabled', :true,
        'ping_interval', '00:00:30',
        'ping_response_time', '00:01:30',
        'set_profile_environment', :true,
        'shutdown_time_limit', '00:01:30',
        'startup_time_limit', '00:01:30'
      ].each_slice(2) do |key, value|
        puppet_resource_should_show(key, value, resource_data)
      end
    end
  end
end
