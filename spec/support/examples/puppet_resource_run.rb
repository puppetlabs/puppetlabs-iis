shared_examples 'with a puppet resource run' do |_type, _name|
  # before(:all) do
  #   # @result = resource(type, name, beaker_opts)
  #   require 'pry';binding.pry
  #   @result = on(default, puppet('resource', type, name))
  # end

  it 'returns successfully' do
    expect(@result.exit_code).to eq 0
  end

  it 'does not return an error' do
    expect(@result.stderr).not_to match(%r{\b})
  end
end
