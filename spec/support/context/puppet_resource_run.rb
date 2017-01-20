shared_context 'with a puppet resource run' do |type, name|
  # before(:all) do
  #   # @result = resource(type, name, beaker_opts)
  #   require 'pry';binding.pry
  #   @result = on(default, puppet('resource', type, name))
  # end

  it 'should return successfully' do
    expect(@result.exit_code).to eq 0
  end

  it 'should not return an error' do
    expect(@result.stderr).not_to match(/\b/)
  end
end
