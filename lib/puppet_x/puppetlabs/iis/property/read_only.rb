module PuppetX
  module PuppetLabs
    module IIS
      module Property
        class ReadOnly < Puppet::Property
          validate do |_value|
            raise "#{name} is read-only and is only available via puppet resource."
          end
        end
      end
    end
  end
end
