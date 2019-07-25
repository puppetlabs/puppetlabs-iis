# The Puppet Extensions Module
module PuppetX
  # PuppetLabs
  module PuppetLabs
    # IIS
    module IIS
      # Property
      module Property
        # string
        class String < Puppet::Property
          validate do |value|
            raise "#{name} should be a String" unless value.is_a? ::String
          end
        end
      end
    end
  end
end
