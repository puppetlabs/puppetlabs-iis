require 'spec_helper_acceptance'

describe 'a minimal IIS config:' do
  before(:all) do
    @manifest = <<-EOF
      # iis_site { "minimal": }
      notify { "something should happen here": }
    EOF
    @result = apply_manifest(@manifest, acceptable_exit_codes: (0...256))
  end

  it_behaves_like 'an idempotent resource'
end
