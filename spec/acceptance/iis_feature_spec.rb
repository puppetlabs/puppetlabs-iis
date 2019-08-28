require 'spec_helper_acceptance'

describe 'iis_feature' do
  context 'when managing features' do
    context 'with default parameters' do
      feature = 'Web-Scripting-Tools'
      manifest = <<-HERE
        iis_feature { '#{feature}':
          ensure => 'present'
        }
      HERE

      idempotent_apply('create iis feature', manifest)

      it "iis_feature is present" do
        result = resource('iis_feature', feature)
        puppet_resource_should_show('ensure', 'present', result)
      end
    end

    context 'with invalid' do
      manifest = <<-HERE
      iis_feature { 'Foo':
        ensure => 'present'
      }
      HERE
      apply_failing_manifest('apply failed manifest', manifest)
    end
  end
end
