# frozen_string_literal: true

# The Puppet Extensions Module
module PuppetX::PuppetLabs::IIS
  # Bindings class
  class Bindings
    def self.sort_bindings(binding_value)
      if binding_value.nil?
        []
      else
        binding_value.sort_by { |a| ((a['protocol'] == 'https') ? '0' : '1') + a['bindinginformation'] }
      end
    end
  end
end
