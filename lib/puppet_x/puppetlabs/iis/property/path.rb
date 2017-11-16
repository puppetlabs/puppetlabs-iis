module PuppetX
  module PuppetLabs
    module IIS
      module Property
        class Path < Puppet::Property
          validate do |value|
            unless value =~ /^.:(\/|\\)/ or value =~ /^\\\\[^\\]+\\[^\\]+/
              fail("#{self.name.to_s} should be a path (local or UNC) not '#{value}'")
            end
          end
        end
      end
    end
  end
end
