require 'spec_helper_acceptance'

describe 'iis_virtual_directory' do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites();

    @site_name = SecureRandom.hex(10)
    create_site(@site_name, true)
  end

  after(:all) do
    remove_all_sites
  end

  context 'when configuring a virtual directory' do
    context 'with default parameters' do
      before(:all) do
        @virt_dir_name = "#{SecureRandom.hex(10)}"
        @manifest  = <<-HERE
          file{ 'c:/foo':
            ensure => 'directory'
          }->
          iis_virtual_directory { '#{@virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{@site_name}',
            physicalpath => 'c:\\foo'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = resource('iis_virtual_directory', @virt_dir_name)
        end

        puppet_resource_should_show('ensure', 'present')
      end

      after(:all) do
        remove_vdir(@virt_dir_name)
      end
    end

    context 'with invalid' do
      context 'physicalpath parameter defined' do
        before(:all) do
          @virt_dir_name = "#{SecureRandom.hex(10)}"
          @manifest  = <<-HERE
          iis_virtual_directory { '#{@virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{@site_name}',
            physicalpath => 'c:\\wakka'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_virtual_directory', @virt_dir_name)
          end

          puppet_resource_should_show('ensure', 'absent')
        end

        after(:all) do
          remove_vdir(@virt_dir_name)
        end
      end

      context 'physicalpath parameter not defined' do
        before(:all) do
          @virt_dir_name = "#{SecureRandom.hex(10)}"
          @manifest  = <<-HERE
          iis_virtual_directory { '#{@virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{@site_name}'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'

        context 'when puppet resource is run' do
          before(:all) do
            @result = resource('iis_virtual_directory', @virt_dir_name)
          end

          puppet_resource_should_show('ensure', 'absent')
        end

        after(:all) do
          remove_vdir(@virt_dir_name)
        end
      end
    end
  end
end
