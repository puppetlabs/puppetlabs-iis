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
      # create_site(site_name, true)
      after(:all) do
        remove_vdir(virt_dir_name, site_name)
      end

      describe 'apply manifest twice' do
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

        iis_idempotent_apply('create iis virtual dir', manifest)
      end

      context 'when puppet resource is run' do
        it 'iis_virtual_directory should be present' do
          puppet_resource_should_show('ensure', 'present', resource('iis_virtual_directory', virt_dir_name))
        end

        context 'when capitalization of paths change' do
          manifest = <<-HERE
            iis_virtual_directory { '#{virt_dir_name}':
              ensure       => 'present',
              sitename     => '#{site_name}',
              # Change capitalization to see if it breaks idempotency
              physicalpath => 'c:\\Foo'
            }
          HERE

          it 'runs with no changes' do
            apply_manifest(manifest, catch_changes: true)
          end
        end
      end

      context 'when physical path changes' do
        describe 'apply manifest twice' do
          manifest = <<-HERE
          iis_virtual_directory { '#{virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{site_name}',
            physicalpath => 'c:\\foo2'
          }
          HERE

          iis_idempotent_apply('create iis virtual dir', manifest)
        end

        context 'when puppet resource is run' do
          it 'physicalpath to be configured' do
            puppet_resource_should_show('physicalpath', 'c:\\foo2', resource('iis_virtual_directory', virt_dir_name))
          end
        end
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

    context 'can remove virtual directory' do
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

    context 'name allows slashes' do
      context 'simple case' do
        virt_dir_name = SecureRandom.hex(10).to_s
        before(:all) do
          create_path('c:\inetpub\test_site')
          create_path('c:\inetpub\test_vdir')
          create_path('c:\inetpub\deeper')
          # create_site(site_name, true)
        end

        manifest = <<-HERE
        iis_virtual_directory{ "test_vdir":
          ensure       => 'present',
          sitename     => "#{site_name}",
          physicalpath => 'c:\\inetpub\\test_vdir',
        }->
        iis_virtual_directory { 'test_vdir\deeper':
          name         => 'test_vdir\deeper',
          ensure       => 'present',
          sitename     => '#{site_name}',
          physicalpath => 'c:\\inetpub\\deeper',
        }
        HERE
        iis_idempotent_apply('create iis virtual dir', manifest)

        after(:all) do
          remove_vdir(virt_dir_name)
        end
      end
    end

    context 'with invalid' do
      context 'physicalpath parameter defined' do
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

      context 'physicalpath parameter not defined' do
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
