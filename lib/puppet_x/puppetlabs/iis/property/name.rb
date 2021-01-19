# frozen_string_literal: true

# The Puppet Extensions Module
module PuppetX
  # PuppetLabs
  module PuppetLabs
    # IIS
    module IIS
      # Property
      module Property
        # name Property
        class Name < Puppet::Property
          validate do |value|
            raise("#{value} is not a valid #{name}") unless %r{^[a-zA-Z0-9\.\-\_\'\s]+$}.match?(value)
          end
        end
      end
    end
  end
end
