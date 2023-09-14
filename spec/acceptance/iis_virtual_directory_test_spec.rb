# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'iis_virtual_directory', :suite_b do
  site_name = SecureRandom.hex(10)
  before(:context) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites
    create_site(site_name, true)
  end

  after(:context) do
    remove_all_sites
  end

  context 'when configuring a virtual directory' do
    context 'with default parameters' do
      before(:all) do
        create_path('C:\foo')
      end

      virt_dir_name = SecureRandom.hex(10).to_s
      manifest = <<-HERE
        file{ 'c:/foo':
          ensure => 'directory'
        }->
        file{ 'c:/foo2':
        ensure => 'directory'
        }->
        iis_virtual_directory { '#{virt_dir_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          physicalpath => 'c:\\foo'
        }
      HERE

      manifest2 = <<-HERE
        iis_virtual_directory { '#{virt_dir_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          # Change capitalization to see if it breaks idempotency
          physicalpath => 'c:\\Foo'
        }
      HERE

      manifest3 = <<-HERE
        iis_virtual_directory { '#{virt_dir_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          physicalpath => 'c:\\foo2'
        }
      HERE

      iis_idempotent_apply('create iis virtual dir', manifest)

      after(:all) do
        remove_vdir(virt_dir_name, site_name)
      end

      it 'iis_virtual_directory should be present' do
        puppet_resource_should_show('ensure', 'present', resource('iis_virtual_directory', virt_dir_name))
      end

      it 'runs with no changes if capitolization changes' do
        apply_manifest(manifest2, catch_changes: true)
      end

      iis_idempotent_apply('change physical path', manifest3)

      it 'physicalpath to be configured' do
        puppet_resource_should_show('physicalpath', 'c:\\foo2', resource('iis_virtual_directory', virt_dir_name))
      end
    end

    context 'with a password wrapped in Sensitive()' do
      virt_dir_name = SecureRandom.hex(10).to_s
      manifest = <<-HERE
        file{ 'c:/foo':
          ensure => 'directory'
        }->
        iis_virtual_directory { '#{virt_dir_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          physicalpath => 'c:\\foo',
          user_name    => 'user',
          password     => Sensitive('#@\\'454sdf'),
        }
      HERE

      iis_idempotent_apply('create iis virtual dir', manifest)

      it 'all parameters are configured' do
        resource_data = resource('iis_virtual_directory', virt_dir_name)
        [
          'ensure', 'present',
          'user_name', 'user',
          'password', '#@\\\'454sdf'
        ].each_slice(2) do |key, value|
          puppet_resource_should_show(key, value, resource_data)
        end
      end

      it 'remove virt dir name' do
        remove_vdir(virt_dir_name, site_name)
      end
    end

    context 'when virtual directory is removed' do
      virt_dir_name = SecureRandom.hex(10).to_s
      before(:all) do
        create_path('c:/foo')
        create_vdir(virt_dir_name, site_name, 'c:/foo')
      end

      manifest = <<-HERE
        iis_virtual_directory { '#{virt_dir_name}':
          sitename     => '#{site_name}',
          ensure       => 'absent'
        }
      HERE

      iis_idempotent_apply('remove iis virtual dir', manifest)

      after(:all) do
        remove_vdir(virt_dir_name)
      end

      it 'iis_virtual_directory to be absent' do
        puppet_resource_should_show('ensure', 'absent', resource('iis_virtual_directory', virt_dir_name))
      end
    end

    context 'with invalid' do
      context 'when physicalpath parameter is defined' do
        virt_dir_name = SecureRandom.hex(10).to_s
        manifest = <<-HERE
          iis_virtual_directory { '#{virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{site_name}',
            physicalpath => 'c:\\wakka'
          }
        HERE
        apply_failing_manifest('apply failing manifest', manifest)

        after(:all) do
          remove_vdir(virt_dir_name)
        end

        it 'iis_virtual_directory to be absent' do
          puppet_resource_should_show('ensure', 'absent', resource('iis_virtual_directory', virt_dir_name))
        end
      end

      context 'when physicalpath parameter is not defined' do
        virt_dir_name = SecureRandom.hex(10).to_s
        manifest = <<-HERE
          iis_virtual_directory { '#{virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{site_name}'
          }
        HERE
        apply_failing_manifest('apply failing manifest', manifest)

        after(:all) do
          remove_vdir(virt_dir_name)
        end

        it 'iis_virtual_directory to be absent' do
          puppet_resource_should_show('ensure', 'absent', resource('iis_virtual_directory', virt_dir_name))
        end
      end
    end
  end
end
