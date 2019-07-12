# @api private
module PuppetX
  # @api private
  module PuppetLabs
    # @api private
    module IIS
      # @api private
      module Property
        # readonly property
        class ReadOnly < Puppet::Property
          validate do |_value|
            raise "#{name} is read-only and is only available via puppet resource."
          end
        end
      end
    end
  end
end
