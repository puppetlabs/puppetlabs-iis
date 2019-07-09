# @api private
module PuppetX
  # @api private
  module PuppetLabs
    # @api private
    module IIS
      # @api private
      module Property
        # path Property
        class Path < Puppet::Property
          validate do |value|
            unless value =~ /^.:(\/|\\)/ || value =~ %r{^\\\\[^\\]+\\[^\\]+}
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
