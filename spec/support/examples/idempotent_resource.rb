shared_examples 'an idempotent resource' do
  it 'should run without errors' do
    apply_manifest(@manifest, :expect_changes => true)
  end

  it 'should run a second time without changes' do
    apply_manifest(@manifest, :expect_changes => false)
  end
end
