# frozen_string_literal: true

# The Puppet Extensions Module
module PuppetX
  # PuppetLabs
  module PuppetLabs
    # IIS
    module IIS
      # Property
      module Property
        # time format
        class TimeFormat < Puppet::Property
          validate do |value|
            raise "#{name} should match datetime format 00:00:00 or 0.00:00:00" unless %r{^(\d+\.)?\d\d:\d\d:\d\d$}.match?(value)
          end
        end
      end
    end
  end
end
