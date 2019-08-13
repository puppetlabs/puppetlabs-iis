# The Puppet Extensions Module
module PuppetX
  # PuppetLabs
  module PuppetLabs
    # IIS
    module IIS
      # Property
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
