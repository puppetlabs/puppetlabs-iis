module PuppetX
  module PuppetLabs
    module IIS
      module Property
        class Name < Puppet::Property
          validate do |value|
            raise("#{value} is not a valid #{name}") unless value =~ %r{^[a-zA-Z0-9\.\-\_\'\s]+$}
          end
        end
      end
    end
  end
end
