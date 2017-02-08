module PuppetX
  module PuppetLabs
    module IIS
      module Property
        class TimeFormat < Puppet::Property
          validate do |value|
            fail "#{self.name.to_s} should match datetime format 00:00:00" unless value =~ /^\d\d:\d\d:\d\d$/
          end
        end
      end
    end
  end
end
