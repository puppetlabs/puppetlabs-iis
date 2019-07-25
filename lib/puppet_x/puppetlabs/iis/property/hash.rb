# The Puppet Extensions Module
module PuppetX
  # PuppetLabs
  module PuppetLabs
    # IIS
    module IIS
      # Property
      module Property
        # hash Property
        class Hash < Puppet::Property
          validate do |value|
            raise "#{name} should be a Hash" unless value.is_a? ::Hash
          end
        end
      end
    end
  end
end
