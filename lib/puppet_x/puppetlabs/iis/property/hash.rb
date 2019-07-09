# @api private
module PuppetX
  # @api private
  module PuppetLabs
    # @api private
    module IIS
      # @api private
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
