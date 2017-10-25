require 'spec_helper'

describe 'iis_application_pool' do
  let(:type_class) { Puppet::Type.type(:iis_application_pool) }

  let :params do
    [
      :name,
    ]
  end

  let :properties do
    [
      :ensure,
      :state,
      :managed_pipeline_mode,
      :managed_runtime_version,
      :auto_start,
      :clr_config_file,
      :enable32_bit_app_on_win64,
      :enable_configuration_override,
      :managed_pipeline_mode,
      :managed_runtime_loader,
      :managed_runtime_version,
      :pass_anonymous_token,
      :start_mode,
      :queue_length,
      :cpu_action,
      :cpu_limit,
      :cpu_reset_interval,
      :cpu_smp_affinitized,
      :cpu_smp_processor_affinity_mask,
      :cpu_smp_processor_affinity_mask2,
      :identity_type,
      :idle_timeout,
      :idle_timeout_action,
      :load_user_profile,
      :log_event_on_process_model,
      :logon_type,
      :manual_group_membership,
      :max_processes,
      :pinging_enabled,
      :ping_interval,
      :ping_response_time,
      :set_profile_environment,
      :shutdown_time_limit,
      :startup_time_limit,
      :orphan_action_exe,
      :orphan_action_params,
      :orphan_worker_process,
      :load_balancer_capabilities,
      :rapid_fail_protection,
      :rapid_fail_protection_interval,
      :rapid_fail_protection_max_crashes,
      :auto_shutdown_exe,
      :auto_shutdown_params,
      :disallow_overlapping_rotation,
      :disallow_rotation_on_config_change,
      :log_event_on_recycle,
      :restart_memory_limit,
      :restart_private_memory_limit,
      :restart_requests_limit,
      :restart_time_limit,
      :restart_schedule,
      :user_name,
      :password
    ]
  end

  let :minimal_config do
    {
      name: 'Some App Pool',
    }
  end

  let :optional_config do
    {
    }
  end

  let :default_config do
     minimal_config.merge(optional_config)
  end

  it 'should have expected properties' do
    expect(type_class.properties.map(&:name)).to include(*properties)
  end

  it 'should have expected parameters' do
    expect(type_class.parameters).to include(*params)
  end

  it 'should not have unexpected properties' do
    expect(properties).to include(*type_class.properties.map(&:name))
  end

  it 'should not have unexpected parameters' do
    expect(params + [:provider]).to include(*type_class.parameters)
  end

  [
    :state,
    :managed_pipeline_mode,
    :managed_runtime_version,
    :start_mode,
    :cpu_action,
    :idle_timeout_action,
    :logon_type,
    :load_balancer_capabilities,
    :identity_type,
    
  ]
  
  [
    :name,
    :clr_config_file,
    :managed_runtime_loader,
    :log_event_on_process_model,
    :orphan_action_exe,
    :orphan_action_params,
    :rapid_fail_protection,
    :auto_shutdown_exe,
    :auto_shutdown_params,
    :log_event_on_recycle,
  ].each do |property|
    it "should require #{property} to be a string" do
      expect(type_class).to require_string_for(property)
    end
  end

  [
    :auto_start,
    :enable32_bit_app_on_win64,
    :enable_configuration_override,
    :pass_anonymous_token,
    :cpu_smp_affinitized,
    :load_user_profile,
    :manual_group_membership,
    :pinging_enabled,
    :set_profile_environment,
    :orphan_worker_process,
    :disallow_overlapping_rotation,
    :disallow_rotation_on_config_change,
  ].each do |property|
    it "should require #{property} to be boolean" do
      config = {name: 'name'}
      config[property] = 'string'
      expect do
        type_class.new(config)
      end.to raise_error(Puppet::Error, /Parameter #{property} failed on .*: Invalid value/)
    end
  end
  
  [
    {:cpu_reset_interval => "00:00:00"},
    {:idle_timeout => "00:00:00"},
    {:ping_interval => "00:00:00"},
    {:ping_response_time => "00:00:00"},
    {:shutdown_time_limit => "00:00:00"},
    {:startup_time_limit => "00:00:00"},
    {:rapid_fail_protection_interval => "00:00:00"},
    {:restart_time_limit => "00:00:00"},
  ].each do |property|
    prop = property.keys[0]
    upper_limit = property[property.keys[0]]
    
    it "should require #{prop} to be a formatted time" do
      config = {name: 'name'}
      config[prop] = 'string'
      expect do
        type_class.new(config)
      end.to raise_error(Puppet::Error, /#{prop} should match datetime format 00:00:00/)
    end
  end

  [
    {:queue_length => 65535},
    {:cpu_limit => 100000},
    {:cpu_smp_processor_affinity_mask => nil},
    {:cpu_smp_processor_affinity_mask2 => nil},
    {:max_processes => 2147483647},
    {:rapid_fail_protection_max_crashes => 2147483647},
    {:restart_memory_limit => nil},
    {:restart_private_memory_limit => nil},
    {:restart_requests_limit => nil},
  ].each do |property|
    prop = property.keys[0]
    upper_limit = property[property.keys[0]]
    it "should require #{prop} to be a number" do
      expect(type_class).to require_integer_for(prop)
    end

    # it "should require #{prop} to be greater than 0" do
    #   expect do
    #     config = {name: 'sample'}
    #     config[prop] = 0
    #     type_class.new(config)
    #   end.to raise_error(Puppet::Error, /#{prop} should be greater than 0/)
    # end
    
    if upper_limit
      it "should require #{prop} to be less than #{upper_limit}" do
        expect do
          upper_limit += 1
          config = {name: 'sample'}
          config[prop] = upper_limit
          type_class.new(config)
        end.to raise_error(Puppet::Error, /#{prop} should be less than or equal to #{upper_limit}/)
      end
    end

  end

  context 'parameter :name' do
    it "should not allow nil" do
      expect {
        pool = type_class.new(
          name: 'foo'
        )
        pool[:name] = nil
      }.to raise_error(Puppet::Error, /Got nil value for name/)
    end

    it "should not allow empty" do
      expect {
        pool = type_class.new(
          name: 'foo'
        )
        pool[:name] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty name must/)
    end

    [ 'value', 'value with spaces', 'UPPER CASE', '0123456789_-', 'With.Period' ].each do |value|
      it "should accept '#{value}'" do
        expect { 
          pool = type_class.new(
            name: 'foo'
          )
          pool[:name] = value
        }.not_to raise_error
      end
    end

    [ '*', '()', '[]', '!@' ].each do |value|
      it "should reject '#{value}'" do
        expect {
          pool = type_class.new(
            name: 'foo'
          )
          pool[:name] = value
        }.to raise_error(Puppet::ResourceError, /is not a valid name/)
      end
    end
  end

  context 'parameter :restart_schedule' do
    it 'should accept a formatted time' do
      pool = type_class.new(
        name: 'foo',
        restart_schedule: '00:00:00',
      )
      expect(pool[:restart_schedule]).to eq(['00:00:00'])
    end
    it 'should accept an array of formatted times' do
      pool = type_class.new(
        name: 'foo',
        restart_schedule: ['00:00:00'],
      )
      expect(pool[:restart_schedule]).to eq(['00:00:00'])
    end
    it 'should reject a value that is not a formatted time' do
      expect do
        config = {
          name: 'foo',
          restart_schedule: 'bottle',
        }
        type_class.new(config)
      end.to raise_error(Puppet::Error, /Parameter restart_schedule failed/)
    end
    it 'should reject a formatted time with a granularity of less than 60 seconds' do
      expect do
        config = {
          name: 'foo',
          restart_schedule: '00:00:45',
        }
        type_class.new(config)
      end.to raise_error(Puppet::Error, /Parameter restart_schedule failed/)
    end
  end

  # [
  #   :cpu_smp_processor_affinity_mask,
  #   :cpu_smp_processor_affinity_mask2,
  #   :max_processes,
  #   :rapid_fail_protection_max_crashes,
  #   :restart_memory_limit,
  #   :restart_private_memory_limit,
  #   :restart_requests_limit,
  # ].each do |property|
  #   it "should require #{property} to be less than 2147483647" do
  #     expect do
  #       config = {name: 'sample'}
  #       config[property] = 0
  #       type_class.new(config)
  #     end.to raise_error(Puppet::Error, /#{property} should be greater than 0/)
  #   end
  # end

  it 'should default ensure to present' do
    pool = type_class.new(
      name: 'foo',
    )
    expect(pool[:ensure]).to eq(:present)
  end

  context 'with a minimal set of properties' do
    let :config do
      minimal_config
    end

    let :app_pool do
      type_class.new(config)
    end

    it 'should be valid' do
      expect { app_pool }.not_to raise_error
    end
  end

  # See https://github.com/puppetlabs/puppetlabs-azure/blob/master/spec/unit/type/azure_vm_spec.rb for more examples
end
