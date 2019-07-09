# @api private
module PuppetX
  # @api private
  module PuppetLabs
    # @api private
    module IIS
      # @api private
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
