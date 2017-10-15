module PuppetX
  module PuppetLabs
    module IIS
      module Property
        class Name < Puppet::Property
          validate do |value|
            fail("#{value} is not a valid #{self.name.to_s}") unless value =~ /^[a-zA-Z0-9\.\-\_\'\s]+$/
          end
        end
      end
    end
  end
end
