# The Puppet Extensions Module
module PuppetX
  # PuppetLabs
  module PuppetLabs
    # IIS
    module IIS
      # Property
      module Property
        # path Property
        class Path < Puppet::Property
          validate do |value|
            unless value =~ /^.:(\/|\\)/ || value =~ /^\\\\[^\\]+\\[^\\]+/
              raise("#{name} should be a path (local or UNC) not '#{value}'")
            end
          end

          def property_matches?(current, desired)
            current.casecmp(desired.downcase).zero?
          end
        end
      end
    end
  end
end
