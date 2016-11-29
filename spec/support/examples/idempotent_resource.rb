shared_examples 'an idempotent resource' do
  it 'should run without errors' do
    expect(@result.exit_code).to eq 2
  end

  it 'should run a second time without changes' do
    second_result = apply_manifest(@manifest, acceptable_exit_codes: (0...256))
    expect(second_result.exit_code).to eq 0
  end
end
