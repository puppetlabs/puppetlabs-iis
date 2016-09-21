describe Puppet::Type.type(:iis_site).provider(:webadministration), :if => Puppet.features.microsoft_windows? do
  let(:resource) { Puppet::Type.type(:iis_site).new(:name => "iis_site") }
  let(:provider) { resource.provider }
  let(:catalog)  { Puppet::Resource::Catalog.new }
  
  before :each do
    resource.provider = provider
  end

  context "verify provider" do
    it "should be an instance of Puppet::Type::Iis_site::ProviderWebadministration" do
      provider.must be_an_instance_of Puppet::Type::Iis_site::ProviderWebadministration
    end

    it "should have a create method" do
      provider.should respond_to(:create)
    end

    it "should have an exists? method" do
      provider.should respond_to(:exists?)
    end

    it "should have a destroy method" do
      provider.should respond_to(:destroy)
    end
    
    it "should have a start method" do
      provider.should respond_to(:start)
    end
    
    it "should have a stop method" do
      provider.should respond_to(:stop)
    end
  end
end
