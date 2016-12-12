module PuppetX
  module PuppetLabs
    module IIS
      module Property
        class Hash < Puppet::Property
          validate do |value|
            fail "#{self.name.to_s} should be a Hash" unless value.is_a? ::Hash
          end
        end
      end
    end
  end
end
