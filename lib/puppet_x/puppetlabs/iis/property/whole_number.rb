# frozen_string_literal: true

# The Puppet Extensions Module
module PuppetX::PuppetLabs
  # IIS
  module IIS::Property
    # WholeNumber Property
    class WholeNumber < Puppet::Property
      validate do |value|
        raise "#{name} should be an Integer" unless value.to_i.to_s == value.to_s
        raise "#{name} should be 0 or greater" unless value.to_i >= 0
      end
    end
  end
end
