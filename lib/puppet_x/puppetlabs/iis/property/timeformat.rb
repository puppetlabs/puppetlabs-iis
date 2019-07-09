# @api private
module PuppetX
  # @api private
  module PuppetLabs
    # @api private
    module IIS
      # @api private
      module Property
        # time format
        class TimeFormat < Puppet::Property
          validate do |value|
            raise "#{name} should match datetime format 00:00:00 or 0.00:00:00" unless value =~ %r{^(\d+\.)?\d\d:\d\d:\d\d$}
          end
        end
      end
    end
  end
end
