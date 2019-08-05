require 'spec_helper_acceptance'

describe 'iis_feature' do
  context 'when managing features' do
    context 'with default parameters' do
      feature = 'Web-Scripting-Tools'
      describe "apply manifest twice" do
        manifest = <<-HERE
          iis_feature { '#{feature}':
            ensure => 'present'
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end

      context 'when puppet resource is run' do
        let(:result) { resource('iis_feature', feature) }
        it "iis_feature is present" do
          puppet_resource_should_show('ensure', 'present', result)
        end
      end
    end

    context 'with invalid' do
      context 'name parameter defined' do
        describe "apply failing manifest" do
          manifest = <<-HERE
          iis_feature { 'Foo':
            ensure => 'present'
          }
          HERE
          it_behaves_like 'a failing manifest', manifest
        end
      end
    end
  end
end
