require 'spec_helper_acceptance'

describe 'iis_application_pool' do
  context 'when configuring an Application Pool' do
    before(:all) do
      @manifest = "iis_application_pool { 'test': }"
      @result = apply_manifest(@manifest, acceptable_exit_codes: (0...256))
    end

    after(:all) do
      # TODO: remove "test" app pool
    end

    it_behaves_like 'an idempotent resource'

    context "when removing the Application Pool" do
      before(:all) do
        @manifest = "iis_application_pool { 'test': ensure => absent }"
        @result = apply_manifest(@manifest, acceptable_exit_codes: (0...256))
      end

      it_behaves_like 'an idempotent resource'
    end
  end

  context 'when puppet resource is run' do
    include_context 'with a puppet resource run', 'iis_application_pool', 'DefaultAppPool'  # guess work
    puppet_resource_should_show('ensure', 'present')
  end
end
