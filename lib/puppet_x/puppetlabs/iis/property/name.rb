# @api private
module PuppetX
  # @api private
  module PuppetLabs
    # @api private
    module IIS
      # @api private
      module Property
        # name Property
        class Name < Puppet::Property
          validate do |value|
            raise("#{value} is not a valid #{name}") unless value =~ %r{^[a-zA-Z0-9\.\-\_\'\s]+$}
          end
        end
      end
    end
  end
end
