require 'spec_helper_acceptance'

describe 'iis_feature' do
  context 'when managing features' do
    # TestRail ID: C100065
    context 'with default parameters' do
      before(:all) do
        @feature = 'Web-Mgmt-Console'
        @manifest  = <<-HERE
          iis_feature { '#{@feature}':
            ensure => 'present'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = resource('iis_feature', @feature)
        end

        puppet_resource_should_show('ensure', 'present')
      end
    end

    # TestRail ID: C100066
    context 'with invalid' do
      context 'name parameter defined' do
        before(:all) do
          @manifest  = <<-HERE
          iis_feature { 'Foo':
            ensure => 'present'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'
      end

    end
  end
end
