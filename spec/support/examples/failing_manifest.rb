shared_examples 'a failing manifest' do |manifest|
  it 'runs with errors' do
    execute_manifest(manifest, expect_failures: true)
  end
end
