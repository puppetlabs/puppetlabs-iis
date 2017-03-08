shared_examples 'a failing manifest' do
  it 'should run with errors' do
    execute_manifest(@manifest, :expect_failures => true)
  end
end
