# frozen_string_literal: true

# The Puppet Extensions Module
module PuppetX
  # PuppetLabs
  module PuppetLabs
    # IIS
    module IIS
      # Property
      module Property
        # PositiveInteger Property
        class PositiveInteger < Puppet::Property
          def insync?(is)
            is.to_i == should.to_i
          end
          validate do |value|
            raise "#{name} should be an Integer" unless value.to_i.to_s == value.to_s
            raise "#{name} should be greater than 0" unless value.to_i.positive?
          end
        end
      end
    end
  end
end
